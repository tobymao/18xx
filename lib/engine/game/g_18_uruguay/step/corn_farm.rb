# frozen_string_literal: true

require_relative '../../../step/assign'

module Engine
  module Game
    module G18Uruguay
      module Step
        class CornFarm < Engine::Step::Assign
          include Farm

          def farm
            @game.corn_farm
          end

          def goods_type
            'GOODS_CORN'
          end

          def description
            'Deliver corn'
          end
        end
      end
    end
  end
end
