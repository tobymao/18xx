# frozen_string_literal: true

require_tree 'engine'

require 'view/tile_manifest'
require 'view/tiles'

module View
  class TilesPage < Tiles
    needs :route

    ROUTE_FORMAT = %r{/tiles/(.*)}.freeze

    TILE_IDS = [
      Engine::Tile::WHITE.keys,
      Engine::Tile::YELLOW.keys,
      Engine::Tile::GREEN.keys,
      Engine::Tile::BROWN.keys,
      Engine::Tile::GRAY.keys,
      Engine::Tile::RED.keys,
    ].reduce(&:+)

    def render
      dest = @route.match(ROUTE_FORMAT)[1]

      err_msg = "Bad tile dest: \"#{dest}\"; should be \"all\", <game_title>, "\
                '<tile_name>, <game_title>/<hex_coord>, or '\
                '<game_title>/<tile_name>'

      if dest == 'all'
        h('div#tiles', [
            h('div#all_tiles', [
                h(:h1, 'Generic Map Hexes and All Track Tiles'),
                *TILE_IDS.map { |t| render_tile_block(t) }
              ]),

          ])
      elsif Engine::GAMES_BY_TITLE.keys.include?(dest)
        game_class = Engine::GAMES_BY_TITLE[dest]
        h('div#tiles', [
            map_hexes_and_tile_manifest_for(game_class)
          ])
      elsif TILE_IDS.include?(dest)
        render_tile_block(dest, scale: 3.0)
      elsif dest.include?('/')
        game_title, dest = dest.split('/')
        begin
          game = Engine::GAMES_BY_TITLE[game_title].new(%w[p1 p2 p3])

          # TODO: handle case with big map and uses X for game-specific tiles
          # (i.e., "X1" is the name of a tile *and* a hex)
          tile, name =
            if game.class::TILES.include?(dest)
              t = game.tile_by_id("#{dest}-0")
              [t, t.name]
            else
              t = game.hex_by_id(dest).tile
              [t, dest]
            end

          render_tile_block(
            name,
            tile: tile,
            location_name: tile.location_name,
            scale: 3.0
          )
        rescue StandardError
          h(:p, err_msg)
        end
      else
        h(:p, err_msg)
      end
    end

    def map_hexes_and_tile_manifest_for(game_class)
      game = game_class.new(%w[p1 p2 p3])
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
              c.abilities(:blocks_hexes)&.dig(:hexes)&.include?(coord)
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

      rendered_tiles = game.tiles.sort.group_by(&:name).map do |name, tiles_|
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
