# frozen_string_literal: true

module Engine
  module Game
    module G18India
      module Map
        TILES = {
          # yellow tiles
          '9' => 41,
          '8' => 41,
          '7' => 6,
          '4' => 16,
          '58' => 16,
          '3' => 8,
          '235' => 2,
          '57' => 3,
          '6' => 3,
          '5' => 3,

          # green tiles
          '80' => 4,
          '81' => 4,
          '82' => 4,
          '83' => 4,
          '141' => 3,
          '142' => 3,
          '143' => 3,
          '144' => 3,
          '619' => 2,
          '14' => 2,
          '15' => 2,
          '59' => 2,
          '205' => 2,
          '206' => 2,
          '12' => 2,
          '13' => 2,

          # brown tiles
          '544' => 2,
          '545' => 2,
          '546' => 2,
          '145' => 2,
          '146' => 2,
          '147' => 2,
          '611' => 6,
          '64' => 1,
          '65' => 1,
          '66' => 1,
          '67' => 1,
          '68' => 1,
          '984' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:50;city=revenue:50;path=a:0,b:_0;path=a:_0,b:1;path=a:2,b:_1;path=a:_1,b:3;label=OO',
          },

          # gray tiles
          '60' => 1,
          '513' => 4,
          'GT6' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'town=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          'IND1' => {
            'count' => 2,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=OO',
          },

          # Ferry yellow / gray tiles
          'IF1' => { 'count' => 1, 'color' => 'yellow', 'code' => 'path=a:2,b:4;label=FERRY' },
          'IF2' => { 'count' => 1, 'color' => 'yellow', 'code' => 'path=a:0,b:2;label=FERRY' },

          # triple town tiles
          'IND2' => {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'town=revenue:20,style:dot;town=revenue:10;town=revenue:10;'\
                      'path=a:1,b:_0;path=a:_0,b:2;path=a:0,b:_1;path=a:_1,b:4;path=a:3,b:_2;path=a:_2,b:5',
          },
          'IND3' => {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'town=revenue:20,style:dot;town=revenue:10;town=revenue:10;'\
                      'path=a:1,b:_0;path=a:4,b:_0;path=a:0,b:_1;path=a:5,b:_1;path=a:2,b:_2;path=a:3,b:_2',
          },
          'IND4' => {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'town=revenue:20,style:dot;town=revenue:10;town=revenue:10;'\
                      'path=a:2,b:_0;path=a:5,b:_0;path=a:1,b:_1;path=a:4,b:_1;path=a:0,b:_2;path=a:3,b:_2',
          },
          'IND5' => {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'town=revenue:20,style:dot;town=revenue:10;town=revenue:10;'\
                      'path=a:2,b:_0;path=a:3,b:_0;path=a:0,b:_1;path=a:1,b:_1;path=a:4,b:_2;path=a:5,b:_2',
          },
          'IND6' => {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'town=revenue:20,style:dot;town=revenue:10;town=revenue:10;'\
                      'path=a:2,b:_0;path=a:5,b:_0;path=a:1,b:_1;path=a:3,b:_1;path=a:0,b:_2;path=a:4,b:_2',
          },
        }.freeze

        LOCATION_NAMES = {
          # Red city names
          'A16' => 'KARACHI',
          'D3' => 'LAHORE',
          'D23' => 'MUMBAI',
          'G36' => 'KOCHI',
          'K30' => 'CHENNAI',
          'K40' => 'COLOMBO',
          'M10' => 'NEPAL',
          'Q10' => 'CHINA',
          'R17' => 'DHAKA',
          # OO cities
          'G8' => 'DELHI',
          'P17' => 'KOLKATA',
          # Commodity names
          'B17' => 'OIL',
          'H15' => 'ORE1',
          'H21' => 'COTTON',
          'I18' => 'SPICES',
          'I28' => 'GOLD',
          'J13' => 'OPIUM',
          'K38' => 'TEA1',
          'L21' => 'ORE2',
          'O12' => 'TEA2',
          'P15' => 'RICE',
          # Commodity Destination Towns
          'P19' => 'HALDIA',
          'M24' => 'VISAKHAPATNAM',
        }.freeze

        HEXES = {
          white: {
            %w[B9 B15 C8 C10 C12 C14 D5 D7 D9 D13 D15 E2 E6 E8 E12 E14 E16 F3 F7 F33 G2 G14 G26 G28 H27 H33 H37
               I6 I22 I32 I34 I36 I38 J9 J35 K10 K18 L17 L19 M16 M18 M20 M22 N11 O10 O18 O20 P11 R11] => '',
            %w[E4 F11 F13 G34 J17 J33 L39 N17] => 'town=revenue:0',
            %w[E10 F9 N19] => 'upgrade=cost:15,terrain:hill',
            %w[F15 N21] => 'upgrade=cost:30,terrain:mountain',
            ['C16'] => 'town=revenue:0;border=edge:5,type:water,cost:30',
            ['D11'] => 'town=revenue:0;upgrade=cost:15,terrain:hill',
            ['D17'] => 'city=revenue:0;border=edge:2,type:water,cost:30',
            %w[D19 F17] => 'town=revenue:0;border=edge:0,type:province;border=edge:5,type:province',
            %w[D25 G12] => 'border=edge:4,type:province',
            ['E18'] => 'upgrade=cost:15,terrain:hill;border=edge:0,type:province;border=edge:5,type:province',
            %w[E20 L15] => 'border=edge:2,type:province;border=edge:3,type:province',
            ['E22'] => 'town=revenue:0;town=revenue:0;town=revenue:0;border=edge:0,type:province;border=edge:5,type:province',
            ['E24'] => 'city=revenue:0;border=edge:0,type:province;border=edge:1,type:province;border=edge:2,type:province;'\
                       'border=edge:3,type:province',
            %w[E26 H13] => 'border=edge:3,type:province;border=edge:4,type:province;border=edge:5,type:province',
            %w[E28 G10] => 'border=edge:4,type:province;border=edge:5,type:province',
            ['E30'] => 'town=revenue:0;border=edge:4,type:province',
            ['F5'] => 'town=revenue:0;town=revenue:0;town=revenue:0',
            ['F19'] => 'upgrade=cost:30,terrain:mountain;border=edge:2,type:province;border=edge:3,type:province',
            %w[F21 G20 H19 H29] => 'border=edge:0,type:province;border=edge:5,type:province',
            ['F23'] => 'town=revenue:0;border=edge:2,type:province;border=edge:3,type:province',
            ['F25'] => 'town=revenue:0;upgrade=cost:30,terrain:mountain;border=edge:1,type:province',
            ['F27'] => 'town=revenue:0;upgrade=cost:30,terrain:mountain;border=edge:1,type:province;'\
                       'border=edge:2,type:province',
            ['F29'] => 'upgrade=cost:30,terrain:mountain;'\
                       'border=edge:0,type:province;border=edge:1,type:province;border=edge:2,type:province',
            %w[F31 J21 J31] => 'border=edge:3,type:province;border=edge:4,type:province',
            ['G4'] => 'border=edge:5,type:province',
            ['G6'] => 'town=revenue:0;upgrade=cost:30,terrain:mountain;'\
                      'border=edge:4,type:province;border=edge:5,type:province,cost:30',
            ['G8'] => 'city=revenue:0;city=revenue:0;label=OO;'\
                      'border=edge:4,type:province,cost:30;border=edge:5,type:province',
            ['G16'] => 'upgrade=cost:30,terrain:mountain;border=edge:0,type:province;border=edge:5,type:province',
            %w[G18 G22 I16] => 'upgrade=cost:15,terrain:hill;border=edge:2,type:province;border=edge:3,type:province',
            ['G24'] => 'border=edge:4,type:water,cost:30',
            ['G30'] => 'upgrade=cost:30,terrain:mountain;'\
                       'border=edge:0,type:province;border=edge:1,type:province;border=edge:5,type:province',
            ['G32'] => 'upgrade=cost:15,terrain:hill;border=edge:3,type:province',
            %w[H3 Q12] => 'border=edge:0,type:province',
            ['H5'] => 'border=edge:1,type:province;border=edge:2,type:province;border=edge:3,type:province',
            ['H7'] => 'border=edge:0,type:water,cost:30;border=edge:1,type:province,cost:30;border=edge:2,type:province,cost:30',
            ['H9'] => 'border=edge:3,type:water,cost:30;border=edge:4,type:water,cost:30;border=edge:5,type:water,cost:30;'\
                      'border=edge:1,type:province;border=edge:2,type:province',
            ['H11'] => 'town=revenue:0;border=edge:4,type:water,cost:30;'\
                       'border=edge:0,type:province;border=edge:1,type:province;border=edge:2,type:province',
            ['H17'] => 'town=revenue:0;upgrade=cost:30,terrain:mountain;border=edge:2,type:province;border=edge:3,type:province',
            %w[H23 Q16] => 'border=edge:0,type:water,cost:30;border=edge:1,type:water,cost:30',
            ['H25'] => 'city=revenue:0;border=edge:3,type:water,cost:30;border=edge:4,type:water,cost:30',
            ['H31'] => 'city=revenue:0;border=edge:2,type:province;border=edge:3,type:province',
            ['H35'] => 'town=revenue:0;town=revenue:0;town=revenue:0;upgrade=cost:15,terrain:hill',
            ['I8'] => 'town=revenue:0;border=edge:1,type:water,cost:30',
            ['I10'] => 'border=edge:0,type:water,cost:30;border=edge:1,type:water,cost:30;border=edge:2,type:water,cost:30',
            ['I12'] => 'border=edge:3,type:water,cost:30;border=edge:4,type:water,cost:30;border=edge:1,type:province',
            ['I14'] => 'upgrade=cost:30,terrain:mountain;border=edge:0,type:province;'\
                       'border=edge:1,type:province;border=edge:2,type:province;border=edge:5,type:province',
            ['I20'] => 'city=revenue:0;border=edge:2,type:province;border=edge:3,type:province;border=edge:4,type:province',
            ['I24'] => 'border=edge:0,type:water,cost:30;border=edge:1,type:water,cost:30;border=edge:5,type:water,cost:30',
            ['I26'] => 'border=edge:3,type:water,cost:30',
            ['I30'] => 'upgrade=cost:15,terrain:hill;'\
                       'border=edge:2,type:province;border=edge:3,type:province;border=edge:4,type:province',
            ['J11'] => 'town=revenue:0;border=edge:0,type:water,cost:30;border=edge:1,type:water,cost:30',
            %w[J15 Q14] => 'border=edge:2,type:province;border=edge:3,type:province;border=edge:4,type:province',
            %w[J19 J29 K20] => 'border=edge:0,type:province;border=edge:1,type:province',
            ['J23'] => 'upgrade=cost:30,terrain:mountain;border=edge:0,type:water,cost:30;'\
                       'border=edge:5,type:province,cost:30',
            ['J25'] => 'upgrade=cost:30,terrain:mountain;border=edge:2,type:water,cost:30;border=edge:3,type:water,cost:30;'\
                       'border=edge:4,type:province;border=edge:5,type:province',
            ['J27'] => 'town=revenue:0;upgrade=cost:30,terrain:mountain;border=edge:4,type:province',
            ['J37'] => 'upgrade=cost:60,terrain:water;label=FERRY',
            ['K12'] => 'town=revenue:0;town=revenue:0;town=revenue:0;border=edge:0,type:water,cost:30;'\
                       'border=edge:1,type:water,cost:30;border=edge:5,type:water,cost:30',
            ['K14'] => 'city=revenue:0;border=edge:3,type:water,cost:30;border=edge:0,type:province;'\
                       'border=edge:1,type:province;border=edge:5,type:province',
            %w[K16 K28 R15] => 'border=edge:3,type:province',
            ['K22'] => 'upgrade=cost:30,terrain:mountain;border=edge:0,type:province,cost:30;'\
                       'border=edge:3,type:province;border=edge:4,type:province;border=edge:5,type:province',
            ['K24'] => 'border=edge:4,type:water,cost:30;'\
                       'border=edge:1,type:province;border=edge:2,type:province,cost:30;border=edge:3,type:province,cost:30',
            ['K26'] => 'border=edge:0,type:province;border=edge:1,type:province;border=edge:2,type:province',
            ['L11'] => 'border=edge:0,type:water,cost:30',
            ['L13'] => 'town=revenue:0;border=edge:2,type:water,cost:30;border=edge:3,type:water,cost:30;'\
                       'border=edge:4,type:water,cost:30;border=edge:0,type:province;border=edge:5,type:province',
            ['L23'] => 'town=revenue:0;border=edge:0,type:water,cost:30;border=edge:1,type:water,cost:30;'\
                       'border=edge:2,type:province',
            %w[L25 Q18] => 'border=edge:3,type:water,cost:30;border=edge:4,type:water,cost:30',
            ['M12'] => 'border=edge:1,type:water,cost:30;border=edge:0,type:province,cost:30',
            ['M14'] => 'border=edge:2,type:province;border=edge:3,type:province,cost:30;border=edge:4,type:province,cost:30',
            ['N13'] => 'town=revenue:0;'\
                       'border=edge:0,type:province,cost:30;border=edge:1,type:province,cost:30;border=edge:5,type:province',
            ['N15'] => 'border=edge:4,type:water,cost:30;border=edge:3,type:province,cost:30',
            ['O14'] => 'border=edge:0,type:water,cost:30;border=edge:1,type:water,cost:30;'\
                       'border=edge:2,type:province;border=edge:3,type:province;border=edge:4,type:province',
            ['O16'] => 'town=revenue:0;border=edge:3,type:water,cost:30;border=edge:4,type:water,cost:30',
            ['P13'] => 'border=edge:0,type:province;border=edge:1,type:province;border=edge:5,type:province',
            ['P17'] => 'city=revenue:0;city=revenue:0;label=OO;'\
                       'border=edge:3,type:water,cost:30;border=edge:4,type:water,cost:30',
            ['R13'] => 'town=revenue:0;border=edge:0,type:province;border=edge:1,type:province',

            # Commodity Locations
            ['B17'] => 'icon=image:18_india/oil,sticky:true,large:true', # OIL
            ['H15'] => 'upgrade=cost:30,terrain:mountain;border=edge:0,type:province;border=edge:4,type:province;'\
                       'border=edge:5,type:province;icon=image:18_india/ore,sticky:true,large:true', # ORE1
            ['H21'] => 'border=edge:2,type:province;border=edge:3,type:province;'\
                       'icon=image:18_india/cotton,sticky:true,large:true', # COTTON
            ['I18'] => 'border=edge:0,type:province;icon=image:18_india/spices,sticky:true,large:true', # SPICES
            ['I28'] => 'upgrade=cost:30,terrain:mountain;border=edge:0,type:province;'\
                       'icon=image:18_india/gold,sticky:true,large:true', # GOLD
            ['J13'] => 'border=edge:3,type:water,cost:30;border=edge:4,type:water,cost:30;border=edge:0,type:province;'\
                       'icon=image:18_india/opium,sticky:true,large:true', # OPIUM
            ['K38'] => 'town=revenue:0;icon=image:18_india/tea,sticky:true,large:true', # TEA1
            ['L21'] => 'upgrade=cost:30,terrain:mountain;border=edge:1,type:province;'\
                       'icon=image:18_india/ore,sticky:true,large:true', # ORE2
            ['O12'] => 'border=edge:0,type:province;icon=image:18_india/tea,sticky:true,large:true', # TEA2
            ['P15'] => 'border=edge:0,type:water,cost:30;border=edge:1,type:water,cost:30;border=edge:3,type:province;'\
                       'icon=image:18_india/rice,sticky:true,large:true', # RICE
          },

          # Red hexes are variable revenue cities
          red: {
            ['A16'] => 'city=revenue:40;path=a:4,b:_0;path=a:5,b:_0;label=+?',
            ['D3'] => 'city=revenue:50;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=+?;',
            ['D23'] => 'city=revenue:60,slots:2;city=revenue:60;path=a:0,b:_0;path=a:3,b:_0;'\
                       'path=a:4,b:_1;path=a:5,b:_1;border=edge:5,type:province;label=+?',
            ['G36'] => 'city=revenue:40,slots:2;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=+?',
            ['K30'] => 'city=revenue:50,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;border=edge:1,type:province;label=+?',
            ['K40'] => 'city=revenue:40;path=a:4,b:_0;label=+?',
            ['M10'] => 'city=revenue:30;path=a:0,b:_0;path=a:2,b:_0;city=revenue:30;path=a:1,b:_1;path=a:5,b:_1;label=+?',
            ['Q10'] => 'city=revenue:40;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=+?',
            ['R17'] => 'city=revenue:30;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;border=edge:1,type:water,cost:30;label=+?',
          },
          gray: {
            %w[B11 B13] => 'path=a:0,b:3',
            ['C6'] => 'town=revenue:10;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['D21'] => 'town=revenue:10;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;border=edge:3,type:province',
            ['F1'] => 'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0',
            ['H39'] => 'town=revenue:10;path=a:3,b:_0;path=a:4,b:_0',
            ['L9'] => 'path=a:1,b:5',
            ['M24'] => 'town=revenue:10;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;border=edge:1,type:water,cost:30',
            ['P19'] => 'town=revenue:10;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          blue: {
            ['C18'] => 'junction;path=a:4,b:_0,terminal:1',
          },
        }.freeze

        LAYOUT = :flat
        AXES = { x: :letter, y: :number }.freeze
      end
    end
  end
end
