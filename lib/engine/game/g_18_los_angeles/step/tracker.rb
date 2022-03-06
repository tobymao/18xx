# frozen_string_literal: true

module Engine
  module Game
    module G18LosAngeles
      module Step
        module Tracker
          def process_lay_tile(action)
            @game.use_che_discount = false
            super
          end

          def remove_border_calculate_cost!(tile, entity, spender)
            total_cost, types = super
            return [total_cost, types] unless @game.che&.owner == entity

            @game.use_che_discount = total_cost.positive?

            [total_cost, types]
          end
        end
      end
    end
  end
end
