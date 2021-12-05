# frozen_string_literal: true

require_relative '../../../step/track'
require_relative '../../../step/automatic_loan'

module Engine
  module Game
    module G18NY
      module Step
        class Track < Engine::Step::Track
          include Engine::Step::AutomaticLoan

          def process_lay_tile(action)
            old_tile = action.hex.tile
            super
            @game.tile_lay(action.hex, old_tile, action.tile)
          end

          def legal_tile_rotation?(entity, hex, tile)
            # Only need to make sure exits stay consistent for town to city upgrade
            old_tile = hex.tile
            if @game.town_to_city_upgrade?(old_tile, tile)
              return old_tile.paths.all? { |old| tile.paths.any? { |new| old.exits == new.exits } } &&
                     !(tile.exits & hex_neighbors(entity, hex)).empty?
            end

            super
          end

          # Prevent terrain discounts from being applied implicitly.
          def border_cost_discount(_entity, _spender, _border, _cost, _hex)
            0
          end

          def tile_lay_abilities_should_block?(entity)
            # AIW should block if the entity still has an action
            !Array(abilities(entity, time: type, passive_ok: false)).empty? && get_tile_lay(entity)
          end
        end
      end
    end
  end
end
