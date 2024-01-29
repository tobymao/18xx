# frozen_string_literal: true

require_relative '../../../step/assign'

module Engine
  module Game
    module G18Uruguay
      module Step
        class SheepFarm < Engine::Step::Assign
          include Farm

          def farm
            @game.sheep_farm
          end

          def goods_type
            'GOODS_SHEEP'
          end

          def description
            'Deliver sheep'
          end
        end
      end
    end
  end
end
