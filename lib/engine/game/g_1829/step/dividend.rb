# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G1829
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

          def dividend_options(entity)
            revenue = @game.routes_revenue(routes) - @round.receivership_loan
            dividend_types.map do |type|
              payout = send(type, entity, revenue)
              payout[:divs_to_corporation] = corporation_dividends(entity, payout[:per_share])
              [type, payout.merge(share_price_change(entity, revenue - payout[:corporation]))]
            end.to_h
          end

          def process_dividend(action)
            entity = action.entity
            revenue = @game.routes_revenue(routes)
            if @round.receivership_loan.positive?
              @log << "Revenue of #{@game.format_currency(revenue)} is reduced by "\
                      "#{@game.format_currency(@round.receivership_loan)} to offset track, token, and/or lease costs"
              revenue -= @round.receivership_loan
            end
            kind = action.kind.to_sym
            payout = dividend_options(entity)[kind]

            rust_obsolete_trains!(entity)

            entity.operating_history[[@game.turn, @round.round_num]] = OperatingInfo.new(
              routes,
              action,
              revenue,
              @round.laid_hexes
            )

            entity.trains.each { |train| train.operated = true }

            @round.receivership_loan = 0
            @round.routes = []

            log_run_payout(entity, kind, revenue, action, payout)

            payout_corporation(payout[:corporation], entity)

            payout_shares(entity, revenue - payout[:corporation]) if payout[:per_share].positive?
            change_share_price(entity, payout)

            pass!
          end

          def corporation_dividends(_entity, _per_share)
            0
          end

          def share_price_change(_entity, revenue)
            if revenue.positive?
              { share_direction: :right, share_times: 1 }
            else
              { share_direction: :left, share_times: 1 }
            end
          end
        end
      end
    end
  end
end
