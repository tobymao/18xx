# frozen_string_literal: true

module Engine
  module Game
    module G1817WO
      module Entities
        COMPANIES = [
          {
            name: 'Pittsburgh Steel Mill',
            value: 40,
            revenue: 0,
            desc: "Owning corp may place special 'New Pittsburgh' yellow tile "\
                  'during tile-laying, regardless of connectivity.  The hex is not reserved, and the '\
                  'power is lost if another company builds there first.',
            sym: 'PSM',
            abilities: [
            {
              type: 'tile_lay',
              hexes: ['I6'],
              tiles: ['X00'],
              when: 'track',
              owner_type: 'corporation',
              count: 1,
              closed_when_used_up: true,
              consume_tile_lay: true,
              special: true,
            },
          ],
            color: nil,
          },
          {
            name: 'Mountain (Ocean) Engineers',
            value: 40,
            revenue: 0,
            desc: 'Owning company receives $20 after laying a yellow tile in a '\
                  'mountain (ocean) hex.  Any fees must be paid first.',
            sym: 'ME',
            abilities: [
              {
                type: 'tile_income',
                income: 20,
                terrain: 'lake',
                owner_type: 'corporation',
                owner_only: true,
              },
            ],
            color: nil,
          },
          {
            name: 'Ohio Bridge Company',
            value: 40,
            revenue: 0,
            desc: 'Comes with one $10 bridge token that may be placed by the owning corp '\
                  'in Mare Nostrum or Dynasties max one token per city, regardless '\
                  'of connectivity.  Allows owning corp to skip $10 river fee '\
                  'when placing yellow tiles.',
            sym: 'OBC',
            abilities: [
              {
                type: 'tile_discount',
                discount: 10,
                terrain: 'water',
                owner_type: 'corporation',
              },
              {
                type: 'assign_hexes',
                hexes: %w[G4 K4],
                count: 1,
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Train Station',
            value: 80,
            revenue: 0,
            desc: 'Provides an additional station marker for the owning corp, awarded at time of purchase',
            sym: 'TS',
            abilities: [
              {
                type: 'additional_token',
                count: 1,
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Minor Coal Mine',
            value: 30,
            revenue: 0,
            desc: 'Comes with one coal mine marker.  When placing a yellow tile '\
                  'in a ocean hex next to a revenue location, can place token to '\
                  'avoid $15 terrain fee.  Marked yellow hexes cannot be upgraded.  '\
                  'Hexes pay $10 extra revenue and do not count as a stop.  May '\
                  'not start or end a route at a coal mine. C8 may not have a coal mine.',
            sym: 'MINC',
            abilities: [
              {
                type: 'tile_lay',
                hexes: %w[B7 E4 E2 F9 I8 K6 L5],
                tiles: %w[7 8 9],
                free: false,
                when: 'track',
                discount: 15,
                consume_tile_lay: true,
                closed_when_used_up: true,
                owner_type: 'corporation',
                count: 1,
              },
            ],
            color: nil,
          },
          {
            name: 'Coal Mine',
            value: 60,
            revenue: 0,
            desc: 'Comes with two coal mine markers.  When placing a yellow tile '\
                  'in a mountain hex next to a revenue location, can place token '\
                  'to avoid $15 terrain fee.  Marked yellow hexes cannot be upgraded.  '\
                  'Hexes pay $10 extra revenue and do not count as a stop.  May '\
                  'not start or end a route at a coal mine. C8 may not have a coal mine.',
            sym: 'CM',
            abilities: [
              {
                type: 'tile_lay',
                hexes: %w[B7 E4 E2 F9 I8 K6 L5],
                tiles: %w[7 8 9],
                free: false,
                when: 'track',
                discount: 15,
                consume_tile_lay: true,
                closed_when_used_up: true,
                owner_type: 'corporation',
                count: 2,
              },
            ],
            color: nil,
          },
          {
            name: 'Major Mail Contract',
            value: 120,
            revenue: 0,
            desc: 'Pays owning corp $20 at the start of each operating round, '\
                  'as long as the company has at least one train.',
            sym: 'MAJM',
            abilities: [
              {
                type: 'revenue_change',
                revenue: 20,
                when: 'has_train',
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 20,
            sym: 'A&S',
            name: 'Alton & Southern Railway',
            logo: '1817/AS',
            simple_logo: '1817/AS.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#ee3e80',
          },
          {
            float_percent: 20,
            sym: 'Belt',
            name: 'Belt Railway of Chicago',
            logo: '1817/Belt',
            simple_logo: '1817/Belt.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            text_color: 'black',
            color: '#f2a847',
          },
          {
            float_percent: 20,
            sym: 'Bess',
            name: 'Bessemer and Lake Erie Railroad',
            logo: '1817/Bess',
            simple_logo: '1817/Bess.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#16190e',
          },
          {
            float_percent: 20,
            sym: 'B&A',
            name: 'Boston and Albany Railroad',
            logo: '1817/BA',
            simple_logo: '1817/BA.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#ef4223',
          },
          {
            float_percent: 20,
            sym: 'DL&W',
            name: 'Delaware, Lackawanna and Western Railroad',
            logo: '1817/DLW',
            simple_logo: '1817/DLW.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#984573',
          },
          {
            float_percent: 20,
            sym: 'GT',
            name: 'Grand Trunk Western Railroad',
            logo: '1817/GT',
            simple_logo: '1817/GT.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#e48329',
          },
          {
            float_percent: 20,
            sym: 'H',
            name: 'Housatonic Railroad',
            logo: '1817/H',
            simple_logo: '1817/H.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            text_color: 'black',
            color: '#bedef3',
          },
          {
            float_percent: 20,
            sym: 'ME',
            name: 'Morristown and Erie Railway',
            logo: '1817/ME',
            simple_logo: '1817/ME.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#ffdea8',
            text_color: 'black',
          },
          {
            float_percent: 20,
            sym: 'PSNR',
            name: 'Pittsburgh, Shawmut and Northern Railroad',
            logo: '1817/PSNR',
            simple_logo: '1817/PSNR.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#0a884b',
          },
          {
            float_percent: 20,
            sym: 'R',
            name: 'Rutland Railroad',
            logo: '1817/R',
            simple_logo: '1817/R.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#165633',
          },
          {
            float_percent: 20,
            sym: 'UR',
            name: 'Union Railroad',
            logo: '1817/UR',
            simple_logo: '1817/UR.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#003d84',
          },
          {
            float_percent: 20,
            sym: 'WC',
            name: 'West Chester Railroad',
            logo: '1817/WC',
            simple_logo: '1817/WC.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#984d2d',
          },
        ].freeze
      end
    end
  end
end
