# frozen_string_literal: true

require_relative 'tiles'

module Engine
  module Game
    module G1858
      module Map
        include G1858::Tiles

        LAYOUT = :flat

        LOCATION_NAMES = {
          'A14' => 'Lisboa',
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
          'F1' => 'Gijón',
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
          'H11' => 'Madrid',
          'H13' => 'Aranjuez',
          'H15' => 'Ciudad Real',
          'H17' => 'Jaén & Linares',
          'H19' => 'Granada',
          'I2' => 'Bilbao',
          'I4' => 'Vitoria',
          'I10' => 'Guadalajara',
          'J3' => 'San Sebastián',
          'J5' => 'Logroño',
          'K18' => 'Murcia',
          'J15' => 'Albacete',
          'K4' => 'Pamplona',
          'L7' => 'Zaragoza',
          'L13' => 'Valencia',
          'L17' => 'Alicante',
          'L19' => 'Cartagena',
          'M2' => 'France',
          'M10' => 'Tortosa',
          'M12' => 'Castellón',
          'N7' => 'Lérida',
          'N9' => 'Reus & Tarragona',
          'O8' => 'Barcelona',
          'P7' => 'Gerona',
        }.freeze

        HEXES = {
          white: {
            # Plain track hexes
            %w[B3 B17 B19 C10 H7 I12] => '',
            %w[A12] =>
                    'border=type:province,edge:4',
            %w[L15] =>
                    'border=type:province,edge:1',
            %w[L9] =>
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:5',
            %w[J19] =>
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2',
            %w[K8] =>
                    'path=track:future,a:1,b:4;' \
                    'icon=image:1858/MZ,sticky:1;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2',
            %w[F17] =>
                    'path=track:future,a:1,b:5;' \
                    'icon=image:1858/CS,sticky:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3',
            %w[J11 J13] =>
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5',
            %w[K14] =>
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2',
            %w[C6] =>
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:5',
            %w[D11] =>
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5',
            %w[J17 K12] =>
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3',
            %w[G16 K16] =>
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4',
            %w[C14] =>
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5',
            %w[E10] =>
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3',
            %w[D17] =>
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:5',
            %w[J7] =>
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5',
            %w[G4] =>
                    'junction;path=track:future,a:4,b:_0;' \
                    'icon=image:1858/AS,sticky:1;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4',
            %w[J9] =>
                    'path=track:future,a:1,b:4;' \
                    'icon=image:1858/MZ,sticky:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5',

            %w[E2] =>
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2',
            %w[E16 G2] =>
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:5',
            %w[M6] =>
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5',
            %w[E6] =>
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2',
            %w[D5] =>
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5',
            %w[D7] =>
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4',
            %w[I18] =>
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5',
            %w[E4] =>
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4',

            %w[O6] =>
                    'upgrade=cost:80,terrain:mountain',
            %w[L5] =>
                    'upgrade=cost:80,terrain:mountain;' \
                    'border=type:province,edge:2',
            %w[H9 I8] =>
                    'upgrade=cost:80,terrain:mountain;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:5',
            %w[I6] =>
                    'upgrade=cost:80,terrain:mountain;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4',
            %w[F3] =>
                    'path=track:future,a:0,b:3;' \
                    'upgrade=cost:80,terrain:mountain;' \
                    'icon=image:1858/LG,sticky:1;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:5',
            %w[I16] =>
                    'upgrade=cost:80,terrain:mountain;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:5',
            %w[L11] =>
                    'upgrade=cost:80,terrain:mountain;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4',
            %w[K10] =>
                    'upgrade=cost:80,terrain:mountain;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:5',
            %w[F11] =>
                    'upgrade=cost:80,terrain:mountain;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5',

            %w[I20] =>
                    'upgrade=cost:120,terrain:mountain;' \
                    'border=type:province,edge:4',
            %w[M4] =>
                    'upgrade=cost:120,terrain:mountain;' \
                    'border=type:province,edge:5',
            %w[N5] =>
                    'upgrade=cost:120,terrain:mountain;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2',

            %w[E14] =>
                    'path=track:future,a:1,b:5;' \
                    'upgrade=cost:20,terrain:water;' \
                    'icon=image:1858/BCR,sticky:1;',
            %w[C8] =>
                    'upgrade=cost:20,terrain:water;' \
                    'border=type:province,edge:3',
            %w[D9] =>
                    'upgrade=cost:20,terrain:water;' \
                    'border=type:province,edge:5',
            %w[C16 C18] =>
                    'upgrade=cost:20,terrain:water;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5',
            %w[G14] =>
                    'upgrade=cost:20,terrain:water;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2',
            %w[C12] =>
                    'upgrade=cost:20,terrain:water;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:5',
            %w[F15] =>
                    'junction;path=track:future,a:2,b:_0;' \
                    'upgrade=cost:20,terrain:water;' \
                    'icon=image:1858/BCR,sticky:1;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5',
            %w[M8] =>
                    'upgrade=cost:20,terrain:water;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5',
            %w[K6] =>
                    'path=track:future,a:3,b:5;' \
                    'upgrade=cost:20,terrain:water;' \
                    'icon=image:1858/ZP,sticky:1;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3',
            %w[F7] =>
                    'upgrade=cost:20,terrain:water;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5',
            %w[E12] =>
                    'path=track:future,a:1,b:5;' \
                    'upgrade=cost:20,terrain:water;' \
                    'icon=image:1858/CMP,sticky:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4',
            %w[F13] =>
                    'path=track:future,a:2,b:4;' \
                    'upgrade=cost:20,terrain:water;' \
                    'icon=image:1858/CMP,sticky:1;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5',
            %w[E8] =>
                    'upgrade=cost:20,terrain:water;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5',

            # Town hexes
            %w[B15] =>
                    'town=revenue:0;' \
                    'border=type:impassable,edge:2',
            %w[J3] =>
                    'town=revenue:0',
            %w[M12] =>
                    'town=revenue:0;' \
                    'border=type:province,edge:3',
            %w[B11] =>
                    'town=revenue:0,style:dot;' \
                    'path=track:future,a:3,b:_0;' \
                    'icon=image:1858/PL,sticky:1;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1',
            %w[H15] =>
                    'town=revenue:0;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1',
            %w[G6 N7] =>
                    'town=revenue:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2',
            %w[I10] =>
                    'town=revenue:0,style:dot;' \
                    'path=track:future,a:_0,b:4;' \
                    'icon=image:1858/MZ,sticky:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3',
            %w[B7 H5] =>
                    'town=revenue:0;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4',
            %w[D3] =>
                    'town=revenue:0;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5',
            %w[K4] =>
                    'town=revenue:0,style:dot;' \
                    'path=track:future,a:0,b:_0;' \
                    'icon=image:1858/ZP,sticky:1;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:5',
            %w[I4] =>
                    'town=revenue:0;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2',
            %w[J5] =>
                    'town=revenue:0;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:5',
            %w[J15] =>
                    'town=revenue:0;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5',
            %w[D19] =>
                    'town=revenue:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3',
            %w[F9] =>
                    'town=revenue:0;' \
                    'icon=image:1858/MS,sticky:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5',
            %w[F5] =>
                    'town=revenue:0,style:dot;' \
                    'path=track:future,a:3,b:_0;' \
                    'icon=image:1858/LG,sticky:1;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5',
            %w[G10] =>
                    'town=revenue:0,style:dot;' \
                    'path=track:future,a:3,b:_0;' \
                    'path=track:future,a:5,b:_0;' \
                    'icon=image:1858/MV,sticky:1;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:5',
            %w[M10] =>
                    'town=revenue:0;' \
                    'upgrade=cost:20,terrain:water;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3',

            %w[F19] =>
                    'town=revenue:0;' \
                    'upgrade=cost:20,terrain:water',
            %w[C20] =>
                    'town=revenue:0;' \
                    'upgrade=cost:20,terrain:water;' \
                    'border=type:province,edge:4',
            %w[D15] =>
                    'town=revenue:0,style:dot;' \
                    'path=track:future,a:_0,b:4;' \
                    'upgrade=cost:20,terrain:water;' \
                    'icon=image:1858/BCR,sticky:1;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2',
            %w[B13] =>
                    'town=revenue:0,style:dot;' \
                    'path=track:future,a:1,b:_0;' \
                    'upgrade=cost:20,terrain:water;' \
                    'icon=image:1858/LC,sticky:1;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4',
            %w[D13] =>
                    'town=revenue:0,style:dot;' \
                    'path=track:future,a:_0,b:4;' \
                    'upgrade=cost:20,terrain:water;' \
                    'icon=image:1858/CMP,sticky:1;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3',
            %w[G12] =>
                    'town=revenue:0,style:dot;' \
                    'path=track:future,a:1,b:_0;' \
                    'path=track:future,a:_0,b:4;' \
                    'upgrade=cost:20,terrain:water;' \
                    'icon=image:1858/CMP,sticky:1;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3',

            %w[P7] =>
                    'town=revenue:0;' \
                    'upgrade=cost:40,terrain:mountain',

            # Double town hexes
            %w[N9] =>
                    'town=revenue:0;town=revenue:0;' \
                    'icon=image:1858/RT,sticky:1;' \
                    'border=type:province,edge:2',
            %w[H17] =>
                    'town=revenue:0;town=revenue:0;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4',
            %w[C4] =>
                    'town=revenue:0,style:dot,loc:1;' \
                    'town=revenue:0,style:dot,loc:3;' \
                    'path=track:future,a:1,b:_0;' \
                    'path=track:future,a:3,b:_1;' \
                    'upgrade=cost:40,terrain:mountain;' \
                    'icon=image:1858/SC,sticky:1,loc:0;' \
                    'icon=image:1858/OV,sticky:1,loc:1;',

            # City hexes
            %w[C2] =>
                    'city=revenue:0;' \
                    'path=track:future,a:0,b:_0;' \
                    'icon=image:1858/SC,sticky:1;',
            %w[H19] =>
                    'city=revenue:0',
            %w[B5] =>
                    'city=revenue:0;' \
                    'path=track:future,a:4,b:_0;' \
                    'icon=image:1858/OV,sticky:1;' \
                    'border=type:province,edge:0;',
            %w[I2] =>
                    'city=revenue:0;' \
                    'icon=image:1858/CB,sticky:1;' \
                    'border=type:province,edge:1',
            %w[G8] =>
                    'city=revenue:0;' \
                    'path=track:future,a:0,b:_0;' \
                    'icon=image:1858/MV,sticky:1;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2',
            %w[B9] =>
                    'city=revenue:0;label=Y;' \
                    'future_label=label:P,color:brown;' \
                    'path=track:future,a:0,b:_0;' \
                    'icon=image:1858/PL,sticky:1;' \
                    'upgrade=cost:20,terrain:water;',
            %w[G20] =>
                    'city=revenue:0;label=Y;' \
                    'path=track:future,a:3,b:_0;' \
                    'icon=image:1858/CM,sticky:1;' \
                    'upgrade=cost:20,terrain:water',
            %w[L13] =>
                    'city=revenue:0;label=Y;' \
                    'icon=image:1858/VJ,sticky:1;' \
                    'upgrade=cost:20,terrain:water;',
            %w[E18] =>
                    'city=revenue:0;label=Y;' \
                    'path=track:future,a:0,b:_0;' \
                    'path=track:future,a:4,b:_0;' \
                    'upgrade=cost:20,terrain:water;' \
                    'icon=image:1858/SJC,sticky:1,loc:0;' \
                    'icon=image:1858/CS,sticky:1,loc:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3',
            %w[E20] =>
                    'city=revenue:0;' \
                    'path=track:future,a:3,b:_0;' \
                    'icon=image:1858/SJC,sticky:1;' \
                    'upgrade=cost:20,terrain:water;',
            %w[G18] =>
                    'city=revenue:0;' \
                    'path=track:future,a:0,b:_0;' \
                    'path=track:future,a:2,b:_0;' \
                    'upgrade=cost:20,terrain:water;' \
                    'icon=image:1858/CM,sticky:1,loc:0;' \
                    'icon=image:1858/CS,sticky:1,loc:1;',
            %w[K18] =>
                    'city=revenue:0;' \
                    'path=track:future,a:_0,b:5;' \
                    'icon=image:1858/MC,sticky:1;' \
                    'upgrade=cost:20,terrain:water;',
            %w[H3] =>
                    'city=revenue:0;' \
                    'path=track:future,a:1,b:_0;' \
                    'icon=image:1858/AS,sticky:1;' \
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5',
            %w[O8] =>
                    'city=revenue:0;label=B;' \
                    'icon=image:1858/BM,sticky:1;',
          },
          yellow: {
            %w[L7] =>
                    'city=revenue:30;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;label=Y;' \
                    'icon=image:1858/MZ,sticky:1;' \
                    'icon=image:1858/ZP,sticky:1;',
            %w[H11] =>
                    'city=revenue:40,groups:Madrid,loc:1;path=a:1,b:_0;' \
                    'city=revenue:40,groups:Madrid,loc:2.5;path=a:2,b:_1;' \
                    'city=revenue:40,groups:Madrid,loc:4;path=a:0,b:_2;path=a:4,b:_2;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;' \
                    'label=M',
            %w[H13] =>
                    'town=revenue:10;path=a:3,b:_0;path=a:_0,b:5;' \
                    'icon=image:1858/MA,sticky:1;',
            %w[I14] =>
                    'path=a:2,b:5',
          },
          green: {
            %w[A14] =>
                    'city=revenue:40,slots:2;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=L;' \
                    'icon=image:1858/LC,sticky:1;' \
                    'border=type:impassable,edge:5',
          },
          red: {
            %w[K2] =>
                    'offboard=revenue:yellow_30|green_40|brown_50|gray_70,groups:France,hide:1;' \
                    'path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;' \
                    'border=edge:5',
            %w[L3] =>
                    'offboard=revenue:yellow_30|green_40|brown_50|gray_70,groups:France,hide:1;' \
                    'path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;path=a:5,b:_0,track:dual;' \
                    'border=edge:2;border=edge:4',
            %w[M2] =>
                    'offboard=revenue:yellow_30|green_40|brown_50|gray_70,groups:France;' \
                    'path=a:0,b:_0,track:dual;' \
                    'border=edge:1;border=edge:5',
            %w[N3 O4] =>
                    'offboard=revenue:yellow_30|green_40|brown_50|gray_70,groups:France,hide:1;' \
                    'path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;' \
                    'border=edge:2;border=edge:5',
            %w[P5] =>
                    'offboard=revenue:yellow_30|green_40|brown_50|gray_70,groups:France,hide:1;' \
                    'path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;' \
                    'border=edge:2',
          },
          blue: {
            %w[A16] =>
                    'offboard=revenue:30;icon=image:port,large:1;path=a:3,b:_0',
            %w[J1] =>
                    'offboard=revenue:20;icon=image:port,large:1;path=a:1,b:_0,track:dual',
          },
          gray: {
            %w[D1] =>
                    'path=a:0,b:1,track:dual;path=a:0,b:5,track:dual;' \
                    'border=type:province,edge:5',
            %w[F1] =>
                    'city=revenue:40,slots:2;' \
                    'icon=image:1858/LG,sticky:1;' \
                    'path=a:5,b:_0,track:dual;path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;',
            %w[F21] =>
                    'path=a:2,b:3;path=a:3,b:4',
            %w[H21] =>
                    'path=a:2,b:3',
            %w[K20] =>
                    'path=a:2,b:3;border=edge:4',
            %w[L17] =>
                    'town=revenue:10;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;border=edge:0',
            %w[L19] =>
                    'town=revenue:10;path=a:2,b:_0;border=edge:1;' \
                    'icon=image:1858/MC,sticky:1;',
          },
        }.freeze
      end
    end
  end
end
