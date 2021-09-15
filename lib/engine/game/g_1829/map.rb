# frozen_string_literal: true

module Engine
  module Game
    module G1829
      module Map
        LAYOUT = :pointy

        BASE_TILES = {
          '1' => 2,
          '2' => 2,
          '3' => 3,
          '4' => 6,
          '5' => 4,
          '6' => 4,
          '7' => 7,
          '8' => 8,
          '9' => 10,
          '12' => 3,
          '13' => 3,
          '14' => 3,
          '15' => 3,
          '16' => 1,
          '17' => 1,
          '18' => 1,
          '19' => 1,
          '20' => 1,
          '21' => 1,
          '22' => 1,
          '23' => 4,
          '24' => 4,
          '25' => 2,
          '26' => 2,
          '27' => 2,
          '28' => 1,
          '29' => 1,
          '30' => 1,
          '31' => 1,
          '32' => 1,
          '33' => 1,
          '34' => 1,
          '38' => 6,
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '48' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:100;city=revenue:100;city=revenue:100;city=revenue:100;city=revenue:100;city=revenue:100' \
            ';path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;label=LD',
          },
          '49' => 1,
          '50' => 2,
          '51' => 3,
        }.freeze

        K1_TILES = {
          '60' => 2,
          '166' => 4,
        }.freeze

        K5_TILES = {
          '55' => 2,
          '56' => 2,
          '11' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
              'town=revenue:10;path=a:0,b:_0;path=a:_0,b:2;path=a:2,b:4;path=a:0,b:4',
          },
          '59' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' =>
              'city=revenue:20;path=a:0,b:_0',
          },
        }.freeze

        K6_TILES = {
          '52' => 3,
          '64' => 1,
          '65' => 1,
          '66' => 1,
          '67' => 1,
        }.freeze
        K6_TILES_ALT = {
          '10' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:3,b:_1;label=OO',
          },
          '35' => 1,
          '36' => 1,
          '37' => 1,
        }.freeze

        DIT_UPGRADES = {
          # gentle curve to three curves with a halt
          '8' => %w[11],
          # yellow double-dit to green K or X city
          '1' => %w[14],
          '2' => %w[15],
          '55' => %w[14],
          '56' => %w[15],
          '59' => %w[12 13],
          # yellow single-dit to green city (also brown/green city)
          '3' => %w[12 14 15],
          '4' => %w[14 15],
          '58' => %w[12 13 14 15],
          # HACK: for 14/15 (green/brown tile that upgrades to browngray)
          '14' => %w[166],
          '15' => %w[166],
        }.freeze

        def append_game_tiles(gtiles, new_tiles)
          new_tiles.each do |k, v|
            if gtiles[k] && v.is_a?(Hash)
              raise GameError, "conflicting tile definitions for tile #{k}" unless gtiles[k].is_a?(Hash)

              gtiles[k]['count'] += v['count']
            elsif gtiles[k]
              raise GameError, "conflicting tile definitions for tile #{k}" if gtiles[k].is_a?(Hash)

              gtiles[k] += v
            else
              gtiles[k] = v.dup
            end
          end
        end

        def game_tiles
          gtiles = {}
          append_game_tiles(gtiles, BASE_TILES) if @units[1]
          append_game_tiles(gtiles, K1_TILES) if @kits[1]
          append_game_tiles(gtiles, K5_TILES) if @kits[5]
          append_game_tiles(gtiles, K6_TILES) if @kits[6]
          append_game_tiles(gtiles, K6_TILES_ALT) unless @kits[6]
          gtiles
        end

        HEXES = {
          white: {
            %w[B7] => 'city=revenue:0;upgrade=cost:40,terrain:water',
            %w[D15 E2 E10 F7 F13 H13 H17 H21 I18 J13 K20] => 'town',
            %w[D17
               E6
               E16
               F3
               F5
               F11
               F15
               F19
               G6
               G8
               G14
               G16
               G18
               G20
               G22
               H1
               H7
               H9
               H11
               H15
               H19
               I2
               I6
               I10
               I12
               I14
               I16
               I20
               J9
               J15
               K10
               K12
               K14
               K18
               L1
               L5
               L7
               L9
               L15
               L19
               M2
               M6
               M8] => 'blank',
            %w[L3 H3 H5 G4 E4 D9 D11 C10] =>
            'upgrade=cost:160,terrain:mountain',
            %w[C12 E12 E14 F21 G12 J5 K22 L17 L11 M4] => 'city',
            ['B9'] => 'town=revenue:0;town=revenue:0;upgrade=cost:160,terrain:mountain',
            %w[F17 I4 K8 K16] => 'town=revenue:0;town=revenue:0',
            %w[I8] => 'town=revenue:0;upgrade=cost:40,terrain:water',
            %w[B13 B15 C16 D3 D7] => 'upgrade=cost:40,terrain:water',
          },
          yellow: {
            %w[J7] =>
                     'city=revenue:0;city=revenue:0;label=OO;upgrade=cost:40,terrain:water',
            %w[L13 F9 D13 B11] => 'city=revenue:0;city=revenue:0;label=OO',
          },
          green: {
            ['C6'] => 'city=revenue:40;city=revenue:40;path=a:5,b:_0;path=a:3,b:_1;label=L',
            ['C8'] => 'city=revenue:40;city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_2
                      ;label=BGM',
            ['G10'] => 'city=revenue:40;city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:3,b:_1;path=a:5,b:_2
                       ;label=BGM',
            ['J17'] => 'city=revenue:50;city=revenue:50;city=revenue:50;path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_2
                       ;upgrade=cost:40,terrain:water;label=LD',
          },
          sepia: {
            ['A6'] => 'path=a:4,b:5',
            ['A8'] => 'path=a:4,b:1;path=a:0,b:5',
            ['A10'] => 'path=a:1,b:5;path=a:0,b:4',
            ['A12'] => 'city=revenue:30;path=a:1,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['A14'] => 'path=a:1,b:5',
            ['B17'] => 'city=revenue:20;path=a:1,b:_0;label=Hull',
            ['C14'] => 'city=revenue:20;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            ['D1'] => 'city=revenue:20;path=a:5,b:_0;path=a:4,b:_0;label=Holyhead',
            ['D5'] => 'path=a:1,b:4;path=a:1,b:5',
            ['E8'] => 'city=revenue:10;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            ['F23'] => 'town=revenue:10;path=a:0,b:_0;path=a:_0,b:1',
            ['G2'] => 'town=revenue:10;path=a:0,b:_0;path=a:_0,b:3',
            ['I22'] => 'city=revenue:20;path=a:1,b:_0;path=a:2,b:_0;label=Harwich',
            ['J3'] => 'city=revenue:20;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=S&M',
            ['J11'] => 'city=revenue:10;path=a:1,b:_0;path=a:2,b:_0;path=a:0,b:_0;path=a:4,b:_0',
            ['J19'] => 'city=revenue:20;path=a:1,b:_0;path=a:2,b:_0;path=a:1,b:2',
            ['K6'] => 'path=a:0,b:3;path=a:0,b:4',
            ['L21'] => 'city=revenue:10;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
            ['M10'] => 'city=revenue:20;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
            ['M18'] => 'path=a:2,b:3',
            ['N1'] => 'city=revenue:30;path=a:3,b:_0;path=a:4,b:_0',
            ['N3'] => 'path=a:1,b:3',
          },
        }.freeze
      end
    end
  end
end
