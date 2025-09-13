# frozen_string_literal: true

module Engine
  module Game
    module G1824Cisleithania
      module Map
        # Cislethania has 3 mine hexes
        MINE_HEXES = %w[C6 A12 A22].freeze

        def map_optional_hexes
          # For 3 players Budapest is a city for Pre-staatsbahn U1
          budapest = @players.size == 3 ? 'city' : 'offboard'
          b_major = ';icon=image:1824/B,sticky:1'
          b_minor = ';icon=image:1824/b_lower_case,sticky:1'
          {
            red: {
              ['A4'] => G1824::Map::DRESDEN_1,
              ['A24'] => G1824::Map::KIEW_1,
              ['A26'] => G1824::Map::KIEW_2,
              ['B3'] => G1824::Map::DRESDEN_2,
              ['E14'] =>
                'offboard=revenue:yellow_20|green_30|brown_40|gray_40;path=a:0,b:_0,terminal:1;'\
                'path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1',
              ['G12'] =>
                "#{budapest}=revenue:yellow_20|green_40|brown_60|gray_70;"\
                'path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1',
              ['F25'] =>
                'offboard=revenue:yellow_20|green_30|brown_40|gray_40;path=a:2,b:_0,terminal:1;'\
                'path=a:3,b:_0,terminal:1',
              ['H1'] => G1824::Map::MAINLAND_1,
              ['I2'] => G1824::Map::MAINLAND_2,
              ['I10'] =>
                'offboard=revenue:yellow_10|green_10|brown_50|gray_50;path=a:1,b:_0,terminal:1;'\
                'path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1',
            },
            gray: {
              ['A12'] => G1824::Map::MINE_2,
              ['A22'] => G1824::Map::MINE_3,
              ['B17'] => 'path=a:0,b:3;path=a:1,b:4;path=a:1,b:3;path=a:0,b:4',
              ['C6'] => G1824::Map::MINE_1,
            },
            white: {
              %w[A8 A20 C10 C16 G2] => G1824::Map::TOWN,
              %w[D25] => "#{G1824::Map::TOWN}#{b_minor}",
              %w[A6 A10] => G1824::Map::TOWN_WITH_MOUNTAIN,
              %w[E24] => "#{G1824::Map::TOWN_WITH_MOUNTAIN}#{b_minor}",
              %w[B13 B25 F11] => G1824::Map::DOUBLE_TOWN_WITH_WATER,
              %w[H3] => G1824::Map::CITY_WITH_MOUNTAIN,
              %w[A18 C26 I8] => G1824::Map::CITY_LABEL_T,
              ['E26'] => "#{G1824::Map::CITY_LABEL_T}#{b_minor}",
              %w[B5 B15 B23 C12 E8 F7 G4 G10] => G1824::Map::CITY,
              ['B9'] => "#{G1824::Map::CITY}#{b_major}",
              %w[B7 B11 B19 B21 C8 C14 C20 C22 C24 D9 D11 D13 D15 E6
                 F9 F13 G6 H9 H11] => G1824::Map::PLAIN,
              %w[D23 G8 H5 H7] => G1824::Map::PLAIN_WITH_MOUNTAIN,
              %w[E10] => G1824::Map::PLAIN_WITH_WATER,
              ['E12'] => "#{G1824::Map::WIEN}#{b_major}",
            },
          }
        end

        def show_map_legend?
          true
        end

        def map_legends
          ['bonus_legend']
        end

        def bonus_legend(_font_color, *_extra_colors)
          [
            # table-wide props
            {
              style: {
                margin: '0.5rem 0 0.5rem 0',
                border: '1px solid',
                borderCollapse: 'collapse',
              },
            },
            # header
            [
              { text: 'Bonus', props: { style: { border: '1px solid' } } },
              { text: 'Run', props: { style: { border: '1px solid' } } },
              { text: 'Icons', props: { style: { border: '1px solid' } } },
              { text: 'G', props: { style: { border: '1px solid' } } },
            ],
            # body
            [
              { text: 'Bukowina', props: { style: { border: '1px solid' } } },
              { text: 'Prag/Wien - Bukowina', props: { style: { textAlign: 'center', border: '1px solid' } } },
              { text: 'B-b', props: { style: { textAlign: 'center', border: '1px solid' } } },
              { text: '50', props: { style: { textAlign: 'right', border: '1px solid' } } },
            ],
          ]
        end
      end
    end
  end
end
