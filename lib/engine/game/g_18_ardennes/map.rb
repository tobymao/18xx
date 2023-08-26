# frozen_string_literal: true

module Engine
  module Game
    module G18Ardennes
      module Map
        LAYOUT = :pointy

        LOCATION_NAMES = {
          'B6' => 'Haarlem',
          'B8' => 'Amsterdam',
          'B12' => 'Arnhem-Nijmegen',
          'B16' => 'The Ruhr',
          'C7' => 'Rotterdam',
          'D12' => 'Eindhoven',
          'D14' => 'Mönchengladbach',
          'D18' => 'Cologne',
          'E5' => 'Vlissingen',
          'E9' => 'Antwerp',
          'E13' => 'Maastricht',
          'E15' => 'Aachen',
          'E19' => 'Bonn',
          'E21' => 'Koblenz',
          'E23' => 'Mainz',
          'E25' => 'Frankfurt-am-Main',
          'F4' => 'Brugge',
          'F6' => 'Gent',
          'F10' => 'Brussels',
          'F14' => 'Liège',
          'G3' => 'Dunkerque',
          'G11' => 'Namur',
          'G19' => 'Trier',
          'G25' => 'Mannheim-Ludwigshafen',
          'H2' => 'Calais',
          'H6' => 'Lille-Roubaix',
          'H8' => 'Mons',
          'H10' => 'Charleroi',
          'H18' => 'Luxembourg',
          'H26' => 'Karlsruhe',
          'I1' => 'Boulogne-sur-Mer',
          'I5' => 'Arras',
          'I7' => 'Douai',
          'I13' => 'Charleville-Mézières',
          'I21' => 'Saarbrücken',
          'J8' => 'Saint-Quentin',
          'J18' => 'Metz',
          'J24' => 'Strasbourg',
          'K5' => 'Amiens',
          'K11' => 'Reims',
          'K19' => 'Nancy',
          'K27' => 'Freiburg-im-Breisgau',
          'L22' => 'Épinal',
          'L26' => 'Mulhouse',
          'M3' => 'Rouen',
          'M7' => 'Paris',
          'M13' => 'Troyes',
          'M23' => 'Belfort',
          'M27' => 'Basel',
        }.freeze

        HEXES = {
          white: {
            # Plain track hexes
            %w[
              B14 C17 D10 D16 D20 D22 E11 E17 F8 F12 F22 F24 F26 G5 G7
              G9 H4 I3 I9 I11 I15 I17 I19 I23 I25 I27 J2 J4 J6 J10 J12 J14 J16 J20
              J26 K3 K7 K9 K13 K15 K17 K21 K25 L4 L10 L12 L14 L16 L18 L20
              M11 M15 M17 M19 M21 M25
            ] => '',
            %w[C9 C11 C13] =>
                    'upgrade=cost:20,terrain:water;',
            %w[D8] =>
                    'upgrade=cost:40,terrain:water;',
            %w[F16 F18 F20 G13 G15 G17 G21 G23 H12 H14 H16 H20 H22 H24 J22 K23 L24] =>
                    'upgrade=cost:40,terrain:mountain;',
            %w[L8] =>
                    'stub=edge:0;',
            %w[B10 M9] =>
                    'stub=edge:1;',
            %w[C15] =>
                    'stub=edge:3;',
            %w[M5] =>
                    'stub=edge:4;',
            %w[L6] =>
                    'stub=edge:5;',

            # Town hexes
            %w[D12 D14 E13 E19 E21 F6 F14 G11 H2 H8 I5 I7 I13 J8 K19 K27 L22 L26 M23] =>
                    'town=revenue:0;',
            %w[G19 H18] =>
                    'town=revenue:0;' \
                    'upgrade=cost:40,terrain:mountain;',
            %w[E23] =>
                    'town=revenue:0;' \
                    'stub=edge:4;',

            # City hexes
            %w[B12 E15 H26 I21 J18 K5] =>
                    'city=revenue:0;',
            %w[D18 E9 G25 H6 J24] =>
                    'city=revenue:0;' \
                    'label=Y;',
            %w[F4 G3] =>
                    'city=revenue:0;' \
                    'path=a:1,b:_0;',
            %w[F10] =>
                    'city=revenue:0;' \
                    'label=Y;' \
                    'future_label=label:B,color:brown;',
            %w[H10] =>
                    'city=revenue:0;' \
                    'upgrade=cost:40,terrain:mountain;',
          },

          yellow: {
            %w[B8] =>
                    'label=A;' \
                    'city=revenue:30;' \
                    'city=revenue:30;' \
                    'path=a:1,b:_0;' \
                    'path=a:4,b:_1;',
            %w[B16] =>
                    'label=R;' \
                    'city=revenue:30;' \
                    'town=revenue:10;' \
                    'path=a:0,b:_0;' \
                    'path=a:_0,b:_1;',
            %w[C7] =>
                    'label=Y;' \
                    'city=revenue:30;' \
                    'city=revenue:30;' \
                    'path=a:0,b:_0;' \
                    'path=a:2,b:_1;',
            %w[E25] =>
                    'label=T;' \
                    'city=revenue:30;' \
                    'city=revenue:30;' \
                    'path=a:0,b:_0;' \
                    'path=a:5,b:_0;' \
                    'path=a:1,b:_1;',
            %w[M7] =>
                    'label=P;' \
                    'city=revenue:40;' \
                    'city=revenue:40;' \
                    'path=a:1,b:_0;' \
                    'path=a:2,b:_0;' \
                    'path=a:3,b:_1;' \
                    'path=a:4,b:_1;',
            %w[M27] =>
                    'label=T;' \
                    'city=revenue:30;' \
                    'city=revenue:30;' \
                    'path=a:1,b:_0;' \
                    'path=a:2,b:_0;' \
                    'path=a:3,b:_1;',
          },
          gray: {
            %w[B6] =>
                    'town=revenue:20;' \
                    'path=a:4,b:_0;' \
                    'path=a:5,b:_0;',
            %w[D6] =>
                    'path=a:3,b:4;',
            %w[E5] =>
                    'city=revenue:20;' \
                    'icon=image:port;' \
                    'path=a:4,b:_0;',
            %w[E7] =>
                    'path=a:1,b:3;',
            %w[F2] =>
                    'offboard=revenue:0;' \
                    'icon=image:port;' \
                    'path=a:4,b:_0;' \
                    'path=a:5,b:_0;',
            %w[G1] =>
                    'offboard=revenue:0;' \
                    'icon=image:port;' \
                    'path=a:4,b:_0;',
            %w[I1] =>
                    'town=revenue:20;' \
                    'path=a:3,b:_0;' \
                    'path=a:4,b:_0;' \
                    'path=a:5,b:_0;',
            %w[J28 L28] =>
                    'path=a:0,b:2;',
            %w[K11] =>
                    'city=revenue:30,loc:5;' \
                    'path=a:1,b:3;' \
                    'path=a:1,b:_0;' \
                    'path=a:3,b:_0;',
            %w[M3] =>
                    'town=revenue:20;' \
                    'path=a:3,b:_0;' \
                    'path=a:4,b:_0;',
            %w[M13] =>
                    'town=revenue:20;' \
                    'path=a:1,b:_0;' \
                    'path=a:4,b:_0;',
          },
        }.freeze
      end
    end
  end
end
