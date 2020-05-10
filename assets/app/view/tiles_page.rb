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

      # all common hexes/tiles
      if dest == 'all'
        h('div#tiles', [
            h('div#all_tiles', [
                h(:h1, 'Generic Map Hexes and Common Track Tiles'),
                *TILE_IDS.map { |t| render_tile_block(t) }
              ]),

          ])

      # everything for one game
      elsif Engine::GAMES_BY_TITLE.keys.include?(dest)
        game_class = Engine::GAMES_BY_TITLE[dest]
        h('div#tiles', [
            map_hexes_and_tile_manifest_for(game_class)
          ])

      # just one tile
      elsif TILE_IDS.include?(dest)
        render_tile_block(dest, scale: 3.0)

      # just one hex/tile from a specific game
      elsif dest.include?('/')
        game_title, dest = dest.split('/')
        begin
          render_individual_tile(game_title, dest)
        rescue StandardError
          h(:p, err_msg)
        end

      # no match from prior conditionals, something must be wrong with the given
      # route
      else
        h(:p, err_msg)
      end
    end

    def render_individual_tile(game_title, dest)
      game = Engine::GAMES_BY_TITLE[game_title].new(%w[p1 p2 p3])

      # TODO?: handle case with big map and uses X for game-specific tiles
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
    end

    def map_hexes_and_tile_manifest_for(game_class)
      game = game_class.new(%w[p1 p2 p3])

      # map_tiles: hash; key is hex ID, value is the Tile there
      map_tiles = game.hexes.map { |h| [h.name, h.tile] }.to_h

      # get mapping of tile -> all hex coordinates using that tile
      tile_to_coords = {}
      map_tiles.each do |coord, tile|
        tile_key = tile_to_coords.keys.find do |k|
          [
            k.name == tile.name,
            k.location_name == tile.location_name,
            k.blockers == tile.blockers,
            k.cities.map(&:reservations) == tile.cities.map(&:reservations),
          ].all?
        end
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
