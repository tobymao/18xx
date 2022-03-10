# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/half_pay'

module Engine
  module Game
    module G1871
      module Step
        class Dividend < Engine::Step::Dividend
          PEIR_DIVIDEND_TYPES = %i[payout half withhold].freeze
          include Engine::Step::HalfPay

          def dividend_types
            return self.class::PEIR_DIVIDEND_TYPES if current_entity.id == 'PEIR'

            self.class::DIVIDEND_TYPES
          end

          def corporation_dividends(entity, per_share)
            dividends_for_entity(entity, entity, per_share) +
              dividends_for_entity(entity, @game.share_pool, per_share)
          end

          def share_price_change(_entity, revenue)
            return { share_direction: :left, share_times: 1 } if revenue.zero?

            return { share_direction: :right, share_times: 1 } if revenue == @game.routes_revenue(routes)

            {}
          end

          def dividends_for_entity(entity, holder, per_share)
            num = holder.shares_of(entity).select(&:buyable).sum(&:percent) / entity.share_percent

            (num * per_share).ceil
          end
        end
      end
    end
  end
end
