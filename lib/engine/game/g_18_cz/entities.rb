# frozen_string_literal: true

module Engine
  module Game
    module G18CZ
      module Entities
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
                  distance: [{ 'nodes' => ['town'], 'pay' => 2, 'visit' => 2 },
                             { 'nodes' => %w[city offboard town], 'pay' => 2, 'visit' => 2 }],
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
                  distance: [{ 'nodes' => ['town'], 'pay' => 2, 'visit' => 2 },
                             { 'nodes' => %w[city offboard town], 'pay' => 2, 'visit' => 2 }],
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
                  distance: [{ 'nodes' => ['town'], 'pay' => 3, 'visit' => 3 },
                             { 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 }],
                  price: 180,
                },
                {
                  name: '3Ed',
                  rusts_on: %w[6Ei 8Ej],
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
                  distance: [{ 'nodes' => ['town'], 'pay' => 3, 'visit' => 3 },
                             { 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 }],
                  price: 180,
                },
                {
                  name: '3Ee',
                  rusts_on: %w[6Ei 8Ej],
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
                  distance: [{ 'nodes' => ['town'], 'pay' => 4, 'visit' => 4 },
                             { 'nodes' => %w[city offboard town], 'pay' => 4, 'visit' => 4 }],
                  price: 400,
                },
                {
                  name: '4Ef',
                  rusts_on: ['8Ej'],
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
                  distance: [{ 'nodes' => ['town'], 'pay' => 4, 'visit' => 4 },
                             { 'nodes' => %w[city offboard town], 'pay' => 4, 'visit' => 4 }],
                  price: 400,
                },
                {
                  name: '4Eg',
                  rusts_on: ['8Ej'],
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
                  distance: [{ 'nodes' => ['town'], 'pay' => 5, 'visit' => 5 },
                             { 'nodes' => %w[city offboard town], 'pay' => 5, 'visit' => 5 }],
                  price: 500,
                },
                {
                  name: '5Eh',
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
                  distance: [{ 'nodes' => ['town'], 'pay' => 5, 'visit' => 5 },
                             { 'nodes' => %w[city offboard town], 'pay' => 5, 'visit' => 5 }],
                  price: 500,
                },
                {
                  name: '6Ei',
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
                  distance: [{ 'nodes' => ['town'], 'pay' => 5, 'visit' => 5 },
                             { 'nodes' => %w[city offboard town], 'pay' => 5, 'visit' => 5 }],
                  price: 500,
                },
                {
                  name: '8Ej',
                  distance: [{ 'nodes' => %w[city offboard], 'pay' => 8, 'visit' => 8 },
                             { 'nodes' => ['town'], 'pay' => 3, 'visit' => 99 }],
                  price: 1000,
                },
              ],
            },
          ].freeze

        COMPANIES = [
            {
              name: 'Plan - Tachau',
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
              name: 'Melnik – Mscheno',
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
              name: 'Zwittau – Politschka',
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
              name: 'Wolframs - Teltsch',
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
              name: 'Strakonitz – Blatna – Bresnitz',
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
              name: 'Martinitz – Rochlitz',
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
              name: 'Raudnitz – Kmetnowes',
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
              name: 'Schweißing – Haid',
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
              name: 'Deutschbrod – Tischnowitz',
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
              name: 'Troppau – Grätz',
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
              name: 'Hannsdorf – Mährisch Altstadt',
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
              name: 'Friedland - Bila',
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
              name: 'Aujezd – Luhatschowitz',
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
              name: 'Neuhaus – Wobratain',
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
              name: 'Opočno – Dobruschka',
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
              name: 'Wekelsdorf – Parschnitz – Trautenau',
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
              name: 'Nezamislitz – Morkowitz',
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
              name: 'Taus – Tachau',
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
              color: :'#e31e24',
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
              color: :'#2b2a29',
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
              color: :'#0971b7',
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
              color: :'#cc6f3c',
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
              color: :'#ae4a84',
              type: 'large',
              reservation_color: nil,
            },
            {
              float_percent: 60,
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
              float_percent: 60,
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
              color: :'#e1af33',
              text_color: 'black',
              type: 'medium',
              reservation_color: nil,
            },
            {
              float_percent: 60,
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
              float_percent: 60,
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
              color: :'#dbe285',
              text_color: 'black',
              type: 'medium',
              reservation_color: nil,
            },
            {
              float_percent: 60,
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
              color: :'#a2d9f7',
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
              fraction_shares: false,
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
              fraction_shares: false,
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
              color: :'#fabc48',
              text_color: 'black',
              type: 'small',
              reservation_color: nil,
              fraction_shares: false,
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
              fraction_shares: false,
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
              color: :'#009846',
              type: 'small',
              reservation_color: nil,
              fraction_shares: false,
            },
          ].freeze
      end
    end
  end
end
