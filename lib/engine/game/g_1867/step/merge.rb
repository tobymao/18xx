# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../token'
require_relative '../../../step/token_merger'
require_relative '../../../step/programmer_merger_pass'

module Engine
  module Game
    module G1867
      module Step
        class Merge < Engine::Step::Base
          include Engine::Step::TokenMerger
          include Engine::Step::ProgrammerMergerPass
          LIMIT_OWNED_BY_ONE_ENTITY = 6
          LIMIT_MERGE = 10

          def actions(entity)
            return [] if !entity.corporation? || entity != current_entity
            return [] if @round.converted

            actions = []

            return ['merge'] if @converting || @merge_major

            actions << 'merge' # performance improvement
            actions << 'convert' if !@merging && can_convert?(entity)
            actions << 'pass' if actions.any?
            actions
          end

          def auto_actions(entity)
            return super if @converting || @merge_major || @merging || can_convert?(entity)

            return [Engine::Action::Pass.new(entity)] if mergeable_candidates(entity).empty?

            super
          end

          def merge_name(_entity = nil)
            return 'Convert' if @converting
            return 'Finish Merge' if @merge_major

            'Merge'
          end

          def merger_auto_pass_entity
            current_entity if !@converting && !@merge_major
          end

          def others_acted?
            !@round.converts.empty?
          end

          def pass_description
            return 'Done Adding Corporations' if @merging

            super
          end

          def can_convert?(entity)
            entity.share_price.types.include?(:convert_range) && entity.type == :minor
          end

          def can_merge?(entity)
            mergeable_candidates(entity).any?
          end

          def description
            return 'Choose Major Corporation' if @converting || @merge_major
            return 'Merge Minor Corporations' if @merging

            'Convert or Merge Minor Corporation'
          end

          def process_convert(action)
            @converting = action.entity
          end

          def finish_convert(action)
            corporation = action.entity
            target = action.corporation

            if !target || !mergeable(corporation).include?(target)
              raise GameError, "Choose a corporation to merge with #{corporation.name}"
            end

            # After conversion it is the new price
            new_price = @game.stock_market.share_prices_with_types(%i[par par_2]).find do |sp|
              sp.price <= corporation.share_price.price
            end

            @game.stock_market.set_par(target, new_price)
            owner = corporation.owner

            @converting = nil

            share = target.shares.first
            @game.share_pool.buy_shares(owner, share.to_bundle, exchange: :free)

            move_tokens(corporation, target)
            receiving = move_assets(corporation, target)

            corp_owner = corporation.owner
            @game.close_corporation(corporation)

            @log << "#{corporation.name} converts into #{target.name} receiving #{receiving.join(', ')}"

            # Replace the entity with the new one.
            @round.entities[@round.entity_index] = target
            @round.converted = target
            @round.converts << target
            @round.merge_type = :convert
            # All players are eligable to buy shares unlike merger
            @round.share_dealing_players = @game.players.rotate(@game.players.index(target.owner))
            @round.share_dealing_multiple = [corp_owner]
          end

          def move_assets(from, to)
            receiving = []

            if from.cash.positive?
              receiving << @game.format_currency(from.cash)
              from.spend(from.cash, to)
            end

            companies = @game.transfer(:companies, from, to).map(&:name)
            receiving << "companies (#{companies.join(', ')})" if companies.any?

            loans = @game.transfer(:loans, from, to).size
            receiving << "loans (#{loans})" if loans.positive?

            trains = @game.transfer(:trains, from, to).map(&:name)
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
            # rounded down between 100-200 in either convert or par_3 areas
            min = @merging.map { |c| c.share_price.price }.min
            max = @merging.map { |c| c.share_price.price }.max
            new_price = [200, [100, (max + min)].max].min
            merged_par = @game.stock_market.share_prices_with_types(%i[par par_2]).find do |sp|
              sp.price <= new_price
            end

            # Players who owned shares are eligable to buy shares unlike merger
            owners = @merging.map(&:owner)
            players = @game.players.select { |p| owners.include?(p) }
            players = players.rotate(players.index(initiator))

            if players.none? { |player| player.cash >= merged_par.price || owners.count(player) >= 2 }
              raise GameError, 'Merge impossible, no player can become president'
            end

            @game.stock_market.set_par(target, merged_par)

            # Replace the entity with the new one.
            @round.entities[@round.entity_index] = target

            @merge_major = false
            # Set that this has been ipoed so presidentless corps can have shares be bought
            target.ipoed = true

            # Transfer assets starting with the initiator
            @merging.sort_by { |m| players.index(m.owner) }.each do |corporation|
              owner = corporation.owner

              share = target.shares.last

              if target.shares.first.president && owner.percent_of(target) == 10
                # give the 10% back
                presidency = target.shares.first
                owner.shares_of(target).first.transfer(presidency.owner)
                # grab the presidency
                @game.share_pool.buy_shares(owner, presidency.to_bundle, exchange: :free)
              else
                @game.share_pool.buy_shares(owner, share.to_bundle, exchange: :free)
              end

              remove_duplicate_tokens(target, @merging)
              move_tokens(corporation, target)

              receiving = move_assets(corporation, target)
              @game.close_corporation(corporation)
              @log << "#{corporation.name} merges into #{target.name} receiving #{receiving.join(', ')}"
              @round.entities.delete(corporation)
            end

            if tokens_above_limits?(target, @merging)
              @game.log << "#{target.name} will be above token limit and must decide which tokens to remove"
              @round.corporations_removing_tokens = [target] + @merging
            else
              # Add the $40 token back
              if target.tokens.size < 3
                new_token = Engine::Token.new(target, price: 40)
                target.tokens << new_token
              end

              tokens = target.tokens.map { |t| t.city&.hex&.id }
              charter_tokens = tokens.size - tokens.compact.size
              @log << "#{target.name} has tokens (#{tokens.size}: #{tokens.compact.size} on hexes #{tokens.compact}"\
                      "#{charter_tokens.positive? ? " & #{charter_tokens} on the charter" : ''})"
            end

            # Deleting the entity changes turn order, restore it.
            @round.goto_entity!(target) unless @round.entities.empty?

            @merging = nil
            @round.converted = target
            @round.converts << target
            @round.merge_type = :merge

            @round.share_dealing_players = players
            @round.share_dealing_multiple = players
          end

          def process_merge(action)
            return finish_convert(action) if @converting

            return finish_merge_to_major(action) if @merge_major

            if !@game.loading && !mergeable(action.entity).include?(action.corporation)
              raise GameError, "Cannot merge with t#{action.corporation.name}"
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
              parts = @game.graph.connected_nodes(corp).keys
              corporations = parts.select(&:city?).flat_map { |c| c.tokens.compact.map(&:corporation) }
              available.concat(corporations - mergeable)
            end

            available.uniq.reject { |c| c.type != :minor || owner_at_limit.include?(c.owner) }
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
              merge_type: nil,
              converts: [],
              share_dealing_players: [],
              share_dealing_multiple: [],
            }
          end
        end
      end
    end
  end
end
