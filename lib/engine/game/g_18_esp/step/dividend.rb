# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/minor_half_pay'

module Engine
  module Game
    module G18ESP
      module Step
        class Dividend < Engine::Step::Dividend
          include Engine::Step::MinorHalfPay
          ACTIONS = %w[dividend].freeze

          def actions(entity)
            return [] if entity.company? || @game.routes_revenue(routes).zero?

            ACTIONS
          end

          def dividend_options(entity)
            revenue = @game.routes_revenue(routes)
            dividend_types.to_h do |type|
              payout = send(type, entity, revenue)
              payout[:divs_to_corporation] = corporation_dividends(entity, payout[:per_share])
              [type, payout.merge(share_price_change(entity, total_revenue - payout[:corporation]))]
            end
          end

          def share_price_change(entity, revenue = 0)
            return { share_direction: :left, share_times: 1 } unless revenue.positive?

            times = 1 if revenue.positive?
            times = 2 if @game.final_ors? && @round.round_num == @game.phase.operating_rounds && @game.north_corp?(entity)
            if times.positive?
              { share_direction: :right, share_times: times }
            else
              {}
            end
          end

          def movement_str(times, dir)
            "#{times} #{dir}"
          end

          def payout_per_share(entity, revenue)
            revenue * 1.0 / entity.total_shares
          end

          def payout(entity, revenue)
            if entity.corporation? && entity.type != :minor
              { corporation: 0, per_share: payout_per_share(entity, revenue) }
            else
              amount = revenue / 2
              { corporation: amount, per_share: amount }
            end
          end

          def withhold(_entity, revenue)
            { corporation: revenue, per_share: 0 }
          end
        end
      end
    end
  end
end
