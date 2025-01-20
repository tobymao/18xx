# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative 'minor_half_pay'

module Engine
  module Game
    module G1837
      module Step
        class Dividend < Engine::Step::Dividend
          DIVIDEND_TYPES = %i[payout half withhold].freeze
          include G1837::Step::MinorHalfPay

          def auto_actions(entity)
            return if !entity.corporation? || !entity.cash.negative?

            [Action::Dividend.new(entity, kind: 'withhold')]
          end

          def half(entity, revenue)
            amount = revenue / 2
            { corporation: amount, per_share: payout_per_share(entity, amount) }
          end

          def dividends_for_entity(entity, holder, per_share)
            (num_paying_shares(entity, holder) * per_share).floor
          end

          def share_price_change(_entity, revenue)
            if revenue.zero?
              { share_direction: :left, share_times: 1 }
            elsif revenue == total_revenue
              { share_direction: :right, share_times: 1 }
            else
              { share_direction: :diagonally_down_right, share_times: 1 }
            end
          end

          def round_state
            super.merge(
              {
                non_paying_shares: Hash.new { |h, k| h[k] = Hash.new(0) },
              }
            )
          end

          private

          def num_paying_shares(entity, holder)
            holder.num_shares_of(entity) - @round.non_paying_shares[holder][entity]
          end
        end
      end
    end
  end
end
