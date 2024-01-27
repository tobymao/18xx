# frozen_string_literal: true

require_relative '../../../step/assign'

module Engine
  module Game
    module G18Uruguay
      module Step
        class CattleFarm < Engine::Step::Assign
          include Farm

          def farm
            @game.cattle_farm
          end

          def goods_type
            'GOODS_CATTLE'
          end

          def description
            'Deliver cattle'
          end
        end
      end
    end
  end
end
