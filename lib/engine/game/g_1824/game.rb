# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'corporation'
require_relative 'depot'
require_relative 'minor'

module Engine
  module Game
    module G1824
      class Game < Game::Base
        include_meta(G1824::Meta)

        attr_accessor :two_train_bought, :forced_mountain_railway_exchange

        register_colors(
          gray70: '#B3B3B3',
          gray50: '#7F7F7F'
        )

        CURRENCY_FORMAT_STR = '%dG'

        BANK_CASH = 12_000

        CERT_LIMIT = { 2 => 14, 3 => 21, 4 => 16, 5 => 13, 6 => 11 }.freeze

        STARTING_CASH = { 2 => 680, 3 => 820, 4 => 680, 5 => 560, 6 => 460 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 4,
          '4' => 6,
          '5' => 5,
          '6' => 5,
          '7' => 5,
          '8' => 10,
          '9' => 10,
          '14' => 4,
          '15' => 8,
          '16' => 1,
          '17' => 1,
          '18' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 3,
          '24' => 3,
          '25' => 2,
          '26' => 2,
          '27' => 2,
          '28' => 1,
          '29' => 1,
          '30' => 1,
          '31' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 1,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '55' => 1,
          '56' => 1,
          '57' => 5,
          '58' => 8,
          '69' => 1,
          '70' => 1,
          '87' => 3,
          '88' => 3,
          '126' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
            'path=a:5,b:_0;label=Bu',
          },
          '401' =>
          {
            'count' => 3,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:0,b:_0;path=a:1,b:_0;label=T',
          },
          '405' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' =>
            'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;label=T',
          },
          '447' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:0,b:_0;path=a:4,b:_0;label=T',
          },
          '490' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Bu',
          },
          '491' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40;city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:5,b:_0;path=a:1,b:_1;'\
            'path=a:2,b:_2;path=a:3,b:_2;path=a:4,b:_1;label=W',
          },
          '493' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:70;city=revenue:70,slots:3;path=a:0,b:_0;path=a:5,b:_0;path=a:2,b:_1;path=a:3,b:_1;'\
            'path=a:4,b:_1;path=a:1,b:_1;label=W',
          },
          '494' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;label=T',
          },
          '495' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
            'path=a:5,b:_0;label=Bu',
          },
          '496' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
            'path=a:5,b:_0;label=W',
          },
          '497' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' =>
            'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;label=T',
          },
          '498' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' =>
            'city=revenue:30;city=revenue:30;path=a:2,b:_1;path=a:3,b:_1;path=a:0,b:_0;path=a:5,b:_0;label=Bu',
          },
          '499' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' =>
            'city=revenue:40;city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;'\
            'path=a:4,b:_1;label=W',
          },
          '611' => 6,
          '619' => 4,
          '630' => 1,
          '631' => 1,
        }.freeze

        LOCATION_NAMES = {
          'A4' => 'Dresden',
          'A18' => 'Krakau',
          'A24' => 'Kiew',
          'B5' => 'Pilsen',
          'B9' => 'Prag',
          'B15' => 'Mährisch-Ostrau',
          'B23' => 'Lemberg',
          'C12' => 'Brünn',
          'C26' => 'Tarnopol',
          'D19' => 'Kaschau',
          'E8' => 'Linz',
          'E12' => 'Wien',
          'E14' => 'Preßburg',
          'E26' => 'Czernowitz',
          'F7' => 'Salzbug',
          'F17' => 'Buda Pest',
          'F23' => 'Klausenburg',
          'G4' => 'Innsbruck',
          'G10' => 'Graz',
          'G18' => 'Szegedin',
          'G26' => 'Kronstadt',
          'H1' => 'Mailand',
          'H3' => 'Bozen',
          'H15' => 'Fünfkirchen',
          'H23' => 'Hermannstadt',
          'H27' => 'Bukarest',
          'I8' => 'Triest',
          'J13' => 'Sarajevo',
        }.freeze

        MARKET = [
          %w[100
             110
             120
             130
             140
             155
             170
             190
             210
             235
             260
             290
             320
             350],
          %w[90
             100
             110
             120
             130
             145
             160
             180
             200
             225
             250
             280
             310
             340],
          %w[80
             90
             100p
             110
             120
             135
             150
             170
             190
             215
             240
             270
             300
             330],
          %w[70 80 90p 100 110 125 140 160 180 200 220],
          %w[60 70 80p 90 100 115 130 150 170],
          %w[50 60 70p 80 90 105 120],
          %w[40 50 60p 70 80],
        ].freeze

        PHASES = [
          {
            name: '2',
            on: '2',
            train_limit: { PreStaatsbahn: 2, Coal: 2, Regional: 4 },
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: { PreStaatsbahn: 2, Coal: 2, Regional: 4 },
            tiles: %i[yellow green],
            status: %w[can_buy_trains
                       may_exchange_coal_railways
                       may_exchange_mountain_railways],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: { PreStaatsbahn: 2, Coal: 2, Regional: 3 },
            tiles: %i[yellow green],
            status: %w[can_buy_trains may_exchange_coal_railways],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: { PreStaatsbahn: 2, Regional: 3, Staatsbahn: 4 },
            tiles: %i[yellow green brown],
            status: ['can_buy_trains'],
            operating_rounds: 3,
          },
          {
            name: '6',
            on: '6',
            train_limit: { Regional: 2, Staatsbahn: 3 },
            tiles: %i[yellow green brown],
            status: ['can_buy_trains'],
            operating_rounds: 3,
          },
          {
            name: '8',
            on: '8',
            train_limit: { Regional: 2, Staatsbahn: 3 },
            tiles: %i[yellow green brown gray],
            status: ['can_buy_trains'],
            operating_rounds: 3,
          },
          {
            name: '10',
            on: '10',
            train_limit: { Regional: 2, Staatsbahn: 3 },
            tiles: %i[yellow green brown gray],
            status: ['can_buy_trains'],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [{ name: '2', distance: 2, num: 9, price: 80, rusts_on: '4' },
                  {
                    name: '1g',
                    distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                               { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                    num: 6,
                    price: 120,
                    available_on: '2',
                    rusts_on: '3g',
                  },
                  {
                    name: '3',
                    distance: 3,
                    num: 7,
                    price: 180,
                    rusts_on: '6',
                    discount: { '2' => 40 },
                  },
                  {
                    name: '2g',
                    distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                               { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                    num: 5,
                    price: 240,
                    available_on: '3',
                    rusts_on: '4g',
                    discount: { '1g' => 60 },
                  },
                  {
                    name: '4',
                    distance: 4,
                    num: 4,
                    price: 300,
                    rusts_on: '8',
                    events: [{ 'type' => 'close_mountain_railways' }, { 'type' => 'sd_formation' }],
                    discount: { '3' => 90 },
                  },
                  {
                    name: '3g',
                    distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                               { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                    num: 4,
                    price: 360,
                    available_on: '4',
                    rusts_on: '5g',
                    discount: { '2g' => 120 },
                  },
                  {
                    name: '5',
                    distance: 5,
                    num: 3,
                    price: 450,
                    rusts_on: '10',
                    events: [{ 'type' => 'close_coal_railways' }, { 'type' => 'ug_formation' }],
                    discount: { '4' => 140 },
                  },
                  {
                    name: '6',
                    distance: 6,
                    num: 3,
                    price: 630,
                    events: [{ 'type' => 'kk_formation' }],
                    discount: { '5' => 200 },
                  },
                  {
                    name: '4g',
                    distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                               { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                    num: 3,
                    price: 600,
                    available_on: '6',
                    discount: { '3g' => 180 },
                  },
                  { name: '8', distance: 8, num: 3, price: 800, discount: { '6' => 300 } },
                  {
                    name: '5g',
                    distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                               { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                    num: 2,
                    price: 800,
                    available_on: '8',
                    discount: { '4g' => 300 },
                  },
                  { name: '10', distance: 10, num: 20, price: 950, discount: { '8' => 400 } }].freeze

        COMPANIES = [
          {
            sym: 'EPP',
            name: 'C1 Eisenbahn Pilsen - Priesen',
            value: 200,
            interval: [120, 140, 160, 180, 200],
            revenue: 0,
            desc: "Buyer take control of minor Coal Railway EPP (C1), which can be exchanged for the Director's "\
                  'certificate of Regional Railway BK during SRs in phase 3 or 4, or automatically when phase 5 starts. '\
                  'BK floats after exchange as soon as 50% or more are owned by players. This private cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
          {
            sym: 'EOD',
            name: 'C2 Eisenbahn Oderberg - Dombran',
            value: 200,
            interval: [120, 140, 160, 180, 200],
            revenue: 0,
            desc: "Buyer take control of minor Coal Railway EOD (C2), which can be exchanged for the Director's "\
                  'certificate of Regional Railway MS during SRs in phase 3 or 4, or automatically when phase 5 starts. '\
                  'MS floats after exchange as soon as 50% or more are owned by players. This private cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
          {
            sym: 'MLB',
            name: 'C3 Mosty - Lemberg Bahn',
            value: 200,
            interval: [120, 140, 160, 180, 200],
            revenue: 0,
            desc: "Buyer take control of minor Coal Railway MLB (C3), which can be exchanged for the Director's "\
                  'certificate of Regional Railway CL during SRs in phase 3 or 4, or automatically when phase 5 starts. '\
                  'CL floats after exchange as soon as 50% or more are owned by players. This private cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
          {
            sym: 'SPB',
            name: 'C4 Simeria-Petrosani Bahn',
            value: 200,
            interval: [120, 140, 160, 180, 200],
            revenue: 0,
            desc: "Buyer take control of minor Coal Railway SPB (C4), which can be exchanged for the Director's "\
                  'certificate of Regional Railway SB during SRs in phase 3 or 4, or automatically when phase 5 starts. '\
                  'SB floats after exchange as soon as 50% or more are owned by players. This private cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
          {
            sym: 'S1',
            name: 'S1 Wien-Gloggnitzer Eisenbahngesellschaft',
            value: 240,
            revenue: 0,
            desc: "Buyer take control of pre-staatsbahn S1, which will be exchanged for the Director's certificate "\
                  'of SD when the first 4 train is sold. Pre-Staatsbahnen starts in Wien (E12). Cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
          {
            sym: 'S2',
            name: 'S2 Kärntner Bahn',
            value: 120,
            revenue: 0,
            desc: 'Buyer take control of pre-staatsbahn S2, which will be exchanged for a 10% share of SD when the '\
                  'first 4 train is sold. Pre-Staatsbahnen starts in Graz (G10). Cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
          {
            sym: 'S3',
            name: 'S3 Nordtiroler Staatsbahn',
            value: 120,
            revenue: 0,
            desc: 'Buyer take control of pre-staatsbahn S3, which will be exchanged for a 10% share of SD when the '\
                  'first 4 train is sold. Pre-Staatsbahnen starts in Innsbruck (G4). Cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
          {
            sym: 'U1',
            name: 'U1 Eisenbahn Pest - Waitzen',
            value: 240,
            revenue: 0,
            desc: "Buyer take control of pre-staatsbahn U1, which will be exchanged for the Director's certificate "\
                  'of UG when the first 5 train is sold. Pre-Staatsbahnen starts in Pest (F17) in base 1824 and in '\
                  'Budapest (G12) for 3 players on the Cislethania map. Cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
          {
            sym: 'U2',
            name: 'U2 Mohacs-Fünfkirchner Bahn',
            value: 120,
            revenue: 0,
            desc: 'Buyer take control of pre-staatsbahn U2, which will be exchanged for a 10% share of UG when the '\
                  'first 5 train is sold. Pre-Staatsbahnen starts in Fünfkirchen (H15). Cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
          {
            sym: 'K1',
            name: 'K1 Kaiserin Elisabeth-Bahn',
            value: 240,
            revenue: 0,
            desc: "Buyer take control of pre-staatsbahn K1, which will be exchanged for the Director's certificate "\
                  'of KK when the first 6 train is sold. Pre-Staatsbahnen starts in Wien (E12). Cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
          {
            sym: 'K2',
            name: 'K2 Kaiser Franz Joseph-Bahn',
            value: 120,
            revenue: 0,
            desc: 'Buyer take control of pre-staatsbahn K2, which will be exchanged for a 10% share of KK when the '\
                  'first 6 train is sold. Pre-Staatsbahnen starts in Wien (E12). Cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 50,
            name: 'Böhmische Kommerzbahn',
            sym: 'BK',
            type: 'Regional',
            tokens: [0, 40, 60, 80],
            logo: '1824/BK',
            simple_logo: '1824/BK.alt',
            color: :blue,
            coordinates: 'B9',
            reservation_color: nil,
          },
          {
            name: 'Mährisch-Schlesische Eisenbahn',
            sym: 'MS',
            type: 'Regional',
            float_percent: 50,
            tokens: [0, 40, 60, 80],
            logo: '1824/MS',
            simple_logo: '1824/MS.alt',
            color: :yellow,
            text_color: 'black',
            coordinates: 'C12',
            reservation_color: nil,
          },
          {
            name: 'Carl Ludwigs-Bahn',
            sym: 'CL',
            type: 'Regional',
            float_percent: 50,
            tokens: [0, 40, 60, 80],
            color: '#B3B3B3',
            logo: '1824/CL',
            simple_logo: '1824/CL.alt',
            coordinates: 'B23',
            reservation_color: nil,
          },
          {
            name: 'Siebenbürgische Bahn',
            sym: 'SB',
            type: 'Regional',
            float_percent: 50,
            tokens: [0, 40, 60, 80],
            logo: '1824/SB',
            simple_logo: '1824/SB.alt',
            color: :green,
            text_color: 'black',
            coordinates: 'G26',
            reservation_color: nil,
          },
          {
            name: 'Bosnisch-Herzegowinische Landesbahn',
            sym: 'BH',
            type: 'Regional',
            float_percent: 50,
            tokens: [0, 40, 100],
            logo: '1824/BH',
            simple_logo: '1824/BH.alt',
            color: :red,
            coordinates: 'J13',
            reservation_color: nil,
          },
          {
            name: 'Südbahn',
            sym: 'SD',
            type: 'Staatsbahn',
            float_percent: 10,
            tokens: [100, 100],
            abilities: [
              {
                type: 'no_buy',
                description: 'Unavailable in SR before phase 4',
              },
            ],
            logo: '1824/SD',
            simple_logo: '1824/SD.alt',
            color: :orange,
            text_color: 'black',
            reservation_color: nil,
          },
          {
            name: 'Ungarische Staatsbahn',
            sym: 'UG',
            type: 'Staatsbahn',
            float_percent: 10,
            tokens: [100, 100, 100],
            abilities: [
              {
                type: 'no_buy',
                description: 'Unavailable in SR before phase 5',
              },
            ],
            logo: '1824/UG',
            simple_logo: '1824/UG.alt',
            color: :purple,
            reservation_color: nil,
          },
          {
            name: 'k&k Staatsbahn',
            sym: 'KK',
            type: 'Staatsbahn',
            float_percent: 10,
            tokens: [40, 100, 100, 100],
            abilities: [
              {
                type: 'no_buy',
                description: 'Unavailable in SR before phase 6',
              },
            ],
            logo: '1824/KK',
            simple_logo: '1824/KK.alt',
            color: :brown,
            reservation_color: nil,
          },
        ].freeze

        MINORS = [
          {
            sym: 'EPP',
            name: 'C1 Eisenbahn Pilsen - Priesen',
            type: 'Coal',
            tokens: [0],
            logo: '1824/C1',
            coordinates: 'C6',
            city: 0,
            color: '#7F7F7F',
          },
          {
            sym: 'EOD',
            name: 'C2 Eisenbahn Oderberg - Dombran',
            type: 'Coal',
            tokens: [0],
            logo: '1824/C2',
            coordinates: 'A12',
            city: 0,
            color: '#7F7F7F',
          },
          {
            float_percent: 100,
            sym: 'MLB',
            name: 'C3 Mosty - Lemberg Bahn',
            type: 'Coal',
            tokens: [0],
            logo: '1824/C3',
            coordinates: 'A22',
            city: 0,
            color: '#7F7F7F',
          },
          {
            sym: 'SPB',
            name: 'C4 Simeria-Petrosani Bahn',
            type: 'Coal',
            tokens: [0],
            logo: '1824/C4',
            coordinates: 'H25',
            city: 0,
            color: '#7F7F7F',
          },
          {
            sym: 'S1',
            name: 'S1 Wien-Gloggnitzer Eisenbahngesellschaft',
            type: 'PreStaatsbahn',
            tokens: [0],
            logo: '1824/S1',
            coordinates: 'E12',
            city: 0,
            color: :orange,
          },
          {
            sym: 'S2',
            name: 'S2 Kärntner Bahn',
            type: 'PreStaatsbahn',
            tokens: [0],
            logo: '1824/S2',
            coordinates: 'G10',
            city: 0,
            color: :orange,
          },
          {
            sym: 'S3',
            name: 'S3 Nordtiroler Staatsbahn',
            type: 'PreStaatsbahn',
            tokens: [0],
            logo: '1824/S3',
            coordinates: 'G4',
            city: 0,
            color: :orange,
          },
          {
            sym: 'U1',
            name: 'U1 Eisenbahn Pest - Waitzen',
            type: 'PreStaatsbahn',
            tokens: [0],
            logo: '1824/U1',
            coordinates: 'F17',
            city: 1,
            color: :purple,
          },
          {
            sym: 'U2',
            name: 'U2 Mohacs-Fünfkirchner Bahn',
            type: 'PreStaatsbahn',
            tokens: [0],
            logo: '1824/U2',
            coordinates: 'H15',
            city: 0,
            color: :purple,
          },
          {
            sym: 'K1',
            name: 'K1 Kaiserin Elisabeth-Bahn',
            type: 'PreStaatsbahn',
            tokens: [0],
            coordinates: 'E12',
            city: 1,
            color: :brown,
            logo: '1824/K1',
          },
          {
            sym: 'K2',
            name: 'K2 Kaiser Franz Joseph-Bahn',
            type: 'PreStaatsbahn',
            tokens: [0],
            logo: '1824/K2',
            coordinates: 'E12',
            city: 2,
            color: :brown,
          },
        ].freeze

        LAYOUT = :pointy

        AXES = { x: :number, y: :letter }.freeze

        GAME_END_CHECK = { bank: :full_or }.freeze

        # Move down one step for a whole block, not per share
        SELL_MOVEMENT = :down_block

        # Cannot sell until operated
        SELL_AFTER = :operate

        # Sell zero or more, then Buy zero or one
        SELL_BUY_ORDER = :sell_buy

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'close_mountain_railways' => ['Mountain railways closed', 'Any still open Montain railways are exchanged'],
          'sd_formation' => ['SD formation', 'The Suedbahn is founded at the end of the OR'],
          'close_coal_railways' => ['Coal railways closed', 'Any still open Coal railways are exchanged'],
          'ug_formation' => ['UG formation', 'The Ungarische Staatsbahn is founded at the end of the OR'],
          'kk_formation' => ['k&k formation', 'k&k Staatsbahn is founded at the end of the OR']
        ).freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'can_buy_trains' => ['Can Buy trains', 'Can buy trains from other corporations'],
          'may_exchange_coal_railways' => ['Coal Railway exchange', 'May exchange Coal Railways during SR'],
          'may_exchange_mountain_railways' => ['Mountain Railway exchange', 'May exchange Mountain Railways during SR']
        ).freeze

        CERT_LIMIT_CISLEITHANIA = { 2 => 14, 3 => 16 }.freeze

        BANK_CASH_CISLEITHANIA = { 2 => 4000, 3 => 9000 }.freeze

        CASH_CISLEITHANIA = { 2 => 830, 3 => 680 }.freeze

        MOUNTAIN_RAILWAY_NAMES = {
          1 => 'Semmeringbahn',
          2 => 'Kastbahn',
          3 => 'Brennerbahn',
          4 => 'Arlbergbahn',
          5 => 'Karawankenbahn',
          6 => 'Wocheinerbahn',
        }.freeze

        MINE_HEX_NAMES = %w[C6 A12 A22 H25].freeze
        MINE_HEX_NAMES_CISLEITHANIA = %w[C6 A12 A22 H25].freeze

        def init_optional_rules(optional_rules)
          opt_rules = super

          # 2 player variant always use the Cisleithania map
          opt_rules << :cisleithania if two_player? && !opt_rules.include?(:cisleithania)

          # Good Time variant is not applicable if Cisleithania is used
          opt_rules -= [:goods_time] if opt_rules.include?(:cisleithania)

          opt_rules
        end

        def init_bank
          return super unless option_cisleithania

          Engine::Bank.new(BANK_CASH_CISLEITHANIA[@players.size], log: @log)
        end

        def init_starting_cash(players, bank)
          return super unless option_cisleithania

          players.each do |player|
            bank.spend(CASH_CISLEITHANIA[@players.size], player)
          end
        end

        def init_train_handler
          trains = self.class::TRAINS.flat_map do |train|
            Array.new((train[:num] || num_trains(train))) do |index|
              Train.new(**train, index: index)
            end
          end

          G1824::Depot.new(trains, self)
        end

        def init_corporations(stock_market)
          corporations = CORPORATIONS.dup

          corporations.map! do |corporation|
            G1824::Corporation.new(
              min_price: stock_market.par_prices.map(&:price).min,
              capitalization: self.class::CAPITALIZATION,
              **corporation.merge(corporation_opts),
            )
          end

          if option_cisleithania
            # Some corporations need to be removed, but they need to exists (for implementation reasons)
            # So set them as closed and removed so that they do not appear
            # Affected: Coal Railway C4 (SPB), Regional Railway BH and SB, and possibly UG
            corporations.each do |c|
              if %w[SB BH].include?(c.name) || (two_player? && c.name == 'UG')
                c.close!
                c.removed = true
              end
            end
          end

          corporations
        end

        def init_minors
          minors = MINORS.dup

          if option_cisleithania
            if two_player?
              # Remove Pre-Staatsbahn U1 and U2, and minor SPB
              minors.reject! { |m| %w[U1 U2 SPB].include?(m[:sym]) }
            else
              # Remove Pre-Staatsbahn U2, minor SPB, and move home location for U1
              minors.reject! { |m| %w[U2 SPB].include?(m[:sym]) }
              minors.map! do |m|
                next m unless m['sym'] == 'U1'

                m['coordinates'] = 'G12'
                m['city'] = 0
                m
              end
            end
          end

          minors.map { |minor| G1824::Minor.new(**minor) }
        end

        def init_companies(players)
          companies = COMPANIES.dup

          mountain_railway_count =
            case players.size
            when 2
              2
            when 3
              option_cisleithania ? 3 : 4
            when 4, 5
              6
            when 6
              4
            end
          mountain_railway_count.times { |index| companies << mountain_railway_definition(index) }

          if option_cisleithania
            # Remove Pre-Staatsbahn U2 and possibly U1
            p2 = players.size == 2
            companies.reject! { |m| m['sym'] == 'U2' || (p2 && m['sym'] == 'U1') }
          end

          companies.map { |company| Company.new(**company) }
        end

        def init_tiles
          tiles = TILES.dup

          if option_goods_time
            # Goods Time increase count for some town related tiles
            tiles['3'] += 3
            tiles['4'] += 3
            tiles['56'] += 1
            tiles['58'] += 3
            tiles['87'] += 2
            tiles['630'] += 1
            tiles['631'] += 1

            # New tile for Goods Time variant
            tiles['204'] = 3
          end

          tiles.flat_map do |name, val|
            init_tile(name, val)
          end
        end

        def option_cisleithania
          @optional_rules&.include?(:cisleithania)
        end

        def option_goods_time
          @optional_rules&.include?(:goods_time)
        end

        def location_name(coord)
          return super unless option_cisleithania

          unless @location_names
            @location_names = LOCATION_NAMES.dup
            @location_names['F25'] = 'Kronstadt'
            @location_names['G12'] = 'Budapest'
            @location_names['I10'] = 'Bosnien'
          end
          @location_names[coord]
        end

        def optional_hexes
          option_cisleithania ? cisleithania_map : base_map
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::DiscardTrain,
            Engine::Step::HomeToken,
            G1824::Step::ForcedMountainRailwayExchange,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G1824::Step::Dividend,
            G1824::Step::BuyTrain,
          ], round_num: round_num)
        end

        def init_round
          @log << '-- First Stock Round --'
          @log << 'Player order is reversed the first turn'
          G1824::Round::FirstStock.new(self, [
            G1824::Step::BuySellParSharesFirstSr,
          ])
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G1824::Step::BuySellParExchangeShares,
          ])
        end

        def or_set_finished
          depot.export!
        end

        def coal_c1
          @c1 ||= minor_by_id('EPP')
        end

        def coal_c2
          @c2 ||= minor_by_id('EOD')
        end

        def coal_c3
          @c3 ||= minor_by_id('MLB')
        end

        def coal_c4
          @c4 ||= minor_by_id('SPB')
        end

        def regional_bk
          @bk ||= corporation_by_id('BK')
        end

        def regional_ms
          @ms ||= corporation_by_id('MS')
        end

        def regional_cl
          @cl ||= corporation_by_id('CL')
        end

        def regional_sb
          @sb ||= corporation_by_id('SB')
        end

        def state_sd
          @sd ||= corporation_by_id('SD')
        end

        def state_ug
          @ug ||= corporation_by_id('UG')
        end

        def state_kk
          @kk ||= corporation_by_id('KK')
        end

        def setup
          @two_train_bought = false
          @forced_mountain_railway_exchange = []

          @companies.each do |c|
            c.owner = @bank
            @bank.companies << c
          end

          @minors.each do |minor|
            hex = hex_by_id(minor.coordinates)
            hex.tile.cities[minor.city].place_token(minor, minor.next_token)
          end

          # Reserve the presidency share to have it as exchange for associated coal railway
          @corporations.each do |c|
            next if !regional?(c) && !staatsbahn?(c)
            next if c.id == 'BH'

            c.shares.find(&:president).buyable = false
            c.floatable = false
          end
        end

        def timeline
          @timeline ||= ['At the end of each OR set, the cheapest train in bank is exported.'].freeze
        end

        def status_str(entity)
          if coal_railway?(entity)
            'Coal Railway - may only own g trains'
          elsif pre_staatsbahn?(entity)
            'Pre-Staatsbahn'
          elsif staatsbahn?(entity)
            'Staatsbahn'
          elsif regional?(entity)
            str = 'Regional Railway'
            if (coal = associated_coal_railway(entity)) && !coal.closed?
              str += " - Presidency reserved (#{coal.name})"
            end
            str
          end
        end

        def can_par?(corporation, parrer)
          super && buyable?(corporation) && !reserved_regional(corporation)
        end

        def g_train?(train)
          train.name.end_with?('g')
        end

        def mountain_railway?(entity)
          entity.company? && entity.sym.start_with?('B')
        end

        def mountain_railway_exchangable?
          @phase.status.include?('may_exchange_mountain_railways')
        end

        def coal_railway?(entity)
          return entity.type == :Coal if entity.minor?

          entity.company? && associated_regional_railway(entity)
        end

        def coal_railway_exchangable?
          @phase.status.include?('may_exchange_coal_railways')
        end

        def pre_staatsbahn?(entity)
          entity.minor? && entity.type == :PreStaatsbahn
        end

        def regional?(entity)
          entity.corporation? && entity.type == :Regional
        end

        def staatsbahn?(entity)
          entity.corporation? && entity.type == :Staatsbahn
        end

        def reserved_regional(entity)
          return false unless regional?(entity)

          president_share = entity.shares.find(&:president)
          president_share && !president_share.buyable
        end

        def buyable?(entity)
          return true unless entity.corporation?

          entity.all_abilities.none? { |a| a.type == :no_buy }
        end

        def corporation_available?(entity)
          buyable?(entity)
        end

        def entity_can_use_company?(_entity, _company)
          # Return false here so that Exchange abilities does not appear in GUI
          false
        end

        def sorted_corporations
          sorted_corporations = super
          return sorted_corporations unless @turn == 1

          # Remove unbuyable stuff in SR 1 to reduce information
          sorted_corporations.select { |c| buyable?(c) }
        end

        def associated_regional_railway(coal_railway)
          key = coal_railway.minor? ? coal_railway.name : coal_railway.id
          case key
          when 'EPP'
            regional_bk
          when 'EOD'
            regional_ms
          when 'MLB'
            regional_cl
          when 'SPB'
            regional_sb
          end
        end

        def associated_coal_railway(regional_railway)
          case regional_railway.name
          when 'BK'
            coal_c1
          when 'MS'
            coal_c2
          when 'CL'
            coal_c3
          when 'SB'
            coal_c4
          end
        end

        def associated_state_railway(prestate_railway)
          case prestate_railway.id
          when 'S1', 'S2', 'S3'
            state_sd
          when 'U1', 'U2'
            state_ug
          when 'K1', 'K2'
            state_kk
          end
        end

        def revenue_for(route, stops)
          # Ensure only g-trains visit mines, and that g-trains visit exactly one mine
          mine_visits = route.hexes.count { |h| mine_hex?(h) }

          raise GameError, 'Exactly one mine need to be visited' if g_train?(route.train) && mine_visits != 1
          raise GameError, 'Only g-trains may visit mines' if !g_train?(route.train) && mine_visits.positive?

          super
        end

        def mine_revenue(routes)
          routes.sum { |r| r.stops.sum { |stop| mine_hex?(stop.hex) ? stop.route_revenue(r.phase, r.train) : 0 } }
        end

        def float_str(entity)
          return super if !entity.corporation || entity.floatable

          case entity.id
          when 'BK', 'MS', 'CL', 'SB'
            needed = entity.percent_to_float
            needed.positive? ? "#{entity.percent_to_float}% (including exchange) to float" : 'Exchange to float'
          when 'UG'
            'U1 exchange floats'
          when 'KK'
            'K1 exchange floats'
          when 'SD'
            'S1 exchange floats'
          else
            'Not floatable'
          end
        end

        def all_corporations
          @corporations.reject(&:removed)
        end

        def event_close_mountain_railways!
          @log << '-- Any remaining Mountain Railways are either exchanged or discarded'
          # If this list contains any companies it will trigger an interrupt exchange/pass step
          @forced_mountain_railway_exchange = @companies.select { |c| mountain_railway?(c) && !c.closed? }
        end

        def event_close_coal_railways!
          @log << '-- Exchange any remaining Coal Railway'
          @companies.select { |c| coal_railway?(c) }.reject(&:closed?).each do |coal_railway_company|
            exchange_coal_railway(coal_railway_company)
          end
        end

        def event_sd_formation!
          @log << 'SD formation not yet implemented'
        end

        def event_ug_formation!
          @log << 'UG formation not yet implemented'
        end

        def event_kk_formation!
          @log << 'KK formation not yet implemented'
        end

        def exchange_coal_railway(company)
          player = company.owner
          minor = minor_by_id(company.id)
          regional = associated_regional_railway(company)

          @log << "#{player.name} receives presidency of #{regional.name} in exchange for #{minor.name}"
          company.close!

          # Transfer Coal Railway cash and trains to Regional. Remove CR token.
          if minor.cash.positive?
            @log << "#{regional.name} receives the #{minor.name} treasury of #{format_currency(minor.cash)}"
            minor.spend(minor.cash, regional)
          end
          unless minor.trains.empty?
            transferred = transfer(:trains, minor, regional)
            @log << "#{regional.name} receives the trains: #{transferred.map(&:name).join(', ')}"
          end
          minor.tokens.first.remove!
          minor.close!

          # Handle Regional presidency, possibly transfering to another player in case they own more in the regional
          presidency_share = regional.shares.find(&:president)
          presidency_share.buyable = true
          regional.floatable = true
          @share_pool.transfer_shares(
            presidency_share.to_bundle,
            player,
            allow_president_change: false,
            price: 0
          )

          # Give presidency to majority owner (with minor owner priority if that player is one of them)
          max_shares = @share_pool.presidency_check_shares(regional).values.max
          majority_share_holders = @share_pool.presidency_check_shares(regional).select { |_, p| p == max_shares }.keys
          if !majority_share_holders.find { |owner| owner == player }
            # FIXME: Handle the case where multiple share the presidency criteria
            new_president = majority_share_holders.first
            @share_pool.change_president(presidency_share, player, new_president, player)
            regional.owner = new_president
            @log << "#{new_president.name} becomes president of #{regional.name} as majority owner"
          else
            regional.owner = player
          end

          float_corporation(regional) if regional.floated?
          regional
        end

        def float_corporation(corporation)
          @log << "#{corporation.name} floats"

          return if corporation.capitalization == :incremental

          floating_capital = case corporation.name
                             when 'BK', 'MS', 'CL', 'SB'
                               corporation.par_price.price * 8
                             else
                               corporation.par_price.price * corporation.total_shares
                             end

          @bank.spend(floating_capital, corporation)
          @log << "#{corporation.name} receives floating capital of #{format_currency(floating_capital)}"
        end

        private

        def mine_hex?(hex)
          option_cisleithania ? MINE_HEX_NAMES_CISLEITHANIA.include?(hex.name) : MINE_HEX_NAMES.include?(hex.name)
        end

        MOUNTAIN_RAILWAY_DEFINITION = {
          sym: 'B%1$d',
          name: 'B%1$d %2$s',
          value: 120,
          revenue: 25,
          desc: 'Moutain railway (B%1$d). Cannot be sold but can be exchanged for a 10 percent share in a '\
                'regional railway during phase 3 SR, or when first 4 train is bought. '\
                'If no regional railway shares are available from IPO this private is lost without compensation.',
          abilities: [
            {
              type: 'no_buy',
              owner_type: 'player',
            },
            {
              type: 'exchange',
              corporations: %w[BK MS CL SB BH],
              owner_type: 'player',
              from: %w[ipo market],
            },
          ],
        }.freeze

        def mountain_railway_definition(index)
          real_index = index + 1
          definition = MOUNTAIN_RAILWAY_DEFINITION.dup
          definition[:sym] = format(definition[:sym], real_index)
          definition[:name] = format(definition[:name], real_index, MOUNTAIN_RAILWAY_NAMES[real_index])
          definition[:desc] = format(definition[:desc], real_index)
          definition
        end

        DRESDEN_1 = 'offboard=revenue:yellow_10|green_20|brown_30|gray_40,hide:1,groups:Dresden;'\
                    'path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1'
        DRESDEN_2 = 'offboard=revenue:yellow_10|green_20|brown_30|gray_40,groups:Dresden;'\
                    'path=a:4,b:_0,terminal:1'
        KIEW_1 = 'offboard=revenue:yellow_10|green_30|brown_40|gray_50,hide:1,groups:Kiew;'\
                 'path=a:0,b:_0,terminal:1;path=a:5,b:_0,terminal:1'
        KIEW_2 = 'offboard=revenue:yellow_10|green_30|brown_40|gray_50,groups:Kiew;'\
                 'path=a:0,b:_0,terminal:1'
        MAINLAND_1 = 'offboard=revenue:yellow_10|green_30|brown_50|gray_70,hide:1,groups:Mainland;'\
                     'path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1'
        MAINLAND_2 = 'offboard=revenue:yellow_10|green_30|brown_50|gray_70,groups:Mainland;path=a:3,b:_0,terminal:1'
        BUKAREST_1 = 'offboard=revenue:yellow_10|green_30|brown_40|gray_50,hide:1,groups:Bukarest;'\
                     'path=a:1,b:_0,terminal:1'
        BUKAREST_2 = 'offboard=revenue:yellow_10|green_30|brown_40|gray_50,groups:Bukarest;path=a:2,b:_0,terminal:1'
        SARAJEVO = 'city=revenue:yellow_10|green_10|brown_50|gray_50;'\
                   'path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1;'\
                   'path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1'
        SARAJEVO_W = 'path=a:2,b:5;path=a:3,b:4'
        SARAJEVO_E = 'path=a:0,b:3;path=a:1,b:2'
        SARAJEVO_S = 'path=a:2,b:3'
        WIEN = 'city=revenue:30;path=a:0,b:_0;city=revenue:30;'\
               'path=a:1,b:_1;city=revenue:30;path=a:2,b:_2;upgrade=cost:20,terrain:water;label=W'

        MINE_1 = 'city=revenue:yellow_10|green_10|brown_40|gray_40;path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1'
        MINE_2 = 'city=revenue:yellow_10|green_10|brown_40|gray_40;path=a:1,b:_0,terminal:1;path=a:5,b:_0,terminal:1'
        MINE_3 = 'city=revenue:yellow_20|green_20|brown_60|gray_60;path=a:1,b:_0,terminal:1;path=a:5,b:_0,terminal:1'
        MINE_4 = 'city=revenue:yellow_10|green_10|brown_40|gray_40;path=a:1,b:_0,terminal:1;path=a:3,b:_0,terminal:1'

        TOWN = 'town=revenue:0'
        TOWN_WITH_WATER = 'town=revenue:0;upgrade=cost:20,terrain:water'
        TOWN_WITH_MOUNTAIN = 'town=revenue:0;upgrade=cost:40,terrain:mountain'
        DOUBLE_TOWN = 'town=revenue:0;town=revenue:0'
        DOUBLE_TOWN_WITH_WATER = 'town=revenue:0;town=revenue:0;upgrade=cost:20,terrain:water'
        CITY = 'city=revenue:0'
        CITY_WITH_WATER = 'city=revenue:0;upgrade=cost:20,terrain:water'
        CITY_WITH_MOUNTAIN = 'city=revenue:0;upgrade=cost:40,terrain:mountain'
        CITY_LABEL_T = 'city=revenue:0;label=T'
        PLAIN = ''
        PLAIN_WITH_MOUNTAIN = 'upgrade=cost:40,terrain:mountain'
        PLAIN_WITH_WATER = 'upgrade=cost:20,terrain:water'

        def base_map
          plain_hexes = %w[B7 B11 B17 B19 B21 C8 C14 C20 C22 C24 D9 D11 D13 D15 D17 E6 E18 E22
                           F9 F13 F15 F21 F25 G6 G12 G14 G22 G24 H9 H13 H19 H21 I10 I12 I14]
          one_town = %w[A8 A20 C10 C16 D25 E20 E24 F19 G2 G20 H11 I20 I22]
          two_towns = %w[B13 B25 F11 I16]
          if option_goods_time
            # Variant Goods Time transform some plain hexes to town(s) hexes
            added_one_town = %w[B7 C8 C20 C22 H21]
            added_two_towns = %w[F25 G24]
            plain_hexes -= added_one_town
            one_town += added_one_town
            plain_hexes -= added_two_towns
            two_towns += added_two_towns
          end
          {
            red: {
              ['A4'] => DRESDEN_1,
              ['A24'] => KIEW_1,
              ['A26'] => KIEW_2,
              ['B3'] => DRESDEN_2,
              ['G28'] => BUKAREST_1,
              ['H27'] => BUKAREST_2,
              ['H1'] => MAINLAND_1,
              ['I2'] => MAINLAND_2,
              ['J13'] => SARAJEVO,
            },
            gray: {
              ['A12'] => MINE_2,
              ['A22'] => MINE_3,
              ['C6'] => MINE_1,
              ['H25'] => MINE_4,
              ['J11'] => SARAJEVO_W,
              ['J15'] => SARAJEVO_E,
              %w[K12 ̈́K14] => SARAJEVO_S,
            },
            white: {
              one_town => TOWN,
              %w[A6 A10] => TOWN_WITH_MOUNTAIN,
              two_towns => DOUBLE_TOWN,
              %w[D19 H3] => CITY_WITH_MOUNTAIN,
              %w[A18 C26 E26 I8] => CITY_LABEL_T,
              %w[B5 B9 B15 B23 C12 E8 F7 F23 G4 G10 G26 H15 H23] => CITY,
              plain_hexes => PLAIN,
              %w[C18 D21 D23 G8 H5 H7] => PLAIN_WITH_MOUNTAIN,
              %w[E10 G16] => PLAIN_WITH_WATER,
              ['E12'] => WIEN,
              ['F17'] => 'city=revenue:20;path=a:0,b:_0;city=revenue:20;path=a:3,b:_1;upgrade=cost:20,terrain:water;'\
                         'label=Bu',
              %w[E14 G18] => CITY_WITH_WATER,
              %w[H17 I18] => TOWN_WITH_WATER,
              ['E16'] => DOUBLE_TOWN_WITH_WATER,
            },
          }
        end

        def cisleithania_map
          # For 3 players Budapest is a city for Pre-staatsbahn U1
          budapest = @players.size == 3 ? 'city' : 'offboard'
          {
            red: {
              ['A4'] => DRESDEN_1,
              ['A24'] => KIEW_1,
              ['A26'] => KIEW_2,
              ['B3'] => DRESDEN_2,
              ['E14'] =>
                'offboard=revenue:yellow_20|green_30|brown_40|gray_40;path=a:0,b:_0,terminal:1;'\
                'path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1',
              ['G12'] =>
                "#{budapest}=revenue:yellow_20|green_40|brown_60|gray_70;"\
                'path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1',
              ['F25'] =>
                'offboard=revenue:yellow_20|green_30|brown_40|gray_40;path=a:2,b:_0,terminal:1;'\
                'path=a:3,b:_0,terminal:1',
              ['H1'] => MAINLAND_1,
              ['I2'] => MAINLAND_2,
              ['I10'] =>
                'offboard=revenue:yellow_10|green_10|brown_50|gray_50;path=a:1,b:_0,terminal:1;'\
                'path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1',
            },
            gray: {
              ['A12'] => MINE_2,
              ['A22'] => MINE_3,
              ['B17'] => 'path=a:0,b:3;path=a:1,b:4;path=a:1,b:3;path=a:0,b:4',
              ['C6'] => MINE_1,
            },
            white: {
              %w[A8 A20 C10 C16 D25 E24 G2] => TOWN,
              %w[A6 A10] => TOWN_WITH_MOUNTAIN,
              %w[B13 B25 F11] => DOUBLE_TOWN_WITH_WATER,
              %w[H3] => CITY_WITH_MOUNTAIN,
              %w[A18 C26 E26 I8] => CITY_WITH_MOUNTAIN,
              %w[B5 B9 B15 B23 C12 E8 F7 G4 G10] => CITY,
              %w[B7 B11 B19 B21 C8 C14 C20 C22 C24 D9 D11 D13 D15 E6
                 F9 F13 G6 H9 H11] => PLAIN,
              %w[D23 G8 H5 H7] => PLAIN_WITH_MOUNTAIN,
              %w[E10] => PLAIN_WITH_WATER,
              ['E12'] => WIEN,
            },
          }
        end
      end
    end
  end
end
