# frozen_string_literal: true

module Engine
  module Game
    module G18Rhl
      module Map
        LAYOUT = :pointy

        AXES = { x: :number, y: :letter }.freeze

        TILES = {
          '1' => 2,
          '2' => 1,
          '3' => 2,
          '4' => 3,
          '5' => 1,
          '6' => 1,
          '7' => 2,
          '8' => 9,
          '9' => 9,
          '15' => 3,
          '16' => 1,
          '18' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 2,
          '24' => 2,
          '25' => 2,
          '26' => 1,
          '27' => 1,
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
          '55' => 2,
          '56' => 2,
          '57' => 1,
          '58' => 3,
          '69' => 2,
          '70' => 1,
          '87' => 2,
          '88' => 1,
          '141' => 2,
          '142' => 2,
          '143' => 1,
          '144' => 1,
          '201' => 1,
          '202' => 1,
          '204' => 1,
          '216' => 3,
          '916' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_1;path=a:1,b:_0;path=a:3,b:_1;path=a:4,b:_0;'\
                      'label=OO',
          },
          '917' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_1;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_1;'\
                      'label=OO',
          },
          '918' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_1;path=a:4,b:_1;'\
                      'label=OO',
          },
          '919' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_1;path=a:5,b:_1;'\
                      'label=OO',
          },
          '920' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_1;path=a:1,b:_0;path=a:3,b:_1;path=a:5,b:_0;'\
                      'label=OO',
          },
          '921' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:3;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=D;'\
                      'upgrade=cost:50,terrain:river;icon=image:18_rhl/trajekt,sticky:0',
          },
          '922' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:3;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=D;'\
                      'upgrade=cost:50,terrain:river;icon=image:18_rhl/trajekt,sticky:0',
          },
          '923' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=K;'\
                      'upgrade=cost:50,terrain:river;icon=image:18_rhl/trajekt,sticky:0',
          },
          '924' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:3;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=K;'\
                      'upgrade=cost:50,terrain:river;icon=image:18_rhl/trajekt,sticky:0',
          },
          '925' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:3;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=DU;'\
                      'upgrade=cost:50,terrain:river;icon=image:18_rhl/trajekt,sticky:0',
          },
          '926' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=DU;'\
                      'upgrade=cost:50,terrain:river;icon=image:18_rhl/trajekt,sticky:0',
          },
          '927' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0;label=D;upgrade=cost:50,terrain:river',
          },
          '928' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                      'path=a:3,b:_0;path=a:4,b:_0;label=K;upgrade=cost:50,terrain:river',
          },
          '929' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0;label=DU;upgrade=cost:50,terrain:river',
          },
          '930' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                      'path=a:4,b:_0;upgrade=cost:30,terrain:mountain;label=AC',
          },
          '931' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:3;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                      'path=a:4,b:_0;label=AC',
          },
          '932' =>
          {
            'count' => 2,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0;label=D/DU/K',
          },
          '932V' =>
          {
            'count' => 2,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0;label=D/K',
          },
          '933' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'town=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;',
          },
          '934' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                      'path=a:4,b:_0;label=Y',
          },
          '935' =>
          {
            'count' => 1,
            'color' => 'orange',
            'code' => 'city=revenue:20,loc:center;town=revenue:10,loc:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_1;'\
                      'path=a:_1,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Osterath',
          },
          '937' =>
          {
            'count' => 3,
            'color' => 'yellow',
            'code' => 'city=revenue:20;city=revenue:20;path=a:0,b:_0;path=a:4,b:_1;label=OO',
          },
          '938' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_1;label=OO',
          },
          '941' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:2,b:_1;path=a:5,b:_1;label=OO',
          },
          '942' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:3,b:_0;path=a:5,b:_1;label=OO',
          },
          '947' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:30,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=Moers',
          },
          '948' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
                      'label=OO',
          },
          '949' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:3,loc:center;town=revenue:20,loc:4;path=a:0,b:_0;path=a:1,b:_0;'\
                      'path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=DU',
          },
          '950' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:30,slots:2,loc:center;town=revenue:10,loc:4;path=a:0,b:_0;path=a:2,b:_0;'\
                      'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Moers',
          },
          '1910' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:10,loc:4;path=a:0,b:2;path=a:0,b:_0;path=a:2,b:_0;label=Ratingen',
          },
          '1911' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:20,loc:4;path=a:0,b:2;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=Ratingen',
          },
          'Essen' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:3,loc:center;town=revenue:20,loc:4;path=a:0,b:_0;path=a:1,b:_0;'\
                      'path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Essen',
          },
        }.freeze

        LOCATION_NAMES = {
          'A4' => 'Nimwegen',
          'A6' => 'Arnheim',
          'A14' => 'Hamburg Münster',
          'B9' => 'Wesel',
          'B15' => 'Berlin Minden',
          'C2' => 'Boxtel',
          'C12' => 'Herne Gelsenkirchen',
          'C14' => 'Östliches Ruhrgebiet',
          'D7' => 'Moers',
          'D9' => 'Duisburg',
          'D11' => 'Oberhausen Mülheim',
          'D13' => 'Essen',
          'E2' => 'Venio',
          'E6' => 'Krefeld',
          'E12' => 'Ratingen',
          'F9' => 'Neuss Düsseldorf',
          'F13' => 'Elberfeld Barmen',
          'G2' => 'Roermond',
          'G6' => 'M-Gladbach Rheydt',
          'G12' => 'Remshcheid Solingen',
          'I10' => 'Köln Deutz',
          'K2' => 'Aachen',
          'K6' => 'Düren',
          'K10' => 'Bonn',
          'J1' => 'Maastrict',
          'J15' => 'Siegerland',
          'L1' => 'Liege',
          'L11' => 'Basel',
          'L13' => 'Frankfurt',
        }.freeze

        EASTERN_RUHR_CONNECTION_CHECK = %w[C12 D13 E14].freeze

        EASTERN_RUHR_HEXES = %w[C14 D15].freeze

        NIMWEGEN_ARNHEIM_OFFBOARD_HEXES = %(A4 A6).freeze

        OSTERATH_POTENTIAL_TILE_UPGRADES_FROM = %w[1 2 55 56 69].freeze

        OUT_TOKENED_HEXES = %w[A14 B15 C2].freeze

        RATINGEN_HEX = 'E12'

        RGE_HEXES = %w[A4 A6 L11 L13].freeze

        RHINE_METROPOLIS_HEXES = %w[D9 F9 I10].freeze

        BASEL_FRANKFURT_OFFBOARD_HEXES = %w[L11 L13].freeze

        def aachen_hex
          @aachen_hex ||= hex_by_id('K2')
        end

        def cologne_hex
          @cologne_hex ||= hex_by_id('I10')
        end

        def duren_hex
          @duren_hex ||= hex_by_id('K6')
        end

        def duisburg_hex
          @duisburg_hex ||= hex_by_id('D9')
        end

        def dusseldorf_hex
          @dusseldorf_hex ||= hex_by_id('F9')
        end

        def roermund_hex
          @roermund_hex ||= hex_by_id('G2')
        end

        def yellow_block_hex
          @yellow_block_hex ||= hex_by_id(RATINGEN_HEX)
        end

        def optional_hexes
          base_map
        end

        def optional_tiles
          remove_tiles(%w[Essen-0 949-0 950-0 932V-0 932V-1]) unless optional_promotion_tiles
          remove_tiles(%w[932-0 932-1]) if optional_promotion_tiles
          remove_tiles(%w[1910-0 1911-0]) unless optional_ratingen_variant
        end

        def remove_tiles(tiles)
          tiles.each do |ot|
            @tiles.reject! { |t| t.id == ot }
            @all_tiles.reject! { |t| t.id == ot }
          end
        end

        def base_map
          e10_configuration = 'border=edge:1,type:impassable,color:blue'
          e12_configuration = 'town=revenue:0;town=revenue:0;upgrade=cost:30,terrain:mountain'
          if optional_ratingen_variant
            e10_configuration += ';stub=edge:0;stub=edge:2;city=revenue:0'
            e12_configuration += ';stub=edge:1;icon=image:1893/green_hex;icon=image:18_rhl/white_wooden_cube,sticky:1'
          end
          {
            red: {
              ['A4'] => 'offboard=revenue:yellow_40|brown_60,groups:NorthWest;path=a:0,b:_0,terminal:1;'\
                        'icon=image:18_rhl/RGE',
              ['A6'] => 'offboard=revenue:yellow_40|brown_60,groups:NorthWest;path=a:5,b:_0,terminal:1;'\
                        'border=edge:0,type:impassable,color:blue;icon=image:18_rhl/RGE',
              ['A14'] => 'city=revenue:yellow_40|brown_60;path=a:0,b:_0,terminal:1',
              ['B15'] => 'city=revenue:yellow_50|brown_80;path=a:1,b:_0,terminal:1',
              ['C2'] => 'city=revenue:yellow_10|brown_30;path=a:4,b:_0,terminal:1',
              ['C14'] => 'city=revenue:10;city=revenue:10;path=a:0,b:_0,terminal:1;path=a:1,b:_1,terminal:1;'\
                         'icon=image:18_rhl/ERh',
              ['D15'] => 'city=revenue:10;city=revenue:10;path=a:0,b:_0,terminal:1;path=a:1,b:_1,terminal:1;'\
                         'label=+10/link;icon=image:18_rhl/ERh',
              ['E2'] => 'city=revenue:yellow_20|brown_40;path=a:3,b:_0;path=a:5,b:_0',
              ['G2'] => 'city=revenue:yellow_10|brown_20,groups:Roermond;path=a:4,b:_0,terminal:1;'\
                        'icon=image:18_rhl/ERh',
              ['J1'] => 'offboard=revenue:yellow_10|brown_30;path=a:5,b:_0,terminal:1',
              ['L1'] => 'offboard=revenue:yellow_30|brown_60;path=a:3,b:_0,terminal:1',
              ['L9'] => 'town=revenue:10;path=a:2,b:_0;path=a:3,b:_0',
              ['L11'] => 'offboard=revenue:yellow_30|brown_70;border=edge:3,type:impassable,color:blue;'\
                         'path=a:2,b:_0;icon=image:18_rhl/RGE',
              ['L13'] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;icon=image:18_rhl/RGE',
            },
            gray: {
              %w[A2 A8 A10 A12 B1 D1 F1 H1 L3 L5 L7] => '',
              %w[F15 H15] => 'path=a:0,b:2',
              ['I4'] => 'path=a:0,b:3',
              ['J15'] => 'city=revenue:yellow_20|brown_40,loc:1;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                         'icon=image:../logos/18_rhl/S',
              ['K14'] => 'path=a:1,b:3',
            },
            white: {
              ['B5'] => 'border=edge:3,type:impassable,color:blue;border=edge:4,type:impassable,color:blue',
              ['B7'] => 'border=edge:0,type:impassable,color:blue;border=edge:1,type:impassable,color:blue;'\
                        'border=edge:5,type:impassable,color:blue',
              ['B9'] => 'city=revenue:0',
              %w[B11 D3 D5 E4 F3 F7 G4 G8 H3 H5 H7 I2 I8 J5 J7 K8] => '',
              %w[B13 E8 F5 J3] => 'town=revenue:0;town=revenue:0',
              %w[C4 I6 K4] => 'town=revenue:0',
              ['C6'] => 'town=revenue:0;border=edge:3,type:impassable,color:blue',
              ['C8'] => 'stub=edge:3;upgrade=cost:30,terrain:water;border=edge:2,type:impassable,color:blue;'\
                        'border=edge:4,type:impassable,color:blue',
              ['C10'] => 'town=revenue:0;town=revenue:0;border=edge:1,type:impassable,color:blue',
              %w[C12 D11] => 'city=revenue:0;city=revenue:0;label=OO',
              ['D13'] => 'city=revenue:0;upgrade=cost:30,terrain:mountain;label=Y',
              ['E6'] => 'city=revenue:0;label=Y',
              ['E8'] => 'town=revenue:0;town=revenue:0;border=edge:4,type:impassable,color:blue',
              ['E10'] => e10_configuration,
              ['E12'] => e12_configuration,
              %w[E14 J13] => 'upgrade=cost:30,terrain:mountain',
              %w[F11 G14 H13] => 'upgrade=cost:60,terrain:mountain',
              ['G10'] => 'town=revenue:0;town=revenue:0;border=edge:0,type:impassable,color:blue;'\
                         'border=edge:1,type:impassable,color:blue',
              ['G12'] => 'city=revenue:0;city=revenue:10;upgrade=cost:30,terrain:mountain;path=a:4,b:_1;label=OO',
              ['H9'] => 'town=revenue:0;border=edge:3,type:impassable,color:blue;border=edge:4,type:impassable,color:blue',
              ['H11'] => 'border=edge:1,type:impassable,color:blue',
              ['I12'] => 'town=revenue:0;upgrade=cost:30,terrain:mountain',
              ['J11'] => 'border=edge:0,type:impassable,color:blue;border=edge:1,type:impassable,color:blue',
              ['K10'] => 'city=revenue:0;border=edge:3,type:impassable,color:blue;border=edge:4,type:impassable,color:blue',
              ['K12'] => 'town=revenue:0;upgrade=cost:30,terrain:mountain;border=edge:0,type:impassable,color:blue;'\
                         'border=edge:1,type:impassable,color:blue',
              %w[G8 J9] => 'border=edge:4,type:impassable,color:blue',
            },
            yellow: {
              ['B3'] => 'path=a:3,b:5',
              ['D9'] => 'city=revenue:20;city=revenue:30;city=revenue:30;upgrade=cost:30,terrain:water;path=a:0,b:_0;'\
                        'path=a:3,b:_1;path=a:5,b:_2;label=DU;partition=a:0,b:3,type:water',
              ['F9'] => 'city=revenue:20;city=revenue:30,loc:3.5;city=revenue:30;upgrade=cost:30,terrain:water;path=a:0,b:_0;'\
                        'path=a:4,b:_1;path=a:5,b:_2;label=D;partition=a:0,b:3,type:water',
              ['F13'] => 'city=revenue:30;city=revenue:30;upgrade=cost:30,terrain:mountain;path=a:1,b:_0;'\
                         'path=a:_0,b:2;path=a:3,b:_1;path=a:_1,b:5;label=Y',
              ['G6'] => 'city=revenue:20;city=revenue:20;path=a:0,b:_0;path=a:2,b:_1;label=OO',
              ['I10'] => 'city=revenue:30;city=revenue:30;city=revenue:20;upgrade=cost:30,terrain:water;'\
                         'path=a:0,b:_0;path=a:2,b:_1;path=a:3,b:_2;label=K;partition=a:0,b:3,type:water',
              ['I14'] => 'upgrade=cost:60,terrain:mountain;path=a:3,b:5',
              ['K2'] => 'city=revenue:20;upgrade=cost:30,terrain:mountain;path=a:3,b:_0;path=a:4,b:_0;label=AC',
              ['K6'] => 'city=revenue:20;path=a:1,b:_0;path=a:4,b:_0',
            },
            green: {
              ['D7'] => 'city=revenue:0;icon=image:../logos/18_rhl/K',
            },
          }
        end
      end
    end
  end
end
