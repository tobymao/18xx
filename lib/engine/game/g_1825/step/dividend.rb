# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G1825
      module Step
        class Dividend < Engine::Step::Dividend
          def actions(entity)
            return [] if entity.corporation? && entity.receivership?

            super
          end

          def skip!
            return super if !current_entity.corporation? || !current_entity.receivership?

            skip_routes = @round.routes
            process_dividend(Action::Dividend.new(current_entity, kind: 'withhold'))

            current_entity.operating_history[[@game.turn, @round.round_num]] =
              OperatingInfo.new(skip_routes, @game.actions.last, @game.routes_revenue(skip_routes), @round.laid_hexes)
          end

          def corporation_dividends(_entity, _per_share)
            0
          end

          def share_price_change(entity, revenue)
            curr_price = entity.share_price.price

            if revenue.positive? && revenue <= curr_price / 2
              {}
            elsif revenue > curr_price / 2 && revenue < 2 * curr_price
              { share_direction: :right, share_times: 1 }
            elsif revenue >= 2 * curr_price && revenue < 3 * curr_price
              { share_direction: :right, share_times: 2 }
            elsif revenue >= 3 * curr_price && revenue < 4 * curr_price
              { share_direction: :right, share_times: 3 }
            elsif revenue >= 4 * curr_price
              { share_direction: :right, share_times: 4 }
            else
              { share_direction: :left, share_times: 1 }
            end
          end
        end
      end
    end
  end
end
