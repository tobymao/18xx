# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module GSystem18
      module Step
        class Track < Engine::Step::Track
          def actions(entity)
            entity.receivership? ? [] : super
          end

          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            super
            @game.post_lay_tile(action.entity, action.tile)
          end
        end
      end
    end
  end
end
