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

          def get_tile_lay(entity)
            action = super
            @game.modify_tile_lay(entity, action)
          end

          def lay_tile_action(action, entity: nil, spender: nil)
            @game.pre_lay_tile_action(action, entity, get_tile_lay(action.entity))

            super
          end

          def round_state
            super.merge(
              {
                last_old_tile: nil,
              }
            )
          end

          def setup
            super
            @round.last_old_tile = nil
          end
        end
      end
    end
  end
end
