# frozen_string_literal: true

require_relative '../g_1861/map'

module Engine
  module Game
    module G1864
      module Map
        # The rulebook directs using 1861's track tile manifest.
        TILES = G1861::Map::TILES.merge({
                                          'X1' =>
                                          {
                                            'count' => 1,
                                            'color' => 'yellow',
                                            'code' => 'city=revenue:30;path=a:1,b:_0;path=a:4,b:_0;label=C',
                                          },
                                          'X2' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:1,b:_0;path=a:5,b:_0;label=C',
          },
                                          'X3' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:0,b:_0;path=a:1,b:_0;label=C',
          },
                                          'X4' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:3;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=C',
          },
                                          'X5' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=C',
          },
                                          'X6' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:20;path=a:1,b:_0;path=a:4,b:_0;stripes=color:green;label=BY',
          },
                                          'X7' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'town=revenue:50;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=BY',
          },
                                          'X8' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'town=revenue:70;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0;label=BY',
          },
                                          'X9' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;'\
                      'path=a:4,b:_0;path=a:0,b:_0;path=a:5,b:_0;label=O',
          },
                                          'X10' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;'\
                      'path=a:4,b:_0;path=a:0,b:_0;path=a:5,b:_0;label=O',
          },
                                        }).freeze

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
          'D21' => 'Rapid City',
          'F1' => 'China',
          'F3' => 'Sacramento',
          'F11' => 'Lucin Cutoff',
          'F23' => 'Bailey Yard',
          'G16' => 'Dotsero Cutoff',
          'G18' => 'Moffat Tunnel',
          'G20' => 'Denver',
          'I8' => 'Death Valley',
          'I10' => 'Las Vegas',
          'H25' => 'Wichita',
          'J19' => 'Santa Fe',
          'J25' => 'Oklahoma City',
          'K4' => 'Australia',
          'K12' => 'Phoenix',
          'L13' => 'Mexico',
        }.freeze

        HEXES = {
          white: {
            %w[A22 A24 B17 B19 B21 B25 C14 C16 C20 C24 C26 D3 D7 D9 D17 D19
               D25 D27 E8 E10 E14 E16 E20 E22 F9 F21 F25 G8 G22 G24 G26 H3
               H7 H9 H13 H21 H27 I4 I6 I12 I14 I18 I20 I22 I24 I26 I28 J7 J9
               J11 J13 J17 J21 K8 K10 K16 K22 K24] => '',
            # Bismarck, Billings, Santa Fe, Oklahoma City: printed only as a decorative
            # minor-home medallion with no revenue number (matching 1861's minor-only
            # homes such as E9/H18/I13/I19/K17), so each gets a plain unlabelled city.
            %w[B23 C18 J19] => 'city=revenue:0',
            ['J25'] => 'city=revenue:0;label=Y',
            %w[E6 E12 F5 F7 F17 G6 G12 H11 I16 J15 K14] => 'upgrade=cost:20,terrain:mountain',
            # The $20 mountain cost is printed on the two edges facing Canada
            # (2 = northwest, 3 = northeast), not across the whole hex.
            %w[B7 B9] => 'border=edge:2,type:mountain,cost:20;border=edge:3,type:mountain,cost:20',
            %w[B15 C8 E4 F15 G10 H19 H23 J23 K6] => 'town=revenue:0',
            ['H15'] => 'town=revenue:0;upgrade=cost:40,terrain:mountain',
            # The $20 water cost sits on the edges into Mexico, not across the hex.
            # Declared on both sides so each draws its half of the marker.
            ['K18'] => 'town=revenue:0;border=edge:0,type:water,cost:20;border=edge:5,type:water,cost:20',
            ['K20'] => 'border=edge:0,type:water,cost:20',
            ['C6'] => 'city=revenue:0;upgrade=cost:20,terrain:water',
            %w[D21 F3 H25 I10] => 'city=revenue:0',
            %w[B13 F13 G4] => 'upgrade=cost:40,terrain:mountain',
            ['G16'] => 'town=revenue:0;upgrade=cost:40,terrain:mountain',
            %w[C4 D23 E24 E26] => 'upgrade=cost:20,terrain:water',
            ['C22'] => 'town=revenue:0;upgrade=cost:20,terrain:water',
            # The $20 water cost is printed on the edges into New Orleans (K28),
            # not across these hexes. Declared on both sides - see the Canada
            # mountain borders for why.
            ['K26'] => 'border=edge:4,type:water,cost:20',
            ['J27'] => 'border=edge:5,type:water,cost:20',
            ['F19'] => 'city=revenue:0;label=C',
            # The printed arrow entrances come in from the west and the east.
            ['F23'] => 'town=revenue:0,style:dot,loc:center;'\
                       'path=a:1,b:_0,terminal:1;path=a:4,b:_0,terminal:1;label=BY',
            ['G28'] => 'upgrade=cost:40,terrain:water',
          },
          yellow: {
            ['B5'] =>
            'city=revenue:30;path=a:4,b:_0;path=a:5,b:_0;'\
            'label=Y;upgrade=cost:20,terrain:water',
            ['B11'] =>
            'city=revenue:20;path=a:1,b:_0;path=a:4,b:_0;'\
            'border=edge:2,type:mountain,cost:20;border=edge:3,type:mountain,cost:20',
            ['D5'] => 'city=revenue:20;path=a:0,b:_0;path=a:3,b:_0',
            # One city with TWO SLOTS - the two circles printed side by side and
            # joined by a single band of track. Slot 0 is minor N's home; the
            # other is reserved for the Union Pacific, whose token is placed at
            # setup. Track runs in from the west and out to the north-east.
            ['F27'] =>
            'city=revenue:20,slots:2;path=a:1,b:_0;path=a:3,b:_0;'\
            'label=O;upgrade=cost:40,terrain:water',
            ['G2'] =>
            'city=revenue:30;path=a:2,b:_0;path=a:3,b:_0;'\
            'label=Y;future_label=label:Kh,color:gray',
            # Three cities: MNN (city 0) faces west, KR (city 1) north-east, and the
            # third, unreserved slot (city 2) south-east.
            ['G14'] =>
            'city=revenue:40;city=revenue:40;city=revenue:40;path=a:1,b:_0;'\
            'path=a:3,b:_1;path=a:5,b:_2;label=K',
            # Three minor homes (M-K east, TR northwest, KK southwest), matching the
            # three-slot pattern 1861 uses for its own triple-minor hex (H8/Moscow).
            ['G20'] =>
            'city=revenue:30;city=revenue:30;city=revenue:30;path=a:4,b:_0;path=a:2,b:_1;'\
            'path=a:0,b:_2;label=M',
            ['J5'] => 'city=revenue:30;path=a:0,b:_0;path=a:4,b:_0;label=Y',
            ['K12'] => 'city=revenue:30;path=a:1,b:_0;path=a:2,b:_0;label=Y',
          },
          green: {
            # Two cities: city 0 carries minor Y's home (edges 0-1), city 1 is the
            # second, unreserved slot (edges 0-5).
            ['D11'] =>
            'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:1,b:_0;'\
            'path=a:0,b:_1;path=a:5,b:_1;label=S',
          },
          gray: {
            %w[E18 H5 H17] => 'icon=image:mountain',
            # The two phase-5 passes. Their towns and revenues are printed from the
            # start; only the through-track appears at phase 5, so each carries a
            # brown dashed frame as the indicator (the solid ring matches the grey
            # hex fill, leaving just the dashes visible).
            ['F11'] =>
            'town=revenue:brown_50|gray_60,style:dot,loc:center;'\
            'path=a:1,b:_0,terminal:1;path=a:4,b:_0,terminal:1',
            ['G18'] =>
            'town=revenue:brown_30|gray_40,style:dot,loc:center;'\
            'path=a:1,b:_0,terminal:1;path=a:4,b:_0,terminal:1',
            ['C10'] => 'icon=image:mountain',
            ['C12'] => 'icon=image:mountain;path=a:2,b:3',
            ['D13'] =>
            'town=revenue:yellow_10|green_20|brown_30|gray_40;'\
            'path=a:0,b:_0;path=a:5,b:_0;icon=image:mountain',
            # Two mountain icons, matching the pair of peaks printed on the hex.
            # There is no single double-mountain asset, and stacking two of the
            # same icon is an established pattern (see 18MEX's paired ports).
            ['D15'] =>
            'town=revenue:yellow_10|green_20|brown_30|gray_40;'\
            'path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;'\
            'icon=image:mountain;icon=image:mountain',
            ['I8'] =>
            'town=revenue:yellow_10|green_20|brown_30|gray_40;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0',
          },
          red: {
            # The Canada band. A6-A12 face B7/B9/B11, whose printed $20 mountain
            # cost sits on the shared edges; borders are declared on BOTH hexes so
            # each draws its own half of the cost marker and neither can cover the
            # other (the marker is centred on the edge). Same convention as 1807.
            ['A14'] =>
            'offboard=revenue:yellow_20|green_30|brown_50|gray_60,hide:1,groups:Canada'\
            'path=a:0,b:_0;path=a:5,b:_0;border=edge:4;border=edge:1;label=N',
            %w[A16 A18] =>
            'offboard=revenue:yellow_20|green_30|brown_50|gray_60,hide:1,groups:Canada'\
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
            'path=a:1,b:_0;path=a:0,b:_0;label=N',
            ['E28'] =>
            'offboard=revenue:yellow_20|green_40|brown_40|gray_70,groups:Chicago;'\
            'path=a:2,b:_0;path=a:1,b:_0;path=a:0,b:_0',
            ['H29'] =>
            'offboard=revenue:yellow_20|green_30|brown_50|gray_60,groups:StLouis;'\
            'path=a:2,b:_0;path=a:1,b:_0;path=a:0,b:_0',
            ['K28'] =>
            'offboard=revenue:yellow_20|green_40|brown_50|gray_70,groups:NewOrleans;'\
            'path=a:2,b:_0;path=a:1,b:_0;'\
            'border=edge:1,type:water,cost:20;border=edge:2,type:water,cost:20;label=S',
            ['L7'] =>
            'offboard=revenue:yellow_20|green_40|brown_50|gray_70,hide:1,groups:Mexico;'\
            'path=a:3,b:_0;path=a:2,b:_0;border=edge:4',
            %w[L9 L11] =>
            'offboard=revenue:yellow_20|green_40|brown_50|gray_70,hide:1,groups:Mexico;'\
            'path=a:3,b:_0;path=a:2,b:_0;border=edge:4;border=edge:1',
            ['L15'] =>
            'offboard=revenue:yellow_20|green_40|brown_50|gray_70,hide:1,groups:Mexico;'\
            'path=a:3,b:_0;path=a:2,b:_0;border=edge:4;border=edge:1;label=S',
            ['L17'] =>
            'offboard=revenue:yellow_20|green_40|brown_50|gray_70,hide:1,groups:Mexico;'\
            'path=a:3,b:_0;path=a:2,b:_0;border=edge:4;border=edge:1;'\
            'border=edge:3,type:water,cost:20',
            ['L13'] =>
            'offboard=revenue:yellow_20|green_40|brown_50|gray_70,groups:Mexico;'\
            'path=a:3,b:_0;path=a:2,b:_0;border=edge:4;border=edge:1',
            ['L19'] =>
            'offboard=revenue:yellow_20|green_40|brown_50|gray_70,hide:1,groups:Mexico;'\
            'path=a:3,b:_0;path=a:2,b:_0;border=edge:1;'\
            'border=edge:2,type:water,cost:20;border=edge:3,type:water,cost:20',
          },
          blue: {
            ['A4'] => 'offboard=revenue:yellow_0|green_40|brown_50|gray_70,groups:Japan;path=a:5,b:_0;border=edge:4',
            %w[B3 G0] => 'junction;path=a:4,b:_0,terminal:1',
            ['E2'] => 'junction;path=a:5,b:_0,terminal:1',
            ['F1'] => 'offboard=revenue:yellow_20|green_40|brown_50|gray_70,groups:China;path=a:5,b:_0',
            ['H1'] => 'path=a:3,b:4',

            ['J3'] => 'junction;path=a:4,b:_0,terminal:1',

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
