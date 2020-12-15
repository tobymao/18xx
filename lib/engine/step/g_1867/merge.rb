# frozen_string_literal: true

require_relative '../base'
require_relative '../../token'

module Engine
  module Step
    module G1867
      class Merge < Base
        LIMIT_OWNED_BY_ONE_ENTITY = 6
        LIMIT_MERGE = 10

        def actions(entity)
          return [] if !entity.corporation? || entity != current_entity
          return [] if @round.converted

          actions = []

          return ['merge'] if @converting || @merge_major

          actions << 'merge' if can_merge?(entity)
          actions << 'convert' if can_convert?(entity)
          actions << 'pass' if actions.any?
          actions
        end

        def merge_name
          return 'Convert' if @converting

          'Merge'
        end

        def can_convert?(entity)
          entity.share_price.types.include?(:convert_range) && entity.type == :minor
        end

        def can_merge?(entity)
          mergeable_candidates(entity).any?
        end

        def description
          return 'Choose Major Corporation' if @converting || @merge_major

          'Convert or Merge Minor Corporation'
        end

        def process_convert(action)
          @converting = action.entity
        end

        def finish_convert(action)
          corporation = action.entity
          target = action.corporation

          if !target || !mergeable(corporation).include?(target)
            @game.game_error("Choose a corporation to merge with #{corporation.name}")
          end

          @game.stock_market.set_par(target, corporation.share_price)
          owner = corporation.owner

          @converting = nil
          @game.close_corporation(corporation)

          share = target.shares.first
          @game.share_pool.buy_shares(owner, share.to_bundle, exchange: :free)

          move_tokens(corporation, target)
          receiving = move_assets(corporation, target)

          @log << "#{corporation.name} converts into #{target.name} receiving #{receiving.join(', ')}"

          # Replace the entity with the new one.
          @round.entities[@round.entity_index] = target
          @round.converted = target
          # All players are eligable to buy shares unlike merger
          @round.share_dealing_players = @game.players.rotate(@game.players.index(target.owner))
          @round.share_dealing_multiple = [corporation.owner]
        end

        def move_assets(from, to)
          receiving = []

          if from.cash.positive?
            receiving << @game.format_currency(from.cash)
            from.spend(from.cash, to)
          end

          companies = from.transfer(:companies, to).map(&:name)
          receiving << "companies (#{companies.join(', ')})" if companies.any?

          loans = from.transfer(:loans, to).size
          receiving << "loans (#{loans})" if loans.positive?

          trains = from.transfer(:trains, to).map(&:name)
          receiving << "trains (#{trains})" if trains.any?

          receiving
        end

        def move_tokens(from, to)
          from.tokens.each do |token|
            new_token = to.next_token
            unless new_token
              new_token = Engine::Token.new(to)
              to.tokens << new_token
            end

            city = token.city
            token.remove!
            city.place_token(to, new_token, check_tokenable: false)
          end
        end

        def finish_merge
          @game.log << "Finish merge of #{@merging.map(&:name).join(',')}"
          @merge_major = true
        end

        def finish_merge_to_major(action)
          target = action.corporation
          initiator = action.entity.owner
          # PAR price is average of lowest and highest priced
          # rounded down between 100-200 (200 can be ignored since max price of minor) between
          min = @merging.map { |c| c.share_price.price }.min
          max = @merging.map { |c| c.share_price.price }.max
          merged = [100, (max + min) / 2].max

          @game.stock_market.set_par(target, @game.find_share_price(merged))

          # Replace the entity with the new one.
          @round.entities[@round.entity_index] = target

          @merge_major = false
          owners = []
          # @todo: sort merging around the initiator then table order
          @merging.each do |corporation|
            owner = corporation.owner
            owners << owner
            @game.close_corporation(corporation)

            share = target.shares.last

            if target.shares.first.president && owner.percent_of(target) == 10
              # give the 10% back
              presidency = target.shares.first
              @game.share_pool.move_share(owner.shares_of(target).first, presidency.owner)
              # grab the presidency
              @game.share_pool.buy_shares(owner, presidency.to_bundle, exchange: :free)
            else
              @game.share_pool.buy_shares(owner, share.to_bundle, exchange: :free)
            end

            # @todo: token reduction code
            move_tokens(corporation, target)
            receiving = move_assets(corporation, target)

            @log << "#{corporation.name} merges into #{target.name} receiving #{receiving.join(', ')}"
            @round.entities.delete(corporation)
          end

          # Deleting the entity changes turn order, restore it.
          @round.goto_entity!(target) unless @round.entities.empty?

          @round.converted = target
          # Players who owned shares are eligable to buy shares unlike merger
          players = @game.players.select { |p| owners.include?(p) }
          @round.share_dealing_players = players.rotate(players.index(initiator))
          @round.share_dealing_multiple = players
          # @todo: 2 tokens, less than 20% ownership
        end

        def process_merge(action)
          return finish_convert(action) if @converting

          return finish_merge_to_major(action) if @merge_major

          unless mergeable(action.entity).include?(action.corporation)
            @game.game_error("Cannot merge with t#{action.corporation.name}")
          end

          @merging ||= [action.entity]
          @game.log << "Adding #{action.corporation.name} to merge of #{@merging.map(&:name).join(',')}"
          @merging << action.corporation

          return unless mergeable_candidates(action.entity).none?

          # No more potential merges, finish merge
          finish_merge
        end

        def process_pass(action)
          if @merging
            finish_merge
          else
            super
          end
        end

        def new_share_price(corporation, target)
          new_price =
            if corporation.total_shares == 2
              corporation.share_price.price + target.share_price.price
            else
              (corporation.share_price.price + target.share_price.price) / 2
            end
          @game.find_share_price(new_price)
        end

        def log_pass(entity)
          super unless entity.share_price.liquidation?
        end

        def mergeable_type(corporation)
          if @converting
            'New Major Corporation for conversion'
          elsif @merge_major
            'New Major Corporation for merger'
          else
            "Corporations that can merge with #{corporation.name}"
          end
        end

        def mergeable_candidates(corporation)
          mergeable = @merging
          mergeable = [corporation] unless @merging
          # Can't merge over 10 corporations
          return [] if mergeable.size == LIMIT_MERGE

          # Individual player cannot merge over 6 (to make them at 60%)
          owner_at_limit = mergeable.group_by(&:owner).select { |_x, y| y.size >= LIMIT_OWNED_BY_ONE_ENTITY }.keys
          available = []
          # Mergeable candidates must be connected by track, minors only have one token which simplifies it
          mergeable.each do |corp|
            cities = @game.graph.connected_nodes(corp).keys
            corporations = cities.flat_map { |c| c.tokens.compact.map(&:corporation) }
            available += corporations - mergeable
          end

          available.uniq.reject { |c| c.type == :major || owner_at_limit.include?(c.owner) }
        end

        def mergeable(corporation)
          if @converting || @merge_major
            @game.corporations.select do |target|
              target.type == :major &&
              !target.floated?
            end
          else
            mergeable_candidates(corporation)
          end
        end

        def show_other_players
          false
        end

        def round_state
          {
            converted: nil,
            share_dealing_players: [],
            share_dealing_multiple: [],
          }
        end
      end
    end
  end
end
