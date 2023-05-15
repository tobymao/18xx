# frozen_string_literal: true

require_relative '../game_error'

# This module is used by games which double sided tiles, providing methods for
# initializing double-sided tiles and keeping tile lists updated appropriately.
module DoubleSidedTiles
  # This must be called in the Game's `setup` method after `@tile_groups` has
  # been initialized.
  def initialize_tile_opposites!
    by_name = @tiles.group_by(&:name)
    @tile_groups.each do |group|
      next unless group.size == 2

      name_a, name_b = group
      num = by_name[name_a].size

      if num != by_name[name_b].size
        raise Engine::GameError, "Sides of double-sided tiles need to have same number (#{name_a}, #{name_b})"
      end

      num.times.each do |index|
        tile_a = tile_by_id("#{name_a}-#{index}")
        tile_b = tile_by_id("#{name_b}-#{index}")

        tile_a.opposite = tile_b
        tile_b.opposite = tile_a
      end
    end
  end

  def update_tile_lists(tile, old_tile)
    if tile.opposite == old_tile
      unused_tiles.delete(tile)
      unused_tiles << old_tile
    else
      if tile.unlimited
        new_tile = add_extra_tile(tile)

        if (opp_name = tile.opposite&.name) && !new_tile.opposite
          opp_tile = tile_by_id("#{opp_name}-#{new_tile.index}") || add_extra_tile(tile_by_id("#{opp_name}-0"))
          opp_tile.opposite = new_tile
          new_tile.opposite = opp_tile
        end
      end

      # TileSelector creates "fake" A1 hexes that are attached to the tiles,
      # so here we need to check that tile.hex actually belongs to the Game
      # object
      if (hex = tile.hex) && (hex == hex_by_id(hex.id))
        raise Engine::GameError,
              "Cannot lay tile #{tile.id}; it is already on hex #{tile.hex.id}"
      end
      if (hex = tile.opposite&.hex) && hex == hex_by_id(hex.id)
        raise Engine::GameError, "Cannot lay tile #{tile.id}; #{tile.opposite.id} is already on hex #{tile.opposite.hex.id}"
      end

      @tiles.delete(tile)
      if tile.opposite
        @tiles.delete(tile.opposite)
        @unused_tiles << tile.opposite
      end

      return if old_tile.preprinted

      @tiles << old_tile
      return unless old_tile.opposite

      @unused_tiles.delete(old_tile.opposite)
      @tiles << old_tile.opposite
    end
  end
end
