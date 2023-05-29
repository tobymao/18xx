# frozen_string_literal: true

module Engine
  module Game
    module G18SJ
      module Map
        TILES = {
          '5' => 4,
          '6' => 4,
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '14' => 4,
          '15' => 4,
          '16' => 2,
          '17' => 1,
          '18' => 1,
          '19' => 2,
          '20' => 2,
          '21' => 1,
          '22' => 1,
          '23' => 3,
          '24' => 3,
          '25' => 2,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '30' => 1,
          '31' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 2,
          '42' => 2,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 2,
          '57' => 5,
          '63' => 2,
          '70' => 1,
          '611' => 2,
          '619' => 3,
          'X1' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Y',
          },
          'X2' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,groups:Stockholm;city=revenue:40,groups:Stockholm;'\
                      'city=revenue:40,groups:Stockholm;city=revenue:40,groups:Stockholm;path=a:0,b:_0;path=a:_0,b:2;'\
                      'path=a:3,b:_1;path=a:_1,b:2;path=a:4,b:_2;path=a:_2,b:2;path=a:5,b:_3;path=a:_3,b:2;label=A',
          },
          'X3' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:2;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Y',
          },
          'X4' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70,groups:Stockholm;city=revenue:70,groups:Stockholm;'\
                      'city=revenue:70,groups:Stockholm;city=revenue:70,groups:Stockholm;path=a:0,b:_0;path=a:_0,b:2;'\
                      'path=a:3,b:_1;path=a:_1,b:2;path=a:4,b:_2;path=a:_2,b:2;path=a:5,b:_3;path=a:_3,b:2;label=A',
          },
          'X5' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:90,slots:4;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=A',
          },
          'X6' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0',
          },
        }.freeze

        LOCATION_NAMES = {
          'A2' => 'Malmö',
          'A6' => 'Halmstad',
          'A10' => 'Göteborg',
          'A16' => 'Oslo',
          'B5' => 'Hässleholm',
          'B11' => 'Alingsås',
          'B31' => 'Narvik',
          'C2' => 'Ystad',
          'C8' => 'Jönköping',
          'C12' => 'Skövde',
          'C16' => 'Karlstad',
          'C24' => 'Östersund',
          'D5' => 'Kalmar',
          'D11' => 'Katrineholm',
          'D15' => 'Köping',
          'D19' => 'Bergslagen',
          'D21' => 'Sveg',
          'D29' => 'Malmfälten',
          'E8' => 'Norrköping',
          'E12' => 'Västerås',
          'E20' => 'Ånge',
          'F13' => 'Uppsala',
          'F19' => 'Sundsvall',
          'F23' => 'Umeå',
          'G10' => 'Stockholm',
          'G26' => 'Luleå',
          'H9' => 'Stockholms hamn',
        }.freeze

        HEXES = {
          red: {
            ['A2'] => 'city=revenue:yellow_20|green_40|brown_50;path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1;'\
                      'icon=image:18_sj/V,sticky:1',
            ['A10'] => 'city=revenue:yellow_20|green_40|brown_70;path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1;'\
                       'path=a:0,b:_0,terminal:1;icon=image:18_sj/V,sticky:1;icon=image:18_sj/b_lower_case,sticky:1',
            ['B31'] => 'offboard=revenue:yellow_20|green_30|brown_70;path=a:0,b:_0;icon=image:18_sj/N,sticky:1;'\
                       'icon=image:18_sj/m_lower_case,sticky:1',
            ['H9'] => 'offboard=revenue:green_30|brown_40;path=a:3,b:_0;icon=image:18_sj/O,sticky:1;'\
                      'icon=image:18_sj/b_lower_case,sticky:1;icon=image:18_sj/S,sticky:1',
          },
          gray: {
            ['A6'] => 'city=revenue:20;path=a:5,b:_0;path=a:0,b:_0;icon=image:port;icon=image:port',
            ['A16'] => 'city=revenue:yellow_50|green_40|brown_20;path=a:1,b:_0;path=a:5,b:_0;path=a:0,b:_0',
            ['D5'] => 'city=revenue:20;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;icon=image:port',
            ['F19'] => 'city=revenue:20;path=a:2,b:_0;path=a:3,b:_0;icon=image:port',
            ['F23'] => 'city=revenue:20;path=a:2,b:_0;path=a:3,b:_0;icon=image:port;icon=image:port',
            ['G26'] => 'city=revenue:20,slots:2;path=a:2,b:_0;path=a:3,b:_0;icon=image:port;'\
                       'icon=image:18_sj/m_lower_case,sticky:1',
          },
          blue: {
            ['B1'] => 'path=a:4,b:5',
            ['G8'] => 'path=a:3,b:4',
            %w[B13 C14] => '',
          },
          white: {
            %w[A4] => 'path=track:future,a:1,b:5;icon=image:18_sj/M-S,sticky:1',
            %w[C6 D7] => 'path=track:future,a:2,b:5;icon=image:18_sj/M-S,sticky:1',
            ['D13'] => 'path=track:future,a:0,b:2;icon=image:18_sj/G-S,sticky:1',
            %w[E14] => 'path=track:future,a:0,b:4;icon=image:18_sj/L-S,sticky:1',
            %w[E16 E18] => 'path=track:future,a:1,b:4;icon=image:18_sj/L-S,sticky:1',
            %w[E24] => 'path=track:future,a:1,b:5;icon=image:18_sj/L-S,sticky:1',
            %w[F25] => 'path=track:future,a:2,b:5;icon=image:18_sj/L-S,sticky:1',
            %w[G12] => 'path=track:future,a:1,b:3;icon=image:18_sj/L-S,sticky:1',
            ['E22'] =>
              'path=track:future,a:1,b:4;upgrade=cost:75,terrain:mountain;'\
              'icon=image:18_sj/L-S,sticky:1',
            ['B5'] =>
              'city=revenue:0;path=track:future,a:2,b:_0;path=track:future,a:5,b:_0;'\
              'icon=image:18_sj/M-S,sticky:1',
            ['E8'] =>
              'city=revenue:0;path=track:future,a:2,b:_0;path=track:future,a:5,b:_0;'\
              'icon=image:18_sj/M-S,sticky:1;icon=image:18_sj/GKB,sticky:1',
            ['E12'] =>
              'city=revenue:0;path=track:future,a:0,b:_0;path=track:future,a:3,b:_0;'\
              'icon=image:18_sj/G-S,sticky:1',
            %w[E20] =>
              'city=revenue:0;path=track:future,a:1,b:_0;path=track:future,a:4,b:_0;'\
              'icon=image:18_sj/L-S,sticky:1',
            %w[F13] =>
              'city=revenue:0;path=track:future,a:0,b:_0;path=track:future,a:3,b:_0;'\
              'icon=image:18_sj/L-S,sticky:1',
            ['C12'] =>
              'city=revenue:0;path=track:future,a:2,b:_0;path=track:future,a:5,b:_0;'\
              'border=edge:2,type:mountain,cost:75;icon=image:18_sj/G-S,sticky:1;'\
              'icon=image:18_sj/GKB,sticky:1',
            ['B11'] =>
              'city=revenue:0;path=track:future,a:2,b:_0;path=track:future,a:5,b:_0;'\
              'border=edge:5,type:mountain,cost:75;icon=image:18_sj/G-S,sticky:1',
            %w[A12 B19 B21 B23 B25 B27] =>
              'upgrade=cost:75,terrain:mountain',
            ['C30'] => 'upgrade=cost:150,terrain:mountain',
            ['D9'] => 'border=edge:2,type:impassable;border=edge:3,type:impassable',
            %w[B17 A8 A14 B3 B7 B9 B15 B29 C4 C18 C20 C22 C26 C28 D17 D23 D25 D27 D31] => '',
            %w[E10 E26 E28 E30 F15 F17 F21 F29 G14 G28 F27] => '',
            ['C10'] => 'border=edge:0,type:impassable;border=edge:5,type:impassable',
            %w[C24 D21] => 'city=revenue:0',
            ['C16'] => 'city=revenue:0;icon=image:18_sj/GKB,sticky:1',
            ['D11'] => 'city=revenue:0;border=edge:2,type:impassable',
            ['D29'] =>
              'city=revenue:0;upgrade=cost:75,terrain:mountain;icon=image:18_sj/M,sticky:1',
            ['F9'] =>
              'path=track:future,a:2,b:5;upgrade=cost:150,terrain:mountain;'\
              'icon=image:18_sj/M-S,sticky:1',
            ['F11'] =>
              'path=track:future,a:0,b:3;upgrade=cost:75,terrain:mountain;'\
              'icon=image:18_sj/G-S,sticky:1',
          },
          yellow: {
            ['C2'] => 'city=revenue:20;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Y;icon=image:port,sticky:1',
            ['C8'] =>
              'city=revenue:20;path=a:1,b:_0;path=a:2,b:_0;border=edge:5,type:impassable;icon=image:18_sj/GKB,sticky:1',
            ['D15'] => 'city=revenue:20;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            ['D19'] =>
              'city=revenue:20;path=a:5,b:_0;path=a:0,b:_0;icon=image:18_sj/B,sticky:1',
            ['G10'] =>
              'city=revenue:20,groups:Stockholm;city=revenue:20,groups:Stockholm;'\
              'city=revenue:20,groups:Stockholm;city=revenue:20,groups:Stockholm;path=a:1,b:_0;path=a:2,b:_1;'\
              'path=a:3,b:_2;path=a:4,b:_3;label=A',
          },
        }.freeze

        LAYOUT = :pointy

        def show_map_legend?
          true
        end

        def map_legend(font_color, *_extra_colors)
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
              { text: 'Icons', props: { style: { border: '1px solid' } } },
              { text: 'kr', props: { style: { border: '1px solid' } } },
            ],
            # body
            [
              {
                text: 'Bergslagen 1',
                props: { style: { border: "1px solid #{font_color}", color: 'white', backgroundColor: 'grey' } },
              },
              {
                text: 'B-b',
                props: {
                  style: {
                    textAlign: 'center',
                    border: "1px solid #{font_color}",
                    color: 'white',
                    backgroundColor: 'grey',
                  },
                },
              },
              {
                text: '50',
                props: {
                  style: {
                    textAlign: 'right',
                    border: "1px solid #{font_color}",
                    color: 'white',
                    backgroundColor: 'grey',
                  },
                },
              },
            ],
            [
              { text: 'Bergslagen 2', props: { style: { border: '1px solid' } } },
              { text: 'B-b-b', props: { style: { textAlign: 'center', border: '1px solid' } } },
              { text: '100', props: { style: { textAlign: 'right', border: '1px solid' } } },
            ],
            [
              {
                text: 'Lapplandspilen',
                props: { style: { border: "1px solid #{font_color}", color: 'white', backgroundColor: 'grey' } },
              },
              {
                text: 'N-S',
                props: {
                  style: {
                    textAlign: 'center',
                    border: "1px solid #{font_color}",
                    color: 'white',
                    backgroundColor: 'grey',
                  },
                },
              },
              {
                text: '100',
                props: {
                  style: {
                    textAlign: 'right',
                    border: "1px solid #{font_color}",
                    color: 'white',
                    backgroundColor: 'grey',
                  },
                },
              },
            ],
            [
              { text: 'Malmfälten 1', props: { style: { border: "1px solid #{font_color}" } } },
              { text: 'M-m', props: { style: { textAlign: 'center', border: "1px solid #{font_color}" } } },
              { text: '50', props: { style: { textAlign: 'right', border: "1px solid #{font_color}" } } },
            ],
            [
              {
                text: 'Malmfälten 2',
                props: { style: { border: "1px solid #{font_color}", color: 'white', backgroundColor: 'grey' } },
              },
              {
                text: 'M-m-m',
                props: {
                  style: {
                    textAlign: 'center',
                    border: "1px solid #{font_color}",
                    color: 'white',
                    backgroundColor: 'grey',
                  },
                },
              },
              {
                text: '100',
                props: {
                  style: {
                    textAlign: 'right',
                    border: "1px solid #{font_color}",
                    color: 'white',
                    backgroundColor: 'grey',
                  },
                },
              },
            ],
            [
              { text: 'Öst-Väst', props: { style: { border: '1px solid' } } },
              { text: 'Ö-V', props: { style: { textAlign: 'center', border: '1px solid' } } },
              { text: '120', props: { style: { textAlign: 'right', border: '1px solid' } } },
            ],
          ]
        end
      end
    end
  end
end
