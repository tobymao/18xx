# frozen_string_literal: true

require_relative '../g_1846/map'

module Engine
  module Game
    module G18BB
      module Map
        TILES = G1846::Map::TILES.merge(
          {
            'CM1' => {
              'count' => 1,
              'color' => 'gray',
              'code' => 'city=revenue:70,slots:2;'\
                        'path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=CM',
            },
            'M1' => {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:1;'\
                        'path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=M',
            },
          }
        ).freeze

        LOCATION_NAMES = G1846::Map::LOCATION_NAMES.dup
        LOCATION_NAMES.merge!({
                                'J12' => 'Lexington',
                                'K9' => 'Bowling Green',
                                'J6' => 'Evansville',
                                'L8' => 'Nashville',
                              })
        LOCATION_NAMES.freeze

        def self.merge_hexes(*hex_sets)
          merged_hexes = Hash.new { |h, color| h[color] = {} }
          hex_sets.each do |hex_set|
            hex_set.each do |color, hexes|
              merged_hexes[color].update(hexes)
            end
          end
          merged_hexes
        end

        MODIFIED_HEXES = {
          yellow: {
            ['J10'] => 'city=revenue:40,groups:Louisville;city=revenue:40,groups:Louisville;'\
                       'path=a:2,b:_0;path=a:3,b:_0;path=a:0,b:_1;path=a:5,b:_1;label=Z;upgrade=cost:40,terrain:water',

          },
          red: {
            ['C5'] => 'offboard=revenue:yellow_20|brown_40,groups:NW;icon=image:1846/50;path=a:5,b:_0;label=N/W;icon=image:port',
            ['D22'] => 'offboard=revenue:yellow_30|brown_60,groups:E;icon=image:1846/30;'\
                       'path=a:1,b:_0;path=a:0,b:_0label=E;border=edge:2',
            ['F22'] => 'offboard=revenue:yellow_30|brown_70,hide:1,groups:E;icon=image:1846/20;'\
                       'path=a:1,b:_0;path=a:2,b:_0;border=edge:0',
            ['H20'] => 'offboard=revenue:yellow_20|brown_40,groups:E;icon=image:1846/30;path=a:1,b:_0;path=a:2,b:_0;label=E',
            ['I1'] => 'offboard=revenue:yellow_50|brown_70,groups:St. Louis;path=a:3,b:_0;'\
                      'path=a:4,b:_0;path=a:5,b:_0;border=edge:5,type:water,cost:40'\
                      'label=W;icon=image:port;icon=image:1846/meat;icon=image:1846/20;'\
                      'icon=image:18_bb/port-orange',
            ['I17'] => 'offboard=revenue:yellow_20|brown_50,groups:E;icon=image:1846/20;path=a:1,b:_0;path=a:2,b:_0;label=E;'\
                       'border=edge:2,type:water,cost:20;icon=image:18_bb/port-orange',
            ['L8'] => 'city=revenue:yellow_30|brown_60,groups:SW,slots:2;icon=image:1846/30;'\
                      'path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1;label=S/W;border=edge:2,type:water,cost:20;'\
                      'border=edge:3,type:water,cost:20;icon=image:18_bb/port-orange',
          },
          gray: {
            ['E21'] => 'city=revenue:yellow_10|green_20;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;'\
                       'icon=image:18_usa/oil-derrick',
            ['F20'] => 'city=revenue:yellow_10|green_20;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
                       'border=edge:2,type:mountain,cost:40',
            ['I5'] => 'city=revenue:yellow_10|green_20,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:0,b:_0',
            ['I15'] => 'city=revenue:yellow_20|green_30;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                       'border=edge:2,type:water,cost:20;border=edge:3,type:water,cost:20;',
            ['K3'] => 'city=revenue:20,slots:2;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'border=edge:4,type:water,cost:20;icon=image:18_bb/port-orange',
            ['H18'] => '',
          },
          white: {
            %w[G9 G15] => 'city=revenue:0;icon=image:18_usa/oil-derrick',
            ['I11'] => 'border=edge:3,type:water,cost:40;border=edge:2,type:water,cost:20;border=edge:1,type:water,cost:20',
            ['I13'] => 'upgrade=cost:40,terrain:mountain;border=edge:3,type:water,cost:40;border=edge:2,type:water,cost:60',
            ['I9'] => 'border=edge:4,type:water,cost:20',
            ['H10'] => 'border=edge:5,type:water,cost:20',
            ['H12'] => 'city=revenue:0;label=Z;border=edge:0,type:water,cost:40;border=edge:5,type:water,cost:60;'\
                       'icon=image:1846/lm,sticky:1;icon=image:1846/boom,sticky:1',
            ['H14'] => 'upgrade=cost:40,terrain:mountain;border=edge:0,type:water,cost:40;border=edge:5,type:water,cost:20',
            ['H16'] => 'upgrade=cost:40,terrain:mountain;border=edge:5,type:water,cost:20;'\
                       'border=edge:0,type:water,cost:20;',
            ['J12'] => 'city=revenue:0;upgrade=cost:40,terrain:mountain',
            ['K9'] => 'city=revenue:0;border=edge:0,type:water,cost:20',
            ['G17'] => 'upgrade=cost:40,terrain:mountain;border=edge:4,type:water,cost:20',
            %w[J14 K11 K13] => 'upgrade=cost:40,terrain:mountain',
            ['J8'] => 'upgrade=cost:40,terrain:water',
            ['J2'] => 'border=edge:2,type:water,cost:40',
            ['J4'] => 'border=edge:4,type:water,cost:40;border=edge:5,type:water,cost:20;icon=image:1846/ic',
            ['J6'] => 'city=revenue:0;border=edge:1,type:water,cost:40;border=edge:5,type:water,cost:40;' \
                      'border=edge:0,type:water,cost:20;icon=image:18_bb/port-orange;icon=image:18_bb/port-orange',
            ['K5'] => 'border=edge:1,type:water,cost:20;border=edge:2,type:water,cost:20;border=edge:3,type:water,cost:20',
            ['K7'] => 'border=edge:2,type:water,cost:40;border=edge:5,type:water,cost:20',
          },
        }.freeze
        BASE_HEXES = G1846::Map::HEXES.dup
        BASE_HEXES[:red].delete(['J10'])
        BASE_HEXES[:white].keys.each { |k| k.dup.each { |hex| k.delete(hex) if %w[H10 I9 J8 G9 G15].include?(hex) } }
        BASE_HEXES.freeze
        HEXES = merge_hexes(BASE_HEXES, MODIFIED_HEXES).freeze

        BRP_TILE = 'city=revenue:yellow_10|green_20,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;'\
                   'path=a:3,b:_0;path=a:5,b:_0;icon=image:18_usa/oil-derrick'
        VCC_TILE = 'city=revenue:40;border=edge:1,type:water,cost:20;border=edge:2,type:water,cost:20;'\
                   'path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;upgrade=cost:80,terrain:mountain;label=CM'
      end
    end
  end
end
