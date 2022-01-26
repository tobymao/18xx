# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../token'
require_relative '../../../step/token_merger'
require_relative '../../../step/programmer_merger_pass'

module Engine
  module Game
    module G18NewEngland
      module Step
        class Merge < Engine::Step::Base
          include Engine::Step::TokenMerger
          include Engine::Step::ProgrammerMergerPass
          CONVERT_PAR = 100

          def actions(entity)
            return [] if !entity.corporation? || entity != current_entity
            return [] if @round.converted

            actions = []

            return ['merge'] if @converting || @merging

            actions << 'merge' # performance improvement
            actions << 'convert' if !@merging && can_convert?(entity)
            actions << 'pass' if actions.any?
            actions
          end

          def auto_actions(entity)
            return super if @converting || @merging || can_convert?(entity)

            return [Engine::Action::Pass.new(entity)] if mergeable_candidates(entity).empty?

            super
          end

          def others_acted?
            !@round.converts.empty?
          end

          def merger_auto_pass_entity
            current_entity unless @converting || @merging
          end

          def merge_name(_entity = nil)
            return 'Finish Convert' if @converting
            return 'Finish Merge' if @merging

            'Merge'
          end

          def pass_description
            return 'Done Adding Corporations' if @merging

            super
          end

          def can_convert?(entity)
            entity.type == :minor &&
              entity.owner.cash >= ((CONVERT_PAR * 2) - (entity.share_price.price * 2)) &&
              @game.any_unstarted_majors?
          end

          def can_merge?(entity)
            mergeable_candidates(entity).any?
          end

          def description
            return 'Choose Major Corporation' if @converting || @merging

            'Convert or Merge Minor Corporation'
          end

          def process_convert(action)
            @converting = action.entity
          end

          def finish_convert(action)
            minor = action.entity
            target = action.corporation

            raise GameError, "Choose a corporation to merge with #{minor.name}" unless target

            new_price = @game.lookup_par_price(CONVERT_PAR)
            @log << "#{target.name} par price is set at #{@game.format_currency(new_price.price)}"

            @game.stock_market.set_par(target, new_price)
            owner = minor.owner

            @converting = nil

            share = @game.bank.shares_of(target).first
            @game.share_pool.buy_shares(owner, share.to_bundle, exchange: :free)

            move_tokens(minor, target)
            receiving = move_assets(minor, target)

            diff = 2 * (CONVERT_PAR - minor.share_price.price)
            owner.spend(diff, target) if diff.positive?

            @log << "#{owner.name} contributes #{@game.format_currency(diff)} to #{target.name}" if diff.positive?
            @log << "#{minor.name} converts into #{target.name} receiving #{receiving.join(', ')}"

            @game.close_corporation(minor)

            # Replace the entity with the new one.
            @round.entities[@round.entity_index] = target
            @round.converted = target
            @round.converts << target
            # New president is eligable to buy shares
            @round.share_dealing_players = [target.owner]
          end

          def finish_merge(action)
            target = action.corporation
            minors = @merging
            owner = action.entity.owner

            raise GameErr, 'Must specifiy two minors' if minors.size != 2

            # par is sum of minor values
            new_price = @game.lookup_par_price(minors.sum { |m| m.share_price.price })
            @log << "#{target.name} par price is set at #{@game.format_currency(new_price.price)}"

            @game.stock_market.set_par(target, new_price)
            share = @game.bank.shares_of(target).first
            @game.share_pool.buy_shares(owner, share.to_bundle, exchange: :free)

            # Replace the entity with the new one.
            @round.entities[@round.entity_index] = target

            # Transfer assets
            @merging.each do |minor|
              move_tokens(minor, target)
              receiving = move_assets(minor, target)
              @game.close_corporation(minor)
              @log << "#{minor.name} merges into #{target.name} receiving #{receiving.join(', ')}"
            end

            # only delete 2nd minor from entities if later in order
            @round.entities.delete(@merging.last) if @round.entities.find_index(@merging.last) > @round.entity_index

            token_hexes = target.tokens.map { |t| t.city&.hex }

            if token_hexes.size != token_hexes.uniq.size
              @game.log << "#{target.name} has multiple tokens in the same hex and must decide which tokens to remove"
              @round.corporations_removing_tokens = [target]
            end

            @round.converted = target
            @round.converts << target
            # New president is eligable to buy shares
            @round.share_dealing_players = [target.owner]
            @merging = nil
          end

          def move_assets(from, to)
            receiving = []

            if from.cash.positive?
              receiving << @game.format_currency(from.cash)
              from.spend(from.cash, to)
            end

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

          def process_merge(action)
            return finish_convert(action) if @converting
            return finish_merge(action) if @merging

            if !@game.loading && !mergeable(action.entity).include?(action.corporation)
              raise GameError, "Cannot merge with #{action.corporation.name}"
            end

            @game.log << "#{action.entity.name} is merging with #{action.corporation.name}"
            @merging = [action.entity]
            @merging << action.corporation
          end

          def mergeable_type(corporation)
            if @converting
              'New Major Corporation for conversion'
            elsif @merging
              'New Major Corporation for merger'
            else
              "Minor(s) that can merge with #{corporation.name}"
            end
          end

          # Mergeable candidates must be connected by track, minors only have one token which simplifies it
          def mergeable_candidates(corporation)
            return [] unless @game.any_unstarted_majors?

            parts = @game.graph.connected_nodes(corporation).keys
            corps = parts.select(&:city?).flat_map { |c| c.tokens.compact.map(&:corporation) }
            # add in corps in same hex as home
            corporation.tokens.first.hex.tile.cities.each do |city|
              city.tokens.each { |tok| corps.append(tok&.corporation) if tok }
            end
            corps.uniq.reject { |c| c.type != :minor || c == corporation || c.owner != corporation.owner }
          end

          def mergeable(corporation)
            if @converting || @merging
              @game.corporations.select do |target|
                target.type != :minor &&
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
