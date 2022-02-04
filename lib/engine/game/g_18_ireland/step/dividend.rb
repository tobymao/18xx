# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G18Ireland
      module Step
        class Dividend < Engine::Step::Dividend
          DIVIDEND_TYPES = %i[payout withhold].freeze

          def share_price_change(entity, revenue = 0)
            price = entity.share_price.price
            return { share_direction: :left, share_times: 1 } unless revenue.positive?

            times = 0
            times = 1 if revenue >= price
            times = 2 if revenue >= price * 2 && entity.type == :minor
            if times.positive?
              { share_direction: :right, share_times: times }
            else
              {}
            end
          end

          def dividends_for_entity(entity, holder, per_share)
            return 0 if holder.player? && holder.bankrupt

            super
          end
        end
      end
    end
  end
end
