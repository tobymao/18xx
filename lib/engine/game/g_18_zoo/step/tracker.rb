# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module Step
        module Tracker
          MOUNTAIN_ICON = Engine::Part::Icon.new('18_zoo/mountain', 'mountain', true, true)
          INVALID_TRACK_UPDATES = [
            { old: 'X8', new: 'X25', diff: [4] },
            { old: 'X8', new: 'X19', diff: [0, 2] },
            { old: 'X7', new: 'X28', diff: [2] },
            { old: 'X7', new: 'X29', diff: [5] },
          ].freeze

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
            # handle edge cases where the new ends override olds but original paths are not touched
            raise GameError, 'New track must override old one' if INVALID_TRACK_UPDATES.any? do |props|
              old_tile.name == props[:old] &&
                new_tile.name == props[:new] &&
                props[:diff].include?((new_tile.rotation - old_tile.rotation + 6) % 6)
            end

            super(entity.company? ? entity.owner : entity, old_tile, new_tile)
          end
        end
      end
    end
  end
end
