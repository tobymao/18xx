# frozen_string_literal: true

module Engine
  module Game
    module GFrost1831
      module Tiles
        # Frost 1831 Tileset: 43 Yellow, 38 Green, 24 Brown, 4 Gray = 109 total
        # rubocop:disable Layout/LineLength
        TILES = {
          # ========================================
          # YELLOW (43 total)
          # ========================================

          # Plain track (25)
          '7' => 5,   # Sharp curve (edges 0-1)
          '8' => 10,  # Gentle curve (edges 0-2)
          '9' => 10,  # Straight (edges 0-3)

          # Town rev 10 (5)
          '3' => 1,   # Town + gentle curve, exits 0-4
          '4' => 1,   # Town + straight, exits 0-3
          '58' => 3,  # Town + gentle curve (variant), exits 0-2

          # City 1-slot rev 20 (11)
          '5' => 2,   # City 1-slot, straight, exits 0-3
          '57' => 3,  # City 1-slot, straight (variant), exits 0-4
          '6' => 4,   # City 1-slot, curve, exits 0-2

          # OO - two cities 1-slot rev 20 each (4)
          'O1' => {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:20;city=revenue:20;path=a:0,b:_0;path=a:2,b:_0;path=a:1,b:_1;path=a:3,b:_1;label=OO',
          },
          '404' => {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:20;city=revenue:20;path=a:1,b:_0;path=a:3,b:_0;path=a:0,b:_1;path=a:4,b:_1;label=OO',
          },

          # ========================================
          # GREEN (38 total)
          # ========================================

          # Plain track (14)
          '23' => 3,  # Track X (4 exits)
          '24' => 3,  # Track junction (4 exits)
          '25' => 2,  # Track (3 exits, variant)
          '26' => 1,  # Track junction
          '27' => 1,  # Track junction
          '28' => 1,  # Track junction
          '29' => 1,  # Track junction
          '16' => 1,  # Track double-curve
          '17' => 1,  # Track
          '18' => 1,  # Track
          '19' => 1,  # Track
          '20' => 1,  # Track + halt (town, rev 10)
          '21' => 1,  # Track
          '22' => 1,  # Track

          # Town rev 10 (2) — standard tiles in engine
          '141' => 1, # Town + gentle curve, exits 0-1-3
          '142' => 1, # Town + straight, exits 0-3-5

          # City 2-slot rev 30 (9)
          '14' => 4,  # City 2-slot, straight
          '15' => 2,  # City 2-slot, curve
          '619' => 3, # City 2-slot, 3 exits

          # OO - two cities 1-slot rev 30 each (4)
          '215' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:0,b:_1;path=a:4,b:_1;label=OO',
          },
          'O2' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:2,b:_0;path=a:1,b:_1;path=a:3,b:_1;label=OO',
          },

          # Special labeled tiles — 2 cities (1x 2-slot + 1x 1-slot) (4)
          'NL11' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;city=revenue:50;path=a:0,b:_0;path=a:3,b:_0;path=a:5,b:_0;path=a:1,b:_1;label=NL;upgrade=cost:50',
          },
          'NL12' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;city=revenue:50;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_1;label=NL;upgrade=cost:50',
          },
          'NL13' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;city=revenue:50;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:1,b:_1;label=NL;upgrade=cost:50',
          },
          'GJ1' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:5,b:_0;label=GJ;upgrade=cost:50',
          },

          # ========================================
          # BROWN (24 total)
          # ========================================

          # Plain track (11)
          '39' => 1,
          '40' => 1,
          '41' => 2,
          '42' => 2,
          '43' => 1,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,

          # Town rev 20 (1) — standard tile in engine
          '145' => 1,

          # City 2-slot rev 40 (4)
          '611' => 4,

          # City 3-slot rev 40 (3) — custom override (base 218 has label X, 2 slots)
          '218' => {
            'count' => 3,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },

          # OO - two cities 2-slot rev 50 each (2)
          'X7' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=OO',
          },

          # Special labeled tiles (3)
          'NL2' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=NL;upgrade=cost:50',
          },
          'GJ2' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=GJ;upgrade=cost:50',
          },
          '246' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:2;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=FT',
          },

          # ========================================
          # GRAY (4 total)
          # ========================================

          # City 4-slot rev 50 (2) — custom override (base 915 has 3 slots)
          '915' => {
            'count' => 2,
            'color' => 'gray',
            'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },

          # Special labeled tiles (2)
          'NL3' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=NL',
          },
          'GJ3' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:70,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=GJ',
          },
        }.freeze
        # rubocop:enable Layout/LineLength
      end
    end
  end
end
