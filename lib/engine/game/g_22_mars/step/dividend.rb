# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G22Mars
      module Step
        class Dividend < Engine::Step::Dividend
          def share_price_change(entity, revenue)
            if revenue.positive?
              if revenue >= 2 * entity.share_price.price
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
