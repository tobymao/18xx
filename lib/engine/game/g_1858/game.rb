# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength
# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G1858
      class Game < Game::Base
        include_meta(G1858::Meta)

        register_colors(red: '#d1232a',
                        orange: '#f58121',
                        black: '#110a0c',
                        blue: '#025aaa',
                        lightBlue: '#8dd7f6',
                        yellow: '#ffe600',
                        green: '#32763f')

        CURRENCY_FORMAT_STR = '%d₧'

        BANK_CASH = 12_000

        CERT_LIMIT = {
          3 => { 5 => 14, 4 => 11 },
          4 => { 6 => 12, 5 => 10, 4 => 8 },
          5 => { 7 => 11, 6 => 10, 5 => 8, 4 => 6 },
        }.freeze

        STARTING_CASH = { 3 => 500, 4 => 375, 5 => 300, 6 => 250 }.freeze

        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = true

        LAYOUT = :flat

        TILES = {
          # Yellow tiles
          '1' => 'unlimited',
          '2' => 'unlimited',
          '3' => 'unlimited',
          '4' => 'unlimited',
          '5' => 'unlimited',
          '6' => 'unlimited',
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '55' => 'unlimited',
          '56' => 'unlimited',
          '57' => 'unlimited',
          '58' => 'unlimited',
          '69' => 'unlimited',
          '71' => 'unlimited',
          '72' => 'unlimited',
          '73' => 'unlimited',
          '74' => 'unlimited',
          '75' => 'unlimited',
          '76' => 'unlimited',
          '77' => 'unlimited',
          '78' => 'unlimited',
          '79' => 'unlimited',
          '201' => 'unlimited',
          '202' => 'unlimited',
          '621' => 'unlimited',
          '630' => 'unlimited',
          '631' => 'unlimited',
          'A1' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:0,b:_0;path=a:1,b:_0;label=B',
          },
          'A2' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:0,b:_0;path=a:2,b:_0;label=B',
          },
          'A3' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:0,b:_0;path=a:3,b:_0;label=B',
          },
          # Green tiles
          '15' => 4,
          '80' => 2,
          '81' => 2,
          '82' => 4,
          '83' => 4,
          '84' => 2,
          '85' => 2,
          '86' => 2,
          '87' => 4,
          '88' => 4,
          '89' => 1,
          '204' => 4,
          '207' => 4,
          '208' => 2,
          '619' => 2,
          '622' => 2,
          '660' => 1,
          '661' => 1,
          '662' => 1,
          '663' => 1,
          '664' => 1,
          '665' => 1,
          '666' => 1,
          '667' => 1,
          '668' => 1,
          '669' => 1,
          '670' => 1,
          '671' => 1,
          '680' => 1,
          '681' => 1,
          '682' => 1,
          '683' => 1,
          '684' => 1,
          '685' => 1,
          '686' => 1,
          '687' => 1,
          '688' => 1,
          '689' => 1,
          '690' => 1,
          '691' => 1,
          '700' => 1,
          '701' => 1,
          '702' => 1,
          '703' => 1,
          '704' => 1,
          '705' => 1,
          '710' => 1,
          '711' => 1,
          '712' => 1,
          '713' => 1,
          '714' => 1,
          '715' => 1,
          'A4' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'junction;path=a:0,b:_0,track:narrow;path=a:2,b:_0,track:narrow;path=a:4,b:_0,track:narrow',

          },
          'A5' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow;path=a:3,b:_0,track:narrow',

          },
          'A6' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow;path=a:3,b:_0,track:narrow;path=a:5,b:_0,track:narrow',

          },
          'A7' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50;city=revenue:50;city=revenue:50;path=a:0,b:_0;path=a:4,b:_0;path=a:1,b:_1;path=a:2,b:_2;label=M',
          },
          'A8' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=B',

          },
          # Brown tiles
          '106' => 2,
          '107' => 2,
          '108' => 2,
          '673' => 4,
          'A9' => {
            'count' => 4,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;path=a:2,b:_0,track:dual;path=a:3,b:_0,track:dual;path=a:4,b:_0,track:dual;path=a:5,b:_0,track:dual',
          },
          'A10' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;path=a:2,b:_0,track:dual;path=a:3,b:_0,track:dual;path=a:4,b:_0,track:dual',
          },
          'A11' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;path=a:2,b:_0,track:dual;path=a:3,b:_0,track:dual;path=a:4,b:_0,track:dual;label=Y',
          },
          'A12' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;path=a:2,b:_0,track:dual;path=a:3,b:_0,track:dual;path=a:4,b:_0,track:dual;path=a:5,b:_0,track:dual;label=Y',
          },
          'A13' => {
            'count' => 8,
            'color' => 'brown',
            'code' => 'town=revenue:10;path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;path=a:2,b:_0,track:dual;path=a:3,b:_0,track:dual;path=a:4,b:_0,track:dual;path=a:5,b:_0,track:dual',
          },
          'A14' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;path=a:3,b:_0;label=L',
          },
          'A15' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70,slots:3;path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;path=a:2,b:_0,track:dual;path=a:3,b:_0,track:dual;path=a:4,b:_0,track:dual;label=M',
          },
          'A16' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;path=a:2,b:_0,track:dual;path=a:3,b:_0,track:dual;label=P',
          },
          'A17' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:3;path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;path=a:2,b:_0,track:dual;path=a:3,b:_0,track:dual;label=B',
          },
          # Gray tiles
          '112' => 2,
          'A18' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:70,slots:2;path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;path=a:3,b:_0;label=L',
          },
          'A19' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:100,slots:3;path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;path=a:2,b:_0,track:dual;path=a:3,b:_0,track:dual;path=a:4,b:_0,track:dual;path=a:5,b:_0,track:dual;label=M',
          },
          'A20' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:80,slots:3;path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;path=a:2,b:_0,track:dual;path=a:3,b:_0,track:dual;label=B',
          },
        }.freeze

        LOCATION_NAMES = {
          'C2' => 'La Curuña',
          'F1' => 'Gijon',
          'H3' => 'Santander',
          'I2' => 'Bilbao',
          'D3' => 'Lugo',
          'J3' => 'Donostia/San Sebastián',
          'M2' => 'France',
          'B5' => 'Vigo',
          'C4' => 'Santiago & Ourense',
          'F5' => 'León',
          'G6' => 'Palencia',
          'H5' => 'Burgos',
          'I4' => 'Vitoria-Gasteiz',
          'J5' => 'Logroso',
          'K4' => 'Pamplona',
          'B7' => 'Braga',
          'B9' => 'Porto',
          'B11' => 'Coimbra',
          'F9' => 'Salamanca',
          'G8' => 'Valladolid',
          'L7' => 'Zaragoza',
          'N7' => 'Lleida',
          'O8' => 'Barcelona',
          'P7' => 'Girona',
          'N9' => 'Reus & Tarragona',
          'M10' => 'Tortosa',
          'M12' => 'Castejón',
          'L13' => 'Valencia',
          'J15' => 'Albacete',
          'H15' => 'Ciudad Real',
          'H13' => 'Aranjuez',
          'H11' => 'Madrid',
          'I10' => 'Guadalajara',
          'G12' => 'Talavera',
          'D13' => 'Cáceres',
          'D15' => 'Badajoz',
          'B13' => 'Santarém',
          'A14' => 'Lisboa',
          'B15' => 'Setúbal',
          'C20' => 'Faro',
          'D19' => 'Huelva',
          'E18' => 'Sevilla',
          'E20' => 'Cádiz',
          'F19' => 'Marchena',
          'G18' => 'Córdoba',
          'G20' => 'Málaga',
          'H19' => 'Granada',
          'H17' => 'Linares & Jaén',
          'K18' => 'Múrcia',
          'L19' => 'Cartagena',
        }.freeze

        DISTANCES = {
          'C2' => [%w[B5], %w[F1 B9], %w[H3 G8 H11 A14], %w[E18 E20 G18 G20 H19 K18 L13 L7 I2], %w[O8]],
          'B5' => [%w[C2], %w[F1 B9], %w[H3 G8 H11 A14], %w[E18 E20 G18 G20 H19 K18 L13 L7 I2], %w[O8]],
          'F1' => [[], %w[B5 C2 G8 H3], %w[B9 H11 I2 L7], %w[E18 A14 E20 G18 G20 H19 K18 L13 O8]],
          'H3' => [[], %w[F1 G8 I2], %w[H11 L7 B5 C2], %w[E18 B9 E20 G18 G20 H19 K18 L13 O8], %w[A14]],
          'I2' => [[], %w[G8 L7 H3], %w[H11 F1 O8 L13], %w[E18 B5 C2 B9 E20 G18 G20 H19 K18], %w[A14]],
          'B9' => [[], %w[A14 B5 C2], %w[F1 G8 E18 E20 G18 G20 H19 H11], %w[H3 K18 L13 L7 I2], %w[O8]],
          'A14' => [[], %w[B9 A14 E18 E20 G18 G20 H19], %w[H11 B5 K18 C2], %w[L13 F1 G8], %w[H3 L7 I2 O8]],
          'G8' => [[], %w[F1 H3 H11 L7 I2], %w[E18 E20 G18 G20 H19 B5 C2 B9 L13 O8 K18], %w[A14]],
          'L7' => [[], %w[H11 G8 I2 O8 L13], %w[F1 H3 E18 E20 G18 G20 H19 K18], %w[A14 B5 C2 B9]],
          'O8' => [[], %w[L7 L13], %w[H11 G8 I2 K18], %w[F1 H3 E18 E20 G18 G20 H19], %w[A14 B5 C2 B9]],
          'H11' => [[], %w[G8 L7 E18 E20 G18 G20 H19 K18], %w[F1 H3 I2 B5 C2 B9 L13 O8 A14]],
          'L13' => [[], %w[L7 O8 H11 K18], %w[G8 E18 E20 G18 G20 H19], %w[I2 F1 H3 A14 B5 C2 B9]],
          'K18' => [[], %w[H11 L13 E18 E20 G18 G20 H19], %w[I2 G8 L7 O8 A14], %w[F1 H3 B5 C2 B9]],
          'E18' => [%w[E20 G18 G20 H19], %w[K18 A14 H11], %w[G8 L7 L13 B9], %w[F1 H3 I2 B5 C2 O8]],
          'E20' => [%w[E18 G18 G20 H19], %w[K18 A14 H11], %w[G8 L7 L13 B9], %w[F1 H3 I2 B5 C2 O8]],
          'G18' => [%w[E18 E20 G20 H19], %w[K18 A14 H11], %w[G8 L7 L13 B9], %w[F1 H3 I2 B5 C2 O8]],
          'G20' => [%w[E18 E20 G18 H19], %w[K18 A14 H11], %w[G8 L7 L13 B9], %w[F1 H3 I2 B5 C2 O8]],
          'H19' => [%w[E18 E20 G18 G20], %w[K18 A14 H11], %w[G8 L7 L13 B9], %w[F1 H3 I2 B5 C2 O8]],
        }.freeze

        MARKET = [
          %w[0c 50 60 65 70p 80p 90p 100p 110p 120p 135p 150p 165 180 200 220 245 270 300],
           ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: { medium: 3, large: 4 },
            tiles: [:yellow],
            operating_rounds: 2,
          },
          {
            name: '3',
            on: '4H',
            train_limit: { medium: 3, large: 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '6H',
            train_limit: { medium: 2, large: 3 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5E',
            train_limit: { large: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 2,
            status: %i[can_par_corporations],
          },
          {
            name: '6',
            on: '6E',
            train_limit: { large: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 2,
            status: %i[can_par_corporations],
          },
          {
            name: '7',
            on: '7E',
            train_limit: { large: 2 },
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
            status: %i[can_par_corporations],
          },
          {
            name: "7'",
            on: "7E'",
            train_limit: { large: 2 },
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
            status: %i[can_par_corporations],
          },
        ].freeze

        TRAINS = [
          {
            name: '2H',
            num: 6,
            distance: 2,
            price: 100,
            wounded_on: '4',
            rusts_on: '6',
          },
          {
            name: '4H',
            num: 5,
            distance: 4,
            price: 200,
            wounded_on: '6',
            rusts_on: '7',
            variants: [
              {
                name: '2M',
                distance: 2,
                price: 100,
              },
            ],
          },
          {
            name: '6H',
            num: 4,
            distance: 6,
            price: 300,
            wounded_on: '7',
            rusts_on: "7'",
            variants: [
              {
                name: '3M',
                distance: 3,
                price: 200,
              },
            ],
          },
          {
            name: '5E',
            num: 3,
            distance: 5,
            price: 500,
            variants: [
              {
                name: '4M',
                distance: 4,
                price: 400,
              },
            ],
            events: [{ 'type' => 'close_companies' }, { 'type' => 'convert_corporations' }],
          },
          {
            name: '6E',
            num: 2,
            distance: 5,
            price: 650,
            variants: [
              {
                name: '5M',
                distance: 5,
                price: 550,
              },
            ],
          },
          {
            name: '7E',
            num: 4,
            distance: 7,
            price: 800,
            variants: [
              {
                name: '6M',
                distance: 6,
                price: 700,
              },
            ],
          },
          {
            name: "7E'",
            num: 20,
            distance: 7,
            price: 800,
            variants: [
              {
                name: '6M',
                distance: 6,
                price: 700,
              },
            ],
          },
          {
            name: '5D',
            num: 20,
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5, 'multiplier' => 2 }],
            price: 1100,
            available_on: '7',
          },
        ].freeze

        COMPANIES = [
          {
            sym: 'P1',
            name: 'P1 - Havana & Guines',
            value: 30,
            revenue: 10,
            color: nil,
          },
          {
            sym: 'P2',
            name: 'P2 - Barcelona & Mataró',
            value: 115,
            discount: 25,
            desc: 'Revenue increases to 35 on phase 2',
            revenue: 23,
            abilities: [
              { type: 'blocks_hexes', hexes: ['O8'] },
              {
                type: 'exchange',
                corporations: [],
                owner_type: 'player',
                from: %w[ipo presidency],
              },
              {
                type: 'revenue_change',
                revenue: 35,
                on_phase: '2',
              },
            ],
            color: nil,
          },
          {
            sym: 'P3',
            name: 'P3 - Madrid & Aranjuez',
            value: 125,
            discount: 25,
            desc: 'Revenue increases to 38 on phase 2',
            revenue: 25,
            abilities: [
              { type: 'blocks_hexes', hexes: %w[H11 H13] },
              {
                type: 'exchange',
                corporations: [],
                owner_type: 'player',
                from: %w[ipo presidency],
              },
              {
                type: 'revenue_change',
                revenue: 38,
                on_phase: '2',
              },
            ],
            color: nil,
          },
          {
            sym: 'P4',
            name: 'P4 - Porto & Lisboa',
            value: 110,
            discount: 20,
            desc: 'Revenue increases to 33 on phase 2',
            revenue: 22,
            abilities: [
              { type: 'blocks_hexes', hexes: %w[B9 B11] },
              # { type: 'tile_lay', hexes: ['B9', 'B11'], tiles: [] },
              {
                type: 'exchange',
                corporations: [],
                owner_type: 'player',
                from: %w[ipo presidency],
              },
              {
                type: 'revenue_change',
                revenue: 33,
                on_phase: '2',
              },
            ],

            color: nil,
          },
          {
            sym: 'P5',
            name: 'P5 - Valencia & Xàtiva',
            value: 100,
            discount: 20,
            desc: 'Revenue increases to 30 on phase 2',
            revenue: 20,
            abilities: [
              { type: 'blocks_hexes', hexes: ['L13'] },
              {
                type: 'exchange',
                corporations: [],
                owner_type: 'player',
                from: 'ipo',
              },
              {
                type: 'revenue_change',
                revenue: 30,
                on_phase: '2',
              },
            ],
            color: nil,
          },
          {
            sym: 'P6',
            name: 'P6 - Reus & Tarragona',
            value: 60,
            discount: 10,
            desc: 'Revenue increases to 18 on phase 2',
            revenue: 12,
            abilities: [
              { type: 'blocks_hexes', hexes: ['N9'] },
              {
                type: 'exchange',
                corporations: [],
                owner_type: 'player',
                from: %w[ipo presidency],
              },
              {
                type: 'revenue_change',
                revenue: 12,
                on_phase: '2',
              },
            ],
            color: nil,
          },
          {
            sym: 'P7',
            name: 'P7 - Lisboa & Carregado',
            value: 90,
            discount: 20,
            desc: 'Revenue increases to 27 on phase 2',
            revenue: 18,
            abilities: [
              { type: 'blocks_hexes', hexes: %w[A14 B13] },
              {
                type: 'exchange',
                corporations: [],
                owner_type: 'player',
                from: %w[ipo presidency],
              },
              {
                type: 'revenue_change',
                revenue: 27,
                on_phase: '2',
              },
            ],
            color: nil,
          },
          {
            sym: 'P8',
            name: 'P8 - Madrid & Valladolid',
            value: 120,
            discount: 25,
            desc: 'Revenue increases to 36 on phase 2',
            revenue: 24,
            abilities: [
              { type: 'blocks_hexes', hexes: %w[G8 G10] },
              {
                type: 'exchange',
                corporations: [],
                owner_type: 'player',
                from: %w[ipo presidency],
              },
              {
                type: 'revenue_change',
                revenue: 36,
                on_phase: '2',
              },
            ],
            color: nil,
          },
          {
            sym: 'P9',
            name: 'P9 - Madrid & Zaragoza',
            value: 95,
            discount: 20,
            desc: 'Revenue increases to 29 on phase 2',
            revenue: 19,
            abilities: [
              { type: 'blocks_hexes', hexes: %w[I10 H11] },
              {
                type: 'exchange',
                corporations: [],
                owner_type: 'player',
                from: %w[ipo presidency],
              },
              {
                type: 'revenue_change',
                revenue: 29,
                on_phase: '2',
              },
            ],
            color: nil,
          },
          {
            sym: 'P10',
            name: 'P10 - Córdoba & Sevilla',
            value: 105,
            discount: 20,
            desc: 'Revenue increases to 32 on phase 2',
            revenue: 21,
            abilities: [
              { type: 'blocks_hexes', hexes: %w[G18 G20] },
              {
                type: 'exchange',
                corporations: [],
                owner_type: 'player',
                from: %w[ipo presidency],
              },
              {
                type: 'revenue_change',
                revenue: 32,
                on_phase: '2',
              },
            ],
            color: nil,
          },
          {
            sym: 'P11',
            name: 'P11 - Sevilla, Jerez, & Cádiz',
            value: 95,
            discount: 15,
            desc: 'Revenue increases to 21 on phase 2',
            revenue: 14,
            abilities: [
              { type: 'blocks_hexes', hexes: %w[E18 E20] },
              {
                type: 'exchange',
                corporations: [],
                owner_type: 'player',
                from: %w[ipo presidency],
              },
              {
                type: 'revenue_change',
                revenue: 21,
                on_phase: '2',
              },
            ],
            color: nil,
          },
          {
            sym: 'P12',
            name: 'P12 - Zaragoza & Pamplona',
            value: 80,
            discount: 15,
            desc: 'Revenue increases to 24 on phase 2',
            revenue: 16,
            abilities: [
              { type: 'blocks_hexes', hexes: %w[K4 K6 L7] },
              {
                type: 'exchange',
                corporations: [],
                owner_type: 'player',
                from: %w[ipo presidency],
              },
              {
                type: 'revenue_change',
                revenue: 24,
                on_phase: '2',
              },
            ],
            color: nil,
          },
          {
            sym: 'P13',
            name: 'P13 - Castejón & Bilbao',
            value: 75,
            discount: 15,
            desc: 'Revenue increases to 23 on phase 2',
            revenue: 15,
            abilities: [
              { type: 'blocks_hexes', hexes: ['I2'] },
              {
                type: 'exchange',
                corporations: [],
                owner_type: 'player',
                from: %w[ipo presidency],
              },
              {
                type: 'revenue_change',
                revenue: 23,
                on_phase: '2',
              },
            ],
            color: nil,
          },
          {
            sym: 'P14',
            name: 'P14 - Córdoba & Málaga',
            value: 85,
            discount: 15,
            desc: 'Revenue increases to 26 on phase 2',
            revenue: 17,
            abilities: [
              { type: 'blocks_hexes', hexes: %w[H17 H19] },
              {
                type: 'exchange',
                corporations: [],
                owner_type: 'player',
                from: %w[ipo presidency],
              },
              {
                type: 'revenue_change',
                revenue: 26,
                on_phase: '2',
              },
            ],
            color: nil,
          },
          {
            sym: 'P15',
            name: 'P15 - Murcia & Cartagena',
            value: 70,
            discount: 15,
            desc: 'Revenue increases to 21 on phase 2',
            revenue: 14,
            abilities: [
              { type: 'blocks_hexes', hexes: %w[K18 L19] },
              {
                type: 'exchange',
                corporations: [],
                owner_type: 'player',
                from: %w[ipo presidency],
              },
              {
                type: 'revenue_change',
                revenue: 21,
                on_phase: '2',
              },
            ],
            color: nil,
          },
          {
            sym: 'P16',
            name: 'P16 - Alar & Santander',
            value: 80,
            discount: 15,
            desc: 'Revenue increases to 24 on phase 2',
            revenue: 16,
            abilities: [
              { type: 'blocks_hexes', hexes: %w[G4 H3] },
              {
                type: 'exchange',
                corporations: [],
                owner_type: 'player',
                from: %w[ipo presidency],
              },
              {
                type: 'revenue_change',
                revenue: 24,
                on_phase: '2',
              },
            ],
            color: nil,
          },
          {
            sym: 'P17',
            name: 'P17 - Badajoz & Ciudad Real',
            value: 65,
            discount: 15,
            desc: 'Revenue increases to 20 on phase 2',
            revenue: 13,
            abilities: [
              { type: 'blocks_hexes', hexes: %w[D15 E14 F15] },
              {
                type: 'exchange',
                corporations: [],
                owner_type: 'player',
                from: %w[ipo presidency],
              },
              {
                type: 'revenue_change',
                revenue: 20,
                on_phase: '2',
              },
            ],
            color: nil,
          },
          {
            sym: 'P18',
            name: 'P18 - Santiago & Curuña',
            value: 100,
            revenue: 30,
            abilities: [
              { type: 'no_buy', on_phase: '1' },
              {
                type: 'exchange',
                corporations: [],
                owner_type: 'player',
                from: %w[ipo presidency],
              },
            ],
            color: nil,
          },
          {
            sym: 'P19',
            name: 'P19 - Medina & Salamanca',
            value: 90,
            revenue: 27,
            abilities: [
              { type: 'no_buy', on_phase: '1' },
              {
                type: 'exchange',
                corporations: [],
                owner_type: 'player',
                from: %w[ipo presidency],
              },
            ],
            color: nil,
          },
          {
            sym: 'P20',
            name: 'P20 - Cáceres, Madrid & Portugal',
            value: 135,
            discount: -30,
            revenue: 40,
            abilities: [
              { type: 'no_buy', on_phase: '1' },
              {
                type: 'exchange',
                corporations: [],
                owner_type: 'player',
                from: %w[ipo presidency],
              },
            ],
            color: nil,
          },
          {
            sym: 'P21',
            name: 'P21 - Ourense & Vigo',
            value: 110,
            revenue: 33,
            abilities: [
              { type: 'no_buy', on_phase: '1' },
              {
                type: 'exchange',
                corporations: [],
                owner_type: 'player',
                from: %w[ipo presidency],
              },
            ],
            color: nil,
          },
          {
            sym: 'P22',
            name: 'P22 - León & Gijón',
            value: 120,
            revenue: 36,
            abilities: [
              { type: 'no_buy', on_phase: '1' },
              {
                type: 'exchange',
                corporations: [],
                owner_type: 'player',
                from: %w[ipo presidency],
              },
            ],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 20,
            sym: 'A',
            name: 'Compañía de los Ferrocarriles Andaluces',
            logo: '1858/A',
            simple_logo: '1858/A.alt',
            tokens: [0, 0, 0],
            color: '#3751dc',
            always_market_price: true,
            type: 'medium',
            shares: [40, 20, 20, 20],
          },
          {
            float_percent: 20,
            sym: 'AVT',
            name: 'Sociedad de los Ferrocarriles de Almansa a Valencia y Tarragona',
            logo: '1858/AVT',
            simple_logo: '1858/AVT.alt',
            tokens: [0, 0, 0],
            color: '#18a6d8',
            always_market_price: true,
            type: 'medium',
            shares: [40, 20, 20, 20],
          },
          {
            float_percent: 20,
            sym: 'MZA',
            name: 'Compañía de los Ferrocarriles de Madrid a Zaragoza y Alicante',
            logo: '1858/MZA',
            simple_logo: '1858/MZA.alt',
            tokens: [0, 0, 0],
            color: :"#fff114",
            always_market_price: true,
            type: 'medium',
            shares: [40, 20, 20, 20],
          },
          {
            float_percent: 20,
            sym: 'N',
            name: 'Compañía de los Caminos de Hierro del Norte de España',
            logo: '1858/N',
            simple_logo: '1858/N.alt',
            tokens: [0, 0, 0],
            color: :"#00000",
            always_market_price: true,
            type: 'medium',
            shares: [40, 20, 20, 20],
          },
          {
            float_percent: 20,
            sym: 'RP',
            name: 'Companhia Real dos Caminhos de Ferro Portugueses',
            logo: '1858/RP',
            simple_logo: '1858/RP.alt',
            tokens: [0, 0, 0],
            color: :"#e51f2e",
            always_market_price: true,
            type: 'medium',
            shares: [40, 20, 20, 20],
          },
          {
            float_percent: 20,
            sym: 'TBF',
            name: 'Companyia dels Ferrocarrils de Tarragona a Barcelona i França',
            logo: '1858/TBF',
            simple_logo: '1858/TBF.alt',
            tokens: [0, 0, 0],
            color: :"#59227f",
            always_market_price: true,
            type: 'medium',
            shares: [40, 20, 20, 20],
          },
          {
            float_percent: 20,
            sym: 'WR',
            name: 'Compañía Nacional de los Ferrocarriles del Oeste',
            logo: '1858/WR',
            simple_logo: '1858/WR.alt',
            tokens: [0, 0, 0],
            color: :"",
            always_market_price: true,
            type: 'medium',
            shares: [40, 20, 20, 20],
          },
          {
            float_percent: 20,
            sym: 'ZPB',
            name: 'Compañía de los Ferrocarriles de Zaragoza a Pamplona y Barcelona',
            logo: '1858/ZPB',
            simple_logo: '1858/ZPB.alt',
            tokens: [0, 0, 0],
            color: :"#ff7700",
            always_market_price: true,
            type: 'medium',
            shares: [40, 20, 20, 20],
          },
        ].freeze

        HEXES = {
          white: {
            %w[B3 H7 C10 I12 B17 B19] => '',
            %w[C2 H19] => 'city=revenue:0',
            %w[D3] => 'town=revenue:0;border=edge:4,type:mountain;border=edge:5,type:mountain',
            %w[E2] => 'upgrade=cost:60,terrain:mountain;border=edge:0,type:mountain;border=edge:1,type:mountain',
            %w[F3 I16] => 'upgrade=cost:80,terrain:mountain;border=edge:0,type:mountain;border=edge:1,type:mountain;border=edge:5,type:mountain',
            %w[G2] => 'upgrade=cost:40,terrain:mountain;border=edge:0,type:mountain;border=edge:5,type:mountain',
            %w[H3] => 'city=revenue:0;upgrade=cost:40,terrain:mountain;border=edge:0,type:mountain;border=edge:1,type:mountain;border=edge:2,type:mountain;border=edge:4,type:mountain;border=edge:5,type:mountain',
            %w[I2] => 'city=revenue:0;border=edge:1,type:mountain',
            %w[J3 B15] => 'town=revenue:0',
            %w[B5] => 'city=revenue:0;border=edge:0,type:mountain',
            %w[C4] => 'town=revenue:0;town=revenue:0;upgrade=cost:40,terrain:mountain',
            %w[D5] => 'upgrade=cost:40,terrain:mountain;border=edge:0,type:mountain;border=edge:4,type:mountain;border=edge:5,type:mountain',
            %w[E4] => 'upgrade=cost:40,terrain:mountain;border=edge:1,type:mountain;border=edge:2,type:mountain;border=edge:3,type:mountain;border=edge:4,type:mountain',
            %w[F5] => 'town=revenue:0;border=edge:3,type:mountain;border=edge:4,type:mountain;border=edge:5,type:mountain',
            %w[G4] => 'border=edge:1,type:mountain;border=edge:2,type:mountain;border=edge:3,type:mountain;border=edge:4,type:mountain',
            %w[H5 B7] => 'town=revenue:0;border=edge:3,type:mountain;border=edge:4,type:mountain',
            %w[I4] => 'town=revenue:0;border=edge:0,type:mountain;border=edge:1,type:mountain;border=edge:2,type:mountain',
            %w[J5] => 'town=revenue:0;border=edge:0,type:mountain;border=edge:1,type:mountain;border=edge:5,type:mountain',
            %w[K4] => 'town=revenue:0;border=edge:0,type:mountain;border=edge:5,type:mountain',
            %w[L5] => 'upgrade=cost:80,terrain:mountain;border=edge:2,type:mountain',
            %w[M4] => 'upgrade=cost:120,terrain:mountain;border=edge:5,type:mountain',
            %w[N5] => 'upgrade=cost:120,terrain:mountain;border=edge:1,type:mountain;border=edge:2,type:mountain',
            %w[C6] => 'border=edge:0,type:mountain;border=edge:1,type:mountain;border=edge:5,type:mountain',
            %w[D7] => 'upgrade=cost:40,terrain:mountain;border=edge:2,type:mountain;border=edge:3,type:mountain;border=edge:4,type:mountain;border=edge:5,type:mountain',
            %w[E6] => 'upgrade=cost:40,terrain:mountain;border=edge:1,type:mountain;border=edge:2,type:mountain',
            %w[F7 D9 C16 C18] => 'upgrade=cost:20,terrain:river;border=edge:4,type:mountain;border=edge:5,type:mountain',
            %w[G6 N7] => 'town=revenue:0;border=edge:1,type:mountain;border=edge:2,type:mountain',
            %w[I6] => 'upgrade=cost:80,terrain:mountain;border=edge:3,type:mountain;border=edge:4,type:mountain',
            %w[J7] => 'border=edge:0,type:mountain;border=edge:3,type:mountain;border=edge:4,type:mountain;border=edge:5,type:mountain',
            %w[K6] => 'upgrade=cost:20,terrain:river;border=edge:1,type:mountain;border=edge:2,type:mountain;border=edge:3,type:mountain',
            %w[M6] => 'upgrade=cost:40,terrain:mountain;border=edge:4,type:mountain;border=edge:5,type:mountain',
            %w[O6] => 'upgrade=cost:80,terrain:mountain',
            %w[P7] => 'town=revenue:0;upgrade=cost:40,terrain:mountain',
            %w[B9 L13 G20] => 'city=revenue:0;upgrade=cost:20,terrain:river;label=Y',
            %w[C8] => 'upgrade=cost:20,terrain:river;border=edge:3,type:mountain',
            %w[E8] => 'upgrade=cost:20,terrain:river;border=edge:1,type:mountain;border=edge:2,type:mountain',
            %w[F9] => 'town=revenue:0;border=edge:4,type:mountain;border=edge:5,type:mountain',
            %w[G8] => 'city=revenue:0;border=edge:1,type:mountain;border=edge:2,type:mountain',
            %w[H9 I8] => 'upgrade=cost:80,terrain:mountain;border=edge:0,type:mountain;border=edge:5,type:mountain',
            %w[J9] => 'border=edge:2,type:mountain;border=edge:3,type:mountain;border=edge:4,type:mountain;border=edge:5,type:mountain',
            %w[K8 J19] => 'border=edge:1,type:mountain;border=edge:2,type:mountain',
            %w[L9] => 'upgrade=cost:20,terrain:mountain;border=edge:0,type:mountain;border=edge:5,type:mountain',
            %w[M8 F15] => 'upgrade=cost:20,terrain:river;border=edge:0,type:mountain;border=edge:4,type:mountain;border=edge:5,type:mountain',
            %w[N9] => 'town=revenue:0;town=revenue:0;border=edge:2,type:mountain',
            %w[O8] => 'city=revenue:0;label=B',
            %w[B11 H15] => 'town=revenue:0;border=edge:0,type:mountain;border=edge:1,type:mountain',
            %w[D11] => 'border=edge:0,type:mountain;border=edge:4,type:mountain;border=edge:5,type:mountain',
            %w[E10 K14] => 'border=edge:0,type:mountain;border=edge:1,type:mountain;border=edge:2,type:mountain',
            %w[F11] => 'upgrade=cost:80,terrain:mountain;border=edge:0,type:mountain;border=edge:1,type:mountain;border=edge:4,type:mountain;border=edge:5,type:mountain',
            %w[G10] => 'town=revenue:0;border=edge:0,type:mountain;border=edge:1,type:mountain;border=edge:2,type:mountain;border=edge:5,type:mountain',
            %w[I10] => 'town=revenue:0;border=edge:2,type:mountain;border=edge:3,type:mountain',
            %w[J11 J13] => 'border=edge:4,type:mountain;border=edge:5,type:mountain',
            %w[K10] => 'upgrade=cost:80,terrain:mountain;border=edge:0,type:mountain;border=edge:1,type:mountain;border=edge:2,type:mountain;border=edge:5,type:mountain',
            %w[L11] => 'upgrade=cost:80,terrain:mountain;border=edge:2,type:mountain;border=edge:3,type:mountain;border=edge:4,type:mountain;border=edge:4,type:mountain',
            %w[M10] => 'town=revenue:0;border=edge:0,type:mountain;border=edge:1,type:mountain;border=edge:2,type:mountain;border=edge:3,type:mountain',
            %w[A12] => 'border=edge:4,type:mountain',
            %w[B13] => 'town=revenue:0;upgrade=cost:20,terrain:river;border=edge:3,type:mountain;border=edge:4,type:mountain',
            %w[C12] => 'upgrade=cost:20,terrain:river;border=edge:0,type:mountain;border=edge:1,type:mountain;border=edge:5,type:mountain',
            %w[D13 G12] => 'town=revenue:0;upgrade=cost:20,terrain:river;border=edge:1,type:mountain;border=edge:2,type:mountain;border=edge:3,type:mountain',
            %w[E12] => 'upgrade=cost:20,terrain:river;border=edge:2,type:mountain;border=edge:3,type:mountain;border=edge:4,type:mountain',
            %w[F13] => 'upgrade=cost:20,terrain:river;border=edge:3,type:mountain;border=edge:4,type:mountain;border=edge:5,type:mountain',
            %w[K12 J17] => 'border=edge:1,type:mountain;border=edge:2,type:mountain;border=edge:3,type:mountain',
            %w[M12] => 'town=revenue:0;border=edge:3,type:mountain',
            %w[C14] => 'border=edge:3,type:mountain;border=edge:4,type:mountain;border=edge:5,type:mountain',
            %w[D15] => 'town=revenue:0;upgrade=cost:20,terrain:river;border=edge:1,type:mountain;border=edge:2,type:mountain',
            %w[E14] => 'upgrade=cost:20,terrain:river',
            %w[G14] => 'upgrade=cost:20,terrain:river;border=edge:0,type:mountain;border=edge:1,type:mountain;border=edge:2,type:mountain',
            %w[J15] => 'town=revenue:0;border=edge:0,type:mountain;border=edge:4,type:mountain;border=edge:5,type:mountain',
            %w[L15] => 'border=edge:1,type:mountain',
            %w[D17] => 'border=edge:0,type:mountain;border=edge:1,type:mountain;border=edge:2,type:mountain;border=edge:5,type:mountain',
            %w[E16] => 'upgrade=cost:40,terrain:mountain;border=edge:0,type:mountain;border=edge:5,type:mountain',
            %w[F17] => 'border=edge:2,type:mountain;border=edge:3,type:mountain',
            %w[G16 K16] => 'border=edge:2,type:mountain;border=edge:3,type:mountain;border=edge:4,type:mountain',
            %w[H17] => 'town=revenue:0;town=revenue:0;border=edge:3,type:mountain;border=edge:4,type:mountain',
            %w[D19] => 'town=revenue:0;border=edge:1,type:mountain;border=edge:2,type:mountain;border=edge:3,type:mountain',
            %w[E18] => 'city=revenue:0;upgrade=cost:20,terrain:river;border=edge:2,type:mountain;border=edge:3,type:mountain;label=Y',
            %w[F19] => 'town=revenue:0;upgrade=cost:20,terrain:river',
            %w[G18 K18 E20] => 'city=revenue:0;upgrade=cost:20,terrain:river',
            %w[I18] => 'upgrade=cost:40,terrain:mountain;border=edge:3,type:mountain;border=edge:4,type:mountain;border=edge:5,type:mountain',
            %w[C20] => 'town=revenue:0;upgrade=cost:20,terrain:river;border=edge:4,type:mountain',
            %w[I20] => 'upgrade=cost:120,terrain:mountain;border=edge:4,type:mountain',
          },
          yellow: {
            %w[L7] => 'city=revenue:30;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;label=Y',
            %w[H11] => 'city=revenue:40;city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:4,b:_0;path=a:1,b:_1;path=a:2,b:_2;border=edge:2,type:mountain;border=edge:3,type:mountain;label=M',
            %w[H13] => 'town=revenue:10;path=a:3,b:_0;path=a:5,b:_0',
            %w[I14] => 'path=a:2,b:5',
          },
          gray: {
            %w[D1] => 'path=a:0,b:1,track:dual;path=a:0,b:5,track:dual',
            %w[F1] => 'city=revenue:40,slots:2;path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;path=a:5,b:_0,track:dual',
            %w[A14] => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            %w[L17] => 'town=revenue:10;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
            %w[L19] => 'town=revenue:10;path=a:2,b:_0',
            %w[K20 H21] => 'path=a:2,b:3',
            %w[F21] => 'path=a:2,b:3;path=a:3,b:4',
          },
          red: {
            %w[K2 N3 O4 P5] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_70,hide:1;path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;border=edge:2;border=edge:5',
            %w[L3] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_70,hide:1;path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;path=a:5,b:_0,track:dual;border=edge:2;border=edge:4',
            %w[M2] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_70;path=a:0,b:_0,track:dual;border=edge:1;border=edge:5',
          },
          blue: {
            %w[J1] => 'offboard=revenue:20;path=a:1,b:_0,track:dual',
            %w[A16] => 'offboard=revenue:30;path=a:3,b:_0',
          },
        }.freeze

        POOL_SHARE_DROP = :one
        SELL_BUY_ORDER = :sell_buy
        SELL_MOVEMENT = :left_block_pres
        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false
        MUST_EMERGENCY_ISSUE_BEFORE_EBUY = true
        HOME_TOKEN_TIMING = :float
        MUST_BUY_TRAIN = :never

        SELL_AFTER = :operate

        GAME_END_CHECK = {}.freeze

        # Two tiles can be laid, only one upgrade
        TILE_LAYS = [{ lay: true, upgrade: true }, { lay: true, upgrade: true, cost: 20, cannot_reuse_same_hex: true }].freeze

        def init_minors
          @companies.map do |company|
            minor = Minor.new(sym: company.sym, name: company.name, tokens: [])
            hexes = abilities(company, :blocks_hexes)&.hexes
            minor.abilities << Engine::Ability::Teleport.new(type: :teleport, tiles: [], hexes: hexes)
            minor
          end
        end

        def setup
          @companies.each do |company|
            next if abilities(company, :no_buy)

            company.owner = @bank
          end
        end

        def event_close_companies!
          super

          @minors.dup.each { |minor| close_corporation(minor) }
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def init_round
          new_stock_round
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::HomeToken,
            G1858::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          @round_num = round_num
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
          ], round_num: round_num)
        end

        def entity_can_use_company?(_entity, _company)
          false
        end

        def city_spot_cost(city)
          entity = @round.current_entity
          return 0 unless entity.corporation?

          distance = entity.corporation.placed_tokens.min do |token|
            DISTANCES[token.city.coordinates].find_index(city.coordinates)
          end

          40 * distance || 20
        end

        def exchange_for_partial_presidency?
          true
        end

        def home_token_locations(corporation)
          Array(abilities(corporation, :blocks_hexes)).map { |ability, _| ability.hexes }.flatten.map { |id| hex_by_id(id) }.reject { |hex| hex.tile.cities.empty? }
        end

        def available_to_start?(_corporation)
          false
        end
      end
    end
  end
  # rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength
end
