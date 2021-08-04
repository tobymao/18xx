# frozen_string_literal: true

module Engine
  module Game
    module G1817DE
      module Entities
        COMPANIES = [

      {
        name: 'Mountain Engineers',
        value: 40,
        revenue: 0,
        desc: 'Owning company receives 20 ℳ after laying a yellow tile in a '\
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
        name: 'Bridge Company',
        value: 80,
        revenue: 0,
        desc: 'Comes with two 10 ℳ bridge token that may be placed by the owning corp '\
              'in Frankfurt and Dresden, max one token per city, regardless of '\
              'connectivity. Allows owning corp to skip 10 ℳ river fee when '\
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
            hexes: %w[D16 J14],
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
              'to avoid 15 ℳ terrain fee.  Marked yellow hexes cannot be upgraded.  '\
              'Hexes pay 10 ℳ extra revenue and do not count as a stop.  May '\
              'not start or end a route at a coal mine.',
        sym: 'MINC',
        abilities: [
          {
            type: 'tile_lay',
            hexes: %w[D14
                      D22
                      D24
                      E15
                      G11
                      G13
                      G17],
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
              'token to avoid 15 ℳ terrain fee.  Marked yellow hexes cannot be '\
              'upgraded.  Hexes pay 10 ℳ extra revenue and do not count as a '\
              'stop.  May not start or end a route at a coal mine.',
        sym: 'MAJC',
        abilities: [
          {
            type: 'tile_lay',
            hexes: %w[D14
                      D22
                      D24
                      E15
                      G11
                      G13
                      G17],
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
        desc: 'Pays owning corp 10 ℳ at the start of each operating round, as '\
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
        desc: 'Pays owning corp 20 ℳ at the start of each operating round, as '\
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

        CORPORATIONS = [
              {
                float_percent: 20,
                sym: 'BD',
                name: 'Badische Eisenbahn',
                logo: '1817_de/BD',
                shares: [100],
                max_ownership_percent: 100,
                tokens: [0],
                always_market_price: true,
                color: 'maroon',
                reservation_color: nil,
              },
              {
                float_percent: 20,
                sym: 'BY',
                name: 'Bayrische Eisenbahn',
                logo: '1817_de/BY',
                shares: [100],
                max_ownership_percent: 100,
                tokens: [0],
                always_market_price: true,
                color: 'dodgerblue',
                reservation_color: nil,
              },

              {
                float_percent: 20,
                sym: 'HE',
                name: 'Hessische Eisenbahn',
                logo: '1817_de/HE',
                shares: [100],
                max_ownership_percent: 100,
                tokens: [0],
                always_market_price: true,
                color: 'darkgreen',
                reservation_color: nil,
              },

              {
                float_percent: 20,
                sym: 'OL',
                name: 'Oldenburgische Eisenbahn',
                logo: '1817_de/OL',
                shares: [100],
                max_ownership_percent: 100,
                tokens: [0],
                always_market_price: true,
                color: 'darkgray',
                reservation_color: nil,
              }, {
                float_percent: 20,
                sym: 'MS',
                name: 'Eisenbahn Mecklenburg Schwerin',
                logo: '1817_de/MS',
                shares: [100],
                max_ownership_percent: 100,
                tokens: [0],
                always_market_price: true,
                color: 'indigo',
                reservation_color: nil,
              }, {
                float_percent: 20,
                sym: 'SX',
                name: 'Sächsische Eisenbahn',
                logo: '1817_de/SX',
                shares: [100],
                max_ownership_percent: 100,
                tokens: [0],
                always_market_price: true,
                color: 'red',
                reservation_color: nil,
              },
              {
                float_percent: 20,
                sym: 'WT',
                name: 'Württembergische Eisenbahn',
                logo: '1817_de/WT',
                shares: [100],
                max_ownership_percent: 100,
                tokens: [0],
                always_market_price: true,
                color: 'yellow',
                text_color: 'black',
                reservation_color: nil,
              }, {
                float_percent: 20,
                sym: 'BM',
                name: 'Bergisch Märkische Bahn',
                logo: '1817_de/BM',
                shares: [100],
                max_ownership_percent: 100,
                tokens: [0],
                always_market_price: true,
                color: 'lime',
                text_color: 'black',
                reservation_color: nil,
              },
              {
                float_percent: 20,
                sym: 'BP',
                name: 'Berlin Potsdamer Bahn',
                logo: '1817_de/BP',
                shares: [100],
                max_ownership_percent: 100,
                tokens: [0],
                always_market_price: true,
                color: 'hotpink',
                reservation_color: nil,
              },
              {
                float_percent: 20,
                sym: 'BS',
                name: 'Berlin Stettiner Bahn',
                logo: '1817_de/BS',
                shares: [100],
                max_ownership_percent: 100,
                tokens: [0],
                always_market_price: true,
                color: '#003d84',
                reservation_color: nil,
              }, {
                float_percent: 20,
                sym: 'KM',
                name: 'Köln-Mindener Bahn',
                logo: '1817_de/KM',
                shares: [100],
                max_ownership_percent: 100,
                tokens: [0],
                always_market_price: true,
                color: 'black',
                reservation_color: nil,
              },
              {
                float_percent: 20,
                sym: 'LD',
                name: 'Leipzig-Dresdner Bahn',
                logo: '1817_de/LD',
                shares: [100],
                max_ownership_percent: 100,
                tokens: [0],
                always_market_price: true,
                color: '#ADD8E6',
                text_color: 'black',
                reservation_color: nil,
              },
              {
                float_percent: 20,
                sym: 'MB',
                name: 'Magdeburger-Bahn',
                logo: '1817_de/MB',
                shares: [100],
                max_ownership_percent: 100,
                tokens: [0],
                always_market_price: true,
                color: 'Burlywood',
                text_color: 'black',
                reservation_color: nil,
              },
              {
                float_percent: 20,
                sym: 'NF',
                name: 'Nürnberg-Fürth',
                logo: '1817_de/NF',
                shares: [100],
                max_ownership_percent: 100,
                tokens: [0],
                always_market_price: true,
                color: '#e48329',
                reservation_color: nil,
              },
              {
                float_percent: 20,
                sym: 'OB',
                name: 'Ostbayrische Bahn',
                logo: '1817_de/OB',
                shares: [100],
                max_ownership_percent: 100,
                tokens: [0],
                always_market_price: true,
                text_color: 'black',
                color: '#bedb86',
                reservation_color: nil,
              }
          ].freeze
      end
    end
  end
end
