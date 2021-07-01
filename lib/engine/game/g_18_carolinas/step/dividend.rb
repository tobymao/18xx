# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G18Carolinas
      module Step
        class Dividend < Engine::Step::Dividend
          def share_price_change(entity, revenue)
            curr_price = entity.share_price.price
            if revenue > curr_price / 2 && revenue < curr_price
              {}
            elsif revenue >= curr_price && revenue < 2 * curr_price
              { share_direction: :right, share_times: 1 }
            elsif revenue >= 2 * curr_price && revenue < 3 * curr_price
              { share_direction: :right, share_times: 2 }
            elsif revenue >= 3 * curr_price && revenue < 4 * curr_price
              { share_direction: :right, share_times: 3 }
            elsif revenue >= 4 * curr_price
              { share_direction: :right, share_times: 4 }
            else
              { share_direction: :left, share_times: 1 }
            end
          end
        end
      end
    end
  end
end
