# frozen_string_literal: true

require_relative 'buy_sell_par_shares'

module Engine
  module Game
    module G1866
      module Step
        class StockTurnToken < Engine::Game::G1866::Step::BuySellParShares
          def actions(entity)
            return ['choose_ability'] unless choices_ability(entity).empty?
            return [] unless entity.player?

            super
          end

          def current_entity
            entity = active_entities[0]
            entity.corporation? && @game.stock_turn_corporation?(entity) ? entity.owner : entity
          end

          def description
            'Stock Turn Token'
          end

          def log_skip(entity)
            return unless @game.stock_turn_corporation?(entity)

            @log << "#{entity.name} has no valid actions and passes"
          end

          def process_buy_shares(action)
            super

            @round.force_next_entity!
          end

          def process_choose_ability(action)
            super

            @round.force_next_entity!
          end

          def process_par(action)
            super

            @round.force_next_entity!
          end

          def process_pass(action)
            super

            @round.force_next_entity!
          end

          def process_sell_shares(action)
            super

            @round.force_next_entity!
          end

          def issuable_shares(_entity)
            []
          end

          def redeemable_shares(_entity)
            []
          end
        end
      end
    end
  end
end
