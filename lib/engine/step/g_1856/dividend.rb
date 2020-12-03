# frozen_string_literal: true

require_relative '../dividend'
require_relative '../../operating_info'
require_relative '../../action/dividend'

module Engine
  module Step
    module G1856
      class Dividend < Dividend
        def dividend_options(entity)
          penalty = @round.interest_penalty[entity] || 0
          revenue = @game.routes_revenue(routes) - penalty
          dividend_types.map do |type|
            payout = send(type, entity, revenue)
            payout[:divs_to_corporation] = corporation_dividends(entity, payout[:per_share])
            [type, payout.merge(share_price_change(entity, revenue - payout[:corporation]))]
          end.to_h
        end

        def process_dividend(action)
          entity = action.entity
          penalty = @round.interest_penalty[entity] || 0
          revenue = @game.routes_revenue(routes) - penalty
          kind = action.kind.to_sym
          payout = dividend_options(entity)[kind]

          rust_obsolete_trains!(entity)

          entity.operating_history[[@game.turn, @round.round_num]] = OperatingInfo.new(
            routes,
            action,
            revenue
          )

          entity.trains.each { |train| train.operated = true }

          @round.routes = []

          log_run_payout(entity, kind, revenue, action, payout)

          @game.bank.spend(payout[:corporation], entity) if payout[:corporation].positive?

          payout_shares(entity, revenue - payout[:corporation]) if payout[:per_share].positive?

          change_share_price(entity, payout)

          pass!
        end

        def log_run_payout(entity, kind, revenue, action, payout)
          if payout[:penalty].positive?
            @log << "#{entity.name} deducts #{@game.format_currency(payout[:penalty])} for unpaid interest"
          end
          unless Dividend::DIVIDEND_TYPES.include?(kind)
            @log << "#{entity.name} runs for #{@game.format_currency(revenue)} and pays #{action.kind}"
          end

          if payout[:corporation].positive?
            @log << "#{entity.name} withholds #{@game.format_currency(payout[:corporation])}"
          elsif payout[:per_share].zero?
            @log << "#{entity.name} does not run"
          end
        end

        def withhold(entity, revenue)
          { corporation: revenue, per_share: 0, penalty: @round.interest_penalty[entity] || 0 }
        end

        def payout(entity, revenue)
          {
            corporation: 0,
            per_share: payout_per_share(entity, revenue),
            penalty: @round.interest_penalty[entity] || 0,
          }
        end
      end
    end
  end
end
