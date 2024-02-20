# frozen_string_literal: true

require_relative '../../../step/dividend'
# require_relative '../../operating_info'
# require_relative '../../action/dividend'

module Engine
  module Game
    module G18India
      module Step
        class Dividend < Engine::Step::Dividend

          def guaranty_pay(entity)
            return 0 unless entity.guaranty_warrant?

            market_value = entity.share_price.price
            market_value.div(20) # pay 5% of market value rounded down
          end

          # guaranty corps pay out 5%
          def withhold(entity, revenue)
            { corporation: revenue, per_share: guaranty_pay(entity) }
          end

          def process_dividend(action)
            entity = action.entity
            revenue = total_revenue
            kind = action.kind.to_sym
            payout = dividend_options(entity)[kind]
            @log << "Revenue: #{revenue} payout: #{payout.to_h} Guaranty pay: #{guaranty_pay(entity)}"

            entity.operating_history[[@game.turn, @round.round_num]] = OperatingInfo.new(
              routes,
              action,
              revenue,
              @round.laid_hexes
            )

            @game.close_companies_on_event!(entity, 'ran_train') unless @round.routes.empty?
            entity.trains.each { |train| train.operated = true }

            rust_obsolete_trains!(entity)

            @round.routes = []
            @round.extra_revenue = 0

            log_run_payout(entity, kind, revenue, action, payout)

            payout_corporation(payout[:corporation], entity)

            payout_shares(entity, revenue - payout[:corporation], payout[:per_share]) if payout[:per_share].positive?

            change_share_price(entity, payout)

            pass!
          end

          # total shares will always be 10 (event when railroad bonds convert)
          def payout_per_share(_entity, revenue)
            revenue / 10.to_f
          end

          def payout_shares(entity, revenue, per_share)
            payouts = {}
            (@game.players + @game.corporations).each do |payee|
              payout_entity(entity, payee, per_share, payouts)
            end

            receivers = payouts
                          .sort_by { |_r, c| -c }
                          .map { |receiver, cash| "#{@game.format_currency(cash)} to #{receiver.name}" }.join(', ')

            log_payout_shares(entity, revenue, per_share, receivers)
          end

          def share_price_change(entity, revenue)
            curr_price = entity.share_price.price

            if (revenue.positive? || guaranty_pay(entity).positive?) && revenue <= curr_price / 2
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
