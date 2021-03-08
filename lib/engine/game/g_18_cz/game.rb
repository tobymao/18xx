# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative '../stubs_are_restricted'

module Engine
  module Game
    module G18CZ
      class Game < Game::Base
        include_meta(G18CZ::Meta)

        register_colors(brightGreen: '#c2ce33',
                        beige: '#e5d19e',
                        lightBlue: '#1EA2D6',
                        mintGreen: '#B1CEC7',
                        yellow: '#ffe600',
                        lightRed: '#F3B1B3')

        CURRENCY_FORMAT_STR = '%d K'

        BANK_CASH = 99_999

        CERT_LIMIT = { 3 => 14, 4 => 12, 5 => 10, 6 => 9 }.freeze

        STARTING_CASH = { 3 => 380, 4 => 300, 5 => 250, 6 => 210 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        TILES = {
          '1' => 1,
          '2' => 1,
          '7' => 5,
          '8' => 14,
          '9' => 13,
          '3' => 4,
          '58' => 4,
          '4' => 4,
          '5' => 4,
          '6' => 4,
          '57' => 4,
          '201' => 2,
          '202' => 2,
          '621' => 2,
          '55' => 1,
          '56' => 1,
          '69' => 1,
          '16' => 1,
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
          '14' => 4,
          '15' => 4,
          '619' => 4,
          '208' => 2,
          '207' => 2,
          '622' => 2,
          '611' => 7,
          '216' => 3,
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 1,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '70' => 1,
          '8885' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:2;path=a:1,b:_1;path=a:_1,b:3;label=OO',
          },
          '8859' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:3;path=a:2,b:_1;path=a:_1,b:5;label=OO',
          },
          '8860' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:_0,b:5;path=a:2,b:_1;path=a:_1,b:4;label=OO',
          },
          '8863' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:1;path=a:2,b:_1;path=a:_1,b:5;label=OO',
          },
          '8864' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:_0,b:5;path=a:2,b:_1;path=a:_1,b:3;label=OO',
          },
          '8865' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:_0,b:5;path=a:3,b:_1;path=a:_1,b:4;label=OO',
          },
          '8889' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' =>
            'city=revenue:30,groups:Praha;city=revenue:30,groups:Praha;city=revenue:30,groups:Praha;path=a:2,b:_0;' \
                  'path=a:3,b:_1;path=a:4,b:_2;label=P',
          },
          '8890' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' =>
            'city=revenue:30,groups:Praha;city=revenue:30,groups:Praha;city=revenue:30,groups:Praha;path=a:0,b:_0;' \
                'path=a:2,b:_1;path=a:4,b:_2;label=P',
          },
          '8891' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40,groups:Praha;city=revenue:40,groups:Praha;city=revenue:40,groups:Praha;' \
                  'city=revenue:40,groups:Praha;path=a:0,b:_0;path=a:2,b:_1;path=a:3,b:_2;path=a:4,b:_3;label=P',
          },
          '8892' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:60,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;' \
                  'path=a:5,b:_0;label=P',
          },
          '8893' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;' \
                  'path=a:5,b:_0;label=P',
          },
          '8894' =>
          {
            'count' => 1,
            'color' => 'red',
            'code' =>
            'city=revenue:green_30|brown_40|gray_50;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;' \
                  'icon=image:18_cz/50;label=Ug',
          },
          '8895' =>
          {
            'count' => 1,
            'color' => 'red',
            'code' =>
            'city=revenue:green_30|brown_40|gray_50;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;' \
                  'icon=image:18_cz/50;label=kk',
          },
          '8896' =>
          {
            'count' => 1,
            'color' => 'red',
            'code' =>
            'city=revenue:green_30|brown_40|gray_50;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;' \
                  'icon=image:18_cz/50;label=SX',
          },
          '8897' =>
          {
            'count' => 1,
            'color' => 'red',
            'code' =>
            'city=revenue:green_30|brown_40|gray_50;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;' \
                  'icon=image:18_cz/50;label=PR',
          },
          '8898' =>
          {
            'count' => 1,
            'color' => 'red',
            'code' =>
            'city=revenue:green_30|brown_40|gray_50;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;' \
                  'icon=image:18_cz/50;label=BY',
          },
          '8866p' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' =>
            'town=revenue:20;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;frame=color:purple',
          },
          '14p' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:30,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;frame=color:purple',
          },
          '887p' =>
          {
            'count' => 4,
            'color' => 'green',
            'code' =>
            'town=revenue:20;path=a:1,b:_0;path=a:3,b:_0;path=a:0,b:_0;path=a:2,b:_0;frame=color:purple',
          },
          '15p' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;frame=color:purple',
          },
          '888p' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' =>
            'town=revenue:20;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;frame=color:purple',
          },
          '889p' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' =>
            'town=revenue:30;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;frame=color:purple',
          },
          '611p' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;' \
                  'frame=color:purple',
          },
          '216p' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Y;' \
                  'frame=color:purple',
          },
          '8894p' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:60,slots:2;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=OO;' \
                  'frame=color:purple',
          },
          '8895p' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:60,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=OO;' \
                  'frame=color:purple',
          },
          '8896p' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:60,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=OO;' \
                  'frame=color:purple',
          },
          '8857p' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;' \
                  'path=a:5,b:_0;label=Y;frame=color:purple',
          },
          '595p' =>
          {
            'count' => 2,
            'color' => 'gray',
            'code' =>
            'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;' \
                  'path=a:5,b:_0;frame=color:purple',
          },
        }.freeze

        LOCATION_NAMES = {
          'G16' => 'Jihlava',
          'D17' => 'Hradec Králové',
          'B11' => 'Děčín',
          'B13' => 'Liberec',
          'C24' => 'Opava',
          'E22' => 'Olomouc',
          'G24' => 'Hulín',
          'G12' => 'Tábor',
          'I12' => 'České Budějovice',
          'F7' => 'Plzeň',
          'E10' => 'Kladno',
          'B9' => 'Teplice & Ústí nad Labem',
          'D27' => 'Frýdlant & Frýdek',
          'C8' => 'Chomutov & Most',
          'E12' => 'Praha',
          'D3' => 'Cheb',
          'D5' => 'Karolvy Vary',
          'E16' => 'Pardubice',
          'C26' => 'Ostrava',
          'F23' => 'Přerov',
          'G20' => 'Brno',
          'I10' => 'Strakonice',
        }.freeze

        MARKET = [
          %w[40
             45
             50p
             53
             55p
             58
             60pP
             63
             65p
             68
             70pP
             75
             80P
             85
             90zP
             95
             100zP
             105
             110z
             115
             120z
             126
             132
             138
             144
             151
             158
             165
             172
             180
             188
             196
             204
             213
             222
             231
             240
             250
             260
             275
             290
             305
             320
             335
             350
             370],
           ].freeze

        PHASES = [
          {
            name: 'a',
            train_limit: { small: 3 },
            tiles: [:yellow],
            corporation_sizes: ['small'],
          },
          {
            name: 'b',
            on: '2b',
            train_limit: { small: 3, medium: 3 },
            tiles: [:yellow],
            status: ['can_buy_companies'],
            corporation_sizes: %w[small medium],
          },
          {
            name: 'c',
            on: '3c',
            train_limit: { small: 3, medium: 3 },
            tiles: [:yellow],
            status: ['can_buy_companies'],
            corporation_sizes: %w[small medium],
          },
          {
            name: 'd',
            on: '3d',
            train_limit: { small: 3, medium: 3, large: 3 },
            tiles: %i[yellow green],
            status: ['can_buy_companies'],
            corporation_sizes: %w[small medium large],
          },
          {
            name: 'e',
            on: '4e',
            train_limit: { small: 2, medium: 3, large: 3 },
            tiles: %i[yellow green],
            status: ['can_buy_companies'],
            corporation_sizes: %w[small medium large],
          },
          {
            name: 'f',
            on: '4f',
            train_limit: { small: 2, medium: 2, large: 3 },
            tiles: %i[yellow green],
            status: ['can_buy_companies'],
            corporation_sizes: %w[small medium large],
          },
          {
            name: 'g',
            on: '5g',
            train_limit: { small: 2, medium: 2, large: 3 },
            tiles: %i[yellow green brown],
            status: ['can_buy_companies'],
            corporation_sizes: %w[small medium large],
          },
          {
            name: 'h',
            on: '5h',
            train_limit: { small: 1, medium: 2, large: 3 },
            tiles: %i[yellow green brown],
            status: ['can_buy_companies'],
            corporation_sizes: %w[small medium large],
          },
          {
            name: 'i',
            on: '5i',
            train_limit: { small: 1, medium: 1, large: 3 },
            tiles: %i[yellow green brown gray],
            status: ['can_buy_companies'],
            corporation_sizes: %w[small medium large],
          },
          {
            name: 'j',
            on: '5j',
            train_limit: { small: 1, medium: 1, large: 2 },
            tiles: %i[yellow green brown gray],
            status: ['can_buy_companies'],
            corporation_sizes: %w[small medium large],
          },
        ].freeze

        TRAINS = [
          {
            name: '2a',
            distance: 2,
            price: 70,
            rusts_on: %w[4e 4f 5g 5h 5i 5j],
            num: 5,
          },
          {
            name: '2b',
            distance: 2,
            price: 70,
            rusts_on: %w[4e 4f 5g 5h 5i 5j],
            num: 4,
            variants: [
              {
                name: '2+2b',
                rusts_on: ['4+4f', '4+4g', '5+5h', '5+5i', '5+5j'],
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                           { 'nodes' => ['town'], 'pay' => 2, 'visit' => 2 }],
                price: 80,
              },
            ],
            events: [{ 'type' => 'medium_corps_available' }],
          },
          {
            name: '3c',
            distance: 3,
            price: 120,
            rusts_on: %w[5g 5h 5i 5j],
            num: 4,
            variants: [
              {
                name: '2+2c',
                rusts_on: ['4+4f', '4+4g', '5+5h', '5+5i', '5+5j'],
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                           { 'nodes' => ['town'], 'pay' => 2, 'visit' => 2 }],
                price: 80,
              },
            ],
          },
          {
            name: '3d',
            distance: 3,
            price: 120,
            rusts_on: %w[5g 5h 5i 5j],
            num: 4,
            variants: [
              {
                name: '3+3d',
                rusts_on: ['5+5h', '5+5i', '5+5j'],
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                           { 'nodes' => ['town'], 'pay' => 3, 'visit' => 3 }],
                price: 180,
              },
              {
                name: '3Ed',
                rusts_on: %w[6E 8E],
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                           { 'nodes' => ['town'], 'pay' => 3, 'visit' => 99 }],
                price: 250,
              },
            ],
            events: [{ 'type' => 'large_corps_available' }],
          },
          {
            name: '4e',
            distance: 4,
            price: 250,
            num: 4,
            variants: [
              {
                name: '3+3e',
                rusts_on: ['5+5h', '5+5i', '5+5j'],
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                           { 'nodes' => ['town'], 'pay' => 3, 'visit' => 3 }],
                price: 180,
              },
              {
                name: '3Ee',
                rusts_on: %w[6E 8E],
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                           { 'nodes' => ['town'], 'pay' => 3, 'visit' => 99 }],
                price: 250,
              },
            ],
          },
          {
            name: '4f',
            distance: 4,
            price: 250,
            num: 4,
            variants: [
              {
                name: '4+4f',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                           { 'nodes' => ['town'], 'pay' => 4, 'visit' => 4 }],
                price: 400,
              },
              {
                name: '4Ef',
                rusts_on: ['8E'],
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                           { 'nodes' => ['town'], 'pay' => 3, 'visit' => 99 }],
                price: 350,
              },
            ],
          },
          {
            name: '5g',
            distance: 5,
            price: 350,
            num: 4,
            variants: [
              {
                name: '4+4g',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                           { 'nodes' => ['town'], 'pay' => 4, 'visit' => 4 }],
                price: 400,
              },
              {
                name: '4Eg',
                rusts_on: ['8E'],
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                           { 'nodes' => ['town'], 'pay' => 3, 'visit' => 99 }],
                price: 350,
              },
            ],
          },
          {
            name: '5h',
            distance: 5,
            price: 350,
            num: 2,
            variants: [
              {
                name: '5+5h',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                           { 'nodes' => ['town'], 'pay' => 5, 'visit' => 5 }],
                price: 500,
              },
              {
                name: '5E',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                           { 'nodes' => ['town'], 'pay' => 3, 'visit' => 99 }],
                price: 700,
              },
            ],
          },
          {
            name: '5i',
            distance: 5,
            price: 350,
            num: 2,
            variants: [
              {
                name: '5+5i',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                           { 'nodes' => ['town'], 'pay' => 5, 'visit' => 5 }],
                price: 500,
              },
              {
                name: '6E',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                           { 'nodes' => ['town'], 'pay' => 3, 'visit' => 99 }],
                price: 800,
              },
            ],
          },
          {
            name: '5j',
            distance: 5,
            price: 350,
            num: 30,
            variants: [
              {
                name: '5+5j',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                           { 'nodes' => ['town'], 'pay' => 5, 'visit' => 5 }],
                price: 500,
              },
              {
                name: '8E',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 8, 'visit' => 8 },
                           { 'nodes' => ['town'], 'pay' => 3, 'visit' => 99 }],
                price: 1000,
              },
            ],
          },
        ].freeze

        COMPANIES = [
          {
            name: 'Small #1',
            value: 25,
            revenue: 5,
            sym: 'S1',
            desc: 'May either ignore the cost to build a river tile or ' \
                   'lay a purple-edged green upgrade to town/city hexes',
            abilities: [
            {
              type: 'tile_lay',
              count: 1,
              owner_type: 'corporation',
              tiles: %w[14p 15p 887p 888p 8866p],
              when: 'owning_corp_or_turn',
              hexes: [],
              reachable: true,
              special: false,
            },
            {
              type: 'tile_lay',
              when: 'track',
              owner_type: 'corporation',
              discount: 10,
              hexes: %w[A10
                        B9
                        C10
                        C12
                        C18
                        D11
                        D13
                        D15
                        D17
                        E12
                        E16
                        F11
                        G10
                        H11],
              reachable: true,
              tiles: %w[3
                        4
                        5
                        6
                        7
                        8
                        9
                        57
                        58
                        8889
                        8890
                        8859
                        8860
                        8863
                        8864
                        8865
                        8885],
              count: 1,
            },
            { type: 'sell_company', when: 'owning_corp_or_turn' },
          ],
            color: nil,
          },
          {
            name: 'Small #2',
            value: 30,
            revenue: 5,
            sym: 'S2',
            desc: 'May either ignore the cost to build a river tile or ' \
                   'lay a purple-edged green upgrade to town/city hexes',
            abilities: [
              {
                type: 'tile_lay',
                count: 1,
                owner_type: 'corporation',
                tiles: %w[14p 15p 887p 888p 8866p],
                when: 'owning_corp_or_turn',
                hexes: [],
                reachable: true,
                special: false,
              },
              {
                type: 'tile_lay',
                when: 'track',
                owner_type: 'corporation',
                discount: 10,
                hexes: %w[A10
                          B9
                          C10
                          C12
                          C18
                          D11
                          D13
                          D15
                          D17
                          E12
                          E16
                          F11
                          G10
                          H11],
                reachable: true,
                tiles: %w[3
                          4
                          5
                          6
                          7
                          8
                          9
                          57
                          58
                          8889
                          8890
                          8859
                          8860
                          8863
                          8864
                          8865
                          8885],
                count: 1,
              },
              { type: 'sell_company', when: 'owning_corp_or_turn' },
            ],
            color: nil,
          },
          {
            name: 'Small #3',
            value: 35,
            revenue: 5,
            sym: 'S3',
            desc: 'May either ignore the cost to build a river tile or ' \
                   'lay a purple-edged green upgrade to town/city hexes',
            abilities: [
              {
                type: 'tile_lay',
                count: 1,
                owner_type: 'corporation',
                tiles: %w[14p 15p 887p 888p 8866p],
                when: 'owning_corp_or_turn',
                hexes: [],
                reachable: true,
                special: false,
              },
              {
                type: 'tile_lay',
                when: 'track',
                owner_type: 'corporation',
                discount: 10,
                hexes: %w[A10
                          B9
                          C10
                          C12
                          C18
                          D11
                          D13
                          D15
                          D17
                          E12
                          E16
                          F11
                          G10
                          H11],
                reachable: true,
                tiles: %w[3
                          4
                          5
                          6
                          7
                          8
                          9
                          57
                          58
                          8889
                          8890
                          8859
                          8860
                          8863
                          8864
                          8865
                          8885],
                count: 1,
              },
              { type: 'sell_company', when: 'owning_corp_or_turn' },
            ],
            color: nil,
          },
          {
            name: 'Small #4',
            value: 40,
            revenue: 5,
            sym: 'S4',
            desc: 'May either ignore the cost to build a river tile or ' \
                   'lay a purple-edged green upgrade to town/city hexes',
            abilities: [
              {
                type: 'tile_lay',
                count: 1,
                owner_type: 'corporation',
                tiles: %w[14p 15p 887p 888p 8866p],
                when: 'owning_corp_or_turn',
                hexes: [],
                reachable: true,
                special: false,
              },
              {
                type: 'tile_lay',
                when: 'track',
                owner_type: 'corporation',
                discount: 10,
                hexes: %w[A10
                          B9
                          C10
                          C12
                          C18
                          D11
                          D13
                          D15
                          D17
                          E12
                          E16
                          F11
                          G10
                          H11],
                reachable: true,
                tiles: %w[3
                          4
                          5
                          6
                          7
                          8
                          9
                          57
                          58
                          8889
                          8890
                          8859
                          8860
                          8863
                          8864
                          8865
                          8885],
                count: 1,
              },
              { type: 'sell_company', when: 'owning_corp_or_turn' },
            ],
            color: nil,
          },
          {
            name: 'Small #5',
            value: 45,
            revenue: 5,
            sym: 'S5',
            desc: 'May either ignore the cost to build a river tile or ' \
                   'lay a purple-edged green upgrade to town/city hexes',
            abilities: [
              {
                type: 'tile_lay',
                count: 1,
                owner_type: 'corporation',
                tiles: %w[14p 15p 887p 888p 8866p],
                when: 'owning_corp_or_turn',
                hexes: [],
                reachable: true,
                special: false,
              },
              {
                type: 'tile_lay',
                when: 'track',
                owner_type: 'corporation',
                discount: 10,
                hexes: %w[A10
                          B9
                          C10
                          C12
                          C18
                          D11
                          D13
                          D15
                          D17
                          E12
                          E16
                          F11
                          G10
                          H11],
                reachable: true,
                tiles: %w[3
                          4
                          5
                          6
                          7
                          8
                          9
                          57
                          58
                          8889
                          8890
                          8859
                          8860
                          8863
                          8864
                          8865
                          8885],
                count: 1,
              },
              { type: 'sell_company', when: 'owning_corp_or_turn' },
            ],
            color: nil,
          },
          {
            name: 'Small #6',
            value: 50,
            revenue: 5,
            sym: 'S6',
            desc: 'May either ignore the cost to build a river tile or ' \
                   'lay a purple-edged green upgrade to town/city hexes',
            abilities: [
              {
                type: 'tile_lay',
                count: 1,
                owner_type: 'corporation',
                tiles: %w[14p 15p 887p 888p 8866p],
                when: 'owning_corp_or_turn',
                hexes: [],
                reachable: true,
                special: false,
              },
              {
                type: 'tile_lay',
                when: 'track',
                owner_type: 'corporation',
                discount: 10,
                hexes: %w[A10
                          B9
                          C10
                          C12
                          C18
                          D11
                          D13
                          D15
                          D17
                          E12
                          E16
                          F11
                          G10
                          H11],
                reachable: true,
                tiles: %w[3
                          4
                          5
                          6
                          7
                          8
                          9
                          57
                          58
                          8889
                          8890
                          8859
                          8860
                          8863
                          8864
                          8865
                          8885],
                count: 1,
              },
              { type: 'sell_company', when: 'owning_corp_or_turn' },
            ],
            color: nil,
          },
          {
            name: 'Medium #1',
            value: 40,
            revenue: 10,
            sym: 'M1',
            desc: 'May either ignore the cost to build a river or hill tile or ' \
                  'lay a purple-edged green or brown upgrade to town/city hexes',
            abilities: [
              {
                type: 'tile_lay',
                count: 1,
                owner_type: 'corporation',
                tiles: %w[14p
                          15p
                          887p
                          888p
                          8866p
                          216p
                          611p
                          889p
                          8894p
                          8895p
                          8896p],
                when: 'owning_corp_or_turn',
                hexes: [],
                reachable: true,
                special: false,
              },
              {
                type: 'tile_lay',
                when: 'track',
                owner_type: 'corporation',
                discount: 20,
                hexes: %w[A10
                          A14
                          B9
                          B17
                          C10
                          C12
                          C18
                          D11
                          D13
                          D15
                          D17
                          D29
                          E12
                          E16
                          E28
                          E6
                          F11
                          F27
                          G10
                          G14
                          G16
                          G18
                          H11
                          H15
                          H17
                          H7
                          J11],
                reachable: true,
                tiles: %w[3
                          4
                          7
                          8
                          9
                          58
                          8889
                          8890
                          8859
                          8860
                          8863
                          8864
                          8865
                          8885
                          5
                          6
                          57],
                count: 1,
              },
              { type: 'sell_company', when: 'owning_corp_or_turn' },
            ],
            color: nil,
          },
          {
            name: 'Medium #2',
            value: 45,
            revenue: 10,
            sym: 'M2',
            desc: 'May either ignore the cost to build a river or hill tile or ' \
                  'lay a purple-edged green or brown upgrade to town/city hexes',
            abilities: [
              {
                type: 'tile_lay',
                count: 1,
                owner_type: 'corporation',
                tiles: %w[14p
                          15p
                          887p
                          888p
                          8866p
                          216p
                          611p
                          889p
                          8894p
                          8895p
                          8896p],
                when: 'owning_corp_or_turn',
                hexes: [],
                reachable: true,
                special: false,
              },
              {
                type: 'tile_lay',
                when: 'track',
                owner_type: 'corporation',
                discount: 20,
                hexes: %w[A10
                          A14
                          B9
                          B17
                          C10
                          C12
                          C18
                          D11
                          D13
                          D15
                          D17
                          D29
                          E12
                          E16
                          E28
                          E6
                          F11
                          F27
                          G10
                          G14
                          G16
                          G18
                          H11
                          H15
                          H17
                          H7
                          J11],
                reachable: true,
                tiles: %w[3
                          4
                          7
                          8
                          9
                          58
                          8889
                          8890
                          8859
                          8860
                          8863
                          8864
                          8865
                          8885
                          5
                          6
                          57],
                count: 1,
              },
              { type: 'sell_company', when: 'owning_corp_or_turn' },
            ],
            color: nil,
          },
          {
            name: 'Medium #3',
            value: 50,
            revenue: 10,
            sym: 'M3',
            desc: 'May either ignore the cost to build a river or hill tile or ' \
                  'lay a purple-edged green or brown upgrade to town/city hexes',
            abilities: [
              {
                type: 'tile_lay',
                count: 1,
                owner_type: 'corporation',
                tiles: %w[14p
                          15p
                          887p
                          888p
                          8866p
                          216p
                          611p
                          889p
                          8894p
                          8895p
                          8896p],
                when: 'owning_corp_or_turn',
                hexes: [],
                reachable: true,
                special: false,
              },
              {
                type: 'tile_lay',
                when: 'track',
                owner_type: 'corporation',
                discount: 20,
                hexes: %w[A10
                          A14
                          B9
                          B17
                          C10
                          C12
                          C18
                          D11
                          D13
                          D15
                          D17
                          D29
                          E12
                          E16
                          E28
                          E6
                          F11
                          F27
                          G10
                          G14
                          G16
                          G18
                          H11
                          H15
                          H17
                          H7
                          J11],
                reachable: true,
                tiles: %w[3
                          4
                          7
                          8
                          9
                          58
                          8889
                          8890
                          8859
                          8860
                          8863
                          8864
                          8865
                          8885
                          5
                          6
                          57],
                count: 1,
              },
              { type: 'sell_company', when: 'owning_corp_or_turn' },
            ],
            color: nil,
          },
          {
            name: 'Medium #4',
            value: 55,
            revenue: 10,
            sym: 'M4',
            desc: 'May either ignore the cost to build a river or hill tile or ' \
                  'lay a purple-edged green or brown upgrade to town/city hexes',
            abilities: [
              {
                type: 'tile_lay',
                count: 1,
                owner_type: 'corporation',
                tiles: %w[14p
                          15p
                          887p
                          888p
                          8866p
                          216p
                          611p
                          889p
                          8894p
                          8895p
                          8896p],
                when: 'owning_corp_or_turn',
                hexes: [],
                reachable: true,
                special: false,
              },
              {
                type: 'tile_lay',
                when: 'track',
                owner_type: 'corporation',
                discount: 20,
                hexes: %w[A10
                          A14
                          B9
                          B17
                          C10
                          C12
                          C18
                          D11
                          D13
                          D15
                          D17
                          D29
                          E12
                          E16
                          E28
                          E6
                          F11
                          F27
                          G10
                          G14
                          G16
                          G18
                          H11
                          H15
                          H17
                          H7
                          J11],
                reachable: true,
                tiles: %w[3
                          4
                          7
                          8
                          9
                          58
                          8889
                          8890
                          8859
                          8860
                          8863
                          8864
                          8865
                          8885
                          5
                          6
                          57],
                count: 1,
              },
              { type: 'sell_company', when: 'owning_corp_or_turn' },
            ],
            color: nil,
          },
          {
            name: 'Medium #5',
            value: 60,
            revenue: 10,
            sym: 'M5',
            desc: 'May either ignore the cost to build a river or hill tile or ' \
                  'lay a purple-edged green or brown upgrade to town/city hexes',
            abilities: [
              {
                type: 'tile_lay',
                count: 1,
                owner_type: 'corporation',
                tiles: %w[14p
                          15p
                          887p
                          888p
                          8866p
                          216p
                          611p
                          889p
                          8894p
                          8895p
                          8896p],
                when: 'owning_corp_or_turn',
                hexes: [],
                reachable: true,
                special: false,
              },
              {
                type: 'tile_lay',
                when: 'track',
                owner_type: 'corporation',
                discount: 20,
                hexes: %w[A10
                          A14
                          B9
                          B17
                          C10
                          C12
                          C18
                          D11
                          D13
                          D15
                          D17
                          D29
                          E12
                          E16
                          E28
                          E6
                          F11
                          F27
                          G10
                          G14
                          G16
                          G18
                          H11
                          H15
                          H17
                          H7
                          J11],
                reachable: true,
                tiles: %w[3
                          4
                          7
                          8
                          9
                          58
                          8889
                          8890
                          8859
                          8860
                          8863
                          8864
                          8865
                          8885
                          5
                          6
                          57],
                count: 1,
              },
              { type: 'sell_company', when: 'owning_corp_or_turn' },
            ],
            color: nil,
          },
          {
            name: 'Medium #6',
            value: 65,
            revenue: 10,
            sym: 'M6',
            desc: 'May either ignore the cost to build a river or hill tile or ' \
                  'lay a purple-edged green or brown upgrade to town/city hexes',
            abilities: [
              {
                type: 'tile_lay',
                count: 1,
                owner_type: 'corporation',
                tiles: %w[14p
                          15p
                          887p
                          888p
                          8866p
                          216p
                          611p
                          889p
                          8894p
                          8895p
                          8896p],
                when: 'owning_corp_or_turn',
                hexes: [],
                reachable: true,
                special: false,
              },
              {
                type: 'tile_lay',
                when: 'track',
                owner_type: 'corporation',
                discount: 20,
                hexes: %w[A10
                          A14
                          B9
                          B17
                          C10
                          C12
                          C18
                          D11
                          D13
                          D15
                          D17
                          D29
                          E12
                          E16
                          E28
                          E6
                          F11
                          F27
                          G10
                          G14
                          G16
                          G18
                          H11
                          H15
                          H17
                          H7
                          J11],
                reachable: true,
                tiles: %w[3
                          4
                          7
                          8
                          9
                          58
                          8889
                          8890
                          8859
                          8860
                          8863
                          8864
                          8865
                          8885
                          5
                          6
                          57],
                count: 1,
              },
              { type: 'sell_company', when: 'owning_corp_or_turn' },
            ],
            color: nil,
          },
          {
            name: 'Large #1',
            value: 55,
            revenue: 20,
            sym: 'L1',
            desc: 'May either ignore the cost to build a river, hill or mountain tile or '\
                  'lay a purple-edged green, brown, or gray upgrade to town/city hexes',
            abilities: [
              {
                type: 'tile_lay',
                count: 1,
                owner_type: 'corporation',
                tiles: %w[14p
                          15p
                          887p
                          888p
                          8866p
                          216p
                          611p
                          889p
                          8894p
                          8895p
                          8896p
                          595p
                          8857p],
                when: 'owning_corp_or_turn',
                hexes: [],
                reachable: true,
                special: false,
              },
              {
                type: 'tile_lay',
                when: 'track',
                owner_type: 'corporation',
                discount: 40,
                hexes: %w[A10
                          A14
                          A16
                          B7
                          B9
                          B17
                          B21
                          C10
                          C12
                          C18
                          C22
                          C4
                          C6
                          D11
                          D13
                          D15
                          D17
                          D29
                          E12
                          E16
                          E28
                          E6
                          F11
                          F27
                          G10
                          G14
                          G16
                          G18
                          H11
                          H15
                          H17
                          H7
                          I8
                          J11],
                reachable: true,
                tiles: %w[3
                          4
                          7
                          8
                          9
                          58
                          8889
                          8890
                          8859
                          8860
                          8863
                          8864
                          8865
                          8885
                          5
                          6
                          57],
                count: 1,
              },
              { type: 'sell_company', when: 'owning_corp_or_turn' },
            ],
            color: nil,
          },
          {
            name: 'Large #2',
            value: 60,
            revenue: 20,
            sym: 'L2',
            desc: 'May either ignore the cost to build a river, hill or mountain tile or '\
                  'lay a purple-edged green, brown, or gray upgrade to town/city hexes',
            abilities: [
              {
                type: 'tile_lay',
                count: 1,
                owner_type: 'corporation',
                tiles: %w[14p
                          15p
                          887p
                          888p
                          8866p
                          216p
                          611p
                          889p
                          8894p
                          8895p
                          8896p
                          595p
                          8857p],
                when: 'owning_corp_or_turn',
                hexes: [],
                reachable: true,
                special: false,
              },
              {
                type: 'tile_lay',
                when: 'track',
                owner_type: 'corporation',
                discount: 40,
                hexes: %w[A10
                          A14
                          A16
                          B7
                          B9
                          B17
                          B21
                          C10
                          C12
                          C18
                          C22
                          C4
                          C6
                          D11
                          D13
                          D15
                          D17
                          D29
                          E12
                          E16
                          E28
                          E6
                          F11
                          F27
                          G10
                          G14
                          G16
                          G18
                          H11
                          H15
                          H17
                          H7
                          I8
                          J11],
                reachable: true,
                tiles: %w[3
                          4
                          7
                          8
                          9
                          58
                          8889
                          8890
                          8859
                          8860
                          8863
                          8864
                          8865
                          8885
                          5
                          6
                          57],
                count: 1,
              },
              { type: 'sell_company', when: 'owning_corp_or_turn' },
            ],
            color: nil,
          },
          {
            name: 'Large #3',
            value: 65,
            revenue: 20,
            sym: 'L3',
            desc: 'May either ignore the cost to build a river, hill or mountain tile or '\
                  'lay a purple-edged green, brown, or gray upgrade to town/city hexes',
            abilities: [
              {
                type: 'tile_lay',
                count: 1,
                owner_type: 'corporation',
                tiles: %w[14p
                          15p
                          887p
                          888p
                          8866p
                          216p
                          611p
                          889p
                          8894p
                          8895p
                          8896p
                          595p
                          8857p],
                when: 'owning_corp_or_turn',
                hexes: [],
                reachable: true,
                special: false,
              },
              {
                type: 'tile_lay',
                when: 'track',
                owner_type: 'corporation',
                discount: 40,
                hexes: %w[A10
                          A14
                          A16
                          B7
                          B9
                          B17
                          B21
                          C10
                          C12
                          C18
                          C22
                          C4
                          C6
                          D11
                          D13
                          D15
                          D17
                          D29
                          E12
                          E16
                          E28
                          E6
                          F11
                          F27
                          G10
                          G14
                          G16
                          G18
                          H11
                          H15
                          H17
                          H7
                          I8
                          J11],
                reachable: true,
                tiles: %w[3
                          4
                          7
                          8
                          9
                          58
                          8889
                          8890
                          8859
                          8860
                          8863
                          8864
                          8865
                          8885
                          5
                          6
                          57],
                count: 1,
              },
              { type: 'sell_company', when: 'owning_corp_or_turn' },
            ],
            color: nil,
          },
          {
            name: 'Large #4',
            value: 70,
            revenue: 20,
            sym: 'L4',
            desc: 'May either ignore the cost to build a river, hill or mountain tile or '\
                  'lay a purple-edged green, brown, or gray upgrade to town/city hexes',
            abilities: [
              {
                type: 'tile_lay',
                count: 1,
                owner_type: 'corporation',
                tiles: %w[14p
                          15p
                          887p
                          888p
                          8866p
                          216p
                          611p
                          889p
                          8894p
                          8895p
                          8896p
                          595p
                          8857p],
                when: 'owning_corp_or_turn',
                hexes: [],
                reachable: true,
                special: false,
              },
              {
                type: 'tile_lay',
                when: 'track',
                owner_type: 'corporation',
                discount: 40,
                hexes: %w[A10
                          A14
                          A16
                          B7
                          B9
                          B17
                          B21
                          C10
                          C12
                          C18
                          C22
                          C4
                          C6
                          D11
                          D13
                          D15
                          D17
                          D29
                          E12
                          E16
                          E28
                          E6
                          F11
                          F27
                          G10
                          G14
                          G16
                          G18
                          H11
                          H15
                          H17
                          H7
                          I8
                          J11],
                reachable: true,
                tiles: %w[3
                          4
                          7
                          8
                          9
                          58
                          8889
                          8890
                          8859
                          8860
                          8863
                          8864
                          8865
                          8885
                          5
                          6
                          57],
                count: 1,
              },
              { type: 'sell_company', when: 'owning_corp_or_turn' },
            ],
            color: nil,
          },
          {
            name: 'Large #5',
            value: 75,
            revenue: 20,
            sym: 'L5',
            desc: 'May either ignore the cost to build a river, hill or mountain tile or '\
                  'lay a purple-edged green, brown, or gray upgrade to town/city hexes',
            abilities: [
              {
                type: 'tile_lay',
                count: 1,
                owner_type: 'corporation',
                tiles: %w[14p
                          15p
                          887p
                          888p
                          8866p
                          216p
                          611p
                          889p
                          8894p
                          8895p
                          8896p
                          595p
                          8857p],
                when: 'owning_corp_or_turn',
                hexes: [],
                reachable: true,
                special: false,
              },
              {
                type: 'tile_lay',
                when: 'track',
                owner_type: 'corporation',
                discount: 40,
                hexes: %w[A10
                          A14
                          A16
                          B7
                          B9
                          B17
                          B21
                          C10
                          C12
                          C18
                          C22
                          C4
                          C6
                          D11
                          D13
                          D15
                          D17
                          D29
                          E12
                          E16
                          E28
                          E6
                          F11
                          F27
                          G10
                          G14
                          G16
                          G18
                          H11
                          H15
                          H17
                          H7
                          I8
                          J11],
                reachable: true,
                tiles: %w[3
                          4
                          7
                          8
                          9
                          58
                          8889
                          8890
                          8859
                          8860
                          8863
                          8864
                          8865
                          8885
                          5
                          6
                          57],
                count: 1,
              },
              { type: 'sell_company', when: 'owning_corp_or_turn' },
            ],
            color: nil,
          },
          {
            name: 'Large #6',
            value: 80,
            revenue: 20,
            sym: 'L6',
            desc: 'May either ignore the cost to build a river, hill or mountain tile or '\
                  'lay a purple-edged green, brown, or gray upgrade to town/city hexes',
            abilities: [
              {
                type: 'tile_lay',
                count: 1,
                owner_type: 'corporation',
                tiles: %w[14p
                          15p
                          887p
                          888p
                          8866p
                          216p
                          611p
                          889p
                          8894p
                          8895p
                          8896p
                          595p
                          8857p],
                when: 'owning_corp_or_turn',
                hexes: [],
                reachable: true,
                special: false,
              },
              {
                type: 'tile_lay',
                when: 'track',
                owner_type: 'corporation',
                discount: 40,
                hexes: %w[A10
                          A14
                          A16
                          B7
                          B9
                          B17
                          B21
                          C10
                          C12
                          C18
                          C22
                          C4
                          C6
                          D11
                          D13
                          D15
                          D17
                          D29
                          E12
                          E16
                          E28
                          E6
                          F11
                          F27
                          G10
                          G14
                          G16
                          G18
                          H11
                          H15
                          H17
                          H7
                          I8
                          J11],
                reachable: true,
                tiles: %w[3
                          4
                          7
                          8
                          9
                          58
                          8889
                          8890
                          8859
                          8860
                          8863
                          8864
                          8865
                          8885
                          5
                          6
                          57],
                count: 1,
              },
              { type: 'sell_company', when: 'owning_corp_or_turn' },
            ],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 50,
            float_excludes_market: true,
            sym: 'SX',
            name: 'Sächsische Eisenbahn',
            logo: '18_cz/SX',
            simple_logo: '18_cz/SX.alt',
            max_ownership_percent: 60,
            always_market_price: true,
            tokens: [0, 40],
            coordinates: %w[A8 B5],
            color: :"#e31e24",
            type: 'large',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            float_excludes_market: true,
            sym: 'PR',
            name: 'Preußische Eisenbahn',
            logo: '18_cz/PR',
            simple_logo: '18_cz/PR.alt',
            max_ownership_percent: 60,
            always_market_price: true,
            tokens: [0, 40],
            coordinates: %w[A22 B19],
            color: :"#2b2a29",
            type: 'large',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            float_excludes_market: true,
            sym: 'BY',
            name: 'Bayrische Staatsbahn',
            logo: '18_cz/BY',
            simple_logo: '18_cz/BY.alt',
            max_ownership_percent: 60,
            always_market_price: true,
            tokens: [0, 40],
            coordinates: %w[F3 H5],
            color: :"#0971b7",
            type: 'large',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            float_excludes_market: true,
            sym: 'kk',
            name: 'kk Staatsbahn',
            logo: '18_cz/kk',
            simple_logo: '18_cz/kk.alt',
            max_ownership_percent: 60,
            always_market_price: true,
            tokens: [0, 40],
            coordinates: %w[J15 I18],
            color: :"#cc6f3c",
            type: 'large',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            float_excludes_market: true,
            sym: 'Ug',
            name: 'Ungarische Staatsbahn',
            logo: '18_cz/Ug',
            simple_logo: '18_cz/Ug.alt',
            max_ownership_percent: 60,
            always_market_price: true,
            tokens: [0, 40],
            coordinates: %w[G28 I24],
            color: :"#ae4a84",
            type: 'large',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            float_excludes_market: true,
            sym: 'BN',
            name: 'Böhmische Nordbahn',
            logo: '18_cz/BN',
            simple_logo: '18_cz/BN.alt',
            max_ownership_percent: 60,
            always_market_price: true,
            shares: [40, 20, 20, 20],
            tokens: [0, 40, 100],
            city: 1,
            coordinates: 'E12',
            color: :darkGrey,
            text_color: 'black',
            type: 'medium',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            float_excludes_market: true,
            sym: 'NWB',
            name: 'Österreichische Nordwestbahn',
            logo: '18_cz/NWB',
            simple_logo: '18_cz/NWB.alt',
            max_ownership_percent: 60,
            always_market_price: true,
            shares: [40, 20, 20, 20],
            tokens: [0, 40, 100],
            city: 0,
            coordinates: 'E12',
            color: :"#e1af33",
            text_color: 'black',
            type: 'medium',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            float_excludes_market: true,
            sym: 'ATE',
            name: 'Aussig-Teplitzer Eisenbahn',
            logo: '18_cz/ATE',
            simple_logo: '18_cz/ATE.alt',
            max_ownership_percent: 60,
            always_market_price: true,
            shares: [40, 20, 20, 20],
            tokens: [0, 40, 100],
            color: :gold,
            text_color: 'black',
            coordinates: 'B9',
            type: 'medium',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            float_excludes_market: true,
            sym: 'BTE',
            name: 'Buschtehrader Eisenbahn',
            logo: '18_cz/BTE',
            simple_logo: '18_cz/BTE.alt',
            max_ownership_percent: 60,
            always_market_price: true,
            shares: [40, 20, 20, 20],
            tokens: [0, 40, 100],
            coordinates: 'D3',
            color: :"#dbe285",
            text_color: 'black',
            type: 'medium',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            float_excludes_market: true,
            sym: 'KFN',
            name: 'Kaiser Ferdinands Nordbahn',
            logo: '18_cz/KFN',
            simple_logo: '18_cz/KFN.alt',
            max_ownership_percent: 60,
            always_market_price: true,
            shares: [40, 20, 20, 20],
            tokens: [0, 40, 100],
            coordinates: 'G20',
            color: :"#a2d9f7",
            text_color: 'black',
            type: 'medium',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'EKJ',
            name: 'Eisenbahn Karlsbad Johanngeorgenstadt',
            logo: '18_cz/EKJ',
            simple_logo: '18_cz/EKJ.alt',
            max_ownership_percent: 75,
            always_market_price: true,
            shares: [50, 25, 25],
            tokens: [0, 40, 100],
            coordinates: 'D5',
            color: :antiqueWhite,
            text_color: 'black',
            type: 'small',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'OFE',
            name: 'Ostrau-Friedlander Eisenbahn',
            logo: '18_cz/OFE',
            simple_logo: '18_cz/OFE.alt',
            max_ownership_percent: 75,
            always_market_price: true,
            shares: [50, 25, 25],
            tokens: [0, 40, 100],
            coordinates: 'C26',
            color: '#F3B1B3',
            text_color: 'black',
            type: 'small',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'BCB',
            name: 'Böhmische Commercialbahn',
            logo: '18_cz/BCB',
            simple_logo: '18_cz/BCB.alt',
            max_ownership_percent: 75,
            always_market_price: true,
            shares: [50, 25, 25],
            tokens: [0, 40, 100],
            coordinates: 'E16',
            color: :"#fabc48",
            text_color: 'black',
            type: 'small',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'MW',
            name: 'Mährische Westbahn',
            logo: '18_cz/MW',
            simple_logo: '18_cz/MW.alt',
            max_ownership_percent: 75,
            always_market_price: true,
            shares: [50, 25, 25],
            tokens: [0, 40, 100],
            coordinates: 'F23',
            color: '#B1CEC7',
            text_color: 'black',
            type: 'small',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'VBW',
            name: 'Vereinigte Böhmerwaldbahnen',
            logo: '18_cz/VBW',
            simple_logo: '18_cz/VBW.alt',
            max_ownership_percent: 75,
            always_market_price: true,
            shares: [50, 25, 25],
            tokens: [0, 40, 100],
            coordinates: 'I10',
            color: :"#009846",
            type: 'small',
            reservation_color: nil,
          },
        ].freeze

        HEXES = {
          gray: { ['D1'] => 'town=revenue:10;path=a:4,b:_0;path=a:5,b:_0' },
          white: {
            %w[A12
               B25
               C16
               D7
               D9
               D19
               D21
               D23
               D25
               E8
               E18
               E20
               E24
               E26
               F9
               F15
               F17
               F19
               F25
               G8
               H9
               H13
               H21] => '',
            %w[H23 I14] => 'border=edge:5,type:offboard',
            %w[J13 I22 G26] => 'border=edge:4,type:offboard',
            ['B23'] => 'border=edge:2,type:offboard',
            %w[F5 I20] => 'border=edge:1,type:offboard',
            ['G4'] => 'border=edge:2,type:offboard;border=edge:5,type:offboard',
            %w[G6 H19 H25] => 'border=edge:0,type:offboard',
            %w[A16 C22 I8] => 'upgrade=cost:40,terrain:mountain',
            ['B21'] =>
            'upgrade=cost:40,terrain:mountain;border=edge:1,type:offboard;border=edge:3,type:offboard',
            ['C4'] => 'upgrade=cost:40,terrain:mountain;border=edge:3,type:offboard',
            ['B7'] =>
            'upgrade=cost:40,terrain:mountain;border=edge:3,type:offboard;border=edge:1,type:offboard',
            %w[A14 D29 E28 E6 H15 G14] => 'upgrade=cost:20,terrain:hill',
            ['F27'] => 'upgrade=cost:20,terrain:hill;border=edge:5,type:offboard',
            ['C6'] =>
            'town=revenue:0;upgrade=cost:40,terrain:mountain;border=edge:2,type:offboard',
            %w[J11 G18] => 'town=revenue:0;upgrade=cost:20,terrain:hill',
            ['H17'] =>
            'town=revenue:0;upgrade=cost:20,terrain:hill;border=edge:5,type:offboard',
            ['H7'] =>
            'town=revenue:0;upgrade=cost:20,terrain:hill;border=edge:1,type:offboard',
            ['B17'] =>
            'town=revenue:0;upgrade=cost:20,terrain:hill;border=edge:4,type:offboard',
            ['G16'] => 'city=revenue:0;upgrade=cost:20,terrain:hill',
            %w[D11 D15 G10 H11] => 'upgrade=cost:10,terrain:water',
            ['D13'] => 'upgrade=cost:10,terrain:water;stub=edge:0',
            ['C18'] => 'upgrade=cost:10,terrain:water;border=edge:3,type:offboard',
            %w[F11 C10 C12] => 'town=revenue:0;upgrade=cost:10,terrain:water',
            ['A10'] =>
            'town=revenue:0;upgrade=cost:10,terrain:water;border=edge:1,type:offboard',
            %w[D17 E16] => 'city=revenue:0;upgrade=cost:10,terrain:water',
            %w[B11 C24 E22 G24 G12 E10 D3 D5 F23 I10] =>
            'city=revenue:0',
            %w[B13 I12 F7 C26 G20] => 'city=revenue:0;label=Y',
            %w[C14 G22 C28] => 'town=revenue:0',
            ['F13'] => 'town=revenue:0;stub=edge:2',
            ['E4'] => 'town=revenue:0;border=edge:0,type:offboard',
            ['E2'] => 'town=revenue:0;border=edge:5,type:offboard',
            ['C20'] => 'town=revenue:0;border=edge:2,type:offboard',
            %w[E14 F21 B15] => 'town=revenue:0;town=revenue:0',
            ['E12'] =>
            'city=revenue:20;city=revenue:20;path=a:5,b:_0;path=a:3,b:_1;label=P;upgrade=cost:10,terrain:water',
            %w[A8 B5] =>
            'label=SX;border=edge:0,type:offboard;border=edge:5,type:offboard;border=edge:4,type:offboard',
            ['B19'] =>
            'label=PR;border=edge:0,type:offboard;border=edge:5,type:offboard;border=edge:4,type:offboard;' \
            'border=edge:1,type:offboard',
            ['A22'] => 'label=PR;border=edge:0,type:offboard;border=edge:5,type:offboard',
            ['H5'] =>
            'label=BY;border=edge:2,type:offboard;border=edge:3,type:offboard;border=edge:4,type:offboard',
            ['F3'] =>
            'label=BY;border=edge:2,type:offboard;border=edge:3,type:offboard;border=edge:4,type:offboard;' \
            'border=edge:5,type:offboard',
            ['I18'] =>
            'label=kk;border=edge:2,type:offboard;border=edge:3,type:offboard;border=edge:4,type:offboard',
            ['J15'] => 'label=kk;border=edge:1,type:offboard;border=edge:2,type:offboard',
            ['I24'] =>
            'label=Ug;border=edge:1,type:offboard;border=edge:2,type:offboard;border=edge:3,type:offboard',
            ['G28'] =>
            'label=Ug;border=edge:1,type:offboard;border=edge:2,type:offboard',
          },
          yellow: {
            %w[D27 C8] => 'city=revenue:0;city=revenue:0;label=OO',
            ['B9'] =>
            'city=revenue:0;city=revenue:0;label=OO;upgrade=cost:10,terrain:water;border=edge:2,type:offboard',
          },
        }.freeze

        LAYOUT = :pointy

        SELL_BUY_ORDER = :sell_buy
        SELL_MOVEMENT = :left_block
        MARKET_SHARE_LIMIT = 1000 # notionally unlimited shares in market

        MUST_BUY_TRAIN = :always

        HOME_TOKEN_TIMING = :operate
        LIMIT_TOKENS_AFTER_MERGER = 999

        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false # if ebuying from depot, must buy cheapest train
        EBUY_OTHER_VALUE = false # allow ebuying other corp trains for up to face

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
          par: :red,
          par_2: :green,
          par_overlap: :blue
        ).freeze

        PAR_RANGE = {
          small: [50, 55, 60, 65, 70],
          medium: [60, 70, 80, 90, 100],
          large: [90, 100, 110, 120],
        }.freeze

        MARKET_TEXT = {
          par: 'Small Corporation Par',
          par_overlap: 'Medium Corporation Par',
          par_2: 'Large Corporation Par',
        }.freeze

        COMPANY_VALUES = [40, 45, 50, 55, 60, 65, 70, 75, 80, 90, 100, 110, 120].freeze

        OR_SETS = [1, 1, 1, 1, 2, 2, 2, 3].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'medium_corps_available' => ['Medium Corps Available',
                                       '5-share corps ATE, BN, BTE, KFN, NWB are available to start'],
          'large_corps_available' => ['Large Corps Available',
                                      '10-share corps By, kk, Sx, Pr, Ug are available to start']
        ).freeze

        TRAINS_FOR_CORPORATIONS = {
          '2a' => :small,
          '2b' => :small,
          '3c' => :small,
          '3d' => :small,
          '4e' => :small,
          '4f' => :small,
          '5g' => :small,
          '5h' => :small,
          '5i' => :small,
          '5j' => :small,
          '2+2b' => :medium,
          '2+2c' => :medium,
          '3+3d' => :medium,
          '3+3e' => :medium,
          '4+4f' => :medium,
          '4+4g' => :medium,
          '5+5h' => :medium,
          '5+5i' => :medium,
          '5+5j' => :medium,
          '3Ed' => :large,
          '3Ee' => :large,
          '4Ef' => :large,
          '4Eg' => :large,
          '5E' => :large,
          '6E' => :large,
          '8E' => :large,
        }.freeze

        include StubsAreRestricted
        attr_accessor :rusted_variants

        def setup
          @or = 0
          # We can modify COMPANY_VALUES and OR_SETS if we want to support the shorter variant
          @last_or = COMPANY_VALUES.size
          @recently_floated = []
          @entity_used_ability_to_track = false
          @rusted_variants = []

          # Only small companies are available until later phases
          @corporations, @future_corporations = @corporations.partition { |corporation| corporation.type == :small }

          block_lay_for_purple_tiles
          init_player_debts
        end

        def init_round
          Round::Draft.new(self,
                           [G18CZ::Step::Draft],
                           snake_order: true)
        end

        def stock_round
          Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G18CZ::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            G18CZ::Step::HomeTrack,
            G18CZ::Step::SellCompanyAndSpecialTrack,
            Engine::Step::HomeToken,
            G18CZ::Step::ReduceTokens,
            G18CZ::Step::BuyCompany,
            Engine::Step::Track,
            G18CZ::Step::Token,
            Engine::Step::Route,
            G18CZ::Step::Dividend,
            G18CZ::Step::UpgradeOrDiscardTrain,
            G18CZ::Step::BuyCorporation,
            Engine::Step::DiscardTrain,
            G18CZ::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def init_stock_market
          StockMarket.new(self.class::MARKET, [], zigzag: true)
        end

        def init_player_debts
          @player_debts = @players.map { |player| [player.id, { debt: 0, penalty_interest: 0 }] }.to_h
        end

        def new_operating_round(round_num = 1)
          @or += 1
          @companies.each do |company|
            company.value = COMPANY_VALUES[@or - 1]
            company.min_price = 1
            company.max_price = company.value
          end

          super
        end

        def or_round_finished
          @recently_floated.clear
        end

        def end_now?(_after)
          @or == @last_or
        end

        def timeline
          @timeline = [
            'At the end of each set of ORs the next available train will be exported
           (removed, triggering phase change as if purchased)',
          ]
          @timeline.append("Game ends after OR #{OR_SETS.size}.#{OR_SETS.last}")
          @timeline.append("Current value of each private company is #{COMPANY_VALUES[[0, @or - 1].max]}")
          @timeline.append("Next set of Operating Rounds will have #{OR_SETS[@turn - 1]} ORs")
        end

        def par_prices(corp)
          par_nodes = stock_market.par_prices
          available_par_prices = PAR_RANGE[corp.type]
          par_nodes.select { |par_node| available_par_prices.include?(par_node.price) }
        end

        def event_medium_corps_available!
          medium_corps, @future_corporations = @future_corporations.partition do |corporation|
            corporation.type == :medium
          end
          @corporations.concat(medium_corps)
          @log << '-- Medium corporations now available --'
        end

        def event_large_corps_available!
          @corporations.concat(@future_corporations)
          @future_corporations.clear
          @log << '-- Large corporations now available --'
        end

        def float_corporation(corporation)
          @recently_floated << corporation

          @log << "#{corporation.name} floats"

          return if corporation.capitalization == :incremental

          @bank.spend(corporation.original_par_price.price * corporation.total_shares, corporation)
          @log << "#{corporation.name} receives #{format_currency(corporation.cash)}"
        end

        def or_set_finished
          depot.export!
        end

        def next_round!
          @round =
            case @round
            when Round::Stock
              @operating_rounds = OR_SETS[@turn - 1]
              reorder_players(:most_cash)
              new_operating_round
            when Round::Operating
              if @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                new_stock_round
              end
            when init_round.class
              init_round_finished
              reorder_players(:least_cash)
              new_stock_round
            end
        end

        def tile_lays(entity)
          return [] if @entity_used_ability_to_track
          return super unless @recently_floated.include?(entity)

          floated_tile_lay = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }]
          floated_tile_lay.unshift({ lay: true, upgrade: true }) if entity.type == :large
          floated_tile_lay
        end

        def corporation_size(entity)
          # For display purposes is a corporation small, medium or large
          entity.type
        end

        def status_str(corp)
          train_type = case corp.type
                       when :small
                         'Normal '
                       when :medium
                         'Plus-'
                       else
                         'E-'
                       end
          "#{corp.type.capitalize} / #{train_type}Trains"
        end

        def block_lay_for_purple_tiles
          @tiles.each do |tile|
            tile.blocks_lay = true if purple_tile?(tile)
          end
        end

        def purple_tile?(tile)
          tile.name.end_with?('p')
        end

        def must_buy_train?(entity)
          !depot.depot_trains.empty? &&
          (entity.trains.empty? ||
            (entity.type == :medium && entity.trains.none? { |item| train_of_size?(item, :medium) }) ||
            (entity.type == :large && entity.trains.none? { |item| train_of_size?(item, :large) }))
        end

        def train_of_size?(item, size)
          name = if item.is_a?(Hash)
                   item[:name]
                 else
                   item.name
                 end

          TRAINS_FOR_CORPORATIONS[name] == size
        end

        def variant_is_rusted?(item)
          name = if item.is_a?(Hash)
                   item[:name]
                 else
                   item.name
                 end
          @rusted_variants.include?(name)
        end

        def home_token_locations(corporation)
          coordinates = COORDINATES_FOR_LARGE_CORPORATION[corporation.id]
          hexes.select { |hex| coordinates.include?(hex.coordinates) }
        end

        def place_home_token(corporation)
          return unless corporation.next_token # 1882
          # If a corp has laid it's first token assume it's their home token
          return if corporation.tokens.first&.used

          if corporation.coordinates.is_a?(Array)
            @log << "#{corporation.name} (#{corporation.owner.name}) must choose tile for home location"

            hexes = corporation.coordinates.map { |item| hex_by_id(item) }

            @round.pending_tracks << {
              entity: corporation,
              hexes: hexes,
            }

            @round.clear_cache!
          else
            hex = hex_by_id(corporation.coordinates)

            tile = hex&.tile

            if corporation.id == 'ATE'
              @log << "#{corporation.name} must choose city for home token"

              @round.pending_tokens << {
                entity: corporation,
                hexes: [hex],
                token: corporation.find_token_by_type,
              }

              @round.clear_cache!
              return
            end

            cities = tile.cities
            city = cities.find { |c| c.reserved_by?(corporation) } || cities.first
            token = corporation.find_token_by_type
            return unless city.tokenable?(corporation, tokens: token)

            @log << "#{corporation.name} places a token on #{hex.name}"
            city.place_token(corporation, token)
          end
        end

        def upgrades_to?(from, to, special = false)
          return true if from.color == :white && to.color == :red
          if purple_tile?(to) && from.towns.size == 2 && !to.towns.empty? && from.color == :yellow && to.color == :green
            return true
          end

          super
        end

        def potential_tiles(corporation)
          tiles.select { |tile| tile.label&.to_s == corporation.name }
        end

        def rust_trains!(train, entity)
          rusted_trains = []
          owners = Hash.new(0)

          trains.each do |t|
            next if t.rusted
            next if t.rusts_on.nil? || t.rusts_on.none?

            # entity is nil when a train is exported. Then all trains are rusting
            train_symbol_to_compare = entity.nil? ? train.variants.values.map { |item| item[:name] } : [train.name]
            should_rust = !(t.rusts_on & train_symbol_to_compare).empty?
            next unless should_rust
            next unless rust?(t)

            rusted_trains << t.name
            owners[t.owner.name] += 1 if t.owner
            rust(t)
          end
          return if rusted_trains.none?

          all_varians = trains.flat_map do |item|
            item.variants.values
          end
          all_rusted_variants = all_varians.select do |item|
            item[:rusts_on]&.include?(train.name)
          end
          all_rusted_names = all_rusted_variants.map { |item| item[:name] }.uniq

          @rusted_variants.concat(all_rusted_names)
          @log << "-- Event: #{rusted_trains.uniq.join(', ')} trains rust " \
            "( #{owners.map { |c, t| "#{c} x#{t}" }.join(', ')}) --"
        end

        def revenue_for(route, stops)
          if route.corporation.type == :large
            number_of_stops = route.train.distance[0][:pay]
            all_stops = stops.map do |stop|
              stop.route_revenue(route.phase, route.train)
            end.sort.reverse.take(number_of_stops)
            revenue = all_stops.sum
            revenue += 50 if stops.any? { |stop| stop.tile.label.to_s == route.corporation.id }
            return revenue
          end
          stops.sum { |stop| stop.route_revenue(route.phase, route.train) }
        end

        def revenue_str(route)
          str = super
          str += " + #{route.corporation.name} bonus" if route.stops.any? do |stop|
                                                           stop.tile.label.to_s == route.corporation.id
                                                         end
          str
        end

        def increase_debt(player, amount)
          entity = @player_debts[player.id]
          entity[:debt] += amount
          entity[:penalty_interest] += amount
        end

        def reset_debt(player)
          entity = @player_debts[player.id]
          entity[:debt] = 0
        end

        def debt(player)
          @player_debts[player.id][:debt]
        end

        def penalty_interest(player)
          @player_debts[player.id][:penalty_interest]
        end

        def player_debt(player)
          debt(player)
        end

        def player_interest(player)
          penalty_interest(player)
        end

        def player_value(player)
          player.value - debt(player) - penalty_interest(player)
        end

        def liquidity(player, emergency: false)
          return player.cash if emergency

          super
        end

        def ability_blocking_step
          @round.steps.find do |step|
            # currently, abilities only care about Tracker, the is_a? check could
            # be expanded to a list of possible classes/modules when needed
            step.is_a?(Engine::Step::Track) && !step.passed? && step.blocks?
          end
        end

        def next_turn!
          super
          @entity_used_ability_to_track = false
        end

        def skip_default_track
          @entity_used_ability_to_track = true
        end

        def ability_usable?(ability)
          case ability
          when Ability::TileLay
            ability.count&.positive?
          else
            true
          end
        end

        def new_token_price
          100
        end

        def route_trains(entity)
          runnable = super

          runnable.select { |item| train_of_size?(item, entity.type) }
        end

        def format_currency(val)
          return format('%0.1f K', val) if (val - val.to_i).positive?

          self.class::CURRENCY_FORMAT_STR % val
        end

        def show_progress_bar?
          true
        end

        def progress_information
          [
            { type: :PRE },
            { type: :SR },
            { type: :OR, value: '40', name: '1.1', exportAfter: true },
            { type: :SR },
            { type: :OR, value: '45', name: '2.1', exportAfter: true },
            { type: :SR },
            { type: :OR, value: '50', name: '3.1', exportAfter: true },
            { type: :SR },
            { type: :OR, value: '55', name: '4.1', exportAfter: true },
            { type: :SR },
            { type: :OR, value: '60', name: '5.1' },
            { type: :OR, value: '65', name: '5.2', exportAfter: true },
            { type: :SR },
            { type: :OR, value: '70', name: '6.1' },
            { type: :OR, value: '75', name: '6.2', exportAfter: true },
            { type: :SR },
            { type: :OR, value: '80', name: '7.1' },
            { type: :OR, value: '90', name: '7.2', exportAfter: true },
            { type: :SR },
            { type: :OR, value: '100', name: '8.1' },
            { type: :OR, value: '110', name: '8.2' },
            { type: :OR, value: '120', name: '8.3' },
            { type: :End },
          ]
        end

        def route_distance(route)
          return super if train_of_size?(route.train, :small)

          n_cities = route.stops.count { |n| n.city? || n.offboard? }

          return n_cities if train_of_size?(route.train, :large)

          n_towns = route.stops.count(&:town?)
          "#{n_cities}+#{n_towns}"
        end
      end
    end
  end
end
