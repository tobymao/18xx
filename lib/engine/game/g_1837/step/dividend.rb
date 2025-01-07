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

          def actions(entity)
            return super if !entity.corporation? || entity.type != :minor

            []
          end

          def skip!
            return super if !current_entity.corporation? || current_entity.type != :minor

            revenue = @game.routes_revenue(routes)
            process_dividend(Action::Dividend.new(
              current_entity,
              kind: revenue.positive? ? 'half' : 'withhold',
            ))
          end

          def half(entity, revenue)
            amount = revenue / 2
            { corporation: amount, per_share: payout_per_share(entity, amount) }
          end

          def dividends_for_entity(entity, holder, per_share)
            (holder.num_shares_of(entity, ceil: false) * per_share).floor
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
        end
      end
    end
  end
end
