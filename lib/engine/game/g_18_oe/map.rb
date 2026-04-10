# frozen_string_literal: true

module Engine
  module Game
    module G18OE
      module Map
        LAYOUT = :pointy
        AXES = { x: :number, y: :letter }.freeze
        TILE_TYPE = :lawson

        LOCATION_NAMES = {
          # UK / Ireland
          'E26'  => 'Inverness',
          'E28'  => 'Aberdeen',
          'F25'  => 'Glasgow',
          'F27'  => 'Dundee',
          'G24'  => 'Stranraer',
          'G26'  => 'Edinburgh',
          'H17'  => 'Sligo',
          'H21'  => 'Belfast',
          'H29'  => 'Newcastle Upon Tyne',
          'I16'  => 'Limerick',
          'I20'  => 'Dublin',
          'I26'  => 'Preston',
          'J15'  => 'Cork',
          'J17'  => 'Waterford',
          'J23'  => 'Holyhead',
          'J25'  => 'Liverpool',
          'J27'  => 'Manchester',
          'J29'  => 'Leeds and Sheffield',
          'K26'  => 'Birmingham',
          'L23'  => 'Cardiff',
          'L25'  => 'Bristol',
          'L29'  => 'Cambridge',
          'M26'  => 'Southampton and Portsmouth',
          'M28'  => 'London',
          # France / Belgium
          'N31'  => 'Lille',
          'N33'  => 'Gent',
          'N35'  => 'Brussel',
          'O24'  => 'Cherbourg',
          'O28'  => 'Le Havre',
          'P19'  => 'Brest',
          'P29'  => 'Rouen',
          'P33'  => 'Reims',
          'P37'  => 'Luxembourg',
          'Q26'  => 'Le Mans',
          'Q30'  => 'Paris',
          'Q38'  => 'Nancy',
          'R23'  => 'Nantes',
          'R29'  => 'Orleans',
          'S34'  => 'Dijon',
          'T27'  => 'Limoges',
          'T37'  => 'Geneve and Lausanne',
          'U24'  => 'Bordeaux',
          'U32'  => 'Saint-Etienne',
          'U34'  => 'Lyon',
          'V21'  => 'Bayonne',
          'V27'  => 'Toulouse',
          'W32'  => 'Nimes and Montpellier',
          # Spain / Portugal / Mediterranean
          'U12'  => 'Gijon',
          'V5'   => 'Braga',
          'V15'  => 'Santander',
          'V17'  => 'Bilbao',
          'W6'   => 'Porto',
          'W18'  => 'Logrono',
          'X11'  => 'Salamanca',
          'X13'  => 'Valladoldid',
          'X25'  => 'Andorra',
          'X33'  => 'Marseille',
          'X35'  => 'Toulon',
          'X37'  => 'Nice',
          'Y14'  => 'Madrid',
          'Y20'  => 'Zaragoza',
          'Z1'   => 'Lisboa',
          'Z3'   => 'Sebutal',
          'Z13'  => 'Toledo',
          'Z25'  => 'Tarragona',
          'Z27'  => 'Barcelona',
          'Z41'  => 'Ajaccio',
          'AA4'  => 'Evora',
          'AA20' => 'Valencia',
          'AB3'  => 'Loule',
          'AB27' => 'Palma',
          'AC8'  => 'Sevilla',
          'AC10' => 'Cordoba',
          'AC12' => 'Granada',
          'AC16' => 'Murcia',
          'AC20' => 'Alicante',
          'AD7'  => 'Gibraltar',
          'AD9'  => 'Malaga',
          'AD13' => 'Almeria',
          'AD15' => 'Lorca',
          'AD17' => 'Cartagena',
          # Scandinavia
          'C48'  => 'Christiania',
          'D57'  => 'Stockholm',
          'F49'  => 'Goteborg',
          'I50'  => 'Kobenhavn',
          # PHS (Prussia / Holland / Switzerland)
          'K46'  => 'Hamburg',
          'L53'  => 'Stettin',
          'M50'  => 'Berlin',
          'N49'  => 'Leipzig',
          'R47'  => 'Breslau',
          # Austria-Hungary
          'R55'  => 'Wien',
          'S60'  => 'Budapest',
          # Italy
          'V41'  => 'Milano',
          'Z47'  => 'Roma',
          'AB51' => 'Napoli',
          # Russia
          'C74'  => 'Sankt-Peterburg',
          'J73'  => 'Minsk',
          'M62'  => 'Warszawa',
          'O80'  => 'Kiev',
          # Constantinople
          'AA82' => 'Constantinople',
        }.freeze

        HEXES = {
          white: {
            %w[
              A42 A66 A68 A70
              B47 B49 B55 B57 B63 B65 B67 B69 B79
              C46 C54 C56 C58 C64 C78 C80
              D45 D55 D69 D71 D73 D75 D77 D79 D83 D85
              E24 E42 E44 E48 E56 E58 E66 E68 E70 E74 E76 E80 E84 E86
              F23 F51 F53 F55 F69 F71 F73 F75 F81 F83 F85
              G16 G18 G20 G46 G50 G52 G54 G56 G68 G70 G72 G76 G78 G80 G82 G84 G86
              H15 H19 H25 H27 H43 H45 H47 H51 H53 H55 H63 H65 H67 H69 H71 H75 H77 H79 H81 H85 H87
              I14 I18 I28 I44 I64 I66 I68 I74 I76 I78 I80 I82
              J13 J19 J45 J67 J69 J75 J77 J79 J81 J83 J85 J87
              K22 K24 K28 K30 K54 K56 K58 K60 K62 K68 K70 K74 K76 K78 K80 K82 K84 K86
              L27 L41 L43 L45 L47 L49 L51 L55 L57 L59 L61 L63 L65 L67 L73 L79 L81 L83 L85 L87
              M22 M24 M40 M42 M44 M46 M48 M52 M54 M56 M58 M60 M64 M66 M68 M70 M82 M84 M86
              N37 N41 N43 N47 N51 N53 N55 N57 N59 N61 N63 N65 N67 N83 N85
              O30 O32 O34 O36 O38 O48 O56 O58 O60 O64 O66 O70 O72 O74 O76 O78 O84 O86
              P21 P23 P25 P27 P31 P35 P39 P43 P47 P49 P51 P53 P59 P61 P63 P65 P67 P69 P71 P73 P75 P77 P79 P81
              Q22 Q24 Q28 Q32 Q34 Q36 Q42 Q44 Q46 Q48 Q54 Q56 Q58 Q66 Q72 Q74 Q76 Q78 Q80 Q82 Q84 Q86
              R25 R27 R31 R33 R35 R37 R41 R43 R45 R49 R53 R57 R59 R63 R65 R67 R73 R75 R77 R79 R81 R83 R85
              S24 S26 S28 S30 S32 S36 S40 S56 S58 S64 S66 S68 S74 S76 S78 S80 S82
              T25 T29 T31 T35 T53 T55 T57 T59 T61 T63 T65 T81
              U6 U8 U22 U26 U28 U48 U50 U54 U56 U58 U60 U62 U64
              V7 V23 V25 V33 V39 V43 V45 V47 V51 V53 V55 V57 V59 V61 V63 V71 V73 V75
              W10 W12 W14 W16 W26 W28 W30 W34 W40 W46 W48 W56 W58 W60 W62 W64 W70 W72 W78
              X5 X9 X17 X21 X29 X43 X49 X55 X75 X77
              Y2 Y4 Y16 Y18 Y22 Y24 Y26 Y44 Y46 Y50 Y56 Y58 Y70 Y72 Y74 Y76
              Z5 Z7 Z9 Z11 Z15 Z17 Z19 Z45 Z51 Z79
              AA2 AA6 AA8 AA14 AA16 AA22 AA48 AA52 AA54 AA62 AA70 AA74 AA76 AA78 AA80 AA84
              AB1 AB5 AB11 AB17 AB39 AB41 AB55 AB57 AB63 AB69
              AC6 AC18 AC38 AC40 AC68 AC78 AC80 AC82 AC84 AC86
              AD5 AD11 AD39 AD67 AD69 AD79 AD85 AD87
              AE72 AE86
              AF49 AF53 AF67 AF81 AF85 AF87
              AG52 AG68
            ] => '',

            # Impassable borders (landtiles_with_borders.csv)
            # Scotland — Highlands barrier
            ['F27'] => 'town=revenue:0;border=edge:0,type:impassable;border=edge:5,type:impassable',
            ['F29'] => 'border=edge:0,type:impassable',
            ['G26'] => 'city=revenue:10;label=Y;upgrade=cost:30,terrain:mountain;border=edge:3,type:impassable',
            ['G28'] => 'border=edge:2,type:impassable;border=edge:3,type:impassable',
            # England — coastal/estuary
            ['L31'] => 'border=edge:0,type:impassable',
            # Channel Islands
            ['M30'] => 'border=edge:3,type:impassable;border=edge:5,type:impassable;upgrade=cost:45,terrain:water',
            # Franco-Belgian border
            ['N31'] => 'city=revenue:20;label=Y;path=a:1,b:_0;border=edge:2,type:impassable',
            # Pyrenees
            ['V19'] => 'border=edge:4,type:impassable;upgrade=cost:30,terrain:mountain',
            ['V21'] => 'town=revenue:0;border=edge:1,type:impassable',
            # Kattegat / Danish straits
            ['K40'] => 'border=edge:4,type:impassable;upgrade=cost:60,terrain:water',
            ['K42'] => 'border=edge:1,type:impassable;upgrade=cost:30,terrain:water',
            # Adriatic — northern entry
            ['AC56'] => 'border=edge:4,type:impassable',
            ['AC58'] => 'border=edge:1,type:impassable',
            # Skagerrak / Norwegian coast
            ['I46'] => 'border=edge:5,type:impassable',
            ['I48'] => 'border=edge:0,type:impassable;upgrade=cost:45,terrain:water',
            ['J47'] => 'border=edge:2,type:impassable;border=edge:3,type:impassable;border=edge:4,type:impassable;border=edge:5,type:impassable;upgrade=cost:60,terrain:water',
            ['J49'] => 'border=edge:0,type:impassable;border=edge:1,type:impassable;border=edge:5,type:impassable;upgrade=cost:60,terrain:water',
            ['K48'] => 'border=edge:2,type:impassable;border=edge:3,type:impassable',
            ['K50'] => 'border=edge:2,type:impassable',
            # North Sea — Danish coast
            ['D47'] => 'border=edge:4,type:impassable;border=edge:5,type:impassable',
            ['D49'] => 'border=edge:1,type:impassable',
            ['D51'] => 'border=edge:5,type:impassable;upgrade=cost:30,terrain:water',
            ['D53'] => 'border=edge:0,type:impassable;upgrade=cost:30,terrain:water',
            ['E52'] => 'border=edge:2,type:impassable;border=edge:3,type:impassable;upgrade=cost:45,terrain:water',
            # Baltic — Gulf of Bothnia entry
            ['C66'] => 'border=edge:5,type:impassable',
            ['D67'] => 'border=edge:2,type:impassable',
            # Norwegian fjord coast
            ['B71'] => 'border=edge:5,type:impassable',
            ['B73'] => 'border=edge:0,type:impassable;upgrade=cost:30,terrain:water',
            ['B75'] => 'border=edge:4,type:impassable',
            ['B77'] => 'border=edge:1,type:impassable;upgrade=cost:45,terrain:water',
            ['C72'] => 'border=edge:2,type:impassable;border=edge:3,type:impassable;upgrade=cost:30,terrain:water',

            # Towns — no terrain
            %w[H17 H29 J17 L29 N33 O24 P19 P29 P33 P37 R29 S34 T27 X35 X37 Z41
               V5 W18 X11 Z3 Z13 Z25 AA4 AB3 AC10 AC12 AC20 AD15] => 'town=revenue:0',
            # Towns — mountain terrain
            %w[G24 I16 I26 U12 V15 AD13] => 'town=revenue:0;upgrade=cost:30,terrain:mountain',
            %w[E26 E28 J23] => 'town=revenue:0;upgrade=cost:45,terrain:mountain',
            ['X25'] => 'town=revenue:0;upgrade=cost:60,terrain:mountain',
            # Towns — water terrain
            %w[L23 AD7] => 'town=revenue:0;upgrade=cost:45,terrain:water',
            # Double towns
            %w[J29 M26 W32] => 'town=revenue:0;town=revenue:0',
            ['T37'] => 'town=revenue:0;town=revenue:0;upgrade=cost:45,terrain:mountain',
            # Cities — no label, no terrain
            %w[F25 H21 J15 L25 Q26 Q38 R23 V27
               C48 F49 K46 L53 N49 R47
               R55 S60 V41 Z47 J73 M62 O80
               Z27 AD17 M50 AB51 C74
               V17 W6 X13 Y20 AA20 AC8 AC16 AB27] => 'city=revenue:0',
            # Cities — label Y
            ['U34'] => 'city=revenue:0;label=Y',
            ['N35'] => 'city=revenue:0;label=Y;upgrade=cost:30,terrain:water',
            # Cities — other labels
            ['K26'] => 'city=revenue:0;label=A',
            ['Q30'] => 'city=revenue:0;label=P',
            # Cities — terrain
            ['Y14'] => 'city=revenue:0;upgrade=cost:45,terrain:mountain',
            ['U32'] => 'city=revenue:0;upgrade=cost:30,terrain:mountain',
            ['AD9'] => 'city=revenue:0;upgrade=cost:30,terrain:mountain',
            ['D57'] => 'city=revenue:0;upgrade=cost:30,terrain:water',
            ['I50'] => 'city=revenue:0;upgrade=cost:45,terrain:water',
            ['AA82'] => 'city=revenue:0;upgrade=cost:45,terrain:water',
            # Cities — pre-printed revenue
            ['U24'] => 'city=revenue:10',
            ['I20'] => 'city=revenue:10;path=a:4,b:_0',
            ['O28'] => 'city=revenue:10;path=a:_0,b:1',
            ['M28'] => 'city=revenue:30;label=L;upgrade=cost:30,terrain:water;path=a:5,b:_0',
            ['X33'] => 'city=revenue:20;label=Y;path=a:_0,b:5',

            # Terrain — water
            ['E78'] => 'upgrade=cost:5,terrain:water',
            %w[C50 C52 D81 E82 F77 F79 G64 G66 G74 H73 I70 I72
               J63 J65 K64 K66 L39 L69 L71 L75 L77
               M36 M38 M72 M74 M76 M78 M80
               N39 N69 N71 N73 N75 N77 N79
               O40 P41 P83 P85 P87
               Q40 Q50 R87 S86
               V77 W74 W76 X69 X71 X73 Y78 Z77 Z23
               AE68 AE70] => 'upgrade=cost:30,terrain:water',
            %w[A72 A74 C42 C76 D41 E50 E54 E72 G44 I52
               K44 L37 N81 O82 S84 Q20
               T75 T77 T79 U76 U78 U80 V79
               AB71 AE52] => 'upgrade=cost:45,terrain:water',
            %w[B81 C82 M34 T23 AB77 AC76 AD71 AG70] => 'upgrade=cost:60,terrain:water',

            # Terrain — mountain
            %w[B51 B53 H83 I84 I86 J71 K72
               O46 O50 O52 O68 P45 P57
               Q70 R39 S42 S50 S62 S70
               T33 T69 U10
               W54 X45 X59 X65
               Z63 Z69 Z73 Z75 AA68
               AB13 AB53 AC64 AC66 AD65 AF69 AG50] => 'upgrade=cost:30,terrain:mountain',
            %w[A48 A50 A52 N45 O42 O44 O62 P55
               Q52 Q60 Q62 Q64 Q68 R51 R61 R69
               S38 S44 S48 T67 T71 T73
               U30 U52 U66 U74
               V9 V13 V29 V35 V65 V69
               W20 W36 W42 W44 W68 X7 X15 X47 X57 X61 X63 X67
               Y6 Y28 Y48 Y62 Y64 Y66 Y68
               Z21 Z49 Z61 Z65 Z71
               AA10 AA12 AA18 AA50 AA64 AA72
               AB7 AB9 AB19 AB65 AB67 AB83 AC14 AC54 AD55 AD81 AD83 AE80 AF83] => 'upgrade=cost:45,terrain:mountain',
            %w[A44 A46 B43 C44 D43
               O54 R71 S46 S52 S54 S72
               T49 T51 U36 U40 U42 U46
               U68 U70 U72 V11 V31 V37 V67
               W8 W24 W38 W66
               X19 X27 Y8 Y10 Y12 Y60 Z67
               AA66 AA86
               AB15 AB85 AE82 AE84 AF51] => 'upgrade=cost:60,terrain:mountain',
            %w[B45 T39 T41 T43 T45 T47 U38 U44 W22 X23] => 'upgrade=cost:120,terrain:mountain',
          },
          yellow: {
            ['J25'] => 'city=revenue:30;label=Y;path=a:2,b:_0;path=a:_0,b:4',
            ['J27'] => 'city=revenue:20;upgrade=cost:30,terrain:mountain;path=a:1,b:_0;path=a:_0,b:4',
          },
          red: {
            ['D25']  => 'offboard=revenue:0;path=a:0,b:_0',                          # Scottish Highlands
            ['A40']  => 'offboard=revenue:0;path=a:0,b:_0',                          # Norwegian Coast (to Narvik)
            ['B41']  => 'offboard=revenue:0;path=a:0,b:_0',                          # Norwegian Coast (to Narvik)
            ['A54']  => 'offboard=revenue:0;path=a:0,b:_0',                          # North Sweden
            ['A56']  => 'offboard=revenue:0;path=a:0,b:_0',                          # North Sweden
            ['B83']  => 'offboard=revenue:0;path=a:0,b:_0',                          # Arkhangelsk
            ['E88']  => 'offboard=revenue:0;path=a:0,b:_0',                          # Moskva
            ['F87']  => 'offboard=revenue:0;path=a:0,b:_0',                          # Moskva
            ['G88']  => 'offboard=revenue:0;path=a:0,b:_0',                          # Moskva
            ['N1']   => 'offboard=revenue:0;path=a:0,b:_0',                          # New York
            ['N87']  => 'offboard=revenue:0;path=a:0,b:_0',                          # Kharkov
            ['S88']  => 'offboard=revenue:0;path=a:0,b:_0',                          # Sevastopol
            ['T87']  => 'offboard=revenue:0;path=a:0,b:_0',                          # Sevastopol
            ['Z1']   => 'offboard=revenue:0;city=revenue:0;city=revenue:0;path=a:0,b:_0', # Lisboa (2 station slots; RCP home)
            ['AB87'] => 'offboard=revenue:0;path=a:0,b:_0',                          # Levant
            ['AD1']  => 'offboard=revenue:0;path=a:0,b:_0',                          # North Africa & The Americas
            ['AF5']  => 'offboard=revenue:0;path=a:0,b:_0',                          # Casablanca
            ['AF11'] => 'offboard=revenue:0;path=a:0,b:_0',                          # Melilla
            ['AF25'] => 'offboard=revenue:0;path=a:0,b:_0',                          # Alger
            ['AG40'] => 'offboard=revenue:0;path=a:0,b:_0',                          # Tunis
            ['AG88'] => 'offboard=revenue:0;path=a:0,b:_0',                          # Alexandria & Suez
            ['AH87'] => 'offboard=revenue:0;path=a:0,b:_0',                          # Alexandria & Suez
          },
          blue: {},
        }.freeze
      end
    end
  end
end
