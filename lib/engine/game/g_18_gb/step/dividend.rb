# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G18GB
      module Step
        class Dividend < Engine::Step::Dividend
          def holder_for_corporation(entity)
            entity
          end

          def share_price_change(entity, revenue)
            if revenue.positive?
              curr_price = entity.share_price.price
              if revenue >= 4 * curr_price
                { share_direction: :right, share_times: 4 }
              elsif revenue >= 3 * curr_price
                { share_direction: :right, share_times: 3 }
              elsif revenue >= 2 * curr_price
                { share_direction: :right, share_times: 2 }
              else
                { share_direction: :right, share_times: 1 }
              end
            else
              { share_direction: :left, share_times: 1 }
            end
          end
        end
      end
    end
  end
end
