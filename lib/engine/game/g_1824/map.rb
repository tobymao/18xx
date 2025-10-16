# frozen_string_literal: true

module Engine
  module Game
    module G1824
      module Map
        LAYOUT = :pointy

        AXES = { x: :number, y: :letter }.freeze

        # Standard game has 4 mine hexes
        MINE_HEXES = %w[C6 A12 A22 H25].freeze

        # Used by 1837, not used in 1824
        ITALY_HEXES = [].freeze

        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 4,
          '4' => 6,
          '5' => 5,
          '6' => 5,
          '7' => 5,
          '8' => 10,
          '9' => 10,
          '14' => 4,
          '15' => 8,
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
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 1,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '55' => 1,
          '56' => 1,
          '57' => 5,
          '58' => 8,
          '69' => 1,
          '70' => 1,
          '87' => 3,
          '88' => 3,
          '126' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
            'path=a:5,b:_0;label=Bu',
          },
          '401' =>
          {
            'count' => 3,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:0,b:_0;path=a:1,b:_0;label=T',
          },
          '405' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' =>
            'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;label=T',
          },
          '447' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:0,b:_0;path=a:4,b:_0;label=T',
          },
          '490' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Bu',
          },
          '491' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:50;city=revenue:50;city=revenue:50;path=a:0,b:_0;path=a:5,b:_0;path=a:1,b:_1;'\
            'path=a:2,b:_2;path=a:3,b:_2;path=a:4,b:_1;label=W',
          },
          '493' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:70;city=revenue:70,slots:3;path=a:0,b:_0;path=a:5,b:_0;path=a:2,b:_1;path=a:3,b:_1;'\
            'path=a:4,b:_1;path=a:1,b:_1;label=W',
          },
          '494' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;label=T',
          },
          '495' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
            'path=a:5,b:_0;label=Bu',
          },
          '496' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
            'path=a:5,b:_0;label=W',
          },
          '497' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' =>
            'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;label=T',
          },
          '498' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' =>
            'city=revenue:30;city=revenue:30;path=a:2,b:_1;path=a:3,b:_1;path=a:0,b:_0;path=a:5,b:_0;label=Bu',
          },
          '499' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' =>
            'city=revenue:40;city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;'\
            'path=a:4,b:_1;label=W',
          },
          '611' => 6,
          '619' => 4,
          '630' => 1,
          '631' => 1,
        }.freeze

        LOCATION_NAMES = {
          'A4' => 'Dresden',
          'A18' => 'Krakau',
          'A24' => 'Kiew',
          'B5' => 'Pilsen',
          'B9' => 'Prag',
          'B15' => 'Mährisch-Ostrau',
          'B23' => 'Lemberg',
          'C12' => 'Brünn',
          'C26' => 'Tarnopol',
          'D19' => 'Kaschau',
          'E8' => 'Linz',
          'E12' => 'Wien',
          'E14' => 'Preßburg',
          'E26' => 'Czernowitz',
          'F7' => 'Salzbug',
          'F17' => 'Buda Pest',
          'F23' => 'Klausenburg',
          'G4' => 'Innsbruck',
          'G10' => 'Graz',
          'G18' => 'Szegedin',
          'G26' => 'Kronstadt',
          'G28' => 'Bukarest',
          'H1' => 'Mailand',
          'H3' => 'Bozen',
          'H15' => 'Fünfkirchen',
          'H23' => 'Hermannstadt',
          'I8' => 'Triest',
          'J11' => 'Sarajevo',
        }.freeze

        DRESDEN_1 = 'offboard=revenue:yellow_10|green_20|brown_30|gray_40,hide:1,groups:Dresden;'\
                    'path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1;border=edge:0'
        DRESDEN_2 = 'offboard=revenue:yellow_10|green_20|brown_30|gray_40,groups:Dresden;'\
                    'path=a:4,b:_0,terminal:1;border=edge:3'
        KIEW_1 = 'offboard=revenue:yellow_10|green_30|brown_40|gray_50,hide:1,groups:Kiew;'\
                 'path=a:0,b:_0,terminal:1;path=a:5,b:_0,terminal:1;border=edge:4'
        KIEW_2 = 'offboard=revenue:yellow_10|green_30|brown_40|gray_50,groups:Kiew;'\
                 'path=a:0,b:_0,terminal:1;border=edge:1'
        MAINLAND_1 = 'offboard=revenue:yellow_10|green_30|brown_50|gray_70,hide:1,groups:Mainland;'\
                     'path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1;border=edge:5'
        MAINLAND_2 = 'offboard=revenue:yellow_10|green_30|brown_50|gray_70,groups:Mainland;'\
                     'path=a:3,b:_0,terminal:1;border=edge:2'
        BUKAREST_1 = 'offboard=revenue:yellow_10|green_30|brown_40|gray_50,hide:1,groups:Bukarest;'\
                     'path=a:1,b:_0,terminal:1;border=edge:0'
        BUKAREST_2 = 'offboard=revenue:yellow_10|green_30|brown_40|gray_50,groups:Bukarest;path=a:2,b:_0,terminal:1;'\
                     'border=edge:3'
        SARAJEVO = 'city=revenue:yellow_10|green_10|brown_50|gray_50;'\
                   'path=a:1,b:_0,lanes:2,terminal:1;path=a:2,b:_0,terminal:1;border=edge:1;'\
                   'path=a:3,b:_0,terminal:1;path=a:4,b:_0,lanes:2,terminal:1;border=edge:4'
        SARAJEVO_W = 'path=a:2,b:4,b_lane:2.0;path=a:3,b:4,b_lane:2.1;border=edge:4;border=edge:5'
        SARAJEVO_E = 'path=a:2,b:1,b_lane:2.0;path=a:3,b:1,b_lane:2.1;border=edge:0;border=edge:1'
        WIEN = 'city=revenue:30;path=a:0,b:_0;city=revenue:30;'\
               'path=a:1,b:_1;city=revenue:30;path=a:2,b:_2;upgrade=cost:20,terrain:water;label=W'

        MINE_1 = 'city=revenue:yellow_10|green_10|brown_40|gray_40;path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1'
        MINE_2 = 'city=revenue:yellow_10|green_10|brown_40|gray_40;path=a:1,b:_0,terminal:1;path=a:5,b:_0,terminal:1'
        MINE_3 = 'city=revenue:yellow_20|green_20|brown_60|gray_60;path=a:1,b:_0,terminal:1;path=a:5,b:_0,terminal:1'
        MINE_4 = 'city=revenue:yellow_20|green_20|brown_60|gray_60;path=a:1,b:_0,terminal:1;path=a:3,b:_0,terminal:1'

        TOWN = 'town=revenue:0'
        TOWN_WITH_WATER = 'town=revenue:0;upgrade=cost:20,terrain:water'
        TOWN_WITH_MOUNTAIN = 'town=revenue:0;upgrade=cost:40,terrain:mountain'
        DOUBLE_TOWN = 'town=revenue:0;town=revenue:0'
        DOUBLE_TOWN_WITH_WATER = 'town=revenue:0;town=revenue:0;upgrade=cost:20,terrain:water'
        CITY = 'city=revenue:0'
        CITY_WITH_WATER = 'city=revenue:0;upgrade=cost:20,terrain:water'
        CITY_WITH_MOUNTAIN = 'city=revenue:0;upgrade=cost:40,terrain:mountain'
        CITY_LABEL_T = 'city=revenue:0;label=T'
        PLAIN = ''
        PLAIN_WITH_MOUNTAIN = 'upgrade=cost:40,terrain:mountain'
        PLAIN_WITH_WATER = 'upgrade=cost:20,terrain:water'

        def map_optional_hexes
          plain_hexes = %w[B7 B11 B17 B19 B21 C8 C14 C20 C22 C24 D9 D11 D13 D15 D17 E6 E18 E22
                           F9 F13 F15 F21 F25 G6 G12 G14 G22 G24 H9 H13 H19 H21 I10 I12 I14]
          one_town = %w[A8 A20 C10 C16 D25 E20 F19 G2 G20 H11 I20 I22]
          two_towns = %w[B13 B25 F11 I16]
          if option_goods_time
            # Variant Goods Time transform some plain hexes to town(s) hexes
            added_one_town = %w[B7 C8 C20 C22 H21]
            added_two_towns = %w[F25 G24]
            plain_hexes -= added_one_town
            one_town += added_one_town
            plain_hexes -= added_two_towns
            two_towns += added_two_towns
          end
          {
            red: {
              ['A4'] => DRESDEN_1,
              ['A24'] => KIEW_1,
              ['A26'] => KIEW_2,
              ['B3'] => DRESDEN_2,
              ['G28'] => BUKAREST_1,
              ['H27'] => BUKAREST_2,
              ['H1'] => MAINLAND_1,
              ['I2'] => MAINLAND_2,
              ['J13'] => SARAJEVO,
              ['J11'] => SARAJEVO_W,
              ['J15'] => SARAJEVO_E,
            },
            gray: {
              ['A12'] => MINE_2,
              ['A22'] => MINE_3,
              ['C6'] => MINE_1,
              ['H25'] => MINE_4,
            },
            white: {
              one_town => TOWN,
              %w[A6 A10 E24] => TOWN_WITH_MOUNTAIN,
              two_towns => DOUBLE_TOWN,
              %w[D19 H3] => CITY_WITH_MOUNTAIN,
              %w[A18 C26 E26 I8] => CITY_LABEL_T,
              %w[B5 B9 B15 B23 C12 E8 F7 F23 G4 G10 G26 H15 H23] => CITY,
              plain_hexes => PLAIN,
              %w[C18 D21 D23 G8 H5 H7] => PLAIN_WITH_MOUNTAIN,
              %w[E10 G16] => PLAIN_WITH_WATER,
              ['E12'] => WIEN,
              ['F17'] => 'city=revenue:20;path=a:0,b:_0;city=revenue:20;path=a:3,b:_1;upgrade=cost:20,terrain:water;'\
                         'label=Bu',
              %w[E14 G18] => CITY_WITH_WATER,
              %w[H17 I18] => TOWN_WITH_WATER,
              ['E16'] => DOUBLE_TOWN_WITH_WATER,
            },
          }
        end
      end
    end
  end
end
