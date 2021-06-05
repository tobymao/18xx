# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module Step
        module Tracker
          MOUNTAIN_ICON = Engine::Part::Icon.new('18_zoo/mountain', 'mountain', true, true)

          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            hex = action.hex
            tile = action.tile

            return super unless %w[M MM].include?(hex.location_name)

            new_label = hex.location_name
            super
            tile.label = new_label
            tile.icons = [MOUNTAIN_ICON]
            tile.location_name = nil
          end

          def update_tile_lists(tile, old_tile)
            @game.tiles.delete(tile)

            additional_tile = @game.tile_by_id(tile.id.start_with?('X') ? tile.id[1..-1] : 'X' + tile.id)
            @game.tiles.delete(additional_tile) if additional_tile

            return if old_tile.preprinted

            if %w[M MM].include?(old_tile.hex.location_name)
              old_tile.label = nil
              old_tile.icons = []
              old_tile.location_name = old_tile.hex.location_name
            end

            @game.tiles << old_tile

            additional_tile = @game.tile_by_id(old_tile.id.start_with?('X') ? old_tile.id[1..-1] : 'X' + old_tile.id)
            @game.tiles << additional_tile if additional_tile
          end

          def check_track_restrictions!(entity, old_tile, new_tile)
            super(entity.company? ? entity.owner : entity, old_tile, new_tile)
          end
        end
      end
    end
  end
end
