# frozen_string_literal: true

module Engine
  module Game
    module G1822PNW
      module Map
        LOCATION_NAMES = {
          'A8' => 'Vancouver, BC',
          'A20' => 'Carson',
          'A22' => 'Calgary',
          'B19' => 'Republic',
          'B23' => 'Calgary',
          'C22' => 'Colville',
          'D11' => 'Bellingham',
          'D13' => 'Wickersham',
          'D19' => 'Brewster',
          'D23' => 'Newport',
          'E2' => 'Neah',
          'E20' => 'Davenport',
          'E24' => 'Spokane',
          'F5' => 'Port Angeles',
          'F9' => 'Port Townsend',
          'F13' => 'Everett',
          'F23' => 'Spokane',
          'G2' => 'Clearwater',
          'G8' => 'Quilcene',
          'G12' => 'Mikilteo',
          'G14' => 'Snohomish',
          'G16' => 'Park Place',
          'G24' => 'Spokane',
          'H11' => 'Seattle',
          'H19' => 'Leavenworth',
          'H21' => 'Wenatchee',
          'I8' => 'Union',
          'I12' => 'Tacoma',
          'J5' => 'Aberdeen',
          'J7' => 'Oakville',
          'J9' => 'Olympia',
          'J13' => 'Sumner',
          'J19' => 'Ellensburg',
          'J23' => 'Sprague',
          'K12' => 'Eatonville',
          'K22' => 'Lind',
          'L9' => 'Chehalis',
          'L11' => 'Kosmos',
          'L19' => 'Yakima',
          'L23' => 'Lewiston Junction',
          'M4' => 'Ilwaco',
          'M10' => 'Kalama',
          'N5' => 'Astoria',
          'N23' => 'Walla Walla',
          'O8' => 'Portland',
          'O10' => 'Vancouver, WA',
          'O14' => 'Stevenson Cascade Locks',
          'O20' => 'Wallula',
          'O22' => 'Walla Walla',
          'P5' => 'Tillamook',
          'P13' => 'Bonneville',
          'P17' => 'The Dalles',
          'P19' => 'Umatilla',
        }.freeze

        LAYOUT = :pointy

        HEXES = {
          white: {
            %w[A10 A12 A18 B9 B11 B17 B21 C10 C18 C20 D21 E12 E22 F21 G20 G22 H15 H23 I14 I22 J11 J21 K4 K6 K8 K10 K14 K18
               K20 L5 L7 M12 M16 M18 N7 N11 N17 O6 P7 P11 P15] => '',
            %w[A20 C22 D13 E20 F5 G2 G8 G12 I8 J7 J13 J19 K12 K22 M10 P5 P13 P19] => 'town=revenue:0',
            %w[B19 D19 F13 G14 G16 H21 J5 J23 L9 L11 L19 L23 P17] => 'city=revenue:0',
            %w[D23] => 'city=revenue:0;icon=image:1822_pnw/GNR,name:GNR_home',
            %w[A14 B13 C12 C16 D17 E14 E18 F1 F3 F7 F15 F19 G6 H7 I4 I16 I20 J15 L13 L17 N15
               O4] => 'upgrade=cost:10,terrain:forest',
            %w[A16 G18 J17] => 'upgrade=cost:150,terrain:mountain',
            %w[G4 H5 I6] => 'upgrade=cost:100,terrain:mountain',
            %w[H11] => 'city=revenue:20,slots:2;upgrade=cost:20;border=edge:4,type:water,cost:75;'\
                       'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Sea;icon=image:1822_pnw/SWW,name:SWW_home',
            %w[H13] => 'border=edge:1,type:water,cost:75',
            %w[H19] => 'city=revenue:20,loc:center;town=revenue:10,loc:3;path=a:_0,b:_1',
            %w[L21 M20 M22 N19 N21] => 'upgrade=cost:20,terrain:water',
            %w[M4] => 'city=revenue:20;path=a:_0,b:2;border=edge:5,type:water,cost:75',
            %w[M14 N13] => 'upgrade=cost:75,terrain:mountain',
            %w[N5] => 'city=revenue:0;border=edge:2,type:water,cost:75',
            %w[O8] => 'city=revenue:20,slots:4;upgrade=cost:20;'\
                      'path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0,lanes:2;label=Por;'\
                      'icon=image:1822_pnw/SPS,name:SPS_home;icon=image:1822_pnw/ORNC,name:ORNC_home',
            %w[O20] => 'city=revenue:0;upgrade=cost:20,terrain:water;icon=image:1822_pnw/NP,name:NP_home',
          },
          yellow: {
            %w[A8] => 'city=revenue:30;path=a:4,b:_0;path=a:5,b:_0;label=T;icon=image:1822_pnw/CPR,name:CPR_home',
            %w[D11] => 'city=revenue:30;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Y',
            %w[F9] => 'city=revenue:30;path=a:0,b:_0;path=a:1,b:_0',
            %w[J9] => 'city=revenue:30;path=a:1,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Y',
            %w[O10] => 'city=revenue:30;upgrade=cost:150,terrain:water;path=a:3,b:_0;path=a:4,b:_0;label=Y',
            %w[O14] => 'city=revenue:20;city=revenue:20;upgrade=cost:150,terrain:water;path=a:0,b:_0;path=a:5,b:_0;path=a:1,b:_1',
          },
          gray: {
            %w[C24] => 'junction;path=a:0,b:_0,terminal:1',
            %w[D25] => 'junction;path=a:1,b:_0,terminal:1',
            %w[E2] => 'town=revenue:20;path=a:0,b:_0;path=a:5,b:_0',
            %w[I12] => 'city=revenue:yellow_20|green_30|brown_40|gray_50,slots:3;'\
                       'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            %w[I24] => 'junction;path=a:0,b:_0,terminal:1',
            %w[K24] => 'junction;path=a:0,b:_0,terminal:1;path=a:2,b:_0,terminal:1',
            %w[L3] => 'town=revenue:10;path=a:5,b:_0',
            %w[M24] => 'junction;path=a:2,b:_0,terminal:1',
            %w[O12] => 'town=revenue:10;path=a:1,b:_0;path=a:4,b:_0',
            %w[P9] => 'path=a:1,b:2,b_lane:2.1;path=a:4,b:2,b_lane:2.0',
            %w[Q6 Q16] => 'junction;path=a:3,b:_0,terminal:1',
            %w[Q8 Q18] => 'junction;path=a:2,b:_0,terminal:1',
          },
          red: {
            %w[A22] => 'city=revenue:yellow_30|green_40|brown_50|gray_60,slots:2;'\
                       'path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;path=a:5,b:_0,lanes:2,terminal:1',
            %w[B23] => 'path=a:0,b:2,b_lane:2.0;path=a:1,b:2,b_lane:2.1',
            %w[F23] => 'city=revenue:yellow_20|green_30|brown_40|gray_50,slots:4;'\
                       'path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1;'\
                       'icon=image:1822_pnw/CMPS,name:CMPS_home',
            %w[N23] => 'path=a:1,b:0,b_lane:2.0;path=a:2,b:0,b_lane:2.1',
            %w[O22] => 'city=revenue:yellow_20|green_30|brown_40|gray_50,slots:2;'\
                       'path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1;path=a:3,b:_0,lanes:2,terminal:1',
          },
          brown: {
            %w[B15 K16] => 'icon=image:mountain;junction;path=a:1,b:_0,terminal:2;path=a:2,b:_0,terminal:2;'\
                           'path=a:3,b:_0,terminal:2;path=a:4,b:_0,terminal:2;path=a:5,b:_0,terminal:2',
            %w[C14] => 'icon=image:mountain;junction;path=a:0,b:_0,terminal:2;path=a:1,b:_0,terminal:2;'\
                       'path=a:2,b:_0,terminal:2;path=a:4,b:_0,terminal:2',
            %w[D15 E16] => 'icon=image:mountain;junction;path=a:0,b:_0,terminal:2;path=a:1,b:_0,terminal:2;'\
                           'path=a:3,b:_0,terminal:2;path=a:4,b:_0,terminal:2',
            %w[F17 I18] => 'icon=image:mountain;junction;path=a:0,b:_0,terminal:2;path=a:1,b:_0,terminal:2;'\
                           'path=a:3,b:_0,terminal:2;path=a:4,b:_0,terminal:2;path=a:5,b:_0,terminal:2',
            %w[H17] => 'icon=image:mountain;junction;path=a:0,b:_0,terminal:2;path=a:1,b:_0,terminal:2;'\
                       'path=a:2,b:_0,terminal:2;path=a:3,b:_0,terminal:2;path=a:4,b:_0,terminal:2',
            %w[L15] => 'icon=image:mountain;junction;path=a:0,b:_0,terminal:2;path=a:1,b:_0,terminal:2;'\
                       'path=a:2,b:_0,terminal:2;path=a:4,b:_0,terminal:2;path=a:5,b:_0,terminal:2',
          },
          blue: {
            %w[B7] => 'junction;path=a:3,b:_0,terminal:1',
            %w[D9] => 'junction;path=a:4,b:_0,terminal:1;path=a:0,b:4,track:thin',
            %w[E8] => 'junction;path=a:5,b:_0,terminal:1;path=a:3,b:5,track:thin',
            %w[E10] => 'junction;path=a:0,b:_0,terminal:2;path=a:3,b:_0,terminal:2;path=a:4,b:_0,terminal:2',
            %w[F11] => 'junction;path=a:1,b:_0,terminal:2;path=a:3,b:_0,terminal:2;path=a:4,b:_0,terminal:2;'\
                       'path=a:5,b:_0,terminal:2',
            %w[G10] => 'junction;path=a:1,b:_0,terminal:2;path=a:2,b:_0,terminal:2;path=a:4,b:_0,terminal:2',
            %w[H9] => 'junction;path=a:0,b:_0,terminal:2;path=a:1,b:_0,terminal:2;path=a:2,b:_0,terminal:2',
            %w[I10] => 'junction;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:2;path=a:4,b:_0,terminal:1;'\
                       'path=a:5,b:_0,terminal:2',
            %w[M2] => 'junction;path=a:4,b:_0,terminal:1',
            %w[M6 O16] => 'junction;path=a:0,b:_0,terminal:2;path=a:1,b:_0,terminal:2;path=a:2,b:_0,terminal:2;'\
                          'path=a:3,b:_0,terminal:2;path=a:5,b:_0,terminal:2',
            %w[M8] => 'junction;path=a:0,b:_0,terminal:2;path=a:2,b:_0,terminal:2;path=a:3,b:_0,terminal:2;'\
                      'path=a:4,b:_0,terminal:2',
            %w[N9] => 'junction;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:2;path=a:3,b:_0,terminal:2;'\
                      'path=a:4,b:_0,terminal:2;path=a:5,b:_0,terminal:2',
            %w[O18] => 'junction;path=a:0,b:_0,terminal:2;path=a:2,b:_0,terminal:2;path=a:3,b:_0,terminal:2;'\
                       'path=a:4,b:_0,terminal:2;path=a:5,b:_0,terminal:2',
          },
        }.freeze

        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 6,
          '4' => 11,
          '5' => 6,
          '6' => 8,
          '7' => 6,
          '8' => 24,
          '9' => 24,
          '55' => 1,
          '56' => 1,
          '57' => 6,
          '58' => 6,
          '69' => 1,
          '14' => 4,
          '15' => 6,
          '80' => 4,
          '81' => 6,
          '82' => 7,
          '83' => 7,
          '141' => 3,
          '142' => 3,
          '143' => 2,
          '144' => 3,
          '207' => 3,
          '208' => 2,
          '619' => 5,
          '622' => 2,
          '63' => 3,
          '544' => 4,
          '545' => 4,
          '546' => 4,
          '611' => 7,
          '60' => 2,
          '455' =>
            {
              'count' => 2,
              'color' => 'gray',
              'code' => 'city=revenue:50,slots:2;'\
                        'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            },
          'X20' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'city=revenue:40,slots:2;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;upgrade=cost:20;label=Sea',
            },
          'X24' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'city=revenue:40,slots:4;'\
                        'path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0,lanes:2;upgrade=cost:20;label=Por',
            },
          '405' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=T',
            },
          'X21' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:60,slots:2;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;upgrade=cost:20;label=Sea',
            },
          'X25' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:60,slots:4;'\
                        'path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0,lanes:2;upgrade=cost:20;label=Por',
            },
          '768' =>
            {
              'count' => 4,
              'color' => 'brown',
              'code' =>
                'town=revenue:10;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            },
          '767' =>
            {
              'count' => 4,
              'color' => 'brown',
              'code' =>
                'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
            },
          '769' =>
            {
              'count' => 4,
              'color' => 'brown',
              'code' =>
                'town=revenue:10;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            },
          'X5' =>
            {
              'count' => 3,
              'color' => 'brown',
              'code' =>
                'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                'path=a:4,b:_0;label=Y',
            },
          'X22' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:80,slots:2;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;upgrade=cost:20;label=Sea',
            },
          'X26' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:80,slots:4;'\
                        'path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0,lanes:2;upgrade=cost:20;label=Por',
            },
          '169' =>
            {
              'count' => 2,
              'color' => 'gray',
              'code' =>
                'junction;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            },
          'X10' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' =>
                'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=T',
            },
          'X11' =>
            {
              'count' => 3,
              'color' => 'gray',
              'code' =>
                'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Y',
            },
          'X16' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=T',
            },
          'X17' =>
            {
              'count' => 2,
              'color' => 'gray',
              'code' =>
                'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            },
          'X18' =>
            {
              'count' => 2,
              'color' => 'gray',
              'code' =>
                'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            },
          'X23' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' => 'city=revenue:100,slots:2;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Sea',
            },
          'X27' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' => 'city=revenue:100,slots:4;'\
                        'path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0,lanes:2;label=Por',
            },
          'PNW3' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'town=revenue:30;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            },
          'PNW4' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:30;path=a:0,b:_0;path=a:3,b:_0;upgrade=cost:75,terrain:mountain',
            },
          'PNW5' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:50,loc:2.5;path=a:1,b:_0;path=a:4,b:_0;path=a:1,b:4',
            },
          'P1' =>
            {
              'count' => 1,
              'color' => 'blue',
              'code' =>
                'city=revenue:yellow_30|green_40,slots:0;path=a:0,b:_0,terminal:1',
            },
          'P2' =>
            {
              'count' => 1,
              'color' => 'blue',
              'code' =>
                'city=revenue:green_40|brown_50|gray_60,slots:0;path=a:0,b:_0,terminal:1',
            },
          'PNW1' =>
            {
              'count' => 1,
              'color' => 'blue',
              'code' => 'path=a:0,b:3;icon=image:1822_pnw/minus_10,large:1',
            },
          'PNW2' =>
            {
              'count' => 1,
              'color' => 'blue',
              'code' => 'path=a:0,b:2;icon=image:1822_pnw/minus_10,large:1',
            },

          'BC' =>
            {
              'count' => 1,
              'color' => 'white',
              'code' => 'icon=image:1822_mx/red_cube,large:1',
              'hidden' => true,
            },

        }.freeze
      end
    end
  end
end
