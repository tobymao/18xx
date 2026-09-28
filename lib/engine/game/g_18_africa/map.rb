# frozen_string_literal: true

module Engine
  module Game
    module G18Africa
      module Map
        # Counts taken from the 18Africa tile sheet (8 pages).
        TILES = {
          # yellow
          '1' => 2,
          '2' => 2,
          '3' => 5,
          '4' => 8,
          '6' => 3,
          '7' => 4,
          '8' => 25,
          '9' => 30,
          '55' => 2,
          '56' => 2,
          '58' => 10,
          '69' => 1,
          '115' => 3,
          '632' => 1,

          # green
          '10' => 2,
          '12' => 3,
          '13' => 3,
          '14' => 2,
          '15' => 2,
          '16' => 1,
          '17' => 1,
          '18' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 3,
          '24' => 3,
          '25' => 2,
          '26' => 2,
          '27' => 2,
          '28' => 1,
          '29' => 1,
          '30' => 1,
          '31' => 1,
          '87' => 2,
          '88' => 2,

          # brown
          '35' => 2,
          '36' => 2,
          '37' => 2,
          '38' => 4,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '933' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'town=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0',
          },

          # gray
          '51' => 5,
          # 18Africa's #169 is a plain four-way junction, unlike the engine's standard #169
          'AF169' => {
            'count' => 2,
            'color' => 'gray',
            'code' => 'junction;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          'A20' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:50;city=revenue:50;path=a:2,b:_0;path=a:3,b:_0;path=a:0,b:_0;'\
                      'path=a:1,b:_1;path=a:5,b:_1',
          },
          'A21' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:50;city=revenue:50;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                      'path=a:4,b:_1;path=a:0,b:_1',
          },
          # through track N-S; from N branch into the western city, from S into the eastern city
          'A22' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:50;city=revenue:50;path=a:0,b:3;path=a:3,b:_0;path=a:0,b:_1;path=a:4,b:_1',
          },
        }.freeze

        LOCATION_NAMES = {
          'B11' => 'Dakar',
          'B13' => 'Bissau',
          'C6' => 'Agadir',
          'C14' => 'Labé & Freetown',
          'D3' => 'Casablanca',
          'D5' => 'Marrakech',
          'E2' => 'Tangier',
          'E4' => 'Meknès & Fez',
          'E16' => 'Abidjan',
          'F3' => 'Oran',
          'F11' => 'Timbuktu',
          'F15' => 'Accra',
          'G2' => 'Algiers',
          'G8' => 'Western Ahaggar',
          'G16' => 'Lagos',
          'H13' => 'Kano',
          'H19' => 'Libreville',
          'I2' => 'Tunis',
          'I4' => 'Tripoli',
          'I18' => 'Yaoundé',
          'I22' => 'Luanda',
          'I24' => 'Lobito',
          'I26' => 'Benguela',
          'J21' => 'Brazzaville & Kinshasa',
          'J29' => 'Walvis Bay',
          'J31' => 'Lüderitz',
          'K14' => "N'Djamena",
          'K16' => 'Bangui',
          'K36' => 'Cape Town',
          'L5' => 'Benghazi',
          'L9' => 'Kufra',
          'L31' => 'Mafeking',
          'M18' => 'Wau & Juba',
          'M24' => 'Zambesi Head',
          'M26' => 'Lusaka',
          'M28' => 'Bulawayo',
          'M32' => 'Pretoria & Johannesburg',
          'M34' => 'Port Elizabeth',
          'N5' => 'Alexandria',
          'N7' => 'Cairo',
          'N27' => 'Salisbury',
          'N31' => 'Lourenço Marques',
          'N33' => 'Durban',
          'O12' => 'Khartoum',
          'O20' => 'Nairobi',
          'O28' => 'Beira',
          'P11' => 'Port Sudan',
          'P13' => 'Asmara',
          'P15' => 'Addis Ababa',
          'P21' => 'Mombasa',
          'P23' => 'Dar es Salaam',
          'Q14' => 'Djibouti',
          'R15' => 'Berbera',
          'R19' => 'Mogadishu',
        }.freeze

        HEXES = {
          white: {
            %w[B9 C8 C10 C12 D7 D9 D11 D13 D15 E6 E8 E10 E14 F5 F7 F9 F13 G4 G6 G10 H3 H5 H11
               I6 I8 I10 I12 I14 I16 I20 J5 J7 J11 J15 J17 J23 J25 J27 K6 K8 K12 K20 K22 K24 K26 K28 K30 K34
               L7 L11 L13 L15 L17 L21 L23 L29 L35 M6 M8 M10 M12 M14 M16 M24 M30 N13 N25 N29
               O10 O18 O22 O26 P19 P25 P27 Q18 R17] => '',

            # towns
            %w[B11 C6 E16 F3 F15 H13 I4 I18 I24 I26 J29 J31 K14 K16 L5 L9 L31 M28 N31 N33 Q14 R15] =>
              'town=revenue:0',
            %w[C14 M18] => 'town=revenue:0;town=revenue:0',
            ['E4'] => 'town=revenue:0;town=revenue:0;upgrade=cost:40,terrain:mountain',
            ['I22'] => 'town=revenue:0;upgrade=cost:80,terrain:water',
            %w[M26 N27] => 'town=revenue:0;upgrade=cost:30,terrain:water',
            ['O28'] => 'town=revenue:0;upgrade=cost:50,terrain:water',
            %w[M34 P13 P15] => 'town=revenue:0;upgrade=cost:30,terrain:mountain',

            # company home cities
            %w[D5 O20 P21] => 'city=revenue:0',
            %w[F11 O12] => 'city=revenue:0;upgrade=cost:30,terrain:water',
            ['N7'] => 'city=revenue:0;upgrade=cost:50,terrain:water',

            # terrain
            %w[E12 M20 N17 O8] => 'upgrade=cost:20,terrain:mountain',
            %w[G8 H7 H9 J9 K10 O16 P17 Q16] => 'upgrade=cost:30,terrain:mountain',
            %w[L25] => 'upgrade=cost:20,terrain:water',
            %w[G12 G14 H15 J19 K18 K32 L19 L27 L33 N9 N11 N15 O14] => 'upgrade=cost:30,terrain:water',
          },

          # Pre-printed yellow double cities; only upgradeable to #10 [3.2.3]
          yellow: {
            ['J21'] => 'city=revenue:20;city=revenue:20;upgrade=cost:60,terrain:water',
            ['M32'] => 'city=revenue:20;city=revenue:20',
          },

          gray: {
            # blocked (lakes / Tibesti)
            %w[J13 M22 N19 O24] => '',

            # plain track
            ['H1'] => 'path=a:1,b:5',
            ['H17'] => 'path=a:2,b:4',
            ['J35'] => 'path=a:4,b:5',
            ['N21'] => 'path=a:2,b:4',
            ['N23'] => 'path=a:0,b:4',
            ['Q20'] => 'path=a:1,b:3',

            # towns
            ['B13'] => 'town=revenue:10;path=a:3,b:_0;path=a:5,b:_0',
            ['H19'] => 'town=revenue:10;path=a:4,b:_0;path=a:5,b:_0',
            ['I2'] => 'town=revenue:10;path=a:1,b:_0;path=a:2,b:_0',
            ['P11'] => 'town=revenue:10;path=a:0,b:_0;path=a:2,b:_0',
            ['R19'] => 'town=revenue:10;path=a:2,b:_0;path=a:3,b:_0',

            # Variable Cities [3.4.4]; the value depends on the route, so only the label is shown,
            # see VARIABLE_CITY_MODIFIERS
            ['D3'] => 'city=revenue:20,hide:1;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=?+20',
            ['E2'] => 'city=revenue:20,hide:1;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=?+0',
            ['G2'] => 'city=revenue:20,hide:1;path=a:1,b:_0;path=a:4,b:_0;label=?+20',
            ['G16'] => 'city=revenue:20,hide:1;path=a:2,b:_0;path=a:5,b:_0;label=?+20',
            ['K36'] => 'city=revenue:20,hide:1;path=a:2,b:_0;path=a:4,b:_0;label=?+40',
            ['N5'] => 'city=revenue:20,hide:1;path=a:0,b:_0;path=a:1,b:_0;label=?+30',
            ['P23'] => 'city=revenue:20,hide:1;path=a:0,b:_0;path=a:3,b:_0;label=?+10',
          },
        }.freeze

        LAYOUT = :flat
        AXES = { x: :letter, y: :number }.freeze

        # Value of a Variable City = highest Non-Variable City on the route + modifier [3.4.4]
        VARIABLE_CITY_MODIFIERS = {
          'D3' => 20, # Casablanca
          'E2' => 0, # Tangier
          'G2' => 20, # Algiers
          'G16' => 20, # Lagos
          'K36' => 40, # Cape Town
          'N5' => 30, # Alexandria
          'P23' => 10, # Dar es Salaam
        }.freeze

        # Concessions [3.4.5]: commodity hex + port hex(es) => bonus.
        CONCESSIONS = {
          'MINERALS' => { commodity: 'G8', ports: %w[D3], bonus: 40 },
          'DATES' => { commodity: 'E4', ports: %w[I2], bonus: 30 },
          'GAS' => { commodity: 'L9', ports: %w[I4], bonus: 50 },
          'OIL' => { commodity: 'E16', ports: %w[G16], bonus: 30 },
          'COPPER' => { commodity: 'M24', ports: %w[I22 P23], bonus: 70 },
          'COTTON' => { commodity: 'P15', ports: %w[Q14], bonus: 100 },
          'GOLD' => { commodity: 'M32', ports: %w[K36], bonus: 30 },
        }.freeze

        # Transcontinental Routes [3.4.6]
        TRANSCONTINENTAL_BONUSES = [
          { hexes: %w[N7 K36], bonus: 80 }, # Cairo - Cape Town
          { hexes: %w[B11 P23], bonus: 100 }, # Dakar - Dar es Salaam
        ].freeze
      end
    end
  end
end
