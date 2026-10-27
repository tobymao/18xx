# frozen_string_literal: true

module Engine
  module Game
    module GFrost1831
      module Map
        LAYOUT = :flat

        LOCATION_NAMES = {
          'B1' => 'Northtown',
          'C10' => 'Snowfield',
          'D7' => 'New London',
          'D15' => 'Plymouth',
          'E8' => 'Slippery Plateau',
          'E14' => 'Coal Route',
          'G10' => 'Dead Lake',
          'G14' => 'South Coal Mine',
          'H3' => 'Old Tunnel',
          'H9' => 'Deep Frost Drilling',
          'I6' => 'Crossing Outpost',
          'I12' => 'Twin Villages',
          'I16' => 'South Passage',
          'J9' => 'Weather Station',
          'L9' => 'Snow Valley',
          'L15' => 'Farmtown',
          'M2' => 'Alberdeen',
          'M6' => 'Grand Junction',
          'O14' => 'Dover',
        }.freeze

        HEXES = {
          red: {
            # Offboard locations — external connections with phase-dependent revenues
            ['A2'] => 'offboard=revenue:yellow_20|green_30|brown_50,'\
                      'hide:1,groups:Northtown;'\
                      'path=a:0,b:_0,terminal:1;border=edge:4',
            ['B1'] => 'offboard=revenue:yellow_20|green_30|brown_50,'\
                      'groups:Northtown;'\
                      'path=a:0,b:_0;path=a:5,b:_0,terminal:1;border=edge:1;'\
                      'icon=image:frost_1831/N,sticky:1;',
            ['D15'] => 'city=revenue:yellow_30|green_40|brown_50;'\
                      'path=a:3,b:_0,terminal:1;icon=image:frost_1831/S,sticky:1;',
            ['I16'] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_60;'\
                      'path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1',
            ['M2'] => 'offboard=revenue:yellow_20|green_30|brown_50|gray_60;'\
                      'path=a:1,b:_0,terminal:1;'\
                      'icon=image:frost_1831/E,sticky:1;',
            ['O14'] => 'offboard=revenue:yellow_20|green_30|brown_50|gray_60;'\
                      'path=a:2,b:_0,terminal:1;'\
                      'icon=image:frost_1831/E,sticky:1;',
          },
          blue: {
            # === Pre-printed blue tiles (not upgradeable) ===
            %w[E8 L9] => '',
            ['G10'] => 'border=edge:4',
            ['H9'] => 'offboard=revenue:brown_40|gray_60,'\
                      'groups:DFD;'\
                      'path=a:2,b:_0,terminal:1;border=edge:1;border=edge:4',
            ['I8'] => 'border=edge:1',
          },
          green: {
            # === Pre-printed green tiles (upgradeable to brown/gray) ===
            ['L15'] => 'city=revenue:40;path=a:3,b:_0;path=a:4,b:_0;label=FT',
          },
          yellow: {
            # === Pre-printed yellow tiles (upgradeable to green) ===
            ['D7'] => 'city=revenue:30;city=revenue:30;city=revenue:30;'\
                      'path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_2;label=NL;'\
                      'icon=image:frost_1831/NL,sticky:1;upgrade=cost:50',
            ['I6'] => 'city=revenue:20;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            ['M6'] => 'city=revenue:30;path=a:2,b:_0;path=a:5,b:_0;'\
                      'label=GJ;upgrade=cost:50',
          },
          gray: {
            # === Pre-printed tiles (fixed, not upgradeable) ===
            ['E14'] => 'path=a:2,b:3;'\
                      'border=edge:4',
            ['F13'] => 'path=a:2,b:4;'\
                      'border=edge:1;border=edge:5',
            ['G2'] => 'path=a:5,b:1;path=a:5,b:2;border=edge:5',
            ['G14'] => 'city=revenue:yellow_40|green_30|brown_20;'\
                      'path=a:3,b:_0;path=a:4,b:_0;'\
                      'border=edge:2',
            ['H3'] => 'path=a:5,b:2;border=edge:2',
            ['J9'] => 'city=revenue:green_40|brown_50;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0',
          },
          white: {
            # === Empty plains (no terrain cost) ===
            %w[E12 K8 L7 L11
               N9] => '',

            # === Mountains (£50) — top/east edge barriers ===
            %w[B3 C2 H11 I10 J7 K4 K10] => 'upgrade=cost:50,terrain:mountain',

            # === Mountains (£80) — deep wilderness ===
            %w[J15] => 'upgrade=cost:80,terrain:mountain',

            # === NL Route hexes (continuous dotted line) ===
            # North branch: A2 offboard → A4 → A6 → B7 → C6 → D7(NL)
            ['A4'] => 'path=track:future,a:0,b:3;icon=image:frost_1831/influence_cube,sticky:1;'\
                      'upgrade=cost:80,terrain:mountain',
            ['A6'] => 'path=track:future,a:5,b:3;icon=image:frost_1831/influence_cube,sticky:1;'\
                      'upgrade=cost:50,terrain:mountain',
            ['B7'] => 'path=track:future,a:2,b:4;'\
                      'icon=image:frost_1831/blizzard,sticky:1;'\
                      'icon=image:frost_1831/influence_cube,sticky:1',
            ['C6'] => 'path=track:future,a:1,b:5;'\
                      'icon=image:frost_1831/influence_cube,sticky:1;'\
                      'icon=image:frost_1831/blizzard,sticky:1;'\
                      'upgrade=cost:50,terrain:mountain',
            # South branch: D7(NL) → D9 → C8 → C10 → C12 → D13 → D15(SP)
            ['D9'] => 'path=track:future,a:2,b:3;'\
                      'icon=image:frost_1831/influence_cube,sticky:1;'\
                      'icon=image:frost_1831/blizzard,sticky:1;'\
                      'upgrade=cost:80,terrain:mountain;'\
                      'border=edge:5,type:impassable',
            ['C8'] => 'path=track:future,a:0,b:5;'\
                      'icon=image:frost_1831/blizzard,sticky:1;'\
                      'icon=image:frost_1831/influence_cube,sticky:1',
            ['C10'] => 'path=track:future,a:0,b:3;'\
                      'icon=image:frost_1831/blizzard,sticky:1;'\
                      'icon=image:frost_1831/influence_cube,sticky:1;'\
                      'city=revenue:0;city=revenue:0;label=OO',
            ['C12'] => 'path=track:future,a:3,b:5;'\
                      'icon=image:frost_1831/influence_cube,sticky:1;'\
                      'upgrade=cost:50,terrain:mountain',
            # East branch: D7(NL) → E6 → E4 → E2 → F1 → Old Tunnel → I4 → I6(Crossing Outpost)
            ['E6'] => 'town=revenue:0;path=track:future,a:1,b:3;'\
                      'icon=image:frost_1831/blizzard,sticky:1;'\
                      'icon=image:frost_1831/influence_cube,sticky:1',
            ['E4'] => 'path=track:future,a:0,b:3;'\
                      'icon=image:frost_1831/blizzard,sticky:1;'\
                      'icon=image:frost_1831/influence_cube,sticky:1',
            ['E2'] => 'path=track:future,a:0,b:4;'\
                      'icon=image:frost_1831/influence_cube,sticky:1',
            ['F1'] => 'path=track:future,a:1,b:5;icon=image:frost_1831/influence_cube,sticky:1',
            ['I4'] => 'path=track:future,a:0,b:2;'\
                      'icon=image:frost_1831/influence_cube,sticky:1;'\
                      'upgrade=cost:50,terrain:mountain',
            # Crossing Outpost → H7 → G6 → F7 → F9 → F11 → G12 → H13 → I14 → J13 → K12 → L13 → L15(Farmtown) → M14 → N13 → O14(Dover)
            ['H7'] => 'path=track:future,a:2,b:4;icon=image:frost_1831/influence_cube,sticky:1',
            ['G6'] => 'path=track:future,a:1,b:5;'\
                      'icon=image:frost_1831/influence_cube,sticky:1;'\
                      'upgrade=cost:50,terrain:mountain',
            ['F7'] => 'path=track:future,a:0,b:4;'\
                      'icon=image:frost_1831/blizzard,sticky:1;'\
                      'icon=image:frost_1831/influence_cube,sticky:1',
            ['F9'] => 'city=revenue:0,slots:1;path=track:future,a:0,b:3;'\
                      'icon=image:frost_1831/blizzard,sticky:1;'\
                      'icon=image:frost_1831/influence_cube,sticky:1',
            ['F11'] => 'path=track:future,a:3,b:5;'\
                      'icon=image:frost_1831/influence_cube,sticky:1',
            ['G12'] => 'path=track:future,a:2,b:5;'\
                      'icon=image:frost_1831/influence_cube,sticky:1',
            ['H13'] => 'path=track:future,a:2,b:5;'\
                      'icon=image:frost_1831/influence_cube,sticky:1',
            ['I14'] => 'path=track:future,a:2,b:4;'\
                      'icon=image:frost_1831/influence_cube,sticky:1;'\
                      'upgrade=cost:50,terrain:mountain',
            ['J13'] => 'town=revenue:0;path=track:future,a:1,b:4;'\
                      'icon=image:frost_1831/influence_cube,sticky:1;',
            ['K12'] => 'path=track:future,a:1,b:5;'\
                      'icon=image:frost_1831/influence_cube,sticky:1',
            ['L13'] => 'path=track:future,a:0,b:2;'\
                      'icon=image:frost_1831/influence_cube,sticky:1',
            ['M14'] => 'path=track:future,a:1,b:4;'\
                      'icon=image:frost_1831/influence_cube,sticky:1;'\
                      'upgrade=cost:50,terrain:mountain',
            ['N13'] => 'path=track:future,a:1,b:5;'\
                      'icon=image:frost_1831/influence_cube,sticky:1;'\
                      'upgrade=cost:50,terrain:mountain',
            # Crossing Outpost → J5 → K6 → L5 → M6(Grand Junction) → N7 → N5 → M4 → L3 → M2(Alberdeen)
            ['J5'] => 'path=track:future,a:1,b:5;'\
                      'icon=image:frost_1831/influence_cube,sticky:1;'\
                      'upgrade=cost:50,terrain:mountain',
            ['K6'] => 'city=revenue:0;path=track:future,a:2,b:4;'\
                      'icon=image:frost_1831/influence_cube,sticky:1',
            ['L5'] => 'town=revenue:0;path=track:future,a:1,b:5;'\
                      'icon=image:frost_1831/influence_cube,sticky:1',
            ['N7'] => 'path=track:future,a:2,b:3;'\
                      'icon=image:frost_1831/influence_cube,sticky:1;'\
                      'upgrade=cost:50,terrain:mountain',
            ['N5'] => 'path=track:future,a:0,b:2;'\
                      'icon=image:frost_1831/influence_cube,sticky:1;',
            ['M4'] => 'path=track:future,a:2,b:5;'\
                      'icon=image:frost_1831/influence_cube,sticky:1;',
            ['L3'] => 'path=track:future,a:4,b:5;'\
                      'icon=image:frost_1831/influence_cube,sticky:1;'\
                      'upgrade=cost:80,terrain:mountain',
            # === Blizzard zone — central-west snowy region ===
            %w[B9 C4 D11 F5] => 'icon=image:frost_1831/blizzard,sticky:1',

            # === Corporation home cities ===
            # OE — Old England Corp
            ['D3'] => 'city=revenue:0,slots:1;icon=image:frost_1831/blizzard,sticky:1',
            # SP — Snow Pilgrims' Railway
            ['D13'] => 'city=revenue:0,slots:1;'\
                      'path=track:future,a:0,b:2;'\
                      'icon=image:frost_1831/influence_cube,sticky:1;',
            # CM — Southern Coal Mine
            # (CM home is now a gray pre-printed hex; token placed at game start)
            # TV — Twin Villages Guild
            ['I12'] => 'city=revenue:0,slots:1;city=revenue:0,slots:1;label=OO',
            # EC — East County Railroad
            ['M10'] => 'city=revenue:0,slots:1;',
            # === Other cities (no corp home) ===
            ['D5'] => 'city=revenue:0;icon=image:frost_1831/blizzard,sticky:1',
            ['E10'] => 'city=revenue:0;border=edge:2,type:impassable;'\
                      'icon=image:frost_1831/blizzard,sticky:1',
            ['J11'] => 'city=revenue:0',
            ['M12'] => 'city=revenue:0',

            # === Faction-reserved cities ===
            ['F3'] => 'city=revenue:0,slots:1;icon=image:frost_1831/faction_base,sticky:1',
            ['G8'] => 'city=revenue:0,slots:1;icon=image:frost_1831/faction_base,sticky:1',
            ['K14'] => 'city=revenue:0,slots:1;icon=image:frost_1831/faction_base,sticky:1',
            ['M8'] => 'city=revenue:0,slots:1;icon=image:frost_1831/faction_base,sticky:1',

            # === Towns ===
            ['B5'] => 'town=revenue:0;icon=image:frost_1831/blizzard,sticky:1',
          },
        }.freeze

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
              { text: 'Route Bonus', props: { style: { border: '1px solid' } } },
              { text: 'Path', props: { style: { border: '1px solid' } } },
              { text: '£', props: { style: { border: '1px solid' } } },
            ],
            # body
            [
              {
                text: 'NL → E (East)',
                props: { style: { border: "1px solid #{font_color}", color: 'white', backgroundColor: 'grey' } },
              },
              {
                text: 'NL-E',
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
                text: '+70',
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
              { text: 'S → NL → N', props: { style: { border: '1px solid' } } },
              { text: 'S-NL-N', props: { style: { textAlign: 'center', border: '1px solid' } } },
              { text: '+50', props: { style: { textAlign: 'right', border: '1px solid' } } },
            ],
          ]
        end
      end
    end
  end
end
