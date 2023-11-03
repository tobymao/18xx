# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module GSteamOverHolland
      module Step
        class Dividend < Engine::Step::Dividend
          DIVIDEND_TYPES = %i[payout withhold].freeze

          def share_price_change(entity, revenue = 0)
            price = entity.share_price.price
            return { share_direction: :left, share_times: 1 } if revenue.zero?

            times = 0 if revenue < price
            times = 1 if revenue >= price
            times = 2 if revenue >= price * 2
            if times.positive?
              { share_direction: :right, share_times: times }
            else
              {}
            end
          end

          def pass!
            super

            @round.steps.find { |s| s.is_a?(GSteamOverHolland::Step::IssueShares) }.dividend_step_passes
          end
        end
      end
    end
  end
end
