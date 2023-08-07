# frozen_string_literal: true

module Engine
  module Game
    module G18Ardennes
      module Map
        LAYOUT = :pointy

        LOCATION_NAMES = {
          'A6' => 'Haarlem',
          'A8' => 'Amsterdam',
          'A12' => 'Arnhem-Nijmegen',
          'A16' => 'The Ruhr',
          'B7' => 'Rotterdam',
          'C12' => 'Eindhoven',
          'C14' => 'Mönchengladbach',
          'C18' => 'Cologne',
          'D5' => 'Vlissingen',
          'D9' => 'Antwerp',
          'D13' => 'Maastricht',
          'D15' => 'Aachen',
          'D19' => 'Bonn',
          'D21' => 'Koblenz',
          'D23' => 'Mainz',
          'D25' => 'Frankfurt-am-Main',
          'E4' => 'Brugge',
          'E6' => 'Gent',
          'E10' => 'Brussels',
          'E14' => 'Liège',
          'F3' => 'Dunkerque',
          'F11' => 'Namur',
          'F19' => 'Trier',
          'F25' => 'Mannheim-Ludwigshafen',
          'G2' => 'Calais',
          'G6' => 'Lille-Roubaix',
          'G8' => 'Mons',
          'G10' => 'Charleroi',
          'G18' => 'Luxembourg',
          'G26' => 'Karlsruhe',
          'H1' => 'Boulogne-sur-Mer',
          'H5' => 'Arras',
          'H7' => 'Douai',
          'H13' => 'Charleville-Mézières',
          'H21' => 'Saarbrücken',
          'I8' => 'Saint-Quentin',
          'I18' => 'Metz',
          'I24' => 'Strasbourg',
          'J5' => 'Amiens',
          'J11' => 'Reims',
          'J19' => 'Nancy',
          'J27' => 'Freiburg-im-Breisgau',
          'K22' => 'Épinal',
          'K26' => 'Mulhouse',
          'L3' => 'Rouen',
          'L7' => 'Paris',
          'L13' => 'Troyes',
          'L23' => 'Belfort',
          'L27' => 'Basel',
        }.freeze

        HEXES = {
          white: {
            # Plain track hexes
            %w[
              A10 A14 B15 B17 C10 C16 C20 C22 D11 D17 E8 E12 E22 E24 E26 F5 F7
              F9 G4 H3 H9 H11 H15 H17 H19 H23 H25 H27 I2 I4 I6 I10 I12 I14 I16 I20
              I26 J3 J7 J9 J13 J15 J17 J21 J25 K4 K6 K8 K10 K12 K14 K16 K18 K20
              L5 L9 L11 L15 L17 L19 L21 L25
            ] => '',
            %w[B9 B11 B13] =>
                    'upgrade=cost:20,terrain:water;',
            %w[C8] =>
                    'upgrade=cost:40,terrain:water;',
            %w[E16 E18 E20 F13 F15 F17 F21 F23 G12 G14 G16 G20 G22 G24 I22 J23 K24] =>
                    'upgrade=cost:40,terrain:mountain;',

            # Town hexes
            %w[C12 C14 D13 D19 D21 D23 E6 E14 F11 G2 G8 H5 H7 H13 I8 J19 J27 K22 K26 L23] =>
                    'town=revenue:0;',
            %w[F19 G18] =>
                    'town=revenue:0;' \
                    'upgrade=cost:40,terrain:mountain;',

            # City hexes
            %w[A12 D15 G26 H21 I18 J5] =>
                    'city=revenue:0;',
            %w[C18 D9 F25 G6 I24] =>
                    'city=revenue:0;' \
                    'label=Y;',
            %w[E4 F3] =>
                    'city=revenue:0;' \
                    'path=a:1,b:_0;',
            %w[E10] =>
                    'city=revenue:0;' \
                    'label=Y;' \
                    'future_label=label:B,color:brown;',
            %w[G10] =>
                    'city=revenue:0;' \
                    'upgrade=cost:40,terrain:mountain;',
          },

          yellow: {
            %w[A8] =>
                    'label=A;' \
                    'city=revenue:30;' \
                    'city=revenue:30;' \
                    'path=a:1,b:_0;' \
                    'path=a:4,b:_1;',
            %w[A16] =>
                    'label=R;' \
                    'city=revenue:30;' \
                    'town=revenue:10;' \
                    'path=a:0,b:_0;' \
                    'path=a:_0,b:_1;',
            %w[B7] =>
                    'label=Y;' \
                    'city=revenue:30;' \
                    'city=revenue:30;' \
                    'path=a:0,b:_0;' \
                    'path=a:2,b:_1;',
            %w[D25] =>
                    'label=T;' \
                    'city=revenue:30;' \
                    'city=revenue:30;' \
                    'path=a:0,b:_0;' \
                    'path=a:5,b:_0;' \
                    'path=a:1,b:_1;',
            %w[L7] =>
                    'label=P;' \
                    'city=revenue:40;' \
                    'city=revenue:40;' \
                    'path=a:1,b:_0;' \
                    'path=a:2,b:_0;' \
                    'path=a:3,b:_1;' \
                    'path=a:4,b:_1;',
            %w[L27] =>
                    'label=T;' \
                    'city=revenue:30;' \
                    'city=revenue:30;' \
                    'path=a:1,b:_0;' \
                    'path=a:2,b:_0;' \
                    'path=a:3,b:_1;',
          },
          gray: {
            %w[A6] =>
                    'town=revenue:20;' \
                    'path=a:4,b:_0;' \
                    'path=a:5,b:_0;',
            %w[C6] =>
                    'path=a:3,b:4;',
            %w[D5] =>
                    'city=revenue:20;' \
                    'icon=image:port;' \
                    'path=a:4,b:_0;',
            %w[D7] =>
                    'path=a:1,b:3;',
            %w[E2] =>
                    'offboard=revenue:0;' \
                    'icon=image:port;' \
                    'path=a:4,b:_0;' \
                    'path=a:5,b:_0;',
            %w[F1] =>
                    'offboard=revenue:0;' \
                    'icon=image:port;' \
                    'path=a:4,b:_0;',
            %w[H1] =>
                    'town=revenue:20;' \
                    'path=a:3,b:_0;' \
                    'path=a:4,b:_0;' \
                    'path=a:5,b:_0;',
            %w[I28 K28] =>
                    'path=a:0,b:2;',
            %w[J11] =>
                    'city=revenue:30,loc:5;' \
                    'path=a:1,b:3;' \
                    'path=a:1,b:_0;' \
                    'path=a:3,b:_0;',
            %w[L3] =>
                    'town=revenue:20;' \
                    'path=a:3,b:_0;' \
                    'path=a:4,b:_0;',
            %w[L13] =>
                    'town=revenue:20;' \
                    'path=a:1,b:_0;' \
                    'path=a:4,b:_0;',
          },
        }.freeze
      end
    end
  end
end
