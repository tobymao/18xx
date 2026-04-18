# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/minor_half_pay'

module Engine
  module Game
    module G18OE
      module Step
        class Dividend < Engine::Step::Dividend
          DIVIDEND_TYPES = %i[payout half withhold].freeze
          include Engine::Step::MinorHalfPay

          def actions(entity)
            return [] unless entity == current_entity
            return [] if entity.company?
            # Nationals always get a dividend action even when revenue is 0 (payout £0
            # is a valid action and must be explicitly taken to advance the OR).
            return ACTIONS if entity.type == :national

            return [] if total_revenue.zero?

            ACTIONS
          end

          # WA-2 (permanent): inject national revenue here via current_entity rather
          # than via game.routes_revenue which relies on current_operator being set.
          def total_revenue
            return @game.national_revenue(current_entity) if current_entity&.type == :national

            super
          end

          # Nationals may only pay all revenue as dividends (no withhold, no split).
          def dividend_types
            return %i[payout] if current_entity&.type == :national

            self.class::DIVIDEND_TYPES
          end

          def half(entity, revenue)
            withheld = half_pay_withhold_amount(entity, revenue)
            { corporation: withheld, per_share: payout_per_share(entity, revenue - withheld) }
          end

          def half_pay_withhold_amount(entity, revenue)
            (revenue / 2 / entity.total_shares) * entity.total_shares
          end

          def share_price_change(entity, revenue = 0)
            return {} if @game.minor_regional_order.include?(entity)

            price = entity.share_price.price
            return { share_direction: :left, share_times: 1 } if revenue < 1

            times = 0
            times = 1 if revenue >= price
            if times.positive?
              { share_direction: :right, share_times: times }
            else
              {}
            end
          end
        end
      end
    end
  end
end
