# frozen_string_literal: true

module Engine
  module Game
    module G1817NA
      module Entities
        COMPANIES = [
          {
            name: 'Denver Telecommunications',
            value: 40,
            revenue: 0,
            desc: 'Owning corp may place special Denver yellow tile during tile-laying, '\
                  'regardless of connectivity.  The hex is not reserved, and the '\
                  'power is lost if another company builds there first.',
            sym: 'DTC',
            abilities: [
            {
              type: 'tile_lay',
              hexes: ['F14'],
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
            name: 'Mountain Engineers',
            value: 40,
            revenue: 0,
            desc: 'Owning company receives $20 after laying a yellow tile in a '\
                  'mountain hex.  Any fees must be paid first.',
            sym: 'ME',
            abilities: [
              {
                type: 'tile_income',
                income: 20,
                terrain: 'mountain',
                owner_type: 'corporation',
                owner_only: true,
              },
            ],
            color: nil,
          },
          {
            name: 'Union Bridge Company',
            value: 80,
            revenue: 0,
            desc: 'Comes with two $10 bridge token that may be placed by the owning corp '\
                  'in Winnipeg or New Orleans, max one token per city, regardless of '\
                  'connectivity. Allows owning corp to skip $10 river fee when '\
                  'placing yellow tiles.',
            sym: 'UBC',
            abilities: [
              {
                type: 'tile_discount',
                discount: 10,
                terrain: 'water',
                owner_type: 'corporation',
              },
              {
                type: 'assign_hexes',
                hexes: %w[D16 H18],
                count: 2,
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
                  'in a mountain hex next to a revenue location, can place token '\
                  'to avoid $15 terrain fee.  Marked yellow hexes cannot be upgraded.  '\
                  'Hexes pay $10 extra revenue and do not count as a stop.  May '\
                  'not start or end a route at a coal mine.',
            sym: 'MINC',
            abilities: [
              {
                type: 'tile_lay',
                hexes: %w[A3
                          B4
                          B8
                          B10
                          D10
                          E11
                          E13
                          F12
                          G13
                          G19
                          H12
                          J14],
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
            name: 'Major Coal Mine',
            value: 90,
            revenue: 0,
            desc: 'Comes with three coal mine markers.  When placing a yellow '\
                  'tile in a mountain hex next to a revenue location, can place '\
                  'token to avoid $15 terrain fee.  Marked yellow hexes cannot be '\
                  'upgraded.  Hexes pay $10 extra revenue and do not count as a '\
                  'stop.  May not start or end a route at a coal mine.',
            sym: 'MAJC',
            abilities: [
              {
                type: 'tile_lay',
                hexes: %w[A3
                          B4
                          B8
                          B10
                          D10
                          E11
                          E13
                          F12
                          G13
                          G19
                          H12
                          J14],
                tiles: %w[7 8 9],
                free: false,
                when: 'track',
                discount: 15,
                consume_tile_lay: true,
                closed_when_used_up: true,
                owner_type: 'corporation',
                count: 3,
              },
            ],
            color: nil,
          },
          {
            name: 'Minor Mail Contract',
            value: 60,
            revenue: 0,
            desc: 'Pays owning corp $10 at the start of each operating round, as '\
                  'long as the company has at least one train.',
            sym: 'MINM',
            abilities: [
              {
                type: 'revenue_change',
                revenue: 10,
                when: 'has_train',
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Major Mail Contract',
            value: 120,
            revenue: 0,
            desc: 'Pays owning corp $20 at the start of each operating round, as '\
                  'long as the company has at least one train.',
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
            shares: [100],
            tokens: [0],
            max_ownership_percent: 100,
            color: '#984573',
          },
          {
            sym: 'J',
            name: 'Elgin, Joliet and Eastern Railway',
            logo: '1817/J',
            simple_logo: '1817/J.alt',
            shares: [100],
            tokens: [0],
            max_ownership_percent: 100,
            text_color: 'black',
            color: '#bedb86',
          },
          {
            sym: 'GT',
            name: 'Grand Trunk Western Railroad',
            logo: '1817/GT',
            simple_logo: '1817/GT.alt',
            shares: [100],
            tokens: [0],
            max_ownership_percent: 100,
            color: '#e48329',
          },
          {
            sym: 'H',
            name: 'Housatonic Railroad',
            logo: '1817/H',
            simple_logo: '1817/H.alt',
            shares: [100],
            tokens: [0],
            max_ownership_percent: 100,
            text_color: 'black',
            color: '#bedef3',
          },
          {
            sym: 'ME',
            name: 'Morristown and Erie Railway',
            logo: '1817/ME',
            simple_logo: '1817/ME.alt',
            shares: [100],
            tokens: [0],
            max_ownership_percent: 100,
            color: '#ffdea8',
            text_color: 'black',
          },
          {
            sym: 'NYOW',
            name: 'New York, Ontario and Western Railway',
            logo: '1817/W',
            simple_logo: '1817/W.alt',
            shares: [100],
            tokens: [0],
            max_ownership_percent: 100,
            color: '#0095da',
          },
          {
            sym: 'NYSW',
            name: 'New York, Susquehanna and Western Railway',
            logo: '1817/S',
            simple_logo: '1817/S.alt',
            shares: [100],
            tokens: [0],
            max_ownership_percent: 100,
            color: '#fff36b',
            text_color: 'black',
          },
          {
            sym: 'PSNR',
            name: 'Pittsburgh, Shawmut and Northern Railroad',
            logo: '1817/PSNR',
            simple_logo: '1817/PSNR.alt',
            shares: [100],
            tokens: [0],
            max_ownership_percent: 100,
            color: '#0a884b',
          },
          {
            sym: 'PLE',
            name: 'Pittsburgh and Lake Erie Railroad',
            logo: '1817/PLE',
            simple_logo: '1817/PLE.alt',
            shares: [100],
            tokens: [0],
            max_ownership_percent: 100,
            color: '#00afad',
          },
          {
            sym: 'PW',
            name: 'Providence and Worcester Railroad',
            logo: '1817/PW',
            simple_logo: '1817/PW.alt',
            shares: [100],
            tokens: [0],
            max_ownership_percent: 100,
            text_color: 'black',
            color: '#bec8cc',
          },
          {
            sym: 'R',
            name: 'Rutland Railroad',
            logo: '1817/R',
            simple_logo: '1817/R.alt',
            shares: [100],
            tokens: [0],
            max_ownership_percent: 100,
            color: '#165633',
          },
          {
            sym: 'SR',
            name: 'Strasburg Railroad',
            logo: '1817/SR',
            simple_logo: '1817/SR.alt',
            shares: [100],
            tokens: [0],
            max_ownership_percent: 100,
            color: '#e31f21',
          },
          {
            sym: 'UR',
            name: 'Union Railroad',
            logo: '1817/UR',
            simple_logo: '1817/UR.alt',
            shares: [100],
            tokens: [0],
            max_ownership_percent: 100,
            color: '#003d84',
          },
          {
            sym: 'WT',
            name: 'Warren & Trumbull Railroad',
            logo: '1817/WT',
            simple_logo: '1817/WT.alt',
            shares: [100],
            tokens: [0],
            max_ownership_percent: 100,
            color: '#e96f2c',
          },
          {
            sym: 'WC',
            name: 'West Chester Railroad',
            logo: '1817/WC',
            simple_logo: '1817/WC.alt',
            shares: [100],
            tokens: [0],
            max_ownership_percent: 100,
            color: '#984d2d',
          },
        ].freeze
      end
    end
  end
end
