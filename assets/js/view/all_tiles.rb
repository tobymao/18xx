# frozen_string_literal: true

require 'engine/company'
require 'engine/corporation'
require 'engine/game/g_1889'
require 'engine/tile'

require 'view/tiles'

module View
  class AllTiles < Tiles
    # TODO: can this automatically discover all defined games?
    GAMES = %w[1889].freeze

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
              h(:h1, 'Track Tiles and Generic Map Hexes'),
              *TILE_IDS.map { |t| render_tile_block(t) }
            ]),

          *GAMES.map { |g| map_hexes_for(g) }
        ])
    end

    def map_hexes_for(game_name)
      game_class = Object.const_get("Engine::Game::G#{game_name}")
      game_hexes = game_class::HEXES
      location_names = game_class::LOCATION_NAMES

      companies = game_class::COMPANIES.map { |c| Engine::Company.new(**c) }
      corporations = game_class::CORPORATIONS.map { |c| Engine::Corporation.new(**c) }

      rendered_tiles = game_hexes.map do |color, hexes|
        hexes.map do |coords, tile_string|
          coords.map.with_index do |coord, _index|
            next if TILE_IDS.include?(tile_string)

            tile = Engine::Tile.from_code(
              coord,
              color,
              tile_string,
              location_name: location_names[coord]
            )

            # add private companies that block tile lays on this hex
            blocker = companies.find do |c|
              c.abilities(:blocks_hex)&.dig(:hex) == coord
            end
            tile.add_blocker!(blocker) unless blocker.nil?

            # reserve corporation home spots
            corporations.select { |c| c.coordinates == coord }.each do |c|
              tile.cities.first.add_reservation!(c.name)
            end

            render_tile_block(
              tile.name,
              tile: tile,
              location_name: tile.location_name
            )
          end.compact
        end
      end.flatten

      h("div#map_hexes_#{game_name}", [
          h(:h1, "#{game_name} Map Hexes"),
          *rendered_tiles,
        ])
    end
  end
end
