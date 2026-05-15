# frozen_string_literal: true

module Engine
  module Game
    module G1862UsaCanada
      module Map
        LAYOUT = :pointy
        AXES = { x: :number, y: :letter }.freeze

        LOCATION_NAMES = {
          # Pacific Northwest
          'B2' => 'Vancouver',
          'C1' => 'Victoria',
          'C3' => 'Seattle',
          'C5' => 'Spokane',
          'D2' => 'Portland',
          # Western Canada
          'A7' => 'Calgary',
          'B10' => 'Regina',
          'B14' => 'Winnipeg',
          'B20' => 'Thunder Bay',
          # Mountain West
          'E6' => 'Boise',
          'D10' => 'Billings',
          'E11' => 'Rapid City',
          'F8' => 'Ogden',
          'G9' => 'Salt Lake City/SLC',
          'G11' => 'Denver',
          # Pacific Coast
          'G3' => 'San Francisco/Sacramento',
          'I5' => 'Los Angeles',
          'J6' => 'San Diego',
          # Great Plains
          'D16' => 'Minneapolis',
          'D18' => 'Duluth',
          'G17' => 'Kansas City',
          'F14' => 'Omaha',
          'G19' => 'St. Louis',
          # Midwest / Great Lakes
          'F20' => 'Chicago',
          'G23' => 'Columbus',
          # Canada East
          'E25' => 'Toronto',
          'D26' => 'Ottawa',
          'C29' => 'Quebec',
          'D28' => 'Montreal',
          # Northeast
          'F28' => 'New York',
          'F30' => 'Boston',
          # Southwest
          'I9' => 'Phoenix',
          'J8' => 'Tucson',
          'J10' => 'Santa Fe',
          'H10' => 'Phoenix',
          # South Central
          'I15' => 'Oklahoma City',
          'J16' => 'Dallas',
          'I17' => 'Little Rock',
          'K15' => 'Austin',
          'K17' => 'Houston',
          # Southeast
          'J18' => 'Jackson',
          'I23' => 'Atlanta',
          'I21' => 'Chattanooga',
          'H26' => 'Richmond',
          'K19' => 'New Orleans',
          'J20' => 'Mobile',
          # Off-board labels
          'A29' => 'Labrador',
          'K9' => 'Mexico',
          'K11' => 'Mexico',
          'L24' => 'Florida',
        }.freeze

        # Tile counts from physical game tile sheet.
        # Yellow: 80 standard + 5 Sonderteile = 85 total
        # Green:  42 standard + 9 Sonderteile = 51 total
        # Brown:  19 standard + 7 Sonderteile = 26 total
        # Gray:    3 standard + 5 Sonderteile =  8 total
        TILES = {
          # Yellow
          '3' => 4,
          '4' => 10,
          '6' => 10,
          '7' => 4,
          '8' => 12,
          '9' => 22,
          '57' => 10,
          '58' => 8,
          # Green
          '14' => 4,
          '15' => 4,
          '16' => 2,
          '19' => 2,
          '20' => 2,
          '23' => 4,
          '24' => 4,
          '25' => 2,
          '26' => 2,
          '27' => 2,
          '28' => 2,
          '29' => 2,
          # Brown
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
          '611' => 7,
          # Gray (city upgrade tiles)
          '895' => 3,
          '899' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:80,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=NO',
          },
          # Special brown 5 edges only 10 revenue
          'GS_204_B' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;',
          },
          # Special gray — Toronto (placed by TOR private)
          'GS_TOR' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=T',
          },
          # Montreal upgrades (label=M; preprint is stored as white internally, exits to edge 2 only)
          'GS_MTL_Y' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:1,b:_0;path=a:2,b:_0;label=M',
          },
          'GS_MTL_G' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=M',
          },
          'GS_MTL_B' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=M',
          },
          # New York upgrades (label=NY; preprint yellow has 2 cities, exits 0/4 and 1/3)
          'GS_NY_G' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40;' \
                      'path=a:0,b:_0;path=a:4,b:_0;path=a:1,b:_1;path=a:3,b:_1;label=NY',
          },
          'GS_NY_B' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:3;' \
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=NY',
          },
          # Shared gray tile — only one exists; goes to Montreal (M) OR New York (NY), not both
          'GS_MTL_GR' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:80,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;' \
                      'path=a:4,b:_0;path=a:5,b:_0;label=M;label=NY',
          },
          # Salt Lake City upgrade yellow
          'GS_SLC_Y' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:1,b:_0;path=a:3,b:_0;label=SLC',
          },
          'GS_SLC_G' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=SLC',
          },
          'GS_SLC_B' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;' \
                      'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=SLC',
          },
          'GS_V_Y' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:5,b:_0;path=a:3,b:_0;label=V',
          },
          'GS_P_Y' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:0,b:_0;path=a:3,b:_0;label=P',
          },
          'GS_L_Y' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:5,b:_0;path=a:2,b:_0;label=L',
          },
          'GS_P_G' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=P',
          },
          'GS_V_G' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=V',
          },
          'GS_L_G' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:5,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=L',
          },
          'GS_S_G' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40;path=a:5,b:_0;path=a:2,b:_1;path=a:4,b:_1;label=S',
          },
          'GS_VSPL_B' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:3;path=a:2,b:_0;path=a:3,b:_0;' \
                      'path=a:4,b:_0;path=a:5,b:_0;label=V;label=S;label=P;label=L',
          },
          'GS_VSPL_G' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:80,slots:3;path=a:2,b:_0;path=a:3,b:_0;' \
                      'path=a:4,b:_0;path=a:5,b:_0;label=V;label=S;label=P;label=L',
          },
          'GS_C_G' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=C',
          },
          'GS_C_B' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=C',
          },
          'GS_NO_G' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=NO',
          },
          'GS_NO_B' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=NO',
          },
          'GS_C_GR' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:80,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=C',
          },

        }.freeze

        MAP_HOMECITY_HEXES = %w[
          C3 B14 D28 D16 F14 F20 F28 G3 J16 J20 K19
        ].freeze

        HEXES = {
          white: {
            # ── Blank upgradeable hexes ──────────────────────────────────────
            %w[
              A11 A13 A17 A19 A21 A23 A25 A27 B12 B14 B16 B18
              B20 B22 B24 B26 C13 C15 C17 C19 C21 C23 C25 C27
              C29 D4 D14 D16 D18 D20 D24 D26 E19 E27 F22
              F24 G15 G21 H14 H16 H18 H22 I25 J14 J22 K13 K23
            ] => '',

            # ── Mountain terrain ($80) ───────────────────────────────────────
            %w[
              A3 A5 B4 B6 B8 C7 C9 D6 D8 E3 E7 E9 F4 F6 F10
              G5 G7 H8 I7
            ] => 'upgrade=cost:80,terrain:mountain',

            # ── Hill terrain ($40) ───────────────────────────────────────────
            %w[
              A9 C11 D12 F12 F26 G13 G25 H12 H24 I11 I13 J12
            ] => 'upgrade=cost:40,terrain:mountain',

            # ── River terrain ($40) ──────────────────────────────────────────
            %w[A15 B28 D30 E1 E13 E15 E17 F2 F16 H4 H20 I19 J24 K21] => 'upgrade=cost:40,terrain:river',

            # ── City with River ($40) ────────────────────────────────────────
            %w[F18 G17] => 'city=revenue:0;upgrade=cost:40,terrain:river',

            # ── Town with river ($40) ────────────────────────────────────────
            %w[G19 J18] => 'town=revenue:0;upgrade=cost:40,terrain:river',

            # ── Plain cities ─────────────────────────────────────────────────
            %w[A7 B10 B14 C29 D16 D26 E11 G11 G23 G27 H10 I15 I23 J6 J10 J16 J20 K15] => 'city=revenue:0',

            # ── Towns ────────────────────────────────────────────────────────
            %w[C5 B20 D10 D18 E5 E29 F8 H6 H26 I9 I17 I21 J8 K17] => 'town=revenue:0',

            # ── Single-slot labeled cities ───────────────────────────────────
            ['B2'] => 'city=revenue:0;label=V', # Vancouver
            ['C3'] => 'city=revenue:0', # Seattle (ORN home)
            ['D2'] => 'city=revenue:0;label=P', # Portland
            ['D28'] => 'city=revenue:10;path=a:2,b:_0;label=M', # Montreal (CP home)
            ['F14'] => 'city=revenue:10;path=a:1,b:_0', # Omaha (UP home)
            ['I5'] => 'city=revenue:0;label=L', # Los Angeles
            # SLC pre-printed white tile — transcontinental junction
            ['G9'] => 'city=revenue:0;label=SLC',

          },

          gray: {
            # Victoria — pre-printed grey town
            ['C1'] => 'town=revenue:20;path=a:3,b:_0',
            # Great Lakes / border — grey blank
            %w[D22 E21] => '',
            # E23 — grey through-path (Toronto → F22 area), rotated 180° per map
            ['E23'] => 'path=a:4,b:0',
            # Toronto — grey city; track exits east into E23
            ['E25'] => 'city=revenue:20;path=a:1,b:_0',
            # Boston — grey city; track exits west toward New York (F28)
            ['F30'] => 'city=revenue:20;path=a:1,b:_0',
            # Unnamed grey town near Mexico border
            ['K7'] => 'town=revenue:20;path=a:2,b:_0',
          },

          yellow: {

            # Chicago: single city, exits W (→F18) and SW (→G19)
            ['F20'] => 'city=revenue:20;path=a:1,b:_0;path=a:0,b:_0;label=C',
            # New Orleans: 120° CW from original (edges 5→1, 0→2)
            ['K19'] => 'city=revenue:20;path=a:1,b:_0;path=a:2,b:_0;label=NO',
            # Sacramento: city 0=WP (→edge 5), city 1=CPR (→edge 0); 120° CCW from photo
            ['G3'] => 'city=revenue:0;city=revenue:0;path=a:4,b:_0;path=a:5,b:_1;label=S',
            # New York: city 0=NYC (NE→E29, W→F26), city 1=NYH (E→F30, SW→G27)
            ['F28'] => 'city=revenue:20;city=revenue:20;path=a:0,b:_0;path=a:4,b:_0;path=a:1,b:_1;path=a:3,b:_1;label=NY',
          },

          red: {
            # Labrador — far northeast off-board (20/40 by phase)
            ['A29'] =>
              'offboard=revenue:yellow_20|brown_40;path=a:0,b:_0;path=a:1,b:_0',
            # Mexico — two hexes south of map (0 yellow, 80 brown)
            ['K9'] =>
              'offboard=revenue:yellow_40|brown_80;path=a:2,b:_0;path=a:3,b:_0',
            ['K11'] =>
              'offboard=revenue:yellow_40|brown_80;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            # Florida — southeast off-board (30/60 by phase)
            ['L24'] =>
              'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0',
          },
        }.freeze
      end
    end
  end
end
