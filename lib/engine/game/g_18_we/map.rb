# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G18WE
      module Map
        TILES = {
          'WE01' => {
            'count' => 3,
            'color' => 'yellow',
            'code' => 'label=Z;city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          'WE02' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'label=Y;city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          'WE03' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'label=Y;city=revenue:30,slots:2;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          'WE04' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'label=Y;city=revenue:30,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          '5' => 'unlimited',
          '6' => 'unlimited',
          '57' => 'unlimited',
          '3' => 'unlimited',
          '4' => 'unlimited',
          '58' => 'unlimited',
          'WE05' => {
            'count' => 3,
            'color' => 'green',
            'code' => 'label=Z;city=revenue:60,slots:3;' \
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          'WE06' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'label=Y;city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          '87' => 'unlimited',
          '88' => 'unlimited',
          '204' => 'unlimited',
          '14' => 'unlimited',
          '15' => 'unlimited',
          '619' => 'unlimited',
          'WE07' => {
            'count' => 3,
            'color' => 'brown',
            'code' => 'label=Z;city=revenue:80,slots:4;' \
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          'WE08' => {
            'count' => 'unlimited',
            'color' => 'brown',
            'code' => 'label=Y;city=revenue:60,slots:3;' \
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          '611' => 'unlimited',
          'WE09' => {
            'count' => 'unlimited',
            'color' => 'brown',
            'code' => 'town=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          'WE10' => {
            'count' => 3,
            'color' => 'gray',
            'code' => 'label=Z;city=revenue:100,slots:4;' \
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          'WE11' => {
            'count' => 'unlimited',
            'color' => 'gray',
            'code' => 'label=Y;city=revenue:80,slots:4;' \
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          '513' => 'unlimited',
          'WE12' => {
            'count' => 'unlimited',
            'color' => 'gray',
            'code' => 'town=revenue:30;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
        }.freeze

        HEXES = {
          blue: {
            # Skaggerak offboard
            ['J1'] => 'border=edge:1;offboard=revenue:green_50|brown_60|gray_70,groups:Skaggerak;path=a:5,b:_0',
            ['I2'] => 'border=edge:4',
            # Denmark Sound offboard
            ['K4'] => 'border=edge:4;offboard=revenue:green_50|brown_60|gray_70,hide:1,groups:DenmarkSound;' \
                      'path=a:1,b:_0;path=a:3,b:5,track:dual',
            ['L3'] => 'border=edge:1;offboard=revenue:green_50|brown_60|gray_70,groups:DenmarkSound;path=a:0,b:_0;path=a:2,b:_0',
            # Baltic Sea offboard
            ['M4'] => 'border=edge:4;offboard=revenue:green_60|brown_80|gray_90,hide:1,groups:BalticSea;' \
                      'path=a:1,b:_0;path=a:5,b:_0',
            ['N3'] => 'border=edge:1;border=edge:4;offboard=revenue:green_60|brown_80|gray_90,groups:BalticSea;' \
                      'path=a:0,b:_0;path=a:5,b:_0',
            ['O2'] => 'border=edge:1;offboard=revenue:green_60|brown_80|gray_90,hide:1,groups:BalticSea;path=a:0,b:_0',
            # North Sea offboard
            ['I4'] => 'border=edge:1;offboard=revenue:green_60|brown_80|gray_90,hide:1,groups:NorthSea;path=a:5,b:_0',
            ['H5'] => 'border=edge:4;offboard=revenue:green_60|brown_80|gray_90,groups:NorthSea;path=a:0,b:_0',
            ['G6'] => 'border=edge:4;offboard=revenue:green_60|brown_80|gray_90,hide:1,groups:NorthSea;' \
                      'path=a:0,b:_0;path=a:1,b:5,track:dual',
            # English Channel offboard
            ['D9'] => 'border=edge:1;offboard=revenue:green_50|brown_60|gray_70,hide:1,groups:EnglishChannel;path=a:5,b:_0',
            ['C10'] => 'border=edge:2;border=edge:4;offboard=revenue:green_50|brown_60|gray_70,groups:EnglishChannel;' \
                       'path=a:0,b:_0;path=a:1,b:_0',
            ['B9'] => 'border=edge:5;offboard=revenue:green_50|brown_60|gray_70,hide:1,groups:EnglishChannel;path=a:0,b:_0',
            # Bay of Biscay offboard
            ['A10'] => 'border=edge:0;offboard=revenue:green_60|brown_80|gray_90,hide:1,groups:BayOfBiscay;path=a:5,b:_0',
            ['A12'] => 'border=edge:3;border=edge:5;offboard=revenue:green_60|brown_80|gray_90,hide:1,groups:BayOfBiscay;' \
                       'path=a:4,b:_0',
            ['B13'] => 'border=edge:0;border=edge:2;offboard=revenue:green_60|brown_80|gray_90,groups:BayOfBiscay;' \
                       'path=a:3,b:_0;path=a:4,b:_0',
            ['B15'] => 'border=edge:0;border=edge:3;offboard=revenue:green_60|brown_80|gray_90,hide:1,groups:BayOfBiscay;' \
                       'path=a:5,b:_0',
            ['B17'] => 'border=edge:3;offboard=revenue:green_60|brown_80|gray_90,hide:1,groups:BayOfBiscay;path=a:4,b:_0',
            # Western Med. offboard
            ['F21'] => 'border=edge:5;offboard=revenue:green_50|brown_60|gray_70,groups:WesternMed;' \
                       'path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            ['G22'] => 'border=edge:2;offboard=revenue:green_50|brown_60|gray_70,hide:1,groups:WesternMed;path=a:3,b:_0',
            # Ligurian Sea offboard
            ['H21'] => 'border=edge:4;border=edge:5;offboard=revenue:green_60|brown_80|gray_90,groups:LigurianSea;' \
                       'path=a:2,b:_0;path=a:3,b:_0',
            ['I20'] => 'border=edge:0;border=edge:1;offboard=revenue:green_60|brown_80|gray_90,hide:1,groups:LigurianSea;' \
                       'path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['I22'] => 'border=edge:2;border=edge:3;offboard=revenue:green_60|brown_80|gray_90,hide:1,groups:LigurianSea;' \
                       'path=a:4,b:_0',
            # Adriatic Sea offboard
            ['L17'] => 'border=edge:0;border=edge:5;offboard=revenue:green_50|brown_60|gray_70,groups:AdriaticSea;' \
                       'path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            ['L19'] => 'border=edge:3;border=edge:4;offboard=revenue:green_50|brown_60|gray_70,hide:1,groups:AdriaticSea;' \
                       'path=a:1,b:_0;path=a:2,b:_0',
            ['M18'] => 'border=edge:1;border=edge:2',
            # Black Sea offboard
            ['P19'] => 'offboard=revenue:green_60|brown_80|gray_90;path=a:1,b:_0',
            # Aegean Sea offboard
            ['O22'] => 'offboard=revenue:green_70|brown_90|gray_100;path=a:3,b:_0',
          },
          red: {
            # Greater UK offboard
            ['A8'] => 'offboard=revenue:green_70|brown_90|gray_100;path=a:4,b:_0',
            # London offboard
            ['E6'] => 'city=slots:4,revenue:green_80|brown_100|gray_130;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0',
            # Scandinavia offboard
            ['K0'] => 'border=edge:5;offboard=revenue:green_60|brown_80|gray_90,groups:Scandinavia;path=a:0,b:_0',
            ['L1'] => 'border=edge:2;offboard=revenue:green_60|brown_80|gray_90,hide:1,groups:Scandinavia;path=a:1,b:_0',
            # St. Petersburg offboard
            ['P3'] => 'border=edge:0;offboard=revenue:green_50|brown_60|gray_70,hide:1,groups:StPetersburg;path=a:1,b:_0',
            ['P5'] => 'border=edge:3;offboard=revenue:green_50|brown_60|gray_70,groups:StPetersburg;path=a:1,b:_0;path=a:2,b:_0',
            # Poland & Ukraine offboard
            ['P7'] => 'border=edge:0;offboard=revenue:green_60|brown_80|gray_90,hide:1,groups:PolandUkraine;' \
                      'path=a:1,b:_0;path=a:2,b:_0',
            ['P9'] => 'border=edge:0;border=edge:3;offboard=revenue:green_60|brown_80|gray_90,groups:PolandUkraine;' \
                      'path=a:1,b:_0;path=a:2,b:_0',
            ['P11'] => 'border=edge:3;offboard=revenue:green_60|brown_80|gray_90,hide:1,groups:PolandUkraine;' \
                       'path=a:1,b:_0;path=a:2,b:_0',
            # Constantinople offboard
            ['P13'] => 'border=edge:0;path=a:0,b:1;path=a:0,b:2',
            ['P15'] => 'border=edge:1;border=edge:3;path=a:1,b:2;path=a:1,b:3',
            ['O16'] => 'border=edge:0;border=edge:4;path=a:0,b:3;path=a:0,b:4',
            ['O18'] => 'border=edge:0;border=edge:3;path=a:0,b:3',
            ['O20'] => 'border=edge:3;city=slots:4,revenue:green_80|brown_100|gray_130;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            # Naples offboard
            ['L21'] => 'border=edge:1;offboard=revenue:green_60|brown_80|gray_90,hide:1,groups:Naples;path=a:2,b:_0',
            ['K22'] => 'border=edge:1;border=edge:4;offboard=revenue:green_60|brown_80|gray_90,groups:Naples;' \
                       'path=a:2,b:_0;path=a:3,b:_0',
            ['J23'] => 'border=edge:4;offboard=revenue:green_60|brown_80|gray_90,hide:1,groups:Naples;path=a:3,b:_0',
            # Southern Spain offboard
            ['D21'] => 'border=edge:5;offboard=revenue:green_60|brown_80|gray_90,groups:Spain;path=a:3,b:_0;path=a:4,b:_0',
            ['E22'] => 'border=edge:2;offboard=revenue:green_60|brown_80|gray_90,hide:1,groups:Spain;path=a:3,b:_0',
            # Portugal offboard
            ['C20'] => 'offboard=revenue:green_50|brown_60|gray_70;path=a:3,b:_0;path=a:4,b:_0',
          },
          gray: {
            # London to Greater UK
            ['B7'] => 'path=a:1,b:5',
            ['C8'] => 'path=a:2,b:4',
            ['D7'] => 'path=a:1,b:4',
            # London Channel crossings
            ['F7'] => 'path=a:0,b:2,track:dual;path=a:2,b:4,track:dual;path=a:2,b:5,track:dual',
            ['E8'] => 'path=a:0,b:3,track:dual;path=a:3,b:5,track:dual',
          },
          white: {
            # Germanic Region:
            ['L7'] => 'frame=color:#59b577;city=revenue:0;label=Z',
            %w[
                    K2 J5 N5 H7 L9 M10 H11 J13
                ] => 'frame=color:#59b577;city=revenue:0;label=Y',
            %w[
                    O4 L5 G8 H9 I10 H13
                ] => 'frame=color:#59b577;city=revenue:0',
            %w[
                    J3 I6 K6 M6 O6 J7 N7 I8 K8 M8 J9 K10 J11 I12
                ] => 'frame=color:#59b577;town=revenue:0',

            # Southeastern Region:
            ['I16'] => 'frame=color:#fbeb66;city=revenue:0;label=Z',
            %w[
                    O8 L11 M14 O14 K16 I18 J21
                ] => 'frame=color:#fbeb66;city=revenue:0;label=Y',
            %w[
                    N9 O10 K12 M12 L15 J17
                ] => 'frame=color:#fbeb66;city=revenue:0',
            %w[
                    N11 O12 L13 N13 I14 K14 H15 J15 N15 M16 H17 K18 H19
                    J19 K20
                ] => 'frame=color:#fbeb66;town=revenue:0',

            # French Region:
            ['F11'] => 'frame=color:#b14bd3;city=revenue:0;label=Z',
            %w[
                    C12 E12 C16 G16 G20
                ] => 'frame=color:#b14bd3;city=revenue:0;label=Y',
            %w[
                    E10 B11 G14 F15 E16 D17 G18 D19
                ] => 'frame=color:#b14bd3;city=revenue:0',
            %w[
                    F9 G10 D11 G12 D13 F13 C14 E14 D15 F17 C18 E18 F19
                    E20
                ] => 'frame=color:#b14bd3;town=revenue:0',
          },
        }.freeze

        LOCATION_NAMES = {
          'K0' => 'Scandinavia',
          'J1' => 'Skaggerak',
          'K2' => 'København',
          'L3' => 'Denmark Sound',
          'N3' => 'Baltic Sea',
          'P5' => 'St. Petersburg',
          'O4' => 'Konigsburg',
          'H5' => 'North Sea',
          'J5' => 'Hamburg',
          'L5' => 'Stettin',
          'N5' => 'Danzig',
          'E6' => 'London',
          'H7' => 'Amsterdam',
          'L7' => 'Berlin',
          'A8' => 'Greater UK',
          'G8' => 'Brussels',
          'O8' => 'Warsaw',
          'H9' => 'Essen',
          'L9' => 'Dresden',
          'N9' => 'Łódź',
          'P9' => 'Poland & Ukraine',
          'C10' => 'English Channel',
          'E10' => 'Rouen',
          'I10' => 'Frankfurt',
          'M10' => 'Breslau',
          'O10' => 'Krakow',
          'B11' => 'Brest',
          'F11' => 'Paris',
          'H11' => 'Köln',
          'L11' => 'Praha',
          'C12' => 'Nantes',
          'E12' => 'Orleans',
          'K12' => 'Pilsen',
          'M12' => 'Brno',
          'B13' => 'Bay of Biscay',
          'H13' => 'Straßburg',
          'J13' => 'München',
          'G14' => 'Dijon',
          'M14' => 'Wien',
          'O14' => 'Budapest',
          'F15' => 'Moulins',
          'L15' => 'Trieste',
          'C16' => 'Bordeaux',
          'E16' => 'Clermont-Ferrand',
          'G16' => 'Lyon',
          'I16' => 'Milano',
          'K16' => 'Venezia',
          'D17' => 'Brive-la-Gaillarde',
          'J17' => 'Verona',
          'L17' => 'Adriatic Sea',
          'G18' => 'Avignon',
          'I18' => 'Genova',
          'D19' => 'Toulouse',
          'P19' => 'Black Sea',
          'C20' => 'Portugal & N.Spain',
          'G20' => 'Marseille',
          'O20' => 'Constantinople',
          'D21' => 'Southern Spain',
          'F21' => 'Western Med.',
          'H21' => 'Ligurian Sea',
          'J21' => 'Roma',
          'K22' => 'Naples & S.Italy',
          'O22' => 'Aegean Sea',
        }.freeze
      end
    end
  end
end
