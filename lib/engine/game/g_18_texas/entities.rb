# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G18Texas
      module Entities
        # rubocop:disable Layout/LineLength

        COMPANIES = [
          {
            name: 'Buffalo Bayou, Brazos and Colorado Railway Company',
            value: 50,
            revenue: 10,
            desc: 'Blocks hex J13 until Phase 5.',
            sym: 'BBBCRC',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['J13'] }],

          },
          {
            name: 'Galveston and Red River Railway Company',
            value: 80,
            revenue: 20,
            desc: 'Teleport to Houston. Phases 3-4. In hex I14, the owning president may upgrade to a #511 tile (at no cost) and place a token as the respective operation steps of an operating corporation. The corporation does not need to have a route to this hex.',
            sym: 'GRRRC',
            abilities: [
                        {
                          type: 'tile_lay',
                          when: 'owning_player_track',
                          owner_type: 'player',
                          description: 'Place 511 tile in I14 for free',
                          consume_tile_lay: true,
                          remove_when_used_up: true,
                          count: 1,
                          hexes: ['I14'],
                          tiles: ['511'],
                        },
                        {
                          type: 'token',
                          when: 'owning_player_token',
                          owner_type: 'player',
                          description: 'Token Houston (I14) without connection',
                          hexes: ['I14'],
                          from_owner: true,
                          remove_when_used_up: true,
                          count: 1,
                        },
                       ],
          },
          {
            name: 'Jay Gould',
            value: 200,
            revenue: 5,
            abilities: [{ type: 'shares', shares: 'random_president' }],
            sym: 'JG',
          }, {
            name: 'International–Great Northern',
            value: 210,
            revenue: 30,
            min_players: 4,
            desc: 'Extra Tile Lay. Phases 3-4. Blocks hexes D13 and E12 until Phase 5. The owning president may place #8 and #9 tiles in these hexes as an extra tile lay during the track laying step of an operating corporation. The tiles must connect to each other.',
            sym: 'IGN',
            abilities: [{ type: 'shares', shares: 'match_share' },
                        { type: 'blocks_hexes', owner_type: 'player', hexes: %w[D13 E12] },
                        {
                          type: 'tile_lay',
                          when: 'owning_player_track',
                          owner_type: 'player',
                          hexes: %w[D13 E12],
                          tiles: %w[8 9],
                          count: 2,
                        }],
          },
          {
            name: 'New Orleans Pacific Railroad',
            value: 240,
            revenue: 40,
            min_players: 5,
            sym: 'NOPR',
            desc: 'Teleport to San Antonio. Phases 3-4. In hex J5, the owning president may upgrade to a #511 tile and place a token as the respective operation steps of a corporation for which they are president. The corporation does not need to have a route to this hex and the hex may be unbuilt or have a yellow tile.',

            abilities: [{ type: 'shares', shares: 'match_share' },

                        {
                          type: 'tile_lay',
                          when: 'owning_player_track',
                          owner_type: 'player',
                          description: 'Place 511 tile in J5 for free',
                          consume_tile_lay: true,
                          remove_when_used_up: true,
                          count: 1,
                          hexes: ['J5'],
                          tiles: ['511'],
                        },
                        {
                          type: 'token',
                          when: 'owning_player_token',
                          owner_type: 'player',
                          description: 'Token San Antonio (J5) without connection',
                          hexes: ['J5'],
                          from_owner: true,
                          remove_when_used_up: true,
                          count: 1,
                        }],
          }
        ].freeze
        # rubocop:enable Layout/LineLength

        CORPORATIONS = [
         {
           float_percent: 50,
           sym: 'T&P',
           name: 'Texas and Pacific Railway',
           logo: '18_texas/TP',
           tokens: [0, 0, 0, 0, 0],
           city: 1,
           coordinates: 'D9',
           color: 'darkmagenta',
           text_color: 'white',
           always_market_price: true,
         },
         {
           float_percent: 50,
           sym: 'MKT',
           name: 'Missouri–Kansas–Texas Railway',
           logo: '18_texas/MKT',
           tokens: [0, 0, 0, 0],
           coordinates: 'B11',
           color: 'green',
           text_color: 'white',
           always_market_price: true,
         },
         {
           float_percent: 50,
           sym: 'SP',
           name: 'Southern Pacific Railroad',
           logo: '18_texas/SP',
           tokens: [0, 0, 0, 0, 0],
           coordinates: 'I14',
           color: 'orange',
           text_color: 'white',
           always_market_price: true,
         },
         {
           float_percent: 50,
           sym: 'MP',
           name: 'Missouri Pacific Railroad',
           logo: '18_texas/MP',
           tokens: [0, 0, 0, 0],
           coordinates: 'G10',
           color: 'red',
           text_color: 'white',
           always_market_price: true,
         },
         {
           float_percent: 50,
           sym: 'SSW',
           name: 'St. Louis Southwestern Railway',
           logo: '18_texas/SSW',
           tokens: [0, 0, 0],
           coordinates: 'D15',
           color: 'blue',
           text_color: 'white',
           always_market_price: true,
         },
         {
           float_percent: 50,
           sym: 'SAA',
           name: 'San Antonio and Aransas Pass',
           logo: '18_texas/SAA',
           tokens: [0, 0, 0],
           coordinates: 'J5',
           color: 'black',
           text_color: 'white',
           always_market_price: true,
         },
       ].freeze
      end
    end
  end
end
