# frozen_string_literal: true

require_relative 'tiles'

module Engine
  module Game
    module G1858
      module Map
        include G1858::Tiles

        LAYOUT = :flat

        LOCATION_NAMES = {
          'F1' => 'Gijón',
          'L17' => 'Alicante',
          'L19' => 'Cartagena',
          'B5' => 'Vigo',
          'B7' => 'Braga',
          'B9' => 'Porto',
          'B11' => 'Coimbra',
          'B13' => 'Santarém',
          'B15' => 'Setúbal',
          'C2' => 'La Coruña',
          'C4' => 'Santiago & Orense',
          'C20' => 'Faro',
          'D3' => 'Lugo',
          'D13' => 'Cáceres',
          'D15' => 'Badajoz',
          'D19' => 'Huelva',
          'E18' => 'Sevilla',
          'E20' => 'Cádiz',
          'F5' => 'León',
          'F9' => 'Salamanca',
          'F19' => 'Marchena',
          'G6' => 'Palencia',
          'G8' => 'Valladolid',
          'G10' => 'Ávila',
          'G12' => 'Talavera',
          'G18' => 'Córdoba',
          'G20' => 'Málaga',
          'H3' => 'Santander',
          'H5' => 'Burgos',
          'H15' => 'Ciudad Real',
          'H17' => 'Jaén & Linares',
          'H19' => 'Granada',
          'I2' => 'Bilbao',
          'I4' => 'Vitoria',
          'I10' => 'Guadalajara',
          'J3' => 'San Sebastián',
          'J5' => 'Logroño',
          'J15' => 'Albacete',
          'K4' => 'Pamplona',
          'K18' => 'Murcia',
          'L13' => 'Valencia',
          'M10' => 'Tortosa',
          'M12' => 'Castellón',
          'N7' => 'Lérida',
          'N9' => 'Reus & Tarragona',
          'O8' => 'Barcelona',
          'P7' => 'Gerona',
          'L7' => 'Zaragoza',
          'H11' => 'Madrid',
          'H13' => 'Aranjuez',
          'A14' => 'Lisboa',
          'M2' => 'France',
        }.freeze

        HEXES = {
          white: {
            # Plain track hexes
            %w[A12 B3 B17 B19 C6 C10 C14 D11 D17 E10 F17 G4 G16 H7 I12 J7 J9 J11
               J13 J17 J19 K8 K12 K14 K16 L9 L15] => '',
            %w[D5 D7 E2 E4 E6 E16 G2 I18 M6] => 'upgrade=cost:40,terrain:mountain',
            %w[F3 F11 H9 I6 I8 I16 K10 L5 L11 O6] => 'upgrade=cost:80,terrain:mountain',
            %w[I20 M4 N5] => 'upgrade=cost:120,terrain:mountain',
            %w[C8 C12 C16 C18 D9 E8 E12 E14 F7 F13 F15 G14 K6 M8] => 'upgrade=cost:20,terrain:water',

            # Town hexes
            %w[B7 B11 B15 D3 D19 F5 F9 G6 G10 H5 H15 I4 I10 J3 J5 J15 K4 M10 M12 N7] => 'town=revenue:0',
            %w[B13 C20 D13 D15 F19 G12] => 'town=revenue:0;upgrade=cost:20,terrain:water',
            %w[P7] => 'town=revenue:0;upgrade=cost:40,terrain:mountain',

            # Double town hexes
            %w[H17 N9] => 'town=revenue:0;town=revenue:0',
            %w[C4] => 'town=revenue:0;town=revenue:0;upgrade=cost:40,terrain:mountain',

            # City hexes
            %w[B5 C2 G8 H19 I2] => 'city=revenue:0',
            %w[B9] => 'city=revenue:0;label=P;label=Y;upgrade=cost:20,terrain:water',
            %w[E18 G20 L13] => 'city=revenue:0;label=Y;upgrade=cost:20,terrain:water',
            %w[E20 G18 K18] => 'city=revenue:0;upgrade=cost:20,terrain:water',
            %w[H3] => 'city=revenue:0;upgrade=cost:40,terrain:mountain',
            %w[O8] => 'city=revenue:0;label=B',
          },
          yellow: {
            %w[L7] => 'city=revenue:30;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;label=Y',
            %w[H11] => 'city=revenue:40,loc:1;path=a:1,b:_0;' \
                       'city=revenue:40,loc:2.5;path=a:2,b:_1;' \
                       'city=revenue:40,loc:4;path=a:0,b:_2;path=a:4,b:_2;' \
                       'label=M',
            %w[H13] => 'town=revenue:10;path=a:3,b:_0;path=a:_0,b:5',
            %w[I14] => 'path=a:2,b:5',
          },
          green: {
            %w[A14] => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=L',
          },
          red: {
            %w[K2] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_70,groups:France,hide:1;' \
                      'path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;' \
                      'border=edge:5',
            %w[L3] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_70,groups:France,hide:1;' \
                      'path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;path=a:5,b:_0,track:dual;' \
                      'border=edge:2;border=edge:4',
            %w[M2] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_70,groups:France;' \
                      'path=a:0,b:_0,track:dual;' \
                      'border=edge:1;border=edge:5',
            %w[N3 O4] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_70,groups:France,hide:1;' \
                         'path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;' \
                         'border=edge:2;border=edge:5',
            %w[P5] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_70,groups:France,hide:1;' \
                      'path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;' \
                      'border=edge:2',
          },
          blue: {
            %w[A16] => 'offboard=revenue:30;path=a:3,b:_0',
            %w[J1] => 'offboard=revenue:20;path=a:1,b:_0,track:dual',
          },
          gray: {
            %w[D1] => 'path=a:0,b:1,track:dual;path=a:0,b:5,track:dual',
            %w[F1] => 'city=revenue:40,slots:2;path=a:5,b:_0,track:dual;path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual',
            %w[F21] => 'path=a:2,b:3;path=a:3,b:4',
            %w[H21] => 'path=a:2,b:3',
            %w[K20] => 'path=a:2,b:3;border=edge:4',
            %w[L17] => 'town=revenue:10;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;border=edge:0',
            %w[L19] => 'town=revenue:10;path=a:2,b:_0;border=edge:1',
          },
        }.freeze
      end
    end
  end
end
