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
          'E26' => 'Inverness',
          'E28' => 'Aberdeen',
          'F25' => 'Glasgow',
          'F27' => 'Dundee',
          'G24' => 'Stranraer',
          'G26' => 'Edinburgh',
          'H17' => 'Sligo',
          'H21' => 'Belfast',
          'H29' => 'Newcastle Upon Tyne',
          'I16' => 'Limerick',
          'I20' => 'Dublin',
          'I26' => 'Preston',
          'J15' => 'Cork',
          'J17' => 'Waterford',
          'J23' => 'Holyhead',
          'J25' => 'Liverpool',
          'J27' => 'Manchester',
          'J29' => 'Leeds and Sheffield',
          'K26' => 'Birmingham',
          'L23' => 'Cardiff',
          'L25' => 'Bristol',
          'L29' => 'Cambridge',
          'M26' => 'Southampton and Portsmouth',
          'M28' => 'London',
          # France / Belgium
          'N31' => 'Lille',
          'N33' => 'Gent',
          'N35' => 'Brussel',
          'O24' => 'Cherbourg',
          'O28' => 'Le Havre',
          'P19' => 'Brest',
          'P29' => 'Rouen',
          'P33' => 'Reims',
          'P37' => 'Luxembourg',
          'Q26' => 'Le Mans',
          'Q30' => 'Paris',
          'Q38' => 'Nancy',
          'R23' => 'Nantes',
          'R29' => 'Orleans',
          'S34' => 'Dijon',
          'T27' => 'Limoges',
          'T37' => 'Geneve and Lausanne',
          'U24' => 'Bordeaux',
          'U32' => 'Saint-Etienne',
          'U34' => 'Lyon',
          'V21' => 'Bayonne',
          'V27' => 'Toulouse',
          'W32' => 'Nimes and Montpellier',
          # Spain / Portugal / Mediterranean
          'U12' => 'Gijon',
          'V5' => 'Braga',
          'V15' => 'Santander',
          'V17' => 'Bilbao',
          'W6' => 'Porto',
          'W18' => 'Logrono',
          'X11' => 'Salamanca',
          'X13' => 'Valladoldid',
          'X25' => 'Andorra',
          'X33' => 'Marseille',
          'X35' => 'Toulon',
          'X37' => 'Nice',
          'Y14' => 'Madrid',
          'Y20' => 'Zaragoza',
          'Z1' => 'Lisboa',
          'Z3' => 'Sebutal',
          'Z13' => 'Toledo',
          'Z25' => 'Tarragona',
          'Z27' => 'Barcelona',
          'Z41' => 'Ajaccio',
          'AA4' => 'Evora',
          'AA20' => 'Valencia',
          'AB3' => 'Loule',
          'AB27' => 'Palma',
          'AC8' => 'Sevilla',
          'AC10' => 'Cordoba',
          'AC12' => 'Granada',
          'AC16' => 'Murcia',
          'AC20' => 'Alicante',
          'AD7' => 'Gibraltar',
          'AD9' => 'Malaga',
          'AD13' => 'Almeria',
          'AD15' => 'Lorca',
          'AD17' => 'Cartagena',
          'U6' => 'A Coruña',
          'AC6' => 'Jerez de la Frontera and Cadiz',
          # Scandinavia
          'C48' => 'Christiania',
          'D57' => 'Stockholm',
          'F49' => 'Goteborg',
          'I50' => 'Kobenhavn',
          'B43' => 'Voss',
          'C58' => 'Gavle and Upsala',
          'D41' => 'Stavanger',
          'D47' => 'Larvik',
          'D51' => 'Karlstad',
          'D53' => 'Örebro',
          'E44' => 'Kristianssand',
          'E56' => 'Norrköping',
          'F53' => 'Jönköping',
          'G46' => 'Aalborg',
          'H47' => 'Aarhus',
          'H51' => 'Halmstad',
          'H55' => 'Karlskrona',
          'I46' => 'Odense',
          'I52' => 'Malmö',
          # PHS (Prussia / Holland / Switzerland)
          'K46' => 'Hamburg',
          'L53' => 'Stettin',
          'M50' => 'Berlin',
          'N49' => 'Leipzig',
          'R47' => 'Breslau',
          'J63' => 'Königsberg',
          'K60' => 'Danzig',
          'K62' => 'Elbing',
          'L37' => 'Amsterdam',
          'L39' => 'Leeuwarden and Groningen',
          'L43' => 'Bremen',
          'M36' => 'Rotterdam',
          'M38' => 'Utrecht',
          'M44' => 'Hannover',
          'M48' => 'Magdeburg',
          'M56' => 'Posen',
          'N41' => 'Barmen and Elberfeld',
          'O40' => 'Köln',
          'O52' => 'Dresden',
          'O56' => 'Breslau',
          'P43' => 'Frankfurt',
          'Q40' => 'Straßburg',
          'Q46' => 'Fürth and Nürnberg',
          'S40' => 'Basel',
          'S42' => 'Zürich',
          'T39' => 'Bern',
          # Austria-Hungary
          'R55' => 'Wien',
          'S60' => 'Budapest',
          'P53' => 'Praha',
          'P61' => 'Krakau',
          'P69' => 'Lemberg',
          'Q52' => 'Pizen',
          'Q56' => 'Brno',
          'Q72' => 'Ternopol',
          'R53' => 'Linz',
          'R59' => 'Preßburg',
          'R67' => 'Kosice',
          'S46' => 'Innsbruck',
          'S50' => 'Salzburg',
          'S68' => 'Debrecen',
          'T53' => 'Graz',
          'T61' => 'Kecskemet',
          'T69' => 'Klausenburg',
          'U52' => 'Laibach',
          'U56' => 'Csaktornya',
          'U62' => 'Szeged',
          'U64' => 'Arad and Temesvar',
          'U72' => 'Kronstadt',
          # Italy
          'V41' => 'Milano',
          'Z47' => 'Roma',
          'AB51' => 'Napoli',
          'V39' => 'Torino',
          'V45' => 'Verona',
          'V47' => 'Venezia',
          'V51' => 'Trieste',
          'W40' => 'Genova',
          'W46' => 'Ferrara and Bologna',
          'X45' => 'Firenze',
          'Y44' => 'Livorno',
          'AA52' => 'Benevento',
          'AB39' => 'Sassari',
          'AB55' => 'Bari',
          'AB57' => 'Brindisi',
          'AC40' => 'Cagliari',
          'AF49' => 'Palermo',
          'AF53' => 'Messina and Catania',
          # Russia
          'C74' => 'Sankt-Peterburg',
          'J73' => 'Minsk',
          'M62' => 'Warszawa',
          'O80' => 'Kiev',
          'B67' => 'Helsinki',
          'B73' => 'Vyborg',
          'C64' => 'Turku',
          'D69' => 'Reval',
          'D75' => 'Luga',
          'D77' => 'Veliky Novgorod',
          'D81' => 'Vyshny Volochyok',
          'D83' => 'Tver',
          'E70' => 'Dorpat',
          'F73' => 'Pskov',
          'G68' => 'Riga',
          'G84' => 'Vyazma',
          'H63' => 'Libavo',
          'H71' => 'Dvinsk',
          'H85' => 'Kaluga',
          'H87' => 'Tula',
          'I66' => 'Kovno',
          'I76' => 'Vitsyebsk',
          'I80' => 'Smolensk',
          'J69' => 'Vilna',
          'J77' => 'Orsha and Mogilyov',
          'K68' => 'Grodno',
          'K78' => 'Bobruisk',
          'K86' => 'Orel',
          'L79' => 'Gomel',
          'L87' => 'Kursk',
          'M68' => 'Brest-Litovsk',
          'M72' => 'Pinsk',
          'N59' => 'Lodz',
          'N65' => 'Lublin',
          'N83' => 'Nezin',
          'P77' => 'Zytomir and Berdichev',
          'P85' => 'Krementchug',
          'Q84' => 'Elisavetgrad',
          'S76' => 'Jassy',
          'S78' => 'Kischinev',
          'S84' => 'Nikolayev',
          'S86' => 'Kherson',
          'T81' => 'Odessa',
          'U78' => 'Galatz',
          'U80' => 'Akkerman',
          'V73' => 'Ploesti',
          # Balkans
          'V55' => 'Zagreb',
          'W64' => 'Beograd',
          'W70' => 'Craiova',
          'W74' => 'Bucharest',
          'X55' => 'Spalato',
          'X59' => 'Sarajevo',
          'Y64' => 'Novi Bazar',
          'Y66' => 'Niš',
          'Y70' => 'Sofia',
          'Z73' => 'Philippopolis',
          'AA62' => 'Shkoder',
          'AA84' => 'Scutari',
          'AB69' => 'Salonica',
          'AC64' => 'Ioannina',
          'AC68' => 'Larissa',
          # Turkey / Greece
          'AB83' => 'Bursa',
          'AC84' => 'Eskisehir',
          'AD79' => 'Smyrna',
          'AE68' => 'Patra',
          'AE72' => 'Athinai',
          'AF87' => 'Adalia',
          'AG68' => 'Sparti',
          # Constantinople
          'AA82' => 'Constantinople',
          # Red Offboard Locations
          'A40' => 'Norwegian Coast (to Narvik)',
          'A54' => 'North Sweden',
          'A56' => 'North Sweden',
          'B41' => 'Bergen',
          'B83' => 'Arkhangelsk',
          'D25' => 'Scottish Highlands',
          'E88' => 'Moskva',
          'F87' => 'Moskva',
          'G88' => 'Moskva',
          'N1' => 'New York',
          'N87' => 'Kharkov',
          'S88' => 'Sevastopol',
          'T87' => 'Sevastopol',
          'AB87' => 'Levant',
          'AD1' => 'North Africa & The Americas',
          'AF5' => 'Casablanca',
          'AF11' => 'Melilla',
          'AF25' => 'Alger',
          'AG40' => 'Tunis',
          'AG88' => 'Alexandria & Suez',
          'AH87' => 'Alexandria & Suez',
        }.freeze

        HEXES = {
          white: {
            %w[
              A42 A66 A68 A70 B47 B49 B55 B57 B63 B65 B69 B79
              C46 C54 C56 C78 C80 D45 D55 D71 D73 D79 D85 E24
              E42 E48 E58 E66 E68 E74 E76 E80 E84 E86 F23 F51
              F55 F69 F71 F75 F81 F83 F85 G16 G18 G20 G50 G52
              G54 G56 G70 G72 G76 G78 G80 G82 G86 H15 H19 H25
              H27 H43 H45 H53 H65 H67 H69 H75 H77 H79 H81 I14
              I18 I28 I44 I64 I68 I74 I78 I82 J13 J19 J45 J67
              J75 J79 J81 J83 J85 J87 K22 K24 K28 K30 K54 K56
              K58 K70 K74 K76 K80 K82 K84 L27 L41 L45 L47 L49
              L51 L55 L57 L59 L61 L63 L65 L67 L73 L81 L83 L85
              M22 M24 M40 M42 M46 M52 M54 M58 M60 M64 M66 M70
              M82 M84 M86 N37 N43 N47 N51 N53 N55 N57 N61 N63
              N67 N85 O30 O32 O34 O36 O38 O48 O58 O60 O64 O66
              O70 O72 O74 O76 O78 O84 O86 P21 P23 P25 P27 P31
              P35 P39 P47 P49 P51 P59 P63 P65 P67 P71 P73 P75
              P79 P81 Q22 Q24 Q28 Q32 Q34 Q36 Q42 Q44 Q48 Q54
              Q58 Q66 Q74 Q76 Q78 Q80 Q82 Q86 R25 R27 R31 R33
              R35 R37 R41 R43 R45 R49 R57 R63 R65 R73 R75 R77
              R79 R81 R83 R85 S24 S26 S28 S30 S32 S36 S56 S58
              S64 S66 S74 S80 S82 T25 T29 T31 T35 T55 T57 T59
              T63 T65 U8 U22 U26 U28 U48 U50 U54 U58 U60 V7
              V23 V25 V33 V43 V53 V57 V59 V61 V63 V71 V75 W10
              W12 W14 W16 W26 W28 W30 W34 W48 W56 W58 W60 W62
              W72 W78 X5 X9 X17 X21 X29 X43 X49 X75 X77 Y2
              Y4 Y16 Y18 Y22 Y24 Y26 Y46 Y50 Y56 Y58 Y72 Y74
              Y76 Z5 Z7 Z9 Z11 Z15 Z17 Z19 Z45 Z51 Z79 AA2
              AA6 AA8 AA14 AA16 AA22 AA48 AA54 AA70 AA74 AA76 AA78 AA80
              AB1 AB5 AB11 AB17 AB41 AB63 AC18 AC38 AC78 AC80 AC82 AC86
              AD5 AD11 AD39 AD67 AD69 AD85 AD87 AE86 AF67 AF81 AF85 AG52
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
            ['I46'] => 'town=revenue:0;town=revenue:0;border=edge:5,type:impassable',
            ['I48'] => 'border=edge:0,type:impassable;upgrade=cost:45,terrain:water',
            ['J47'] => 'border=edge:2,type:impassable;border=edge:3,type:impassable;' \
                       'border=edge:4,type:impassable;border=edge:5,type:impassable;upgrade=cost:60,terrain:water',
            ['J49'] => 'border=edge:0,type:impassable;border=edge:1,type:impassable;' \
                       'border=edge:5,type:impassable;upgrade=cost:60,terrain:water',
            ['K48'] => 'border=edge:2,type:impassable;border=edge:3,type:impassable',
            ['K50'] => 'border=edge:2,type:impassable',
            # North Sea — Danish coast
            ['D47'] => 'town=revenue:0;town=revenue:0;border=edge:4,type:impassable;border=edge:5,type:impassable',
            ['D49'] => 'border=edge:1,type:impassable',
            ['D51'] => 'town=revenue:0;town=revenue:0;border=edge:5,type:impassable;upgrade=cost:30,terrain:water',
            ['D53'] => 'town=revenue:0;town=revenue:0;border=edge:0,type:impassable;upgrade=cost:30,terrain:water',
            ['E52'] => 'border=edge:2,type:impassable;border=edge:3,type:impassable;upgrade=cost:45,terrain:water',
            # Baltic — Gulf of Bothnia entry
            ['C66'] => 'border=edge:5,type:impassable',
            ['D67'] => 'border=edge:2,type:impassable',
            # Norwegian fjord coast
            ['B71'] => 'border=edge:5,type:impassable',
            ['B73'] => 'town=revenue:0;border=edge:0,type:impassable;upgrade=cost:30,terrain:water',
            ['B75'] => 'border=edge:4,type:impassable',
            ['B77'] => 'border=edge:1,type:impassable;upgrade=cost:45,terrain:water',
            ['C72'] => 'border=edge:2,type:impassable;border=edge:3,type:impassable;upgrade=cost:30,terrain:water',

            # Towns — no terrain
            %w[H17 H29 J17 L29 N33 O24 P19 P29 P33 P37 R29 S34 T27 X35 X37 Z41
               V5 V21 W18 X11 Z3 Z13 Z25 AA4 AB3 AC10 AC12 AC20 AD15
               K60 K62 L43 M48 M56 P43 P61 Q56 Q72
               R53 R59 R67 S40 S68 T61 U56 U62 X55
               V45 V47 Y44 AA52 AB39 AB55
               C64 D69 D75 D83 E70 F73 G84 H71 H85
               I66 I80 K68 L79 L87 N59 N65 N83 Q84
               V73 W70 AA84 AC68 AC84 AG68 AF87] => 'town=revenue:0',
            # Towns — mountain terrain
            %w[G24 I16 I26 U12 V15 AD13] => 'town=revenue:0;upgrade=cost:30,terrain:mountain',
            %w[E26 E28 J23] => 'town=revenue:0;upgrade=cost:45,terrain:mountain',
            ['X25'] => 'town=revenue:0;upgrade=cost:60,terrain:mountain',
            # Towns — water terrain
            %w[L23 AD7] => 'town=revenue:0;upgrade=cost:45,terrain:water',
            # Double towns
            %w[J29 M26 W32
               C58 E44 F53 G46 H51 H55
               N41 Q46 U64 W46 AF53
               J77 P77
               AC6 U6] => 'town=revenue:0;town=revenue:0',
            ['T37'] => 'town=revenue:0;town=revenue:0;upgrade=cost:45,terrain:mountain',
            # Cities — no label, no terrain
            %w[ H21 J15 L25 Q26 Q38 R23 V27
                C48 F49 L53 N49 J73 AD17
                V17 W6 X13 Y20 AA20 AC8 AC16 AB27] => 'city=revenue:0',
            # Cities — no terrain (added station geometry)
            %w[ AA62 AB57 AB69 AC40 AD79
                AE72 AF49 B67 D77 E56 G68 H47 H63 H87 I76 J69 K78
                K86 M44 M68
                O56 P69 S76 S78 T53 T81
                V39 V51 V55 W40 W64
                Y70] => 'city=revenue:0',
            # Cities — label Y
            ['U34'] => 'city=revenue:0;label=Y',
            ['N35'] => 'city=revenue:0;label=Y;upgrade=cost:30,terrain:water',
            # Cities — other labels
            ['K26'] => 'city=revenue:0;label=A',
            ['Q30'] => 'city=revenue:0;label=P',
            # Cities — terrain
            ['Y14'] => 'city=revenue:0;label=A;upgrade=cost:45,terrain:mountain',
            ['U32'] => 'city=revenue:0;upgrade=cost:30,terrain:mountain',
            ['AD9'] => 'city=revenue:0;upgrade=cost:30,terrain:mountain',
            ['D57'] => 'city=revenue:0;upgrade=cost:30,terrain:water',
            ['I50'] => 'city=revenue:0;label=Y;upgrade=cost:45,terrain:water',
            ['AA82'] => 'city=revenue:30;city=revenue:30;upgrade=cost:45,terrain:water;label=C',
            # Cities — pre-printed revenue
            ['U24'] => 'city=revenue:10',
            ['I20'] => 'city=revenue:10;path=a:4,b:_0',
            ['O28'] => 'city=revenue:10;path=a:_0,b:1',
            ['M28'] => 'city=revenue:30;label=L;upgrade=cost:30,terrain:water;path=a:5,b:_0',
            ['X33'] => 'city=revenue:20;label=Y;path=a:_0,b:5',

            ['F25'] => 'city=revenue:0;label=Y',
            ['Z27'] => 'city=revenue:0;label=Y',
            ['K46'] => 'city=revenue:0;label=Y',
            ['M50'] => 'city=revenue:0;label=B',
            ['R47'] => 'city=revenue:0;label=Y',
            ['R55'] => 'city=revenue:0;label=A',
            ['S60'] => 'city=revenue:0;label=Y',
            ['P53'] => 'city=revenue:0;label=Y',
            ['V41'] => 'city=revenue:0;label=Y',
            ['Z47'] => 'city=revenue:0;label=Y',
            ['AB51'] => 'city=revenue:0;label=N',
            ['C74'] => 'city=revenue:0;label=S',
            ['M62'] => 'city=revenue:0;label=Y',
            ['O80'] => 'city=revenue:0;label=Y',
            # Cities — water terrain
            ['AE68'] => 'town=revenue:0;upgrade=cost:30,terrain:water',
            ['D41'] => 'town=revenue:0;town=revenue:0;upgrade=cost:45,terrain:water',
            ['D81'] => 'town=revenue:0;upgrade=cost:30,terrain:water',
            ['I52'] => 'city=revenue:0;upgrade=cost:45,terrain:water',
            ['J63'] => 'city=revenue:0;label=Y;upgrade=cost:30,terrain:water',
            ['L37'] => 'city=revenue:0;label=Y;upgrade=cost:45,terrain:water',
            ['L39'] => 'town=revenue:0;town=revenue:0;upgrade=cost:30,terrain:water',
            ['M36'] => 'city=revenue:0;upgrade=cost:30,terrain:water',
            ['M38'] => 'town=revenue:0;upgrade=cost:30,terrain:water',
            ['M72'] => 'town=revenue:0;upgrade=cost:30,terrain:water',
            ['O40'] => 'city=revenue:0;label=Y;upgrade=cost:30,terrain:water',
            ['P85'] => 'town=revenue:0;upgrade=cost:30,terrain:water',
            ['Q40'] => 'city=revenue:0;upgrade=cost:30,terrain:water',
            ['S84'] => 'town=revenue:0;upgrade=cost:45,terrain:water',
            ['S86'] => 'town=revenue:0;upgrade=cost:30,terrain:water',
            ['U78'] => 'town=revenue:0;upgrade=cost:45,terrain:water',
            ['U80'] => 'town=revenue:0;upgrade=cost:45,terrain:water',
            ['W74'] => 'city=revenue:0;label=Y;upgrade=cost:30,terrain:water',
            # Cities — mountain terrain
            ['AB83'] => 'town=revenue:0;upgrade=cost:45,terrain:mountain',
            ['AC64'] => 'town=revenue:0;upgrade=cost:30,terrain:mountain',
            ['B43'] => 'town=revenue:0;upgrade=cost:60,terrain:mountain',
            ['O52'] => 'city=revenue:0;upgrade=cost:30,terrain:mountain',
            ['Q52'] => 'town=revenue:0;upgrade=cost:45,terrain:mountain',
            ['S42'] => 'city=revenue:0;upgrade=cost:30,terrain:mountain',
            ['S46'] => 'town=revenue:0;upgrade=cost:60,terrain:mountain',
            ['S50'] => 'city=revenue:0;upgrade=cost:30,terrain:mountain',
            ['T39'] => 'town=revenue:0;upgrade=cost:120,terrain:mountain',
            ['T69'] => 'city=revenue:0;upgrade=cost:30,terrain:mountain',
            ['U52'] => 'town=revenue:0;upgrade=cost:45,terrain:mountain',
            ['U72'] => 'town=revenue:0;upgrade=cost:45,terrain:mountain',
            ['X45'] => 'city=revenue:0;label=Y;upgrade=cost:45,terrain:mountain',
            ['X59'] => 'town=revenue:0;upgrade=cost:30,terrain:mountain',
            ['Y64'] => 'town=revenue:0;upgrade=cost:45,terrain:mountain',
            ['Y66'] => 'town=revenue:0;upgrade=cost:45,terrain:mountain',
            ['Z73'] => 'town=revenue:0;upgrade=cost:30,terrain:mountain',

            # Terrain — water
            ['E78'] => 'upgrade=cost:5,terrain:water',
            %w[C50 C52 E82 F77 F79 G64 G66 G74 H73 I70 I72 J65 K64 K66 L69 L71 L75 L77 M74 M76 M78 M80
               N39 N69 N71 N73 N75 N77 N79 P41 P83 P87 Q50 R87
               V77 W76 X69 X71 X73 Y78 Z77 Z23 AE70] => 'upgrade=cost:30,terrain:water',
            %w[A72 A74 C42 C76 E50 E54 E72 G44
               K44 N81 O82 Q20
               T75 T77 T79 U76 V79
               AB71 AE52] => 'upgrade=cost:45,terrain:water',
            %w[B81 C82 M34 T23 AB77 AC76 AD71 AG70] => 'upgrade=cost:60,terrain:water',

            # Terrain — mountain
            %w[B51 B53 H83 I84 I86 J71 K72
               O46 O50 O68 P45 P57
               Q70 R39 S62 S70
               T33 U10
               W54 X65
               Z63 Z69 Z75 AA68
               AB13 AB53 AC66 AD65 AF69 AG50] => 'upgrade=cost:30,terrain:mountain',
            %w[A48 A50 A52 N45 O42 O44 O62 P55 Q60 Q62 Q64 Q68 R51 R61 R69
               S38 S44 S48 T67 T71 T73
               U30 U66 U74
               V9 V13 V29 V35 V65 V69
               W20 W36 W42 W44 W68 X7 X15 X47 X57 X61 X63 X67
               Y6 Y28 Y48 Y62 Y68
               Z21 Z49 Z61 Z65 Z71
               AA10 AA12 AA18 AA50 AA64 AA72
               AB7 AB9 AB19 AB65 AB67 AC14 AC54 AD55 AD81 AD83 AE80 AF83] => 'upgrade=cost:45,terrain:mountain',
            %w[A44 A46 C44 D43
               O54 R71 S52 S54 S72
               T49 T51 U36 U40 U42 U46
               U68 U70 V11 V31 V37 V67
               W8 W24 W38 W66
               X19 X27 Y8 Y10 Y12 Y60 Z67
               AA66 AA86
               AB15 AB85 AE82 AE84 AF51] => 'upgrade=cost:60,terrain:mountain',
            %w[B45 T41 T43 T45 T47 U38 U44 W22 X23] => 'upgrade=cost:120,terrain:mountain',
          },
          yellow: {
            ['J25'] => 'city=revenue:30;label=Y;path=a:2,b:_0;path=a:_0,b:4',
            ['J27'] => 'city=revenue:20;upgrade=cost:30,terrain:mountain;path=a:1,b:_0;path=a:_0,b:4',
          },
          red: {
            ['D25'] => 'offboard=revenue:0;path=a:0,b:_0',                          # Scottish Highlands
            ['A40'] => 'offboard=revenue:0;path=a:0,b:_0',                          # Norwegian Coast (to Narvik)
            ['B41'] => 'offboard=revenue:0;path=a:0,b:_0',                          # Bergen
            ['A54'] => 'offboard=revenue:0;path=a:0,b:_0',                          # North Sweden
            ['A56'] => 'offboard=revenue:0;path=a:0,b:_0',                          # North Sweden
            ['B83'] => 'offboard=revenue:0;path=a:0,b:_0',                          # Arkhangelsk
            ['E88'] => 'offboard=revenue:0;path=a:0,b:_0',                          # Moskva
            ['F87'] => 'offboard=revenue:0;path=a:0,b:_0',                          # Moskva
            ['G88'] => 'offboard=revenue:0;path=a:0,b:_0',                          # Moskva
            ['N1'] => 'offboard=revenue:0;path=a:0,b:_0', # New York
            ['N87'] => 'offboard=revenue:0;path=a:0,b:_0',                          # Kharkov
            ['S88'] => 'offboard=revenue:0;path=a:0,b:_0',                          # Sevastopol
            ['T87'] => 'offboard=revenue:0;path=a:0,b:_0',                          # Sevastopol
            ['Z1'] => 'offboard=revenue:0;city=revenue:0;city=revenue:0;path=a:0,b:_0', # Lisboa (2 station slots; RCP home)
            ['AB87'] => 'offboard=revenue:0;path=a:0,b:_0', # Levant
            ['AD1'] => 'offboard=revenue:0;path=a:0,b:_0',                          # North Africa & The Americas
            ['AF5'] => 'offboard=revenue:0;path=a:0,b:_0',                          # Casablanca
            ['AF11'] => 'offboard=revenue:0;path=a:0,b:_0',                          # Melilla
            ['AF25'] => 'offboard=revenue:0;path=a:0,b:_0',                          # Alger
            ['AG40'] => 'offboard=revenue:0;path=a:0,b:_0',                          # Tunis
            ['AG88'] => 'offboard=revenue:0;path=a:0,b:_0',                          # Alexandria & Suez
            ['AH87'] => 'offboard=revenue:0;path=a:0,b:_0',                          # Alexandria & Suez
          },
          blue: {
            %w[
              A0 A2 A4 A6 A8 A10 A12 A14 A16 A18 A20 A22
              A24 A26 A28 A30 A32 A34 A36 A38 A58 A60 A62 A64
              B1 B3 B5 B7 B9
              B11 B13 B15 B17 B19 B21 B23 B25 B27 B29 B31 B33
              B35 B37 B39 B59 B61 C0 C2 C4 C6 C8
              C10 C12 C14 C16 C18 C20 C22 C24 C26 C28 C30 C32
              C34 C36 C38 C40 C60 C62 C68 C70 D1
              D3 D5 D7 D9 D11 D13 D15 D17 D19 D21 D23 D27
              D29 D31 D33 D35 D37 D39 D59 D61 D63 D65 E0
              E2 E4 E6 E8 E10 E12 E14 E16 E18 E20 E22 E30
              E32 E34 E36 E38 E40 E46 E60 E62 E64 F1 F3 F5
              F7 F9 F11 F13 F15 F17 F19 F21 F31 F33 F35 F37
              F39 F41 F43 F45 F47 F57 F59 F61 F63 F65 F67 G0
              G2 G4 G6 G8 G10 G12 G14 G22 G30 G32 G34 G36
              G38 G40 G42 G48 G58 G60 G62 H1 H3 H5 H7 H9
              H11 H13 H23 H31 H33 H35 H37 H39 H41 H49 H57 H59
              H61 I0 I2 I4 I6 I8 I10 I12 I22 I24 I30 I32
              I34 I36 I38 I40 I42 I54 I56 I58 I60 I62 J1
              J3 J5 J7 J9 J11 J21 J31 J33 J35 J37 J39 J41
              J43 J51 J53 J55 J57 J59 J61 K0 K2 K4 K6 K8
              K10 K12 K14 K16 K18 K20 K32 K34 K36 K38 K52
              L1 L3 L5 L7 L9 L11 L13 L15 L17 L19 L21 L33
              L35 M0 M2 M4 M6 M8 M10 M12 M14 M16 M18 M20
              M32 N3 N5 N7 N9 N11 N13 N15 N17 N19 N21
              N23 N25 N27 N29 O0 O2 O4 O6 O8 O10 O12 O14
              O16 O18 O20 O22 O26 P1 P3 P5 P7 P9 P11
              P13 P15 P17 Q0 Q2 Q4 Q6 Q8 Q10 Q12 Q14 Q16
              Q18 R1 R3 R5 R7 R9 R11 R13 R15 R17 R19
              R21 S0 S2 S4 S6 S8 S10 S12 S14 S16 S18 S20
              S22 T1 T3 T5 T7 T9 T11 T13 T15 T17 T19 T21
              T83 T85 U0 U2 U4 U14 U16 U18 U20 U82 U84 U86
              U88 V1 V3 V49 V81 V83 V85 V87 W0 W2 W4 W50
              W52 W80 W82 W84 W86 W88 X1 X3 X31 X39 X41 X51
              X53 X79 X81 X83 X85 X87 Y0 Y30 Y32 Y34 Y36 Y38
              Y40 Y42 Y52 Y54 Y80 Y82 Y84 Y86 Y88 Z29 Z31 Z33
              Z35 Z37 Z39 Z43 Z53 Z55 Z57 Z59 Z81 Z83 Z85 Z87
              AA0 AA24 AA26 AA28 AA30 AA32 AA34 AA36 AA38 AA40 AA42 AA44
              AA46 AA56 AA58 AA60 AA88 AB21 AB23 AB25 AB29 AB31 AB33 AB35
              AB37 AB43 AB45 AB47 AB49 AB59 AB61 AB73 AB75 AB79 AB81 AC0
              AC2 AC4 AC22 AC24 AC26 AC28 AC30 AC32 AC34 AC36 AC42 AC44
              AC46 AC48 AC50 AC52 AC60 AC62 AC70 AC72 AC74 AD3 AD19
              AD21 AD23 AD25 AD27 AD29 AD31 AD33 AD35 AD37 AD41 AD43 AD45
              AD47 AD49 AD51 AD53 AD57 AD59 AD61 AD63 AD73 AD75 AD77 AE0
              AE2 AE4 AE6 AE8 AE10 AE12 AE14 AE16 AE18 AE20 AE22 AE24
              AE26 AE28 AE30 AE32 AE34 AE36 AE38 AE40 AE42 AE44 AE46 AE48
              AE50 AE54 AE56 AE58 AE60 AE62 AE64 AE66 AE74 AE76 AE78
              AF1 AF3 AF7 AF9 AF13 AF15 AF17 AF19 AF21 AF23 AF27 AF29
              AF31 AF33 AF35 AF37 AF39 AF41 AF43 AF45 AF47 AF55 AF57 AF59
              AF61 AF63 AF65 AF71 AF73 AF75 AF77 AF79 AG0 AG2 AG4 AG6
              AG8 AG10 AG12 AG14 AG16 AG18 AG20 AG22 AG24 AG26 AG28 AG30
              AG32 AG34 AG36 AG38 AG42 AG44 AG46 AG48 AG54 AG56 AG58 AG60
              AG62 AG64 AG66 AG72 AG74 AG76 AG78 AG80 AG82 AG84 AG86 AH1
              AH3 AH5 AH7 AH9 AH11 AH13 AH15 AH17 AH19 AH21 AH23 AH25
              AH27 AH29 AH31 AH33 AH35 AH37 AH39 AH41 AH43 AH45 AH47 AH49
              AH51 AH53 AH55 AH57 AH59 AH61 AH63 AH65 AH67 AH69 AH71 AH73
              AH75 AH77 AH79 AH81 AH83 AH85
              ] => '',
          },
        }.freeze
      end
    end
  end
end
