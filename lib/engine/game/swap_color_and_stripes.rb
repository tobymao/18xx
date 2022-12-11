# frozen_string_literal: true

#
# This module provides a function to flip a tile's the color and stripes, making
# the color that was the stripes the tile's new effective color. It should be
# called in after a LayTile action is processed, e.g., in Game#action_processed.
#
module SwapColorAndStripes
  def swap_color_and_stripes(tile)
    tile.color, tile.stripes.color = tile.stripes.color, tile.color if tile.stripes
  end
end
