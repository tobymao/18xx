# frozen_string_literal: true

require_tree 'engine'

require 'lib/params'
require 'view/tile_manifest'
require 'view/tiles'

module View
  class TilesPage < Tiles
    needs :route

    ROUTE_FORMAT = %r{/tiles/([^/?]*)(?:/([^?]+))?}.freeze

    TILE_IDS = [
      Engine::Tile::WHITE.keys,
      Engine::Tile::YELLOW.keys,
      Engine::Tile::GREEN.keys,
      Engine::Tile::BROWN.keys,
      Engine::Tile::GRAY.keys,
      Engine::Tile::RED.keys,
    ].reduce(&:+)

    def render
      match = @route.match(ROUTE_FORMAT)
      dest = match[1]
      hexes_or_tiles = match[2]

      # parse URL params 'r' and 'n'; but don't apply them to /tiles/all, are
      # you trying to kill your browser?
      @rotations =
        case (r = Lib::Params['r'])
        when nil
          [0]
        when 'all'
          (0..5).to_a
        else
          # apparently separating rotations in URL with '+' works by passing ' '
          # to split here
          r.split(' ').map(&:to_i)
        end
      @location_name = Lib::Params['n']

      # all common hexes/tiles
      if dest == 'all'
        h('div#tiles', [
            h('div#all_tiles', [
                h(:h1, 'Generic Map Hexes and Common Track Tiles'),
                *TILE_IDS.flat_map { |t| render_tile_blocks(t) }
              ]),

          ])

      # hexes/tiles from a specific game
      elsif hexes_or_tiles
        game_title = dest
        hex_or_tile_ids = hexes_or_tiles.split('+')
        rendered = hex_or_tile_ids.flat_map { |id| render_individual_tile_from_game(game_title, id) }
        h('div#tiles', rendered)

      # everything for one or more games
      elsif (game_titles = dest.split('+')).all? { |g| Engine::GAMES_BY_TITLE.keys.include?(g) }

        rendered = game_titles.flat_map do |g|
          game_class = Engine::GAMES_BY_TITLE[g]
          map_hexes_and_tile_manifest_for(game_class)
        end

        h('div#tiles', rendered)

      # common tile(s)
      else
        tile_ids = dest.split('+')
        rendered = tile_ids.flat_map do |id|
          render_tile_blocks(
            id,
            scale: 3.0,
            rotations: @rotations,
            location_name: @location_name,
          )
        end
        h('div#tiles', rendered)
      end
    end

    def render_individual_tile_from_game(game_title, dest)
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

      render_tile_blocks(
        name,
        tile: tile,
        location_name: tile.location_name || @location_name,
        scale: 3.0,
        rotations: @rotations,
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

      rendered_map_hexes = map_hexes.sort.flat_map do |tile|
        render_tile_blocks(
          tile.name,
          tile: tile,
          location_name: tile.location_name
        )
      end

      rendered_tiles = game.tiles.sort.group_by(&:name).flat_map do |name, tiles_|
        render_tile_blocks(
          name,
          tile: tiles_.first,
          num: tiles_.size,
          rotations: @rotations,
          location_name: @location_name,
        )
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
