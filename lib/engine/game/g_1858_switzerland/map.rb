# frozen_string_literal: true

module Engine
  module Game
    module G1858Switzerland
      module Map
        LAYOUT = :flat

        LOCATION_NAMES = {
          'A12' => 'Genève',
          'A14' => 'South France',
          'B7' => 'Central France',
          'B16' => 'North South bonus',
          'C6' => 'La Chaux de Fonds',
          'C8' => 'Yverdon',
          'C10' => 'Lausanne',
          'C12' => 'Vevey & Montreux',
          'D3' => 'North France',
          'D7' => 'Neuchatel',
          'D9' => 'Fribourg',
          'D11' => 'Bulle',
          'D13' => 'Sion',
          'E4' => 'Basel',
          'E6' => 'Biel',
          'E8' => 'Bern',
          'F5' => 'Olten',
          'F9' => 'Thun',
          'F11' => 'Lötschberg',
          'F13' => 'Brig',
          'G4' => 'Baden & Brugg',
          'G14' => 'Simplon',
          'H3' => 'Schaffhausen',
          'H5' => 'Zürich',
          'H7' => 'Luzern',
          'H9' => 'Altdorf',
          'H11' => 'Gotthard',
          'H15' => 'Italy',
          'I2' => 'Germany',
          'I4' => 'Winterthur',
          'I6' => 'Wil',
          'I14' => 'Lugano',
          'J3' => 'Frauenfeld',
          'J5' => 'St Gallen',
          'J7' => 'Glarus',
          'J13' => 'Bellinzona',
          'K4' => 'Rorschach',
          'K8' => 'Chur',
          'L7' => 'Austria',
          'L16' => 'East West bonus',
        }.freeze

        HEXES = {
          white: {
            %w[A10] =>
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:0;',
            %w[B9] => '',
            %w[B11] =>
                    'junction;path=track:future,a:1,b:_0;' \
                    'icon=image:1858_switzerland/OS,sticky:1;' \
                    'border=type:province,edge:1;' \
                    'border=type:impassable,edge:5;',
            %w[C6] =>
                    'town=revenue:0;' \
                    'border=type:province,edge:4;',
            %w[C8] =>
                    'town=revenue:0;',
            %w[C10] =>
                    'city=revenue:0;label=Y;' \
                    'path=track:future,a:4,b:_0;' \
                    'icon=image:1858_switzerland/LFB,sticky:1;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:5;',
            %w[C12] =>
                    'town=revenue:0;town=revenue:0;' \
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:impassable,edge:2;' \
                    'border=type:province,edge:3;',
            %w[C14] =>
                    'upgrade=cost:80,terrain:mountain;',
            %w[D5] =>
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:4;',
            %w[D7] =>
                    'town=revenue:0;' \
                    'icon=image:1858_switzerland/JN,sticky:1;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[D9] =>
                    'town=revenue:0;' \
                    'path=track:future,a:1,b:_0;' \
                    'icon=image:1858_switzerland/LFB,sticky:1;' \
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[D11] =>
                    'town=revenue:0;' \
                    'upgrade=cost:80,terrain:mountain;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;',
            %w[D13] =>
                    'town=revenue:0;' \
                    'upgrade=cost:40,terrain:mountain;' \
                    'path=track:future,a:4,b:_0;' \
                    'icon=image:1858_switzerland/VZ,sticky:1;',
            %w[D15] =>
                    'upgrade=cost:120,terrain:mountain;',
            %w[E4] =>
                    'city=revenue:0;label=Y;' \
                    'path=track:future,a:5,b:_0;' \
                    'icon=image:1858_switzerland/SCB,sticky:1;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;',
            %w[E6] =>
                    'town=revenue:0;' \
                    'icon=image:1858_switzerland/EB,sticky:1;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;',
            %w[E8] =>
                    'city=revenue:0;label=Y;' \
                    'future_label=label:B,color:gray;' \
                    'icon=image:1858_switzerland/BSB,sticky:1;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;',
            %w[E10] =>
                    'upgrade=cost:80,terrain:mountain;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;',
            %w[E12] =>
                    'upgrade=cost:40,terrain:mountain;' \
                    'junction;path=track:future,a:1,b:_0;' \
                    'icon=image:1858_switzerland/VZ,sticky:1;',
            %w[E14] =>
                    'upgrade=cost:120,terrain:mountain;',
            %w[F3] => '',
            %w[F5] =>
                    'town=revenue:0;' \
                    'path=track:future,a:2,b:_0;' \
                    'path=track:future,a:5,b:_0;' \
                    'icon=image:1858_switzerland/SCB,sticky:1;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:5;',
            %w[F7] =>
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[F9] =>
                    'town=revenue:0;' \
                    'icon=image:1858_switzerland/BB,sticky:1;' \
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[F11] =>
                    'icon=image:1858_switzerland/L,sticky:1;' \
                    'upgrade=cost:120,terrain:mountain;' \
                    'border=type:province,edge:3;',
            %w[F13] =>
                    'town=revenue:0;' \
                    'upgrade=cost:40,terrain:mountain;',
            %w[F15] =>
                    'upgrade=cost:120,terrain:mountain;',
            %w[G4] =>
                    'town=revenue:0;town=revenue:0;' \
                    'path=track:future,a:5,b:_0;' \
                    'icon=image:1858_switzerland/NB,sticky:1;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[G6] =>
                    'junction;path=track:future,a:2,b:_0;' \
                    'icon=image:1858_switzerland/SCB,sticky:1;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;',
            %w[G8] =>
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:5;',
            %w[G10] =>
                    'upgrade=cost:120,terrain:mountain;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[G12] =>
                    'junction;path=track:future,a:4,b:_0;' \
                    'icon=image:1858_switzerland/FOB,sticky:1;' \
                    'upgrade=cost:120,terrain:mountain;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[G14] =>
                    'icon=image:1858_switzerland/S,sticky:1;' \
                    'upgrade=cost:120,terrain:mountain;' \
                    'border=type:province,edge:4;',
            %w[H3] =>
                    'town=revenue:0;' \
                    'path=track:future,a:0,b:_0;' \
                    'icon=image:1858_switzerland/NOB,sticky:1;' \
                    'border=type:province,edge:1;',
            %w[H7] =>
                    'city=revenue:0;' \
                    'icon=image:1858_switzerland/BLB,sticky:1;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[H9] =>
                    'town=revenue:0;' \
                    'path=track:future,a:0,b:_0;' \
                    'icon=image:1858_switzerland/GB,sticky:1;' \
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[H13] =>
                    'upgrade=cost:80,terrain:mountain;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;',
            %w[I4] =>
                    'city=revenue:0;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[I6] =>
                    'town=revenue:0;' \
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;',
            %w[I8] =>
                    'upgrade=cost:80,terrain:mountain;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;',
            %w[I10] =>
                    'junction;path=track:future,a:1,b:_0;' \
                    'icon=image:1858_switzerland/FOB,sticky:1;' \
                    'upgrade=cost:120,terrain:mountain;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;',
            %w[I12] =>
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;',
            %w[I14] =>
                    'city=revenue:0;' \
                    'icon=image:1858_switzerland/AFAI,sticky:1;',
            %w[J3] =>
                    'town=revenue:0;' \
                    'border=type:province,edge:1;',
            %w[J5] =>
                    'city=revenue:0;' \
                    'icon=image:1858_switzerland/VSB,sticky:1;' \
                    'path=track:future,a:4,b:_0;' \
                    'border=type:province,edge:2;',
            %w[J7] =>
                    'town=revenue:0;' \
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:5;',
            %w[J9] =>
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:3;',
            %w[J11] =>
                    'upgrade=cost:80,terrain:mountain;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;',
            %w[J13] =>
                    'town=revenue:0;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;',
            %w[K4] =>
                    'town=revenue:0;' \
                    'icon=image:1858_switzerland/VSB,sticky:1;' \
                    'path=track:future,a:1,b:_0;',
            %w[K6] =>
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:0;',
            %w[K8] =>
                    'town=revenue:0;' \
                    'icon=image:1858_switzerland/ChA,sticky:1;' \
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;',
            %w[K10] =>
                    'upgrade=cost:80,terrain:mountain;',
            %w[K12] =>
                    'upgrade=cost:120,terrain:mountain;' \
                    'border=type:province,edge:1;',
            %w[L9] =>
                    'upgrade=cost:120,terrain:mountain;',
            %w[L11] =>
                    'upgrade=cost:120,terrain:mountain;',
          },

          yellow: {
            %w[H5] =>
                    'city=revenue:40,groups:Zürich,loc:4.5;' \
                    'city=revenue:40,groups:Zürich,loc:1.5;' \
                    'path=a:0,b:_0;path=a:3,b:_0;path=a:2,b:_1;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:5;' \
                    'label=Z;',
          },

          green: {
            %w[A12] =>
                    'city=revenue:40,slots:2;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=G;' \
                    'icon=image:1858_switzerland/OS,sticky:1;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;',
          },

          red: {
            # South France
            %w[A14] =>
                    'offboard=revenue:yellow_20|green_30|brown_40|gray_50;' \
                    'icon=image:1858_switzerland/west;' \
                    'path=a:3,b:_0;',

            # Central France
            %w[B7] =>
                    'offboard=revenue:yellow_30|green_40|brown_50|gray_60;' \
                    'icon=image:1858_switzerland/west;' \
                    'path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;' \
                    'border=edge:3;',

            # North France
            %w[C4] =>
                    'offboard=revenue:yellow_30|green_40|brown_50|gray_60,groups:France,hide:1;' \
                    'path=a:5,b:_0;' \
                    'border=edge:1;border=edge:4;',
            %w[D3] =>
                    'offboard=revenue:yellow_30|green_40|brown_50|gray_60,groups:France;' \
                    'icon=image:1858_switzerland/north;' \
                    'path=a:0,b:_0;path=a:5,b:_0;' \
                    'border=edge:1;border=edge:4;',
            %w[E2] =>
                    'offboard=revenue:yellow_30|green_40|brown_50|gray_60,groups:France,hide:1;' \
                    'path=a:0,b:_0;' \
                    'border=edge:1;',

            # Germany
            %w[H1] =>
                    'offboard=revenue:yellow_30|green_40|brown_50|gray_70,groups:Germany,hide:1;' \
                    'path=a:0,b:_0;' \
                    'border=edge:5;',
            %w[I2] =>
                    'offboard=revenue:yellow_30|green_40|brown_50|gray_70,groups:Germany;' \
                    'icon=image:1858_switzerland/north;' \
                    'path=a:0,b:_0;path=a:1,b:_0;' \
                    'border=edge:2;',

            # Italy
            %w[H15] =>
                    'offboard=revenue:yellow_20|green_30|brown_50|gray_60,groups:Italy;' \
                    'icon=image:1858_switzerland/south;' \
                    'path=a:2,b:_0;path=a:4,b:_0;' \
                    'border=edge:5;',
            %w[I16] =>
                    'offboard=revenue:yellow_20|green_30|brown_50|gray_60,groups:Italy,hide:1;' \
                    'path=a:3,b:_0;' \
                    'border=edge:2;',

            # Austria
            %w[L5] =>
                    'offboard=revenue:yellow_20|green_30|brown_40|gray_50,groups:Austria,hide:1;' \
                    'path=a:1,b:_0;path=a:2,b:_0;' \
                    'border=edge:0;',
            %w[L7] =>
                    'offboard=revenue:yellow_20|green_30|brown_40|gray_50,groups:Austria;' \
                    'icon=image:1858_switzerland/east;' \
                    'path=a:2,b:_0;' \
                    'border=edge:3;',
          },

          gray: {
            %w[H11] =>
                    'path=track:broad,a:3,b:5;' \
                    'path=track:narrow,a:1,b:4;' \
                    'icon=image:1858_switzerland/FOB,sticky:1;' \
                    'icon=image:1858_switzerland/GB,sticky:1;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[B16] => 'offboard=revenue:yellow_0|green_0|brown_50|gray_60;',
            %w[L16] => 'offboard=revenue:yellow_0|green_0|brown_60|gray_80;',
          },
        }.freeze

        # These are the number of provincial borders crossed when travelling between cities.
        # This is done as a 2D hash of city coordinates. The rows and columns are ordered
        # by province:
        #   1. Genève (Genève)
        #   2. Vaud (Lausanne)
        #   3. Bern (Bern)
        #   4. Basel (Basel)
        #   5. Zürich (Zürich and Winterthur)
        #   6. Luzern (Luzern)
        #   7. Ticino (Lugano)
        #   8. St Gallen (St Gallen)
        # rubocop: disable Layout/HashAlignment
        TOKEN_DISTANCES = {
          'A12' => { 'A12' => 0, 'C10' => 1, 'E8' => 2, 'E4' => 3, 'H5' => 4, 'I4' => 4, 'H7' => 3, 'I14' => 3, 'J5' => 4 },
          'C10' => { 'A12' => 1, 'C10' => 0, 'E8' => 1, 'E4' => 2, 'H5' => 3, 'I4' => 3, 'H7' => 2, 'I14' => 2, 'J5' => 3 },
          'E8'  => { 'A12' => 2, 'C10' => 1, 'E8' => 0, 'E4' => 1, 'H5' => 2, 'I4' => 2, 'H7' => 1, 'I14' => 2, 'J5' => 2 },
          'E4'  => { 'A12' => 3, 'C10' => 2, 'E8' => 1, 'E4' => 0, 'H5' => 1, 'I4' => 1, 'H7' => 1, 'I14' => 3, 'J5' => 2 },
          'H5'  => { 'A12' => 4, 'C10' => 3, 'E8' => 2, 'E4' => 1, 'H5' => 0, 'I4' => 0, 'H7' => 1, 'I14' => 3, 'J5' => 1 },
          'I4'  => { 'A12' => 4, 'C10' => 3, 'E8' => 2, 'E4' => 1, 'H5' => 0, 'I4' => 0, 'H7' => 1, 'I14' => 3, 'J5' => 1 },
          'H7'  => { 'A12' => 3, 'C10' => 2, 'E8' => 1, 'E4' => 1, 'H5' => 1, 'I4' => 1, 'H7' => 0, 'I14' => 2, 'J5' => 1 },
          'I14' => { 'A12' => 3, 'C10' => 2, 'E8' => 2, 'E4' => 3, 'H5' => 3, 'I4' => 3, 'H7' => 2, 'I14' => 0, 'J5' => 2 },
          'J5'  => { 'A12' => 4, 'C10' => 3, 'E8' => 2, 'E4' => 2, 'H5' => 1, 'I4' => 1, 'H7' => 1, 'I14' => 2, 'J5' => 0 },
        }.freeze
        # rubocop: enable Layout/HashAlignment
      end
    end
  end
end
