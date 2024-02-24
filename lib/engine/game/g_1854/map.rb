# frozen_string_literal: true

module Engine
  module Game
    module G1854
      module Map
        LOCATION_NAMES = {
          'A19' => 'Prag',
          'A25' => 'Brünn',
          'B18' => 'Freistadt',
          'B22' => 'Stockerau & Klosterneuburg',
          'C13' => 'Braunau',
          'C15' => 'Ried',
          'C17' => 'Linz',
          'C19' => 'Ybbs',
          'C21' => 'Krems & Tulln',
          'C23' => 'Wien & Vienna',
          'C27' => 'Pressburg', # TODO: check spelling
          'D0' => 'Paris',
          'D12' => 'München',
          'D16' => 'Wels',
          'D18' => 'Steyr & Bad Ischl',
          'D20' => 'Amstetten & Sankt Pölten',
          'D22' => 'Modling & Baden',
          'D24' => 'Wiener Neustadt',
          'D26' => 'Eisenstadt',
          'D28' => 'Budapest',
          'D4' => 'Augsburg', # TODO: check spelling
          'E1' => 'Zurich',
          'E11' => 'Kufstein & Wörgl',
          'E13' => 'Salzburg',
          'E21' => 'Leoben & Kapfenberg',
          'E23' => 'Semmeringbahn',
          'E3' => 'Bregenz',
          'E5' => 'Außerfernbahn',
          'F14' => 'Mauterndorf',
          'F16' => 'Murtalbahn',
          'F2' => 'Dornbirn & Feldkirch',
          'F20' => 'Graz-Köflacher Bahn',
          'F22' => 'Graz',
          'F24' => 'Oberwart',
          'F28' => 'Konstantinopel',
          'F4' => 'Arlbergbahn',
          'F6' => 'Landeck',
          'F8' => 'Innsbruck',
          'G1' => 'Vaduz',
          'G3' => 'Bludenz',
          'H10' => 'Brenner',
          'H12' => 'Lienz',
          'H16' => 'Spital & Villach',
          'H18' => 'Klagenfurt',
          'I15' => 'Venedig',
          'I19' => 'Laibach',
          'J28' => 'Kirchdorf',
          'J32' => 'Steyr',
          'J34' => 'Amstetten',
          'J38' => 'Sankt Pölten',
          'L28' => 'Bad Ischl',
          'M35' => 'Hieflau',
        }.freeze

        HEXES = {
          red: {
            ['D4'] => 'offboard=revenue:yellow_00|green_20|brown_30|gray_40;path=a:0,b:_0',
            ['G1'] => 'offboard=revenue:yellow_20|green_20|brown_20|gray_20;path=a:3,b:_0',
            ['I19'] => 'offboard=revenue:yellow_20|green_30|brown_30|gray_40;path=a:2,b:_0',
            ['A25'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_40;path=a:5,b:_0',
            ['C27'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_50;path=a:1,b:_0',
            ['E1'] => 'town=style:dot,loc:4.0,revenue:yellow_20|green_30|brown_40|gray_50;'\
                      'town=style:dot,loc:center,revenue:yellow_20|green_30|brown_40|gray_50;'\
                      'path=a:4,b:_0;path=a:2,b:_0;path=a:2,b:_1;path=a:5,b:_1',
            ['I15'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_50;path=a:3,b:_0',
            ['A19'] => 'offboard=revenue:yellow_20|green_30|brown_50|gray_50;path=a:5,b:_0',
            ['D12'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_50;'\
                       'path=a:5,b:_0;path=a:0,b:4;icon=image:1854/minus_ten,loc:0.5',
            ['I29'] => 'offboard=revenue:yellow_10|green_20|brown_30;path=a:5,b:_0',
            ['M39'] => 'offboard=revenue:yellow_10|green_20|brown_30;path=a:2,b:_0',
            ['E27'] => 'town=style:dot,loc:2,revenue:yellow_30|green_40|brown_50|gray_60,groups:Budapest,hide:1;'\
                       'path=a:2,b:_0;path=a:5,b:_0;path=a:5,b:3;border=edge:3',
            ['H10'] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_60;path=a:2,b:_0;path=a:3,b:_0',
            ['D28'] => 'town=style:dot,loc:0.5,revenue:yellow_30|green_40|brown_50|gray_60,groups:Budapest;'\
                       'path=a:1,b:_0;path=a:0,b:_0;border=edge:0',
          },
          gray: {
            %w[A21 I31 I37] => 'path=a:0,b:5',
            %w[M31 M37] => 'town=revenue:10;path=a:2,b:_0;path=a:_0,b:3',
            %w[M35] => 'city=revenue:yellow_10|green_20|brown_30,loc:2.5;path=a:2,b:_0;path=a:_0,b:3',
            %w[L28] => 'city=revenue:20,loc:3.5;path=a:3,b:_0;path=a:_0,b:4',
            %w[J28] => 'city=revenue:yellow_10|green_20|brown_30,loc:4.5;path=a:4,b:_0;path=a:_0,b:5',
            ['C13'] => 'town=revenue:10;path=a:4,b:_0;path=a:_0,b:5',
            ['H12'] => 'town=revenue:10;path=a:2,b:_0;path=a:_0,b:4',
            ['D0'] => 'offboard=revenue:90;path=a:5,b:_0',
            ['F28'] => 'offboard=revenue:90;path=a:2,b:_0',
          },
          white: {
            %w[B24 B26 E25 G23 G21 G19 G9 H20 K35 L34 C25] => 'blank',
            %w[B20] => 'upgrade=cost:50,terrain:mountain',
            %w[B16 K31 K29] => 'upgrade=cost:60,terrain:mountain',
            %w[D14 E7 E9 E23 L38] => 'upgrade=cost:70,terrain:mountain',
            %w[G15 H14] => 'upgrade=cost:80,terrain:mountain',
            %w[E19 E15 F20] => 'upgrade=cost:90,terrain:mountain',
            %w[E17 E5 F16] => 'upgrade=cost:100,terrain:mountain',
            %w[F4] => 'upgrade=cost:120,terrain:mountain',
            %w[F10] => 'upgrade=cost:50,terrain:water',
            %w[C15 D16 D26 F24 D24] => 'town=revenue:0',
            %w[C19 F6] => 'town=revenue:0;upgrade=cost:50,terrain:water',
            %w[B18 K33] => 'town=revenue:0;upgrade=cost:50,terrain:mountain',
            %w[L30 L36 K39] => 'town=revenue:0;upgrade=cost:60,terrain:mountain',
            %w[G3] => 'town=revenue:0;upgrade=cost:80,terrain:mountain',
            %w[F2 J30] => 'town=revenue:0;town=revenue:0',
            %w[D18 D20] => 'town=revenue:0;town=revenue:0;frame=color:#BBB',
            %w[B22 J36 K37
               D22] => 'town=revenue:0;town=revenue:0;upgrade=cost:50,terrain:mountain',
            %w[C21 E11] => 'town=revenue:0;town=revenue:0;upgrade=cost:50,terrain:water',
            %w[H16] => 'town=revenue:0;town=revenue:0;upgrade=cost:70,terrain:mountain',
            %w[L32] => 'town=revenue:0;town=revenue:0;upgrade=cost:80,terrain:mountain',
            %w[E21] => 'town=revenue:0;town=revenue:0;upgrade=cost:120,terrain:mountain',
            %w[C17 E3 E13 F22 F8 H18 J34 J32] => 'city=revenue:0',
          },
          yellow: {
            ['C23'] => 'city=revenue:40,loc:0;city=revenue:40,loc:1;city=revenue:40,loc:2;'\
                       'path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;label=W',
            ['J38'] => 'city=revenue:20,loc:1;city=revenue:20,loc:5;path=a:1,b:_0;path=a:5,b:_1',
          },
          brown: {
            %w[F12 F18 G17 G13 G11 G7 G5] => 'icon=image:1854/mine',
            %w[F14] => 'town=revenue:10;path=a:4,b:_0;icon=image:1854/mine',
          },
          purple: {
          },
          blue: {
          },
        }.freeze

        LAYOUT = :pointy
      end
    end
  end
end
