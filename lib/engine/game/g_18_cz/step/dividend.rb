# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G18CZ
      module Step
        class Dividend < Engine::Step::Dividend
          def payout_per_share(entity, revenue)
            (revenue / entity.total_shares.to_f)
          end

          def share_price_change(entity, revenue = 0)
            return { share_direction: :left, share_times: 2 } unless revenue.positive?

            max_moves = @game.maximum_share_price_change(entity)
            times = (max_moves < 2 ? max_moves : 2)
            times = (max_moves < 4 ? max_moves : 4) if entity.type == :large
            { share_direction: :right, share_times: times }
          end

          def corporation_dividends(_entity, _per_share)
            0
          end

          def movement_str(times, dir)
            "#{times / 2} #{dir}"
          end
        end
      end
    end
  end
end
