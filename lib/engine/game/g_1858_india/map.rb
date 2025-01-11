# frozen_string_literal: true

module Engine
  module Game
    module G1858India
      module Map
        LAYOUT = :pointy
        AXES = { x: :number, y: :letter }.freeze

        LOCATION_NAMES = {
          'A4' => 'Kabul',
          'A6' => 'Peshawar',
          'B7' => 'Rawalapindi',
          'B9' => 'Srinigar',
          'C8' => 'Lahore',
          'C10' => 'Amritar & Ludhiana',
          'D1' => 'Quetta',
          'D5' => 'Multan',
          'D9' => 'Bhatinda',
          'D11' => 'Ambala & Saharanpur',
          'D13' => 'Meerut & Moradabad',
          'E2' => 'Shikapur',
          'E8' => 'Bikaner',
          'E12' => 'Delhi',
          'E14' => 'Bareilly',
          'E20' => 'Kathmandu',
          'E24' => 'Lhasa',
          'F7' => 'Jodhpur',
          'F9' => 'Jaipur',
          'F11' => 'Agra & Gwalior',
          'F13' => 'Cawnpore',
          'F15' => 'Lucknow',
          'F17' => 'Gorakhpur',
          'F21' => 'Darbhanga',
          'F23' => 'Darjeeling',
          'F25' => 'Gauhati',
          'G2' => 'Karachi',
          'G16' => 'Allahabad',
          'G18' => 'Benares',
          'G20' => 'Patna',
          'G22' => 'Bhagaipur',
          'H7' => 'Ahmadabad',
          'H11' => 'Bhopal',
          'H13' => 'Jubbulpore',
          'H21' => 'Assensole & Burdwan',
          'H25' => 'Dacca',
          'I4' => 'Jamnaga',
          'I6' => 'Baroda',
          'I10' => 'Indore',
          'I22' => 'Calcutta',
          'I24' => 'Khulna',
          'I26' => 'Chittagong',
          'J7' => 'Surat',
          'J11' => 'Amraoti',
          'J13' => 'Nagpur',
          'J15' => 'Raipur',
          'J19' => 'Cuttack',
          'K6' => 'Bombay',
          'K8' => 'Poona',
          'K14' => 'Warangal',
          'L7' => 'Kolhapur',
          'L9' => 'Solapur',
          'L13' => 'Hyderabad',
          'L17' => 'Visagapatam',
          'M10' => 'Bellary',
          'M14' => 'Bezawada',
          'O8' => 'Mangalore',
          'O10' => 'Mysore',
          'O12' => 'Bangalore',
          'O14' => 'Madras',
          'P11' => 'Coimbatore',
          'P13' => 'Trichinopoly',
          'Q10' => 'Cochin',
          'Q12' => 'Madura',
          'R11' => 'Trivandrum',

          # Province names.
          'B5' => 'NORTHWEST FRONTIER',
          'B11' => 'KASHMIR',
          'D3' => 'BALUCHISTAN',
          'D7' => 'PUNJAB',
          'E16' => 'NEPAL',
          'F3' => 'SIND',
          'F19' => 'UNITED PROVINCES',
          'G8' => 'RAJPUTANA',
          'G10' => 'CENTRAL INDIA',
          'H5' => 'GUJURAT',
          'H23' => 'ASSAM',
          'I14' => 'CENTRAL PROVINCES',
          'I20' => 'BENGAL',
          'K12' => 'HYDERABAD',
          'M8' => 'BOMBAY',
          'M12' => 'MADRAS',
          'N11' => 'MYSORE',
        }.freeze

        HEXES = {
          white: {
            %w[A6] =>
                    'city=revenue:0;' \
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[A8] =>
                    'upgrade=cost:20,terrain:river;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;',
            %w[A10 A12 A14] =>
                    'upgrade=cost:120,terrain:mountain;',
            %w[B5] =>
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[B7] =>
                    'city=revenue:0;' \
                    'upgrade=cost:20,terrain:river;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;',
            %w[B9] =>
                    'town=revenue:0;' \
                    'upgrade=cost:80,terrain:mountain;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:5;',
            %w[B11] =>
                    'upgrade=cost:120,terrain:mountain;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:5;',
            %w[B13] =>
                    'upgrade=cost:120,terrain:mountain;' \
                    'border=type:province,edge:0;',
            %w[C2] =>
                    'upgrade=cost:80,terrain:mountain;',
            %w[C4] =>
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[C6] =>
                    'upgrade=cost:40,terrain:river;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;',
            %w[C8] =>
                    'city=revenue:0;' \
                    'border=type:province,edge:3;',
            %w[C10] =>
                    'town=revenue:0;' \
                    'town=revenue:0;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;',
            %w[C12] =>
                    'upgrade=cost:80,terrain:mountain;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:5;',
            %w[D1] =>
                    'town=revenue:0;' \
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:5;',
            %w[D3] =>
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[D5] =>
                    'city=revenue:0;' \
                    'upgrade=cost:40,terrain:river;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:5;',
            %w[D7] =>
                    'upgrade=cost:20,terrain:river;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:5;',
            %w[D9] =>
                    'town=revenue:0;' \
                    'border=type:province,edge:0;',
            %w[D11] =>
                    'town=revenue:0;' \
                    'town=revenue:0;' \
                    'border=type:province,edge:4;',
            %w[D13] =>
                    'town=revenue:0;' \
                    'town=revenue:0;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:4;',
            %w[D15] =>
                    'upgrade=cost:120,terrain:mountain;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;',
            %w[E2] =>
                    'town=revenue:0;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;',
            %w[E4] =>
                    'upgrade=cost:40,terrain:river;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;',
            %w[E6] =>
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;',
            %w[E8] =>
                    'town=revenue:0;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;',
            %w[E10] =>
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:5;',
            %w[E14] =>
                    'town=revenue:0;' \
                    'upgrade=cost:20,terrain:river;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;',
            %w[E16] =>
                    'upgrade=cost:120,terrain:mountain;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:5;',
            %w[E18] =>
                    'upgrade=cost:120,terrain:mountain;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:5;',
            %w[F1] => '',
            %w[F3] =>
                    'upgrade=cost:40,terrain:river;',
            %w[F5] =>
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[F7] =>
                    'town=revenue:0;' \
                    'border=type:province,edge:1;',
            %w[F9] =>
                    'city=revenue:0;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[F11] =>
                    'town=revenue:0;' \
                    'town=revenue:0;' \
                    'upgrade=cost:20,terrain:river;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;',
            %w[F13] =>
                    'city=revenue:0;' \
                    'upgrade=cost:20,terrain:river;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:5;',
            %w[F15] =>
                    'city=revenue:0;' \
                    'upgrade=cost:20,terrain:river;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:3;',
            %w[F17] =>
                    'town=revenue:0;' \
                    'upgrade=cost:20,terrain:river;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;',
            %w[F19] =>
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[F21] =>
                    'town=revenue:0;' \
                    'upgrade=cost:20,terrain:river;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;',
            %w[F23] =>
                    'town=revenue:0;' \
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[F25] =>
                    'town=revenue:0;' \
                    'upgrade=cost:40,terrain:river;' \
                    'border=type:province,edge:1;',
            %w[G2] =>
                    'city=revenue:0;' \
                    'label=Y;' \
                    'upgrade=cost:40,terrain:river;' \
                    'border=type:province,edge:5;',
            %w[G4] =>
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[G6] =>
                    'upgrade=cost:20,terrain:river;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:5;',
            %w[G8] =>
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[G10] =>
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;',
            %w[G12] =>
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:5;',
            %w[G14] =>
                    'upgrade=cost:20,terrain:river;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[G16] =>
                    'city=revenue:0;' \
                    'upgrade=cost:40,terrain:river;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:5;',
            %w[G18] =>
                    'town=revenue:0;' \
                    'upgrade=cost:40,terrain:river;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[G20] =>
                    'city=revenue:0;' \
                    'upgrade=cost:40,terrain:river;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;',
            %w[G22] =>
                    'town=revenue:0;' \
                    'upgrade=cost:40,terrain:river;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[G24] =>
                    'upgrade=cost:40,terrain:river;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;',
            %w[G26] =>
                    'upgrade=cost:40,terrain:mountain;',
            %w[H3] =>
                    'upgrade=cost:40,terrain:river;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;' \
                    'border=type:impassible,edge:5;',
            %w[H5] =>
                    'upgrade=cost:40,terrain:river;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;',
            %w[H7] =>
                    'city=revenue:0;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[H9] =>
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;',
            %w[H11] =>
                    'town=revenue:0;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[H13] =>
                    'town=revenue:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;',
            %w[H15] =>
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;',
            %w[H17] =>
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;',
            %w[H19] =>
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:2;',
            %w[H21] =>
                    'town=revenue:0;' \
                    'town=revenue:0;' \
                    'upgrade=cost:20,terrain:river;' \
                    'border=type:province,edge:4;',
            %w[H23] =>
                    'upgrade=cost:60,terrain:river;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;',
            %w[H25] =>
                    'city=revenue:0;' \
                    'upgrade=cost:40,terrain:river;',
            %w[I4] =>
                    'town=revenue:0;' \
                    'border=type:impassible,edge:2;',
            %w[I6] =>
                    'town=revenue:0;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[I8] =>
                    'upgrade=cost:20,terrain:river;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:5;',
            %w[I10] =>
                    'town=revenue:0;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[I12] =>
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;',
            %w[I14] =>
                    'upgrade=cost:40,terrain:mountain;',
            %w[I16] =>
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;',
            %w[I18] =>
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;',
            %w[I20] => '',
            %w[I24] =>
                    'town=revenue:0;' \
                    'upgrade=cost:40,terrain:river;' \
                    'border=type:province,edge:1;',
            %w[J7] =>
                    'town=revenue:0;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;',
            %w[J9] =>
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:5;',
            %w[J11] =>
                    'town=revenue:0;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:5;',
            %w[J13] =>
                    'city=revenue:0;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:5;',
            %w[J15] =>
                    'town=revenue:0;' \
                    'border=type:province,edge:0;',
            %w[J17] =>
                    'upgrade=cost:20,terrain:river;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;',
            %w[J19] =>
                    'town=revenue:0;' \
                    'upgrade=cost:20,terrain:river;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;',
            %w[J21] =>
                    'upgrade=cost:40,terrain:river;',
            %w[K6] =>
                    'city=revenue:0;' \
                    'label=Y;',
            %w[K8] =>
                    'town=revenue:0;' \
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;',
            %w[K10] =>
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;',
            %w[K12] =>
                    'upgrade=cost:20,terrain:river;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;',
            %w[K14] =>
                    'town=revenue:0;' \
                    'upgrade=cost:20,terrain:river;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;',
            %w[K16] =>
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;',
            %w[K18] =>
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;',
            %w[K20] =>
                    'upgrade=cost:40,terrain:river;' \
                    'border=type:province,edge:1;',
            %w[L7] =>
                    'town=revenue:0;' \
                    'upgrade=cost:40,terrain:mountain;',
            %w[L9] =>
                    'town=revenue:0;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[L11] =>
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:5;',
            %w[L13] =>
                    'city=revenue:0;' \
                    'border=type:province,edge:0;',
            %w[L15] =>
                    'upgrade=cost:20,terrain:river;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;',
            %w[L17] =>
                    'town=revenue:0;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;',
            %w[M8] =>
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[M10] =>
                    'town=revenue:0;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:5;',
            %w[M12] =>
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;',
            %w[M14] =>
                    'town=revenue:0;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;',
            %w[M16] =>
                    'upgrade=cost:40,terrain:river;' \
                    'border=type:province,edge:3;',
            %w[N7] =>
                    'border=type:province,edge:4;' \
                    'border=type:impassible,edge:5;',
            %w[N9] =>
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;',
            %w[N11] =>
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;',
            %w[N13] =>
                    'upgrade=cost:20,terrain:river;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:3;',
            %w[O8] =>
                    'town=revenue:0;' \
                    'border=type:impassible,edge:2;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;',
            %w[O10] =>
                    'city=revenue:0;' \
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:1;' \
                    'border=type:province,edge:5;',
            %w[O12] =>
                    'city=revenue:0;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[O14] =>
                    'city=revenue:0;' \
                    'label=Y;' \
                    'border=type:province,edge:1;',
            %w[P9] =>
                    'border=type:province,edge:3;',
            %w[P11] =>
                    'town=revenue:0;' \
                    'upgrade=cost:40,terrain:mountain;' \
                    'border=type:province,edge:2;' \
                    'border=type:province,edge:3;',
            %w[P13] =>
                    'city=revenue:0;' \
                    'border=type:province,edge:2;',
            %w[Q10 Q12 R11] =>
                    'town=revenue:0;',
          },

          yellow: {
            %w[E12] =>
                    'city=revenue:30,groups:Delhi;' \
                    'city=revenue:30,groups:Delhi;' \
                    'city=revenue:30,groups:Delhi;' \
                    'path=a:0,b:_0;' \
                    'path=a:2,b:_1;' \
                    'path=a:4,b:_2;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;' \
                    'border=type:province,edge:5;',
            %w[I22] =>
                    'city=revenue:30,groups:Calcutta;' \
                    'city=revenue:30,groups:Calcutta;' \
                    'city=revenue:30,groups:Calcutta;' \
                    'path=a:0,b:_0;' \
                    'path=a:2,b:_1;' \
                    'path=a:4,b:_2;' \
                    'border=type:province,edge:3;' \
                    'border=type:province,edge:4;',
          },

          red: {
            %w[A4] =>
                    'offboard=revenue:yellow_20|green_30|brown_40|gray_40;' \
                    'path=track:dual,a:4,b:_0;',
            %w[E20] =>
                    'offboard=revenue:yellow_20|green_30|brown_40|gray_40;' \
                    'path=track:dual,a:0,b:_0;' \
                    'border=type:province,edge:0;' \
                    'border=type:province,edge:5;',
            %w[E24] =>
                    'offboard=revenue:yellow_20|green_30|brown_40|gray_40;' \
                    'path=track:dual,a:0,b:_0;',
          },

          gray: {
            %w[I26] =>
                    'town=revenue:20;' \
                    'path=a:2,b:_0;',
          },

          blue: {
            %w[H1 I2 J3 J25 K22 L5 L19 L21 M6 M18 N5 N17 O6 O16 P7 Q8 Q14 R9 R13 S10 S12] => '',
            %w[J5] =>
                    'path=a:2,b:3;' \
                    'path=a:5,b:5,terminal:1,ignore:1;',
            %w[J23] =>
                    'path=a:2,b:2,terminal:1,ignore:1;',
            %w[K4] =>
                    'path=a:4,b:4,terminal:1,ignore:1;',
            %w[N15] =>
                    'path=a:0,b:0,terminal:1,ignore:1;',
            %w[P15] =>
                    'path=a:2,b:2,terminal:1,ignore:1;',
          },
        }.freeze

        # These are the number of provincial borders crossed when travelling between cities.
        # This is done as a 2D hash of city coordinates. The rows and columns are ordered
        # by province:
        #   1. Northwest Frontier (Peshawar).
        #   2. Punjab (Rawalapindi, Lahore, Multan and Delhi).
        #   3. Sind (Karachi).
        #   4. Rajputana (Jaipur).
        #   5. United Provinces (Cawnpore, Lucknow, Allahabad).
        #   6. Bengal (Patna, Calcutta).
        #   7. Assam (Dacca).
        #   8. Central Provinces (Nagpur).
        #   9. Gujurat (Ahmadabad).
        #  10. Bombay (Bombay).
        #  11. Hyderabad (Hyderabad).
        #  12. Madras (Madras, Trichinopoly).
        #  13. Mysore (Mysore, Bangalore).
        # Kashmir, Baluchistan, Central India and Nepal do not have any large cities.
        # rubocop: disable Layout/HashAlignment, Layout/MultilineHashKeyLineBreaks
        TOKEN_DISTANCES = {
          'A6' => {
            'A6'  => 0, 'B7'  => 1, 'C8'  => 1, 'D5'  => 1, 'E12' => 1, 'G2'  => 2, 'G8'  => 2,
            'F13' => 2, 'F15' => 2, 'G16' => 2, 'G20' => 3, 'I22' => 3, 'H25' => 4, 'J13' => 3,
            'H7'  => 2, 'K6'  => 3, 'L13' => 4, 'O14' => 4, 'P13' => 4, 'O10' => 4, 'O12' => 4
          },
          'B7' => {
            'A6'  => 1, 'B7'  => 0, 'C8'  => 0, 'D5'  => 0, 'E12' => 0, 'G2'  => 1, 'G8'  => 1,
            'F13' => 1, 'F15' => 1, 'G16' => 1, 'G20' => 2, 'I22' => 2, 'H25' => 3, 'J13' => 2,
            'H7'  => 2, 'K6'  => 2, 'L13' => 3, 'O14' => 3, 'P13' => 3, 'O10' => 3, 'O12' => 3
          },
          'C8' => {
            'A6'  => 1, 'B7'  => 0, 'C8'  => 0, 'D5'  => 0, 'E12' => 0, 'G2'  => 1, 'G8'  => 1,
            'F13' => 1, 'F15' => 1, 'G16' => 1, 'G20' => 2, 'I22' => 2, 'H25' => 3, 'J13' => 2,
            'H7'  => 2, 'K6'  => 2, 'L13' => 3, 'O14' => 3, 'P13' => 3, 'O10' => 3, 'O12' => 3
          },
          'D5' => {
            'A6'  => 1, 'B7'  => 0, 'C8'  => 0, 'D5'  => 0, 'E12' => 0, 'G2'  => 1, 'G8'  => 1,
            'F13' => 1, 'F15' => 1, 'G16' => 1, 'G20' => 2, 'I22' => 2, 'H25' => 3, 'J13' => 2,
            'H7'  => 2, 'K6'  => 2, 'L13' => 3, 'O14' => 3, 'P13' => 3, 'O10' => 3, 'O12' => 3
          },
          'E12' => {
            'A6'  => 1, 'B7'  => 0, 'C8'  => 0, 'D5'  => 0, 'E12' => 0, 'G2'  => 1, 'G8'  => 1,
            'F13' => 1, 'F15' => 1, 'G16' => 1, 'G20' => 2, 'I22' => 2, 'H25' => 3, 'J13' => 2,
            'H7'  => 2, 'K6'  => 2, 'L13' => 3, 'O14' => 3, 'P13' => 3, 'O10' => 3, 'O12' => 3
          },
          'G2' => {
            'A6'  => 2, 'B7'  => 1, 'C8'  => 1, 'D5'  => 1, 'E12' => 1, 'G2'  => 0, 'G8'  => 1,
            'F13' => 2, 'F15' => 2, 'G16' => 2, 'G20' => 3, 'I22' => 3, 'H25' => 4, 'J13' => 3,
            'H7'  => 1, 'K6'  => 2, 'L13' => 3, 'O14' => 3, 'P13' => 3, 'O10' => 3, 'O12' => 3
          },
          'G8' => {
            'A6'  => 2, 'B7'  => 1, 'C8'  => 1, 'D5'  => 1, 'E12' => 1, 'G2'  => 1, 'G8'  => 0,
            'F13' => 2, 'F15' => 2, 'G16' => 2, 'G20' => 3, 'I22' => 3, 'H25' => 4, 'J13' => 2,
            'H7'  => 1, 'K6'  => 2, 'L13' => 3, 'O14' => 3, 'P13' => 3, 'O10' => 3, 'O12' => 3
          },
          'F13' => {
            'A6'  => 2, 'B7'  => 1, 'C8'  => 1, 'D5'  => 1, 'E12' => 1, 'G2'  => 2, 'G8'  => 2,
            'F13' => 0, 'F15' => 0, 'G16' => 0, 'G20' => 1, 'I22' => 1, 'H25' => 2, 'J13' => 1,
            'H7'  => 2, 'K6'  => 2, 'L13' => 2, 'O14' => 3, 'P13' => 3, 'O10' => 3, 'O12' => 3
          },
          'F15' => {
            'A6'  => 2, 'B7'  => 1, 'C8'  => 1, 'D5'  => 1, 'E12' => 1, 'G2'  => 2, 'G8'  => 2,
            'F13' => 0, 'F15' => 0, 'G16' => 0, 'G20' => 1, 'I22' => 1, 'H25' => 2, 'J13' => 1,
            'H7'  => 2, 'K6'  => 2, 'L13' => 2, 'O14' => 3, 'P13' => 3, 'O10' => 3, 'O12' => 3
          },
          'G16' => {
            'A6'  => 2, 'B7'  => 1, 'C8'  => 1, 'D5'  => 1, 'E12' => 1, 'G2'  => 2, 'G8'  => 2,
            'F13' => 0, 'F15' => 0, 'G16' => 0, 'G20' => 1, 'I22' => 1, 'H25' => 2, 'J13' => 1,
            'H7'  => 2, 'K6'  => 2, 'L13' => 2, 'O14' => 3, 'P13' => 3, 'O10' => 3, 'O12' => 3
          },
          'G20' => {
            'A6'  => 3, 'B7'  => 2, 'C8'  => 2, 'D5'  => 2, 'E12' => 2, 'G2'  => 3, 'G8'  => 3,
            'F13' => 1, 'F15' => 1, 'G16' => 1, 'G20' => 0, 'I22' => 0, 'H25' => 1, 'J13' => 1,
            'H7'  => 3, 'K6'  => 2, 'L13' => 2, 'O14' => 3, 'P13' => 3, 'O10' => 3, 'O12' => 3
          },
          'I22' => {
            'A6'  => 3, 'B7'  => 2, 'C8'  => 2, 'D5'  => 2, 'E12' => 2, 'G2'  => 3, 'G8'  => 3,
            'F13' => 1, 'F15' => 1, 'G16' => 1, 'G20' => 0, 'I22' => 0, 'H25' => 1, 'J13' => 1,
            'H7'  => 3, 'K6'  => 2, 'L13' => 2, 'O14' => 3, 'P13' => 3, 'O10' => 3, 'O12' => 3
          },
          'H25' => {
            'A6'  => 4, 'B7'  => 3, 'C8'  => 3, 'D5'  => 3, 'E12' => 3, 'G2'  => 4, 'G8'  => 4,
            'F13' => 2, 'F15' => 2, 'G16' => 2, 'G20' => 1, 'I22' => 1, 'H25' => 0, 'J13' => 2,
            'H7'  => 4, 'K6'  => 3, 'L13' => 3, 'O14' => 4, 'P13' => 4, 'O10' => 4, 'O12' => 4
          },
          'J13' => {
            'A6'  => 3, 'B7'  => 2, 'C8'  => 2, 'D5'  => 2, 'E12' => 2, 'G2'  => 3, 'G8'  => 2,
            'F13' => 1, 'F15' => 1, 'G16' => 1, 'G20' => 1, 'I22' => 1, 'H25' => 2, 'J13' => 0,
            'H7'  => 2, 'K6'  => 1, 'L13' => 1, 'O14' => 2, 'P13' => 2, 'O10' => 2, 'O12' => 2
          },
          'H7' => {
            'A6'  => 3, 'B7'  => 2, 'C8'  => 2, 'D5'  => 2, 'E12' => 2, 'G2'  => 1, 'G8'  => 1,
            'F13' => 2, 'F15' => 2, 'G16' => 2, 'G20' => 3, 'I22' => 3, 'H25' => 4, 'J13' => 2,
            'H7'  => 0, 'K6'  => 1, 'L13' => 2, 'O14' => 2, 'P13' => 2, 'O10' => 2, 'O12' => 2
          },
          'K6' => {
            'A6'  => 3, 'B7'  => 2, 'C8'  => 2, 'D5'  => 2, 'E12' => 2, 'G2'  => 2, 'G8'  => 2,
            'F13' => 2, 'F15' => 2, 'G16' => 2, 'G20' => 2, 'I22' => 2, 'H25' => 3, 'J13' => 1,
            'H7'  => 1, 'K6'  => 0, 'L13' => 1, 'O14' => 1, 'P13' => 1, 'O10' => 1, 'O12' => 1
          },
          'L13' => {
            'A6'  => 4, 'B7'  => 3, 'C8'  => 3, 'D5'  => 3, 'E12' => 3, 'G2'  => 3, 'G8'  => 3,
            'F13' => 2, 'F15' => 2, 'G16' => 2, 'G20' => 2, 'I22' => 2, 'H25' => 3, 'J13' => 1,
            'H7'  => 2, 'K6'  => 1, 'L13' => 0, 'O14' => 1, 'P13' => 1, 'O10' => 2, 'O12' => 2
          },
          'O14' => {
            'A6'  => 4, 'B7'  => 3, 'C8'  => 3, 'D5'  => 3, 'E12' => 3, 'G2'  => 3, 'G8'  => 3,
            'F13' => 3, 'F15' => 3, 'G16' => 3, 'G20' => 3, 'I22' => 3, 'H25' => 4, 'J13' => 2,
            'H7'  => 2, 'K6'  => 1, 'L13' => 1, 'O14' => 0, 'P13' => 0, 'O10' => 1, 'O12' => 1
          },
          'P13' => {
            'A6'  => 4, 'B7'  => 3, 'C8'  => 3, 'D5'  => 3, 'E12' => 3, 'G2'  => 3, 'G8'  => 3,
            'F13' => 3, 'F15' => 3, 'G16' => 3, 'G20' => 3, 'I22' => 3, 'H25' => 4, 'J13' => 2,
            'H7'  => 2, 'K6'  => 1, 'L13' => 1, 'O14' => 0, 'P13' => 0, 'O10' => 1, 'O12' => 1
          },
          'O10' => {
            'A6'  => 4, 'B7'  => 3, 'C8'  => 3, 'D5'  => 3, 'E12' => 3, 'G2'  => 3, 'G8'  => 3,
            'F13' => 3, 'F15' => 3, 'G16' => 3, 'G20' => 3, 'I22' => 3, 'H25' => 4, 'J13' => 2,
            'H7'  => 2, 'K6'  => 1, 'L13' => 2, 'O14' => 1, 'P13' => 1, 'O10' => 0, 'O12' => 0
          },
          'O12' => {
            'A6'  => 4, 'B7'  => 3, 'C8'  => 3, 'D5'  => 3, 'E12' => 3, 'G2'  => 3, 'G8'  => 3,
            'F13' => 3, 'F15' => 3, 'G16' => 3, 'G20' => 3, 'I22' => 3, 'H25' => 4, 'J13' => 2,
            'H7'  => 2, 'K6'  => 1, 'L13' => 2, 'O14' => 1, 'P13' => 1, 'O10' => 0, 'O12' => 0
          },
        }.freeze
        # rubocop: enable Layout/HashAlignment, Layout/MultilineHashKeyLineBreaks
      end
    end
  end
end
