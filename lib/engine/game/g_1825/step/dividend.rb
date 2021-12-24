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

          def dividend_options(entity)
            revenue = @game.routes_revenue(routes) - @round.receivership_loan
            dividend_types.to_h do |type|
              payout = send(type, entity, revenue)
              payout[:divs_to_corporation] = corporation_dividends(entity, payout[:per_share])
              [type, payout.merge(share_price_change(entity, revenue - payout[:corporation]))]
            end
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
            @game.check_bank_broken!
            @game.check_bankrupt!(entity)

            pass!
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
