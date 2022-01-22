# frozen_string_literal: true

require_relative 'buy_sell_par_shares'

module Engine
  module Game
    module G1866
      module Step
        class StockTurnToken < Engine::Game::G1866::Step::BuySellParShares
          ACTIONS = %w[buy_shares par sell_shares pass].freeze

          def actions(entity)
            return ['choose_ability'] unless choices_ability(entity).empty?
            return [] if entity != current_entity || !current_entity.player?
            return ['sell_shares'] if must_sell?(current_entity)

            ACTIONS
          end

          def current_entity
            entity = active_entities[0]
            return unless entity

            entity.corporation? && @game.stock_turn_corporation?(entity) ? entity.owner : entity
          end

          def description
            'Stock Turn Token'
          end

          def log_pass(entity)
            @log << "#{entity.name} passes" if @round.current_actions.empty?
          end

          def log_skip(entity)
            return unless @game.stock_turn_corporation?(entity)

            @log << "#{entity.name} has no valid actions and passes"
          end

          def process_buy_shares(action)
            super

            change_market
            @round.force_next_entity!
          end

          def process_choose_ability(action)
            super

            change_market
            @round.force_next_entity!
          end

          def process_par(action)
            super

            change_market
            @round.force_next_entity!
          end

          def process_pass(action)
            super

            change_market
            @round.force_next_entity!
          end

          def issuable_shares(_entity)
            []
          end

          def redeemable_shares(_entity)
            []
          end

          def change_market
            bought = bought? || bought_stock_token?
            sold = sold?
            times = 3
            times = 2 if sold
            times = 1 if bought
            times = 0 if bought && sold
            return unless times.positive?

            entity = active_entities[0]
            current_price = entity.share_price.price
            times.times { @game.stock_market.move_right(entity) }
            @log << "#{current_entity.name}'s stock turn token price changes from "\
                    "#{@game.format_currency(current_price)} to #{@game.format_currency(entity.share_price.price)}"
          end
        end
      end
    end
  end
end
