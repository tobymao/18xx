# frozen_string_literal: true

module Engine
  module Game
    module G1864
      module Map
        # The rulebook directs using 1861's track tile manifest.
        TILES = {
          '3' => 2,
          '4' => 4,
          '5' => 2,
          '6' => 2,
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '14' => 2,
          '15' => 2,
          '16' => 2,
          '17' => 2,
          '18' => 2,
          '19' => 2,
          '20' => 2,
          '21' => 2,
          '22' => 2,
          '23' => 5,
          '24' => 5,
          '25' => 4,
          '26' => 2,
          '27' => 2,
          '28' => 2,
          '29' => 2,
          '30' => 2,
          '31' => 2,
          '39' => 2,
          '40' => 2,
          '41' => 2,
          '42' => 2,
          '43' => 2,
          '44' => 2,
          '45' => 2,
          '46' => 2,
          '47' => 2,
          '57' => 2,
          '58' => 4,
          '63' => 3,
          '87' => 2,
          '88' => 2,
          '201' => 3,
          '202' => 3,
          '204' => 2,
          '207' => 5,
          '208' => 2,
          '611' => 3,
          '619' => 2,
          '621' => 2,
          '622' => 2,
          '623' => 3,
          '624' => 1,
          '625' => 1,
          '626' => 1,
          '635' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,loc:0.5;city=revenue:40,loc:2.5;city=revenue:40,loc:4.5;'\
                      'path=a:4,b:_0;path=a:_0,b:3;path=a:0,b:_2;path=a:_2,b:5;path=a:2,b:_1;'\
                      'path=a:_1,b:1;label=K;upgrade=cost:40,terrain:water',
          },
          '636' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;path=a:4,b:_0;path=a:3,b:_0;path=a:2,b:_0;'\
                      'path=a:1,b:_0;path=a:0,b:_0;path=a:5,b:_0;label=K',
          },
          '637' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,loc:0.5;city=revenue:50,loc:2.5;city=revenue:50,loc:4.5;'\
                      'path=a:4,b:_0;path=a:_0,b:3;path=a:0,b:_2;path=a:_2,b:5;'\
                      'path=a:2,b:_1;path=a:_1,b:1;label=M',
          },
          '638' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70,slots:3;path=a:4,b:_0;path=a:3,b:_0;path=a:2,b:_0;'\
                      'path=a:1,b:_0;path=a:0,b:_0;path=a:5,b:_0;label=M',
          },
          '639' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:100,slots:4;path=a:4,b:_0;path=a:3,b:_0;path=a:2,b:_0;'\
                      'path=a:1,b:_0;path=a:0,b:_0;path=a:5,b:_0;label=M',
          },
          '640' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:3;path=a:4,b:_0;path=a:3,b:_0;path=a:2,b:_0;'\
                      'path=a:1,b:_0;path=a:0,b:_0;path=a:5,b:_0;label=Kh',
          },
          '641' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;path=a:4,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=S',
          },
          '642' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:70,slots:3;path=a:4,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=S',
          },
          '801' => 2,
          '911' => 3,

          # Game-specific tiles from cards/StdEd-SheetG-1.pdf (bottom-left of the sheet).
          # Cheyenne ("C" label) set: the map hex starts blank, upgraded with these.
          'X1' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:4,b:_0;path=a:1,b:_0;label=C',
          },
          'X2' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;path=a:4,b:_0;path=a:2,b:_0;path=a:0,b:_0;label=C',
          },
          # Omaha ("O" label) set: the yellow tile is pre-printed directly on hex F27;
          # these are its green/brown upgrades (Task 4's NATIONAL_RESERVATIONS handles
          # the UP-reserved slot and minor N's home).
          'X3' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30;path=a:4,b:_0;path=a:3,b:_0;path=a:2,b:_0;'\
                      'path=a:1,b:_0;path=a:0,b:_0;path=a:5,b:_0;label=O',
          },
          'X4' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:2;path=a:4,b:_0;path=a:2,b:_0;path=a:0,b:_0;label=O',
          },
          # Bailey Yard ("BY" label) set: the map hex starts blank, upgraded with these
          # three - the striped yellow/green tile is its first tile.
          'X5' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:4,b:_0;path=a:1,b:_0;label=BY',
          },
          'X6' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;path=a:4,b:_0;path=a:3,b:_0;path=a:2,b:_0;'\
                      'path=a:1,b:_0;path=a:0,b:_0;path=a:5,b:_0;label=BY',
          },
          'X7' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:70,slots:3;path=a:4,b:_0;path=a:3,b:_0;path=a:2,b:_0;'\
                      'path=a:1,b:_0;path=a:0,b:_0;path=a:5,b:_0;label=BY',
          },
        }.freeze

        LOCATION_NAMES = {
          # The 10 cities Task 11's route bonuses match on - spelled exactly as printed.
          'B27' => 'Great Lakes',
          'B5' => 'Seattle',
          'K28' => 'New Orleans',
          'J5' => 'Los Angeles',
          'H29' => 'St. Louis',
          'G2' => 'San Francisco',
          'E28' => 'Chicago',
          'F27' => 'Omaha',
          'F19' => 'Cheyenne',
          'G14' => 'Salt Lake',

          # Other named hexes (flavor / minor homes / special revenue spots).
          'A4' => 'Japan',
          'A12' => 'Canada',
          'B11' => 'Spokane',
          'C6' => 'Portland',
          'B23' => 'Bismarck',
          'C18' => 'Billings',
          'D5' => 'Eugene',
          'D11' => 'Boise',
          'D13' => 'Sun Valley Ski Resort',
          'D15' => "Yellowstone Nat'l Park",
          'F1' => 'China',
          'F23' => 'Bailey Yard',
          'G20' => 'Denver',
          'I8' => 'Death Valley',
          'J19' => 'Santa Fe',
          'J25' => 'Oklahoma City',
          'K4' => 'Australia',
          'K12' => 'Phoenix',
          'L13' => 'Mexico',
        }.freeze

        HEXES = {
          white: {
            %w[A22 A24 B17 B19 B21 B25 C14 C16 C20 C24 C26 D3 D7 D9 D17 D19
               D21 D25 D27 E4 E8 E10 E14 E16 E20 E22 F3 F9 F15 F21 F25 G8 G10 G22 G24 G26 H3
               H7 H9 H13 H19 H21 H23 H25 H27 I4 I6 I10 I12 I14 I18 I20 I22 I24 I26 I28 J7 J9
               J11 J13 J17 J21 J23 J27 K6 K8 K10 K16 K22 K24] => '',
            # Bismarck, Billings, Santa Fe, Oklahoma City: printed only as a decorative
            # minor-home medallion with no revenue number (matching 1861's minor-only
            # homes such as E9/H18/I13/I19/K17), so each gets a plain unlabelled city.
            %w[B23 C18 J19 J25] => 'city=revenue:0',
            %w[E6 E12 F5 F7 F17 G6 G12 H11 I16 J15 K14] => 'upgrade=cost:20,terrain:mountain',
            # The $20 mountain cost is printed on the two edges facing Canada
            # (2 = northwest, 3 = northeast), not across the whole hex.
            %w[B7 B9] => 'border=edge:2,type:mountain,cost:20;border=edge:3,type:mountain,cost:20',
            %w[B15 C8] => 'town=revenue:0',
            ['C6'] => 'city=revenue:0;upgrade=cost:20,terrain:water',
            %w[B13 F13 G4 G16 H15] => 'upgrade=cost:40,terrain:mountain',
            %w[C4 C22 D23 E24 E26 K18 K20 K26] => 'upgrade=cost:20,terrain:water',
            ['F19'] => 'label=C',
            ['F23'] => 'label=BY',
            ['G28'] => 'upgrade=cost:40,terrain:water',
          },
          yellow: {
            ['B5'] => 'city=revenue:30;path=a:4,b:_0;path=a:5,b:_0;label=Y;upgrade=cost:20,terrain:water',
            ['B11'] =>
            'city=revenue:20;path=a:1,b:_0;path=a:4,b:_0;'\
            'border=edge:2,type:mountain,cost:20;border=edge:3,type:mountain,cost:20',
            ['D5'] => 'city=revenue:20;path=a:0,b:_0;path=a:3,b:_0',
            ['F27'] =>
            'city=revenue:20;path=a:1,b:_0;path=a:5,b:_0;label=O;upgrade=cost:40,terrain:water',
            ['G2'] => 'city=revenue:30;path=a:4,b:_0;path=a:5,b:_0;label=Y;future_label=label:Kh,color:gray',
            # Two minor homes (KR, MNN): west stub feeds city 0, east stub feeds city 1.
            ['G14'] => 'city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:4,b:_1;label=K',
            # Three minor homes (M-K east, TR northwest, KK southwest), matching the
            # three-slot pattern 1861 uses for its own triple-minor hex (H8/Moscow).
            ['G20'] =>
            'city=revenue:30;city=revenue:30;city=revenue:30;path=a:4,b:_0;path=a:2,b:_1;'\
            'path=a:0,b:_2;label=M',
            ['J5'] => 'city=revenue:30;path=a:2,b:_0;path=a:0,b:_0;label=Y',
            ['K12'] => 'city=revenue:30;path=a:3,b:_0;path=a:1,b:_0;label=Y',
          },
          green: {
            # Two cities: city 0 carries minor Y's home (edges 0-1), city 1 is the
            # second, unreserved slot (edges 0-5).
            ['D11'] =>
            'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:1,b:_0;'\
            'path=a:0,b:_1;path=a:5,b:_1;label=S',
          },
          gray: {
            %w[E18 F11 G18 H5 H17] => '',
            ['C10'] => 'icon=image:mountain',
            ['C12'] => 'icon=image:mountain;path=a:2,b:3',
            ['D13'] =>
            'town=revenue:yellow_10|green_20|brown_30|gray_40;'\
            'path=a:0,b:_0;path=a:5,b:_0;icon=image:mountain',
            ['D15'] =>
            'town=revenue:yellow_10|green_20|brown_30|gray_40;'\
            'path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0',
            ['I8'] =>
            'town=revenue:yellow_10|green_20|brown_30|gray_40;path=a:3,b:_0;path=a:1,b:_0;path=a:5,b:_0',
          },
          red: {
            # The Canada band. A6-A12 face B7/B9/B11, whose printed $20 mountain
            # cost sits on the shared edges; borders are declared on BOTH hexes so
            # each draws its own half of the cost marker and neither can cover the
            # other (the marker is centred on the edge). Same convention as 1807.
            %w[A14 A16 A18] =>
            'offboard=revenue:yellow_20|green_30|brown_50|gray_60,hide:1,groups:Canada;'\
            'path=a:0,b:_0;path=a:5,b:_0;border=edge:4;border=edge:1',
            ['A6'] =>
            'offboard=revenue:yellow_20|green_30|brown_50|gray_60,hide:1,groups:Canada;'\
            'path=a:0,b:_0;path=a:5,b:_0;border=edge:4;border=edge:1;'\
            'border=edge:5,type:mountain,cost:20',
            %w[A8 A10] =>
            'offboard=revenue:yellow_20|green_30|brown_50|gray_60,hide:1,groups:Canada;'\
            'path=a:0,b:_0;path=a:5,b:_0;border=edge:4;border=edge:1;'\
            'border=edge:0,type:mountain,cost:20;border=edge:5,type:mountain,cost:20',
            ['A12'] =>
            'offboard=revenue:yellow_20|green_30|brown_50|gray_60,groups:Canada;'\
            'path=a:0,b:_0;path=a:5,b:_0;border=edge:4;border=edge:1;'\
            'border=edge:0,type:mountain,cost:20',
            ['A20'] =>
            'offboard=revenue:yellow_20|green_30|brown_50|gray_60,hide:1,groups:Canada;'\
            'path=a:4,b:_0;path=a:0,b:_0;path=a:5,b:_0;border=edge:1',
            ['B27'] =>
            'offboard=revenue:yellow_20|green_30|brown_50|gray_60,groups:GreatLakes;'\
            'path=a:1,b:_0;path=a:0,b:_0',
            ['E28'] =>
            'offboard=revenue:yellow_20|green_40|brown_40|gray_70,groups:Chicago;'\
            'path=a:2,b:_0;path=a:1,b:_0;path=a:0,b:_0',
            ['H29'] =>
            'offboard=revenue:yellow_20|green_30|brown_50|gray_60,groups:StLouis;'\
            'path=a:2,b:_0;path=a:1,b:_0;path=a:0,b:_0',
            ['K28'] =>
            'offboard=revenue:yellow_20|green_40|brown_50|gray_70,groups:NewOrleans;'\
            'path=a:2,b:_0;path=a:1,b:_0',
            ['L7'] =>
            'offboard=revenue:yellow_20|green_40|brown_50|gray_70,hide:1,groups:Mexico;'\
            'path=a:3,b:_0;path=a:2,b:_0;border=edge:4',
            %w[L9 L11 L15 L17] =>
            'offboard=revenue:yellow_20|green_40|brown_50|gray_70,hide:1,groups:Mexico;'\
            'path=a:3,b:_0;path=a:2,b:_0;border=edge:4;border=edge:1',
            ['L13'] =>
            'offboard=revenue:yellow_20|green_40|brown_50|gray_70,groups:Mexico;'\
            'path=a:3,b:_0;path=a:2,b:_0;border=edge:4;border=edge:1',
            ['L19'] =>
            'offboard=revenue:yellow_20|green_40|brown_50|gray_70,hide:1,groups:Mexico;'\
            'path=a:3,b:_0;path=a:2,b:_0;border=edge:1',
          },
          blue: {
            ['A4'] => 'offboard=revenue:yellow_0|green_40|brown_50|gray_70,groups:Japan;path=a:5,b:_0;border=edge:4',
            ['F1'] => 'offboard=revenue:yellow_20|green_40|brown_50|gray_70,groups:China;path=a:4,b:_0;path=a:5,b:_0',
            ['K4'] =>
            'offboard=revenue:yellow_20|green_40|brown_50|gray_70,groups:Australia;path=a:4,b:_0;path=a:3,b:_0',
          },
        }.freeze

        LAYOUT = :pointy
        AXES = { x: :number, y: :letter }.freeze
      end
    end
  end
end
