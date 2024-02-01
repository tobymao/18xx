# frozen_string_literal: true

module Engine
  module Game
    module GSystem18
      module Map
        S18_TILES = {
          '1' => 1,
          '2' => 1,
          '5' => 2,
          '6' => 2,
          '7' => 2,
          '8' => 2,
          '9' => 2,
          '12' => 1,
          '13' => 1,
          '14' => 2,
          '15' => 2,
          '23' => 1,
          '24' => 1,
          '25' => 1,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 1,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '53' => 2,
          '55' => 1,
          '56' => 1,
          '57' => 4,
          '59' => 2,
          '61' => 2,
          '63' => 4,
          '64' => 1,
          '65' => 1,
          '66' => 1,
          '67' => 1,
          '68' => 1,
          '69' => 1,
          '70' => 1,
          '205' => 1,
          '206' => 1,
          '619' => 2,
        }.freeze

        def game_tiles
          tiles = {}
          S18_TILES.each { |i,j| tiles[i] = j.dup }

          if map?(:NEUS)
            tiles.delete('5')
            tiles.delete('12')
            tiles.delete('13')
            tiles.delete('205')
            tiles.delete('206')
            tiles.delete('619')
            tiles.merge!({
              '54' => 1,
              '62' => 1,
              'X1' =>
              {
                'count' => 1,
                'color' => 'gray',
                'code' =>
                'city=revenue:70,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=B'
              },
              'X2' =>
              {
                'count' => 1,
                'color' => 'gray',
                'code' =>
                'city=revenue:100,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=NY'
              },
            })
          elsif map?(:France)
            tiles['619'] = 1
            tiles.merge!({
              '204' => 1,
              '611' => 2,
              'X1' =>
              {
                'count' => 1,
                'color' => 'gray',
                'code' =>
                'city=revenue:70,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=B'
              },
              'X3' =>
              {
                'count' => 1,
                'color' => 'green',
                'code' =>
                'city=revenue:60;city=revenue:60;city=revenue:60;path=a:0,b:_0;path=a:5,b:_0;path=a:1,b:_1;path=a:2,b:_1;path=a:3,b:_2;path=a:4,b:_2;label=P'
              },
              'X4' =>
              {
                'count' => 1,
                'color' => 'brown',
                'code' =>
                'city=revenue:80,slots:2;city=revenue:80;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_1;path=a:3,b:_1;path=a:4,b:_0;path=a:5,b:_0;label=P'
              },

            })
          end

          tiles
        end

        def game_location_names
          if map?(:NEUS)
            {
              'B3' => 'Chicago',
              'B11' => 'Detroit & Cleveland',
              'B11' => 'Erie',
              'B11' => 'Boston',
              'C10' => 'New York City',
              'D9' => 'Washington DC',
            }
          elsif map?(:France)
            {
              'B4' => 'London',
              'B6' => 'Lille',
              'C3' => 'Caen',
              'C5' => 'Paris',
              'C9' => 'Strasbourg',
              'C11' => 'Stuttgart',
              'D2' => 'Nantes',
              'D4' => 'Tours & Poitiers',
              'D8' => 'Dijon & Geneva',
              'E3' => 'Bordeaux',
              'E7' => 'Lyon',
              'F4' => 'Toulouse',
              'F6' => 'Montpelier',
              'F8' => 'Marseille',
              'F10' => 'Monaco',
              'G5' => 'Barcelona',
            }
          end
        end

        def game_hexes
          if map?(:NEUS)
            {
              gray: {
                ['A6'] => 'path=a:0,b:5',
                ['A2'] => 'path=a:4,b:5',
                ['A4'] => 'path=a:1,b:5',
                ['A8'] => 'path=a:0,b:5;path=a:0,b:4',
                ['A10'] => 'path=a:0,b:5;path=a:1,b:4',
                ['A12'] => 'path=a:0,b:1',

                ['D3'] => 'path=a:3,b:4',
                ['D11'] => 'path=a:0,b:1',
                %w[E8 E10] => 'path=a:2,b:3',
              },

              blue: {
                ['B1'] => 'junction;path=a:4,b:_0,terminal:1',
                ['C2'] => 'junction;path=a:3,b:_0,terminal:1',
                ['C12'] => 'junction;path=a:2,b:_0,terminal:1',

              },
              white: {
                %w[B7 C4] => 'city',
                %w[C6] => 'town=revenue:0;town=revenue:0;upgrade=cost:120,terrain:mountain',
                %w[C8] => 'town=revenue:0;town=revenue:0;upgrade=cost:40,terrain:mountain',
                %w[B9 D5] => 'upgrade=cost:40,terrain:mountain',
                ['D7'] => 'upgrade=cost:120,terrain:mountain',
              },
              yellow: {
                ['B3'] => 'city=revenue:30;path=a:2,b:_0;path=a:4,b:_0;label=B',
                ['B5'] => 'city=revenue:0;city=revenue:0;label=OO',
                ['D9'] => 'city=revenue:30;city=revenue:0;path=a:2,b:_0;label=OO',
                ['B11'] => 'city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;label=B',
                ['C10'] => 'city=revenue:40;city=revenue:40;path=a:2,b:_0;label=NY',
                ['I15'] => 'city=revenue:30;path=a:4,b:_0;path=a:0,b:_0;label=B',

              },
            }
          elsif map?(:France)
            {
              gray: {
                %w[A5] => 'town=revenue:0;path=a:0,b:_0;path=a:5,b:_0',
                %w[B8] => 'town=revenue:0;town=revenue:0;path=a:0,b:_0;path=a:1,b:_0;path=a:0,b:_1;path=a:5,b:_1',
                %w[C1] => 'town=revenue:0;path=a:4,b:_0;path=a:5,b:_0',
                %w[D10] => 'town=revenue:0;path=a:1,b:_0;path=a:2,b:_0',
                %w[E1 F2] => 'town=revenue:0;path=a:3,b:_0;path=a:4,b:_0',
                %w[E9] => 'town=revenue:0;town=revenue:0;path=a:0,b:_0;path=a:1,b:_0;path=a:1,b:_1;path=a:2,b:_1',
                %w[G9] => 'town=revenue:0;path=a:2,b:_0;path=a:3,b:_0',
              },

              red: {
                %w[B4] => 'offboard=revenue:green_40|brown_70;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
                %w[C11] => 'offboard=revenue:yellow_20|green_30|brown_40;path=a:1,b:_0',
                %w[F10] => 'offboard=revenue:green_30|brown_40;path=a:1,b:_0;path=a:0,b:_0',
                %w[G5] => 'offboard=revenue:yellow_20|green_20|brown_40;path=a:2,b:_0;path=a:3,b:_0',
              },
              white: {
                %w[C3 C9 D2 E3 E7 F4 F6] => 'city',
                %w[C7 D6 E5] => 'town=revenue:0;town=revenue:0',
              },
              yellow: {
                ['B6'] => 'city=revenue:30;path=a:4,b:_0;label=B',
                ['C5'] => 'city=revenue:40;city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:4,b:_1;path=a:5,b:_2;label=P',
                %w[D4 D8] => 'city=revenue:0;city=revenue:0;label=OO',
                ['F8'] => 'city=revenue:30;path=a:1,b:_0;label=B',
              },
            }
          end
        end

        LAYOUT = :pointy
      end
    end
  end
end
