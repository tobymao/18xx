# frozen_string_literal: true

require_relative 'map'

module Engine
  module Game
    module G18Hiawatha
      module Entities
        include G18Hiawatha::Map

        COMPANIES = [
          {
            name: 'Muntzenberger Brewery',
            value: 60,
            revenue: 0,
            desc: 'Owning corporation may place the Kenosha yellow tile during the tile-laying phase, '\
                  'counts as a yellow tile lay. No connectivity requirement. The Kenosha hex is not reserved '\
                  'for this tile, power is lost if another company builds a regular tile there first.',
            sym: 'MB',
            abilities: [
              {
                type: 'tile_lay',
                hexes: ['D6'],
                tiles: ['X00H'],
                when: 'track',
                owner_type: 'corporation',
                count: 1,
                closed_when_used_up: true,
                consume_tile_lay: true,
                special: true,
              },
            ],
          },
          {
            name: 'Union Station',
            value: 60,
            revenue: 0,
            desc: 'Provides an additional station marker for the owning corp, awarded at time of purchase',
            sym: 'US',
            abilities: [
              {
                type: 'additional_token',
                count: 1,
                owner_type: 'corporation',
              },
            ],
          },
          {
            name: "Farmer's Union",
            value: 60,
            revenue: 0,
            desc: 'Comes with two Farm markers. They may be placed on a connected Farm hex along with a yellow tile '\
                  'as a regular tile placement. Marked yellow hexes cannot be upgraded. Hexes pay $10 extra revenue and '\
                  'do not count as a stop. May not start or end a route at a Farm.',
            sym: 'FU',
            abilities: [
              {
                type: 'tile_lay',
                hexes: %w[B2 C1 E3 F2],
                tiles: %w[7 8 9],
                when: 'track',
                consume_tile_lay: true,
                closed_when_used_up: true,
                owner_type: 'corporation',
                count: 2,
              },
            ],
          },
          {
            name: 'Great Lakes Shipping',
            value: 40,
            revenue: 0,
            desc: 'Owning corporation gets one Port token. It may be placed on an offboard location that has a Port (anchor) ' \
                  'symbol. All trains of all corporations gain +10 revenue to the routes of all trains running to this Port.',
            sym: 'GLS',
            abilities: [
              {
                type: 'assign_hexes',
                when: 'owning_corp_or_turn',
                hexes: %w[A9 D10 G13],
                count: 1,
                owner_type: 'corporation',
              },
            ],
          },
          {
            name: 'Freight Company',
            value: 50,
            revenue: 0,
            desc: 'Owning corporation can place a freight token on any one offboard location. The token  ' \
                  'cannot be moved once placed. The owning corporation gains +10 revenue to the routes of '\
                  'all trains running to this token.',
            sym: 'FC',
            abilities: [
              {
                type: 'assign_hexes',
                when: 'owning_corp_or_turn',
                hexes: %w[A1 A9 D10 E1 G13 I3 I13],
                count: 1,
                owner_type: 'corporation',
              },
              {
                type: 'assign_corporation',
                count: 1,
                owner_type: 'corporation',
              },
            ],
          },
          {
            name: 'Receivership Railroad',
            sym: 'RR',
            value: 120,
            revenue: 0,
            desc: 'Owning corporation immediately gets a free 2-train (labelled 2RR), regardless of the current phase, ' \
                  'unless in Phase 4 (in which case 2-trains have been rusted.)',
            abilities: [
              # defined in assign.rb
            ],
          },
          {
            name: 'Jacob Leinenkugel Brewing Company',
            sym: 'JLBC',
            value: 60,
            revenue: 0,
            desc: 'The owning corporation may lay a green city tile on their home location instead of a yellow city tile, '\
                  'or upgrade their home location to a green city tile if already yellow. This may be used during any phase.',
            abilities: [
              {
                type: 'tile_lay',
                hexes: [],
                tiles: %w[14 15 619 592H 592H2],
                special: false,
                when: %i[track special_track],
                count: 1,
                consume_tile_lay: true,
              },
            ],
          },
          {
            name: 'Postal Contract',
            value: 90,
            revenue: 0,
            desc: 'Pays owning corporation $20 at the start of each operating round. Corporation is not required to own a '\
                  'train to receive this bonus.',
            sym: 'PC',
            abilities: [
              # defined in buy_sell_par_shares.rb
            ],
          },
        ].freeze

        def corporation_opts
          {
            float_percent: 20,
            always_market_price: true,
          }
        end

        CORPORATIONS = [
          {
            sym: 'DL&W',
            name: 'Delaware, Lackawanna and Western Railroad',
            logo: '1817/DLW',
            simple_logo: '1817/DLW.alt',
            shares: [40, 20, 20, 20],
            tokens: [0],
            color: '#984573',
          },
          {
            sym: 'J',
            name: 'Elgin, Joliet and Eastern Railway',
            logo: '1817/J',
            simple_logo: '1817/J.alt',
            shares: [40, 20, 20, 20],
            tokens: [0],
            text_color: 'black',
            color: '#bedb86',
          },
          {
            sym: 'GT',
            name: 'Grand Trunk Western Railroad',
            logo: '1817/GT',
            simple_logo: '1817/GT.alt',
            shares: [40, 20, 20, 20],
            tokens: [0],
            color: '#e48329',
          },
          {
            sym: 'H',
            name: 'Housatonic Railroad',
            logo: '1817/H',
            simple_logo: '1817/H.alt',
            shares: [40, 20, 20, 20],
            tokens: [0],
            text_color: 'black',
            color: '#bedef3',
          },
          {
            sym: 'ME',
            name: 'Morristown and Erie Railway',
            logo: '1817/ME',
            simple_logo: '1817/ME.alt',
            shares: [40, 20, 20, 20],
            tokens: [0],
            color: '#ffdea8',
            text_color: 'black',
          },
          {
            sym: 'NYOW',
            name: 'New York, Ontario and Western Railway',
            logo: '1817/W',
            simple_logo: '1817/W.alt',
            shares: [40, 20, 20, 20],
            tokens: [0],
            color: '#0095da',
          },
          {
            sym: 'NYSW',
            name: 'New York, Susquehanna and Western Railway',
            logo: '1817/S',
            simple_logo: '1817/S.alt',
            shares: [40, 20, 20, 20],
            tokens: [0],
            color: '#fff36b',
            text_color: 'black',
          },
          {
            sym: 'PSNR',
            name: 'Pittsburgh, Shawmut and Northern Railroad',
            logo: '1817/PSNR',
            simple_logo: '1817/PSNR.alt',
            shares: [40, 20, 20, 20],
            tokens: [0],
            color: '#0a884b',
          },
          {
            sym: 'PLE',
            name: 'Pittsburgh and Lake Erie Railroad',
            logo: '1817/PLE',
            simple_logo: '1817/PLE.alt',
            shares: [40, 20, 20, 20],
            tokens: [0],
            color: '#00afad',
          },
          {
            sym: 'PW',
            name: 'Providence and Worcester Railroad',
            logo: '1817/PW',
            simple_logo: '1817/PW.alt',
            shares: [40, 20, 20, 20],
            tokens: [0],
            text_color: 'black',
            color: '#bec8cc',
          },
          {
            sym: 'R',
            name: 'Rutland Railroad',
            logo: '1817/R',
            simple_logo: '1817/R.alt',
            shares: [40, 20, 20, 20],
            tokens: [0],
            color: '#165633',
          },
          {
            sym: 'UR',
            name: 'Union Railroad',
            logo: '1817/UR',
            simple_logo: '1817/UR.alt',
            shares: [40, 20, 20, 20],
            tokens: [0],
            color: '#003d84',
          },
        ].freeze
      end
    end
  end
end
