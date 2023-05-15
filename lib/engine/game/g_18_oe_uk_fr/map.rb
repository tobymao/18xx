# frozen_string_literal: true

module Engine
  module Game
    module G18OEUKFR
      module Map
        LAYOUT = :pointy
        AXES = { x: :number, y: :letter }.freeze
        TILE_TYPE = :lawson

        LOCATION_NAMES = {
          'C40' => 'Norwegian Coast (to Narvik)',
          'D25' => 'Scottish Highlands',
          'E26' => 'Inverness',
          'E28' => 'Aberdeen',
          'F25' => 'Glasgow',
          'F27' => 'Dundee',
          'G24' => 'Stranraer',
          'G26' => 'Edinburgh',
          'H17' => 'Silgo',
          'H21' => 'Belfast',
          'H29' => 'Newcastle Upon Tyne',
          'I16' => 'Limerick',
          'I20' => 'Dublin',
          'I26' => 'Preston',
          'J15' => 'Cork',
          'J17' => 'Waterford',
          'J23' => 'Hollyhead',
          'J25' => 'Liverpool',
          'J27' => 'Manchester',
          'J29' => 'Leeds and Sheffield',
          'K26' => 'Birmingham',
          'L17' => 'Celtic Sea',
          'L23' => 'Cardiff',
          'L25' => 'Bristol',
          'L29' => 'Cambridge',
          'M26' => 'Southampton and Portsmouth',
          'M28' => 'London',
          'N21' => 'English Channel',
          'N31' => 'Lille',
          'N33' => 'Gent',
          'N35' => 'Brussel',
          'O24' => 'Cherbourg',
          'O28' => 'Le Havre',
          'P13' => 'New York',
          'P15' => 'North Atlantic',
          'P19' => 'Brest',
          'P29' => 'Rouen',
          'P33' => 'Reims',
          'P37' => 'Luxembourg',
          'P39' => 'Berlin',
          'Q26' => 'Le Mans',
          'Q30' => 'Paris',
          'Q38' => 'Nancy',
          'R23' => 'Nantes',
          'R29' => 'Orleans',
          'S20' => 'Bay of Biscay',
          'S34' => 'Dijon',
          'T27' => 'Limoges',
          'T37' => 'Geneve and Lausanne',
          'U24' => 'Bordeaux',
          'U32' => 'Saint-Etienne',
          'U34' => 'Lyon',
          'V21' => 'Bayonne',
          'V27' => 'Toulouse',
          'W32' => 'Nimes and Montpellier',
          'X23' => 'Madrid',
          'X25' => 'Andorra',
          'X33' => 'Marseille',
          'X35' => 'Toulon',
          'X37' => 'Nice',
          'Z33' => 'Sea of Sardinia',
          'Z39' => 'Tyhrrhenian Sea',
          'Z41' => 'Ajaccio',
          'AA14' => 'North Africa & The Americas',
          'AA24' => 'Alger',
          'AA38' => 'Constantinople',
          'AA40' => 'Aegean Sea',
        }.freeze

        HEXES = {
          white: {
            %w[H19 H27 I18 I28 K28 K30 L27 M24 N37 O30 O32 O34 O36 O38 P21 P23 P25 P27 P31 P35 Q22 Q24 Q28 Q32 Q34 Q36 R25 R27
               R31 R33 R35 R37 S24 S26 S28 S30 S32 S36 T25 T29 T31 T35 U22 U26 U28 V23 V25 V33 W26 W28 W30 W34 X29] => '',
            %w[K22 M22 R39 T33] => 'upgrade=cost:30,terrain:mountain',
            %w[G18 H15 J19 K24 S38 U30 V29 V35 W36 Y28] => 'upgrade=cost:45,terrain:mountain',
            %w[U36 V31 V37 W24 W38 X27] => 'upgrade=cost:60,terrain:mountain',
            %w[U38 W22] => 'upgrade=cost:120,terrain:mountain',
            %w[G16 G20 I14] => 'upgrade=cost:30,terrain:water',
            %w[E24 H25 J13 Q20] => 'upgrade=cost:45,terrain:water',
            %w[F23 T23] => 'upgrade=cost:60,terrain:water',
            %w[H17 H29 J17 L29 N33 O24 P19 P29 P33 P37 R29 S34 T27 X35 X37 Z41] => 'town=revenue:0',
            %w[J29 M26 W32] => 'town=revenue:0;town=revenue:0',
            %w[F25 H21 J15 L25 Q26 Q38 R23 V27] => 'city=revenue:0',
            %w[F29 L31] => 'border=edge:0,type:impassable',
            ['F27'] => 'town=revenue:0;border=edge:0,type:impassable;border=edge:5,type:impassable',
            ['G28'] => 'border=edge:2,type:impassable;border=edge:3,type:impassable',
            ['M30'] => 'border=edge:3,type:impassable;border=edge:5,type:impassable;upgrade=cost:45,terrain:water',
            ['V21'] => 'town=revenue:0;border=edge:1,type:impassable',
            %w[G24 I16 I26] => 'town=revenue:0;upgrade=cost:30,terrain:mountain',
            %w[E26 E28 J23] => 'town=revenue:0;upgrade=cost:45,terrain:mountain',
            ['X25'] => 'town=revenue:0;upgrade=cost:60,terrain:mountain',
            ['L23'] => 'town=revenue:0;upgrade=cost:45,terrain:water',
            ['T37'] => 'town=revenue:0;town=revenue:0;upgrade=cost:45,terrain:mountain',
            ['G26'] => 'city=revenue:10;label=Y;upgrade=cost:30,terrain:mountain;border=edge:3,type:impassable',
            ['I20'] => 'city=revenue:10;path=a:4,b:_0',
            ['K26'] => 'city=revenue:0;label=A',
            ['M28'] => 'city=revenue:30;label=L;upgrade=cost:30,terrain:water;path=a:5,b:_0',
            ['N31'] => 'city=revenue:20;label=Y;path=a:1,b:_0;border=edge:2,type:impassable',
            ['N35'] => 'city=revenue:0;label=Y;upgrade=cost:30,terrain:water',
            ['O28'] => 'city=revenue:10;path=a:_0,b:1',
            ['Q30'] => 'city=revenue:0;label=P',
            ['U24'] => 'city=revenue:10',
            ['U32'] => 'city=revenue:0;upgrade=cost:30,terrain:mountain',
            ['U34'] => 'city=revenue:0;label=Y',
            ['X33'] => 'city=revenue:20;label=Y;path=a:_0,b:5',
          },
          yellow: {
            ['J25'] => 'city=revenue:30;label=Y;path=a:2,b:_0;path=a:_0,b:4',
            ['J27'] => 'city=revenue:20;upgrade=cost:30,terrain:mountain;path=a:1,b:_0;path=a:_0,b:4',
          },
          red: {
            ['C40'] => 'offboard=revenue:yellow_30|green_60|brown_80|gray_120;path=a:1,b:0',
            ['D25'] => 'offboard=revenue:yellow_20|green_40|brown_50;path=a:0,b:_0;path=a:5,b:_0',
            ['P13'] => 'offboard=revenue:green_60|brown_100|gray_160;path=a:3,b:_0;path=a:5,b:_0',
            ['P39'] => 'offboard=revenue:yellow_30|green_60|brown_90|gray_120;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
            ['X23'] => 'offboard=revenue:yellow_30|green_50|brown_80|gray_100;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            ['AA14'] => 'offboard=revenue:green_40|brown_80|gray_120;path=a:4,b:_0',
            ['AA24'] => 'offboard=revenue:yellow_30|green_40|brown_60|gray_100;path=a:2,b:_0',
            ['AA38'] => 'offboard=revenue:yellow_30|green_50|brown_80|gray_100;path=a:4,b:_0',
          },
          blue: {
            # north atlantic
            ['O14'] => 'border=edge:5',
            ['P15'] => 'border=edge:0;border=edge:2',
            ['Q14'] => 'border=edge:3',

            # english channel
            ['N19'] => 'border=edge:0;border=edge:4;border=edge:5',
            ['N21'] => 'border=edge:0;border=edge:1;border=edge:4;border=edge:5',
            ['N25'] => 'path=a:0,b:3;offboard=revenue:0;border=edge:1;border=edge:4;border=edge:5', # -1 ferry
            %w[N23 N27] => 'border=edge:0;border=edge:1;border=edge:4',
            ['N29'] => 'path=a:2,b:4;border=edge:1',
            ['O18'] => 'junction;path=a:5,b:_0,terminal:1;border=edge:3;border=edge:4',
            ['O20'] => 'border=edge:1;border=edge:2;border=edge:3;border=edge:4',
            ['O22'] => 'border=edge:1;border=edge:2;border=edge:3',
            ['O26'] => 'junction;path=a:1,b:_0,terminal:1;path=a:4,b:_0,terminal:1;'\
                       'icon=image:port,sticky:1;border=edge:2;border=edge:3',

            # bay of biscay
            ['P17'] => 'border=edge:0;border=edge:5', # needs a port
            ['Q16'] => 'border=edge:3;border=edge:4;border=edge:5',
            ['Q18'] => 'border=edge:0;border=edge:1;border=edge:2;border=edge:5',
            %w[R17 S18 T19] => 'border=edge:2;border=edge:3;border=edge:4;border=edge:5',
            ['R19'] => 'border=edge:0;border=edge:1;border=edge:2;border=edge:4;border=edge:5',
            ['R21'] => 'border=edge:0;border=edge:1;border=edge:5', # needs a port
            ['S20'] => 'border=edge:0;border=edge:1;border=edge:2;border=edge:3;border=edge:4;border=edge:5',
            ['S22'] => 'border=edge:0;border=edge:1;border=edge:2',
            ['T21'] => 'border=edge:0;border=edge:1;border=edge:2;border=edge:3', # needs an offshore port
            ['U20'] => 'border=edge:2;border=edge:3',

            # celtic sea
            ['G22'] => 'path=a:0,b:4;border=edge:2;border=edge:5',
            ['H23'] => 'border=edge:0;border=edge:2;border=edge:5', # needs port
            ['I22'] => 'junction;path=a:1,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
                       'border=edge:0;border=edge:3;border=edge:4', # needs port/ferry
            ['I24'] => 'junction;path=a:1,b:_0;path=a:4,b:_0;path=a:5,b:_0;border=edge:1;border=edge:2', # needs port/ferry
            ['J21'] => 'border=edge:0;border=edge:3', # needs port
            ['K14'] => 'border=edge:0;border=edge:4;border=edge:5',
            ['K16'] => 'border=edge:0;border=edge:1;border=edge:4;border=edge:5', # needs a port
            ['K18'] => 'border=edge:0;border=edge:1;border=edge:4;border=edge:5',
            ['K20'] => 'border=edge:0;border=edge:1;border=edge:3;border=edge:5',
            %w[L13 L15 L17 L19 M16] => 'border=edge:0;border=edge:1;border=edge:2;border=edge:3;border=edge:4;border=edge:5',
            ['L21'] => 'border=edge:0;border=edge:1;border=edge:2', # needs an offshore port
            %w[M14 N15] => 'border=edge:2;border=edge:3;border=edge:4;border=edge:5',
            ['M18'] => 'border=edge:0;border=edge:1;border=edge:2;border=edge:3;border=edge:4',
            ['M20'] => 'border=edge:1;border=edge:2;border=edge:3',
            ['N17'] => 'border=edge:0;border=edge:1;border=edge:2;border=edge:3',
            ['O16'] => 'border=edge:2;border=edge:3',

            # silver coast

            # balearic sea

            # strait of gibraltar

            # sea of sardinia
            ['X31'] => 'border=edge:0;border=edge:5',
            ['Y30'] => 'border=edge:0;border=edge:3;border=edge:4;border=edge:5',
            ['Y32'] => 'border=edge:0;border=edge:1;border=edge:2;border=edge:4;border=edge:5',
            ['Y34'] => 'icon=image:port,sticky:1;junction;path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1;'\
                       'border=edge:0;border=edge:1;border=edge:4;border=edge:5',
            ['Y36'] => 'icon=image:port,sticky:1;junction;path=a:3,b:_0,terminal:1;'\
                       'border=edge:0;border=edge:1;border=edge:4;border=edge:5',
            ['Y38'] => 'path=a:2,b:4;border=edge:0;border=edge:1;border=edge:3;border=edge:4',
            ['Y40'] => 'path=a:1,b:5;border=edge:1;border=edge:2;border=edge:3',
            ['Z29'] => 'border=edge:3;border=edge:4',
            %w[Z31 Z33 Z35] => 'border=edge:1;border=edge:2;border=edge:3;border=edge:4',
            ['Z37'] => 'border=edge:1;border=edge:2;border=edge:3',

            # tyrrhenian sea
            ['Z39'] => '',

            # aegean sea
            ['AA40'] => '', # needs a port
          },
        }.freeze
      end
    end
  end
end
