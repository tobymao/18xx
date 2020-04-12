# frozen_string_literal: true

require 'engine/tile'

require 'view/tiles'

module View
  class AllTiles < Tiles
    def render
      tile_ids = [
        Engine::Tile::WHITE.keys,
        Engine::Tile::YELLOW.keys,
        Engine::Tile::GREEN.keys,
        Engine::Tile::BROWN.keys,
        Engine::Tile::GRAY.keys,
      ].reduce(&:+)

      generic_tiles, game_tiles = tile_ids.partition { |id| id =~ /;/ }

      children = (generic_tiles + game_tiles).map do |tile|
        render_tile_block(tile)
      end

      h('div#tiles', children)
    end
  end
end
