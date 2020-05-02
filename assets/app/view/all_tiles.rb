# frozen_string_literal: true

require_tree 'engine'

require 'view/tile_manifest'
require 'view/tiles'

module View
  class AllTiles < Tiles
    TILE_IDS = [
      Engine::Tile::WHITE.keys,
      Engine::Tile::YELLOW.keys,
      Engine::Tile::GREEN.keys,
      Engine::Tile::BROWN.keys,
      Engine::Tile::GRAY.keys,
    ].reduce(&:+)

    def render
      h('div#tiles', [
          h('div#all_tiles', [
              h(:h1, 'Generic Map Hexes and All Track Tiles'),
              *TILE_IDS.map { |t| render_tile_block(t) }
            ]),

          *Engine::GAMES.map { |g| map_hexes_for(g) }
        ])
    end

    def map_hexes_for(game_class)
      game_hexes = game_class::HEXES
      location_names = game_class::LOCATION_NAMES

      companies = game_class::COMPANIES.map { |c| Engine::Company.new(**c) }
      corporations = game_class::CORPORATIONS.map { |c| Engine::Corporation.new(**c) }

      map_tiles = game_hexes.map do |color, hexes|
        hexes.map do |coords, tile_string|
          coords.map.with_index do |coord, _index|
            tile =
              if TILE_IDS.include?(tile_string)
                Engine::Tile.for(tile_string)
              else
                Engine::Tile.from_code(
                  coord,
                  color,
                  tile_string,
                  location_name: location_names[coord]
                )
              end

            # add private companies that block tile lays on this hex
            blocker = companies.find do |c|
              c.abilities(:blocks_hex)&.dig(:hex) == coord
            end
            if blocker
              tile.add_blocker!(blocker)
              # name it with the coord to distinguish this tile from its
              # standard archetype that doesn't have a blocker
              tile.name = coord
            end

            # reserve corporation home spots
            corporations.select { |c| c.coordinates == coord }.each do |c|
              tile.cities.first.add_reservation!(c.name)

              # name it with the coord to distinguish this tile from its
              # standard archetype that doesn't have a blocker
              tile.name = coord
            end

            [coord, tile]
          end.compact
        end
      end.flatten.each_slice(2).to_a.to_h

      # get mapping of tile -> all coordinates using that tile (for starting map
      # hex "tiles")
      tile_to_coords = {}
      map_tiles.each do |coord, tile|
        tile_key = tile_to_coords.keys.find { |k| k&.name == tile.name }
        if tile_key.nil?
          tile_to_coords[tile] = [coord]
        else
          tile_to_coords[tile_key] << coord
        end
      end

      # truncate "names" (list of hexes with this tile)
      map_hexes = tile_to_coords.map do |tile, coords|
        name = coords.join(',')
        name = "#{name.slice(0, 10)}..." if name.size > 13
        tile.name = name
        tile
      end

      rendered_map_hexes = map_hexes.sort.map do |tile|
        render_tile_block(
          tile.name,
          tile: tile,
          location_name: tile.location_name
        )
      end

      tiles = game_class::TILES.flat_map do |name, num|
        num.times.map do |index|
          Engine::Tile.for(name, index: index)
        rescue Engine::GameError
          # use "TODO" tiles for when a game has a tile in its TILES that is
          # not yet defined in Engine::TILES
          Engine::Tile.from_code(name, 'white', 'l=TODO', index: index)
        end
      end

      rendered_tiles = tiles.sort.group_by(&:name).map do |name, tiles_|
        render_tile_block(name, tile: tiles_.first, num: tiles_.size)
      end

      h("div#hexes_and_tiles_#{game_class.title}", [
          h(:h1, game_class.title.to_s),
          h("div#map_hexes_#{game_class.title}", [
              h(:h2, "#{game_class.title} Map Hexes"),
              *rendered_map_hexes,
            ]),
          h("div#game_tiles_#{game_class.title}", [
              h(:h2, "#{game_class.title} Tile Manifest"),
              *rendered_tiles,
            ])
        ])
    end
  end
end
