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
              'in Magdeburg, Frankfurt and/or Dresden, max one token per city, regardless of '\
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
            hexes: %w[H10 D16 J14],
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
                      E15
                      G11],
            tiles: %w[7 8 9],
            free: false,
            when: 'owning_corp_or_turn',
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
                      E15
                      G11],
            tiles: %w[7 8 9],
            free: false,
            when: 'owning_corp_or_turn',
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
             sym: 'LD',
             name: 'Leipzig-Dresdner Bahn',
             logo: '1817/DLW',
             simple_logo: '1817/DLW.alt',
             shares: [100],
             max_ownership_percent: 100,
             tokens: [0],
             always_market_price: true,
             color: '#984573',
             reservation_color: nil,
           },
           {
             float_percent: 20,
             sym: 'OB',
             name: 'Ostbayrische Bahn',
             logo: '1817/J',
             simple_logo: '1817/J.alt',
             shares: [100],
             max_ownership_percent: 100,
             tokens: [0],
             always_market_price: true,
             text_color: 'black',
             color: '#bedb86',
             reservation_color: nil,
           },
           {
             float_percent: 20,
             sym: 'NF',
             name: 'Nürnberg-Fürth',
             logo: '1817/GT',
             simple_logo: '1817/GT.alt',
             shares: [100],
             max_ownership_percent: 100,
             tokens: [0],
             always_market_price: true,
             color: '#e48329',
             reservation_color: nil,
           },
           {
             float_percent: 20,
             sym: 'BY',
             name: 'Bayrische Eisenbahn',
             logo: '1817/H',
             simple_logo: '1817/H.alt',
             shares: [100],
             max_ownership_percent: 100,
             tokens: [0],
             always_market_price: true,
             text_color: 'black',
             color: '#bedef3',
             reservation_color: nil,
           },
           {
             float_percent: 20,
             sym: 'SX',
             name: 'Sächsische Eisenbahn',
             logo: '1817/ME',
             simple_logo: '1817/ME.alt',
             shares: [100],
             max_ownership_percent: 100,
             tokens: [0],
             always_market_price: true,
             color: '#ffdea8',
             text_color: 'black',
             reservation_color: nil,
           },
           {
             float_percent: 20,
             sym: 'BD',
             name: 'Badische Eisenbahn',
             logo: '1817/W',
             simple_logo: '1817/W.alt',
             shares: [100],
             max_ownership_percent: 100,
             tokens: [0],
             always_market_price: true,
             color: '#0095da',
             reservation_color: nil,
           },
           {
             float_percent: 20,
             sym: 'HE',
             name: 'Hessische Eisenbahn',
             logo: '1817/S',
             simple_logo: '1817/S.alt',
             shares: [100],
             max_ownership_percent: 100,
             tokens: [0],
             always_market_price: true,
             color: '#fff36b',
             text_color: 'black',
             reservation_color: nil,
           },
           {
             float_percent: 20,
             sym: 'WT',
             name: 'Württembergische Eisenbahn',
             logo: '1817/PSNR',
             simple_logo: '1817/PSNR.alt',
             shares: [100],
             max_ownership_percent: 100,
             tokens: [0],
             always_market_price: true,
             color: '#0a884b',
             reservation_color: nil,
           },
           {
             float_percent: 20,
             sym: 'MS',
             name: 'Eisenbahn Mecklenburg Schwerin',
             logo: '1817/PLE',
             simple_logo: '1817/PLE.alt',
             shares: [100],
             max_ownership_percent: 100,
             tokens: [0],
             always_market_price: true,
             color: '#00afad',
             reservation_color: nil,
           },
           {
             float_percent: 20,
             sym: 'OL',
             name: 'Oldenburgische Eisenbahn',
             logo: '1817/PW',
             simple_logo: '1817/PW.alt',
             shares: [100],
             max_ownership_percent: 100,
             tokens: [0],
             always_market_price: true,
             text_color: 'black',
             color: '#bec8cc',
             reservation_color: nil,
           },
           {
             float_percent: 20,
             sym: 'BM',
             name: 'Bergisch Märkische Bahn',
             logo: '1817/R',
             simple_logo: '1817/R.alt',
             shares: [100],
             max_ownership_percent: 100,
             tokens: [0],
             always_market_price: true,
             color: '#165633',
             reservation_color: nil,
           },
           {
             float_percent: 20,
             sym: 'BP',
             name: 'Berlin Potsdamer Bahn',
             logo: '1817/SR',
             simple_logo: '1817/SR.alt',
             shares: [100],
             max_ownership_percent: 100,
             tokens: [0],
             always_market_price: true,
             color: '#e31f21',
             reservation_color: nil,
           },
           {
             float_percent: 20,
             sym: 'BS',
             name: 'Berlin Stettiner Bahn',
             logo: '1817/UR',
             simple_logo: '1817/UR.alt',
             shares: [100],
             max_ownership_percent: 100,
             tokens: [0],
             always_market_price: true,
             color: '#003d84',
             reservation_color: nil,
           },
           {
             float_percent: 20,
             sym: 'KM',
             name: 'Köln-Mindener Bahn',
             logo: '1817/WT',
             simple_logo: '1817/WT.alt',
             shares: [100],
             max_ownership_percent: 100,
             tokens: [0],
             always_market_price: true,
             color: '#e96f2c',
             reservation_color: nil,
           },
           {
             float_percent: 20,
             sym: 'MB',
             name: 'Magdeburger-Bahn',
             logo: '1817/WC',
             simple_logo: '1817/WC.alt',
             shares: [100],
             max_ownership_percent: 100,
             tokens: [0],
             always_market_price: true,
             color: '#984d2d',
             reservation_color: nil,
           },
          ].freeze
      end
    end
  end
end
