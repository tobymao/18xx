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
          'A56' => 'North Sweden',
          'A64' => 'Finland',
          'B41' => 'Bergen',
          'B83' => 'Arkhangelsk',
          'D25' => 'Scottish Highlands',
          'F87' => 'Moskva',
          'N1' => 'New York',
          'N87' => 'Kharkov',
          'T87' => 'Sevastopol',
          'AB87' => 'Levant',
          'AD1' => 'North Africa & The Americas',
          'AF5' => 'Casablanca',
          'AF11' => 'Melilla',
          'AF25' => 'Alger',
          'AG40' => 'Tunis',
          'AG88' => 'Alexandria & Suez',
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
              I18 I28 I68 I74 I78 I82 J13 J19 J75 J79 J81
              J83 J85 J87 K22 K24 K28 K30 K54 K56 K58 K70 K74
              K76 K80 K82 K84 L27 L41 L45 L47 L49 L51 L55 L57
              L65 L67 L73 L81 L83 L85 M22 M24 M40 M42 M46
              M52 M54 M64 M66 M70 M82 M84 M86 N43 N47
              N51 N53 N55 N61 N63 N67 N85 O30 O32 O34 O36
              O48 O74 O76 O78 O84 O86 P21 P23 P25 P27 P31
              P35 P47 P75 P79 P81 Q22 Q24 Q28 Q32 Q34
              Q36 Q42 Q44 Q48 Q54 Q58 Q66 Q76 Q78 Q80 Q82
              Q86 R25 R27 R31 R33 R35 R37 R41 R43 R45 R57 R63
              R65 R77 R79 R81 R83 R85 S24 S26 S28 S30 S32 S36
              S56 S58 S64 S66 S80 S82 T25 T29 T31 T35 T55 T57
              T59 T63 T65 U8 U22 U26 U28 U54 U58 U60 V7 V23
              V25 V33 V43 V53 V57 V59 V61 V63 V71 V75 W10 W12
              W14 W16 W26 W28 W30 W34 W48 W56 W58 W60 W62 W72
              W78 X5 X9 X17 X21 X29 X43 X49 X75 X77 Y2 Y4
              Y16 Y18 Y22 Y24 Y46 Y50 Y56 Y58 Y72 Y74 Y76 Z5
              Z7 Z9 Z11 Z15 Z17 Z19 Z45 Z51 Z79 AA2 AA6 AA8
              AA14 AA16 AA22 AA48 AA54 AA70 AA74 AA76 AA78 AA80 AB1 AB5
              AB11 AB17 AB41 AB63 AC18 AC38 AC78 AC80 AC82 AC86 AD5 AD11
              AD39 AD67 AD69 AD85 AD87 AE86 AF67 AF81 AF85 AG52
            ] => '',

            # National zone province borders
            ['O38'] => 'partition=a:-1,b:3,type:province;partition=a:-1,b:0,type:province',
            # FR/PHS intra-hex
            ['N37'] => 'partition=a:-1,b:2,type:province;partition=a:-1,b:5,type:province',
            ['Q38'] => 'city=revenue:0;partition=a:-1,b:3,type:province;partition=a:-1,b:0,type:province',
            ['R39'] => 'upgrade=cost:30,terrain:hill;partition=a:-1,b:2,type:province;partition=a:-1,b:0,type:province',
            ['S38'] => 'upgrade=cost:45,terrain:hill;partition=a:-1,b:4,type:province;partition=a:-1,b:1,type:province',
            # PHS/AH intra-hex
            ['O54'] => 'upgrade=cost:60,terrain:mountain;partition=a:-1,b:1,type:province;partition=a:-1,b:5,type:province',
            ['P49'] => 'partition=a:-1,b:0,type:province;partition=a:-1,b:2,type:province',
            ['Q50'] => 'upgrade=cost:30,terrain:water;partition=a:-1,b:2,type:province;partition=a:-1,b:5,type:province',
            ['R51'] => 'upgrade=cost:45,terrain:hill;partition=a:-1,b:1,type:province;partition=a:-1,b:3,type:province',
            ['S44'] => 'upgrade=cost:45,terrain:hill;partition=a:-1,b:1,type:province;partition=a:-1,b:5,type:province',
            ['S48'] => 'upgrade=cost:45,terrain:hill;partition=a:-1,b:2,type:province;partition=a:-1,b:4,type:province',
            # PHS/RU intra-hex
            ['I64'] => 'partition=a:-1,b:2,type:province;partition=a:-1,b:5,type:province',
            ['K64'] => 'upgrade=cost:30,terrain:water;partition=a:-1,b:4,type:province;partition=a:-1,b:1,type:province',
            ['L61'] => 'partition=a:-1,b:4,type:province;partition=a:-1,b:1,type:province',
            ['M58'] => 'partition=a:-1,b:4,type:province;partition=a:-1,b:1,type:province',
            ['O58'] => 'partition=a:-1,b:2,type:province;partition=a:-1,b:5,type:province',
            ['P73'] => 'partition=a:-1,b:2,type:province;partition=a:-1,b:5,type:province',
            # AH/RU intra-hex
            ['Q74'] => 'partition=a:-1,b:3,type:province;partition=a:-1,b:0,type:province',
            # FR/IT intra-hex
            ['V37'] => 'upgrade=cost:60,terrain:mountain;partition=a:-1,b:4,type:province;partition=a:-1,b:0,type:province',
            ['W38'] => 'upgrade=cost:60,terrain:mountain;partition=a:-1,b:2,type:province;partition=a:-1,b:0,type:province',
            # PHS/IT intra-hex
            ['U38'] => 'upgrade=cost:120,terrain:mountain;' \
                       'partition=a:-1,b:3,type:province;partition=a:-1,b:4,type:province;' \
                       'partition=a:-1,b:0,type:province',
            ['U40'] => 'upgrade=cost:60,terrain:mountain;partition=a:-1,b:2,type:province;partition=a:-1,b:4,type:province',
            ['U42'] => 'upgrade=cost:60,terrain:mountain;partition=a:-1,b:2,type:province;partition=a:-1,b:4,type:province',
            ['I44'] => 'border=edge:5,type:province',
            ['I66'] => 'town=revenue:0;border=edge:0,type:province',
            ['J45'] => 'border=edge:2,type:province;border=edge:3,type:province',
            ['J65'] => 'upgrade=cost:30,terrain:water;border=edge:3,type:province;' \
                       'border=edge:4,type:province;border=edge:5,type:province',
            ['J67'] => 'border=edge:1,type:province',
            ['K62'] => 'town=revenue:0;border=edge:5,type:province',
            ['K66'] => 'upgrade=cost:30,terrain:water;border=edge:2,type:province',
            ['L59'] => 'border=edge:5,type:province',
            ['L63'] => 'border=edge:2,type:province',
            ['M34'] => 'upgrade=cost:60,terrain:lake;border=edge:0,type:province;border=edge:5,type:province',
            ['M60'] => 'border=edge:2,type:province',
            ['N33'] => 'town=revenue:0;border=edge:3,type:province',
            ['N57'] => 'border=edge:4,type:province',
            ['N59'] => 'town=revenue:0;border=edge:1,type:province',
            ['O50'] => 'upgrade=cost:30,terrain:hill;border=edge:5,type:province',
            ['O56'] => 'city=revenue:0;border=edge:0,type:province;border=edge:5,type:province',
            ['O60'] => 'border=edge:0,type:province;border=edge:5,type:province',
            ['O62'] => 'upgrade=cost:45,terrain:hill;border=edge:0,type:province;border=edge:5,type:province',
            ['O64'] => 'border=edge:0,type:province;border=edge:5,type:province',
            ['O66'] => 'border=edge:0,type:province;border=edge:5,type:province',
            ['O68'] => 'upgrade=cost:30,terrain:hill;border=edge:0,type:province;border=edge:5,type:province',
            ['O70'] => 'border=edge:0,type:province;border=edge:5,type:province',
            ['O72'] => 'border=edge:0,type:province',

            ['P37'] => 'town=revenue:0;border=edge:4,type:province',
            ['P39'] => 'border=edge:1,type:province',
            ['P51'] => 'border=edge:2,type:province',
            ['P55'] => 'upgrade=cost:45,terrain:hill;border=edge:3,type:province',
            ['P57'] => 'upgrade=cost:30,terrain:hill;border=edge:2,type:province',
            ['P59'] => 'border=edge:3,type:province',
            ['P61'] => 'town=revenue:0;border=edge:2,type:province;border=edge:3,type:province',
            ['P63'] => 'border=edge:2,type:province;border=edge:3,type:province',
            ['P65'] => 'border=edge:2,type:province;border=edge:3,type:province',
            ['P67'] => 'border=edge:2,type:province;border=edge:3,type:province',
            ['P69'] => 'city=revenue:0;border=edge:2,type:province;border=edge:3,type:province',
            ['P71'] => 'border=edge:2,type:province;border=edge:3,type:province',
            ['R49'] => 'border=edge:5,type:province',
            ['R73'] => 'border=edge:4,type:province',
            ['R75'] => 'border=edge:0,type:province;border=edge:1,type:province',
            ['S74'] => 'border=edge:3,type:province;border=edge:4,type:province',
            ['S76'] => 'city=revenue:0;border=edge:0,type:province;border=edge:1,type:province',
            ['T43'] => 'upgrade=cost:120,terrain:mountain;border=edge:4,type:province;border=edge:5,type:province',
            ['T45'] => 'upgrade=cost:120,terrain:mountain;border=edge:0,type:province;' \
                       'border=edge:1,type:province;border=edge:5,type:province',
            ['T47'] => 'upgrade=cost:120,terrain:mountain;border=edge:0,type:province;border=edge:5,type:province',
            ['T49'] => 'upgrade=cost:60,terrain:mountain;border=edge:0,type:province',
            ['T75'] => 'upgrade=cost:45,terrain:river;border=edge:3,type:province',
            ['U44'] => 'upgrade=cost:120,terrain:mountain;border=edge:2,type:province;border=edge:3,type:province',
            ['U46'] => 'upgrade=cost:60,terrain:mountain;border=edge:2,type:province;border=edge:3,type:province',
            ['U48'] => 'border=edge:2,type:province;border=edge:3,type:province;border=edge:4,type:province',
            ['U50'] => 'border=edge:1,type:province',
            ['W20'] => 'upgrade=cost:45,terrain:hill;border=edge:3,type:province',
            ['X23'] => 'upgrade=cost:120,terrain:mountain;border=edge:3,type:province',
            ['Y26'] => 'border=edge:3,type:province',
            # Impassable borders (landtiles_with_borders.csv)
            # Scotland — Highlands barrier
            ['F27'] => 'town=revenue:0;border=edge:0,type:impassable;border=edge:5,type:impassable',
            ['F29'] => 'border=edge:0,type:impassable',
            ['G26'] => 'city=revenue:10;label=Y;upgrade=cost:30,terrain:hill;' \
                       'border=edge:3,type:impassable;icon=image:port,sticky:1',
            ['G28'] => 'border=edge:2,type:impassable;border=edge:3,type:impassable',
            # England — coastal/estuary
            ['L31'] => 'border=edge:0,type:impassable',
            # Channel Islands
            ['M30'] => 'border=edge:3,type:impassable;border=edge:5,type:impassable;' \
                       'upgrade=cost:45,terrain:river',
            # Franco-Belgian border
            ['N31'] => 'city=revenue:10;label=Y;border=edge:2,type:impassable;path=a:1,b:_0',
            # Pyrenees
            ['V19'] => 'border=edge:4,type:impassable;upgrade=cost:30,terrain:hill',
            ['V21'] => 'town=revenue:0;border=edge:1,type:impassable;border=edge:0,type:province',
            ['W22'] => 'upgrade=cost:120,terrain:mountain;' \
                       'partition=a:-1,b:2,type:province;partition=a:-1,b:5,type:province',
            ['W24'] => 'upgrade=cost:60,terrain:mountain;border=edge:0,type:province',
            ['X27'] => 'upgrade=cost:60,terrain:mountain;border=edge:0,type:province',
            ['Y28'] => 'upgrade=cost:45,terrain:hill;' \
                       'partition=a:-1,b:2,type:province;partition=a:-1,b:4,type:province',
            # Kattegat / Danish straits
            ['K40'] => 'border=edge:4,type:impassable;upgrade=cost:60,terrain:lake',
            ['K42'] => 'border=edge:1,type:impassable;upgrade=cost:30,terrain:water',
            # Adriatic — northern entry
            ['AC56'] => 'border=edge:4,type:impassable',
            ['AC58'] => 'border=edge:1,type:impassable',
            # Skagerrak / Norwegian coast
            ['I46'] => 'town=revenue:0;border=edge:5,type:impassable;border=edge:0,type:province',
            ['J47'] => 'border=edge:2,type:impassable;border=edge:3,type:impassable;' \
                       'border=edge:4,type:impassable;border=edge:5,type:impassable;upgrade=cost:60,terrain:lake',
            ['J49'] => 'border=edge:0,type:impassable;border=edge:1,type:impassable;' \
                       'border=edge:2,type:province;border=edge:3,type:province;' \
                       'border=edge:5,type:impassable;upgrade=cost:60,terrain:lake',
            ['K48'] => 'border=edge:2,type:impassable;border=edge:3,type:impassable',
            ['K50'] => 'border=edge:2,type:impassable',
            # North Sea — Danish coast
            ['D47'] => 'town=revenue:0;border=edge:4,type:impassable;border=edge:5,type:impassable',
            ['D49'] => 'border=edge:1,type:impassable',
            ['D51'] => 'town=revenue:0;border=edge:5,type:impassable;upgrade=cost:30,terrain:water',
            ['D53'] => 'town=revenue:0;border=edge:0,type:impassable;upgrade=cost:30,terrain:water',
            ['E52'] => 'border=edge:2,type:impassable;border=edge:3,type:impassable;upgrade=cost:45,terrain:river',
            # Baltic — Gulf of Bothnia entry
            ['C66'] => 'border=edge:5,type:impassable',
            ['D67'] => 'border=edge:2,type:impassable',
            # Norwegian fjord coast
            ['B71'] => 'border=edge:5,type:impassable',
            ['B73'] => 'town=revenue:0;border=edge:0,type:impassable;upgrade=cost:30,terrain:water',
            ['B75'] => 'border=edge:4,type:impassable',
            ['B77'] => 'border=edge:1,type:impassable;upgrade=cost:45,terrain:river',
            ['C72'] => 'border=edge:2,type:impassable;border=edge:3,type:impassable;upgrade=cost:30,terrain:water',

            # Towns — no terrain
            %w[
              E44 F53 H17 H29 J17 L29 O24 P29 P33 R29 S34
              T27 Z41 V5 W18 X11 Z3 Z13 Z25 AA4 AB3
              AC10 AC12 AC20 AD15 L43 M48 M56 P43 Q56 Q72 R53
              R59 R67 S40 S68 T61 U56 U62 X55 V45 Y44 AA52
              AB55 D69 D75 D83 E70 F73 G84 H71 H85 I80
              K68 L79 L87 N65 N83 Q84 V73 W70 AA84 AC68 AC84 AG68
              AF87 H51
            ] => 'town=revenue:0',
            # Towns — port icon
            %w[
              AB39 C64 G46 H55 K60 P19 V47 X35 X37
            ] => 'town=revenue:0;icon=image:port,sticky:1',
            # Towns — mountain terrain
            %w[G24 I16 U12 V15 AD13] => 'town=revenue:0;upgrade=cost:30,terrain:hill',
            ['I26'] => 'town=revenue:0;upgrade=cost:30,terrain:hill;icon=image:port,sticky:1',
            %w[E26 E28] => 'town=revenue:0;upgrade=cost:45,terrain:hill',
            ['J23'] => 'town=revenue:0;upgrade=cost:45,terrain:hill;icon=image:port,sticky:1',
            ['X25'] => 'town=revenue:0;upgrade=cost:60,terrain:mountain;' \
                       'partition=a:-1,b:2,type:province;partition=a:-1,b:5,type:province',
            # Towns — water terrain
            ['L23'] => 'town=revenue:0;upgrade=cost:45,terrain:river',
            ['AD7'] => 'town=revenue:0;upgrade=cost:45,terrain:river;icon=image:port,sticky:1',
            # Double towns
            %w[J29 M26 W32
               N41 Q46 U64 W46 AF53
               J77 P77] => 'town=revenue:0;town=revenue:0',
            %w[AC6 C58 U6] => 'town=revenue:0;town=revenue:0;icon=image:port,sticky:1',
            ['T37'] => 'town=revenue:0;town=revenue:0;upgrade=cost:45,terrain:hill;' \
                       'partition=a:-1,b:1,type:province;partition=a:-1,b:5,type:province',
            # Cities — no label, no terrain
            %w[
              J15 Q26 V27 F49 L53 N49
              J73 V17 W6 X13 Y20 AA20 AC8 AC16 AB27
            ] => 'city=revenue:0',
            ['C48'] => 'city=revenue:10;icon=image:port,sticky:1',
            # Cities — no terrain (added station geometry)
            %w[
              AA62 AB57 AB69 AC40 AF49 B67 D77 E56 G68 H47 H63
              H87 I76 J69 K78 K86 M44 M68 S78 T53 T81 V51
              V55 W64 Y70
            ] => 'city=revenue:0',
            # Cities — port icon
            %w[AD17 F25 H21 L25 R23 W40] => 'city=revenue:0;icon=image:port,sticky:1',
            ['V39'] => 'city=revenue:30',
            # Cities — label Y
            ['U34'] => 'city=revenue:0;label=Y',
            ['N35'] => 'city=revenue:0;label=Y;upgrade=cost:30,terrain:water;' \
                       'border=edge:2,type:province;border=edge:3,type:province',
            # Cities — other labels
            ['K26'] => 'city=revenue:0;label=A',
            ['Q30'] => 'city=revenue:0;label=P',
            # Cities — terrain
            ['Y14'] => 'city=revenue:0;label=A;upgrade=cost:45,terrain:hill',
            ['U32'] => 'city=revenue:0;upgrade=cost:30,terrain:hill',
            ['AD9'] => 'city=revenue:0;upgrade=cost:30,terrain:hill',
            ['D57'] => 'city=revenue:0;upgrade=cost:30,terrain:water;icon=image:port,sticky:1',
            ['AA82'] => 'city=revenue:20;city=revenue:20;upgrade=cost:45,terrain:river;' \
                        'label=C;path=a:2,b:_0;icon=image:port,sticky:1',
            ['U24'] => 'city=revenue:10;icon=image:port,sticky:1',
            ['I20'] => 'city=revenue:10;path=a:4,b:_0;icon=image:port,sticky:1',
            ['O28'] => 'city=revenue:0;path=a:1,b:_0;icon=image:port,sticky:1',
            ['AD79'] => 'city=revenue:0;path=a:1,b:_0;icon=image:port,sticky:1',
            ['M28'] => 'city=revenue:30;label=L;upgrade=cost:30,terrain:water;path=a:5,b:_0;icon=image:port,sticky:1',
            ['X33'] => 'city=revenue:20;label=Y;path=a:5,b:_0;icon=image:port,sticky:1',

            ['Z27'] => 'city=revenue:20;label=Y;path=a:0,b:_0;icon=image:port,sticky:1',
            ['K46'] => 'city=revenue:20;label=Y;icon=image:port,sticky:1',
            ['M50'] => 'city=revenue:0;label=B',
            ['R47'] => 'city=revenue:0;label=Y',
            ['R55'] => 'city=revenue:0;label=A',
            ['S60'] => 'city=revenue:0;label=Y',
            ['P53'] => 'city=revenue:0;label=Y',
            ['V41'] => 'city=revenue:0;label=Y',
            ['Z47'] => 'city=revenue:0;label=Y',
            ['AB51'] => 'city=revenue:20;label=N',
            ['C74'] => 'city=revenue:20;label=S;icon=image:port,sticky:1',
            ['M62'] => 'city=revenue:0;label=Y',
            ['O80'] => 'city=revenue:0;label=Y',
            # Cities — water terrain
            ['AE68'] => 'town=revenue:0;upgrade=cost:30,terrain:water;icon=image:port,sticky:1',
            ['D41'] => 'town=revenue:0;upgrade=cost:45,terrain:river;icon=image:port,sticky:1',
            ['D81'] => 'town=revenue:0;upgrade=cost:30,terrain:water',
            ['I52'] => 'city=revenue:0;upgrade=cost:45,terrain:river',
            ['J63'] => 'city=revenue:0;label=Y;upgrade=cost:30,terrain:water;icon=image:port,sticky:1',
            ['L39'] => 'town=revenue:0;town=revenue:0;upgrade=cost:30,terrain:water',
            ['M36'] => 'city=revenue:0;upgrade=cost:30,terrain:water;border=edge:0,type:province',
            ['M38'] => 'town=revenue:0;upgrade=cost:30,terrain:water',
            ['M72'] => 'town=revenue:0;upgrade=cost:30,terrain:water',
            ['O40'] => 'city=revenue:0;label=Y;upgrade=cost:30,terrain:water',
            ['P85'] => 'town=revenue:0;upgrade=cost:30,terrain:water',
            ['Q40'] => 'city=revenue:0;upgrade=cost:30,terrain:water',
            ['S84'] => 'town=revenue:0;upgrade=cost:45,terrain:river;icon=image:port,sticky:1',
            ['S86'] => 'town=revenue:0;upgrade=cost:30,terrain:water',
            ['U78'] => 'town=revenue:0;upgrade=cost:45,terrain:river',
            ['U80'] => 'town=revenue:0;upgrade=cost:45,terrain:river',
            ['W74'] => 'city=revenue:0;label=Y;upgrade=cost:30,terrain:water',
            # Cities — mountain terrain
            ['AB83'] => 'town=revenue:0;upgrade=cost:45,terrain:hill',
            ['AC64'] => 'town=revenue:0;upgrade=cost:30,terrain:hill',
            ['B43'] => 'town=revenue:0;upgrade=cost:60,terrain:mountain',
            ['O52'] => 'city=revenue:0;upgrade=cost:30,terrain:hill;' \
                       'partition=a:-1,b:1,type:province;partition=a:-1,b:5,type:province',
            ['Q52'] => 'town=revenue:0;upgrade=cost:45,terrain:hill',
            ['S42'] => 'city=revenue:0;upgrade=cost:30,terrain:hill',
            ['S46'] => 'town=revenue:0;upgrade=cost:60,terrain:mountain;' \
                       'partition=a:-1,b:1,type:province;partition=a:-1,b:4,type:province',
            ['S50'] => 'city=revenue:0;upgrade=cost:30,terrain:hill;border=edge:2,type:province',
            ['T39'] => 'town=revenue:0;upgrade=cost:120,terrain:mountain',
            ['T69'] => 'city=revenue:0;upgrade=cost:30,terrain:hill',
            ['U52'] => 'town=revenue:0;upgrade=cost:45,terrain:hill',
            ['U72'] => 'town=revenue:0;upgrade=cost:45,terrain:hill',
            ['X45'] => 'city=revenue:0;label=Y;upgrade=cost:45,terrain:hill',
            ['X59'] => 'town=revenue:0;upgrade=cost:30,terrain:hill',
            ['Y64'] => 'town=revenue:0;upgrade=cost:45,terrain:hill',
            ['Y66'] => 'town=revenue:0;upgrade=cost:45,terrain:hill',
            ['Z73'] => 'town=revenue:0;upgrade=cost:30,terrain:hill',

            # Terrain — water
            ['E78'] => 'upgrade=cost:5,terrain:water',
            %w[
              C50 C52 E82 F77 F79 G64 G66 G74 H73 I70 I72
              L69 L71 L75 L77 M74 M76 M78 M80 N39 N69 N71 N73
              N75 N77 N79 P41 P83 P87 R87 V77 W76 X69 X71
              X73 Y78 Z77 Z23 AE70
            ] => 'upgrade=cost:30,terrain:water',
            %w[
              A72 A74 C42 C76 E50 E54 E72 G44 K44 N81 O82 Q20
              T77 T79 U76 V79 AB71 AE52
            ] => 'upgrade=cost:45,terrain:river',
            %w[
              B81 C82 T23 AB77 AC76 AD71 AG70
            ] => 'upgrade=cost:60,terrain:lake',

            # Terrain — mountain
            %w[
              B51 B53 H83 I84 I86 J71 K72 O46 P45 Q70 S62
              S70 T33 U10 W54 X65 Z63 Z69 Z75 AA68 AB13 AB53 AC66
              AD65 AF69 AG50
            ] => 'upgrade=cost:30,terrain:hill',
            %w[
              A48 A50 A52 N45 O42 O44 Q60 Q62 Q64 Q68 R61
              R69 T67 T71 T73 U30 U66 U74 V9 V13
              V29 V35 V65 V69 W36 W42 W44 W68 X7 X15 X47 X57
              X61 X63 X67 Y6 Y48 Y62 Y68 Z21 Z49 Z61 Z65 Z71
              AA10 AA12 AA18 AA50 AA64 AA72 AB7 AB9 AB19 AB65 AB67 AC14
              AC54 AD55 AD81 AD83 AE80 AF83
            ] => 'upgrade=cost:45,terrain:hill',
            %w[
              A44 A46 C44 D43 R71 S52 S54 S72 T51 U36
              U68 U70 V11 V31 V67 W8 W66 X19 Y8
              Y10 Y12 Y60 Z67 AA66 AA86 AB15 AB85 AE82 AE84 AF51
            ] => 'upgrade=cost:60,terrain:mountain',
            %w[
              B45 T41
            ] => 'upgrade=cost:120,terrain:mountain',
          },
          yellow: {
            ['L37'] => 'city=revenue:30;label=Y;upgrade=cost:45,terrain:river;path=a:0,b:_0;' \
                       'path=a:_0,b:5;icon=image:port,sticky:1',
            ['I48'] => 'border=edge:0,type:impassable;upgrade=cost:45,terrain:river;path=a:2,b:4;' \
                       'border=edge:5,type:province',
            ['I50'] => 'city=revenue:30;label=Y;upgrade=cost:45,terrain:river;path=a:1,b:_0;' \
                       'path=a:_0,b:3;border=edge:0,type:province;icon=image:port,sticky:1',
            ['J25'] => 'city=revenue:30;label=Y;path=a:2,b:_0;path=a:_0,b:4',
            ['J27'] => 'city=revenue:20;upgrade=cost:30,terrain:hill;path=a:1,b:_0;path=a:_0,b:4',
            ['AE72'] => 'city=revenue:20;path=a:1,b:_0;path=a:5,b:_0',
          },
          gray: {
            # North Sweden approach
            ['A54'] => 'path=a:1,b:4',
            # Moskva approach
            ['G88'] => 'path=a:0,b:2',
            # Sevastopol approach
            ['S88'] => 'path=a:0,b:1',
          },
          red: {
            ['D25'] => 'offboard=revenue:yellow_20|green_40|brown_50|gray_50;path=a:0,b:_0;path=a:5,b:_0', # Scottish Highlands
            # North Sweden
            ['A56'] => 'city=revenue:yellow_30|green_50|brown_80|gray_100,slots:2;' \
                       'path=a:1,b:_0;path=a:_0,b:0;path=a:_0,b:4;path=a:_0,b:5',
            # Finland
            ['A64'] => 'city=revenue:yellow_30|green_40|brown_60|gray_80,slots:2;' \
                       'path=a:0,b:_0;path=a:_0,b:1;path=a:_0,b:4',
            # Bergen
            ['B41'] => 'city=revenue:yellow_30|green_60|brown_80|gray_120,slots:2;' \
                       'path=a:1,b:_0;path=a:_0,b:3;path=a:_0,b:4;' \
                       'icon=image:port,sticky:1',
            ['B83'] => 'offboard=revenue:yellow_30|green_50|brown_60|gray_60', # Arkhangelsk — no path defined
            # Moskva
            ['F87'] => 'city=revenue:yellow_30|green_50|brown_80|gray_100,slots:3;' \
                       'path=a:0,b:_0;path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:5',
            ['N1'] => 'offboard=revenue:green_60|brown_100|gray_160;path=a:5,b:_0;icon=image:port,sticky:1', # New York
            # Kharkov
            ['N87'] => 'offboard=revenue:yellow_30|green_40|brown_60|gray_80;' \
                       'city=revenue:0,slots:2;path=a:0,b:_0;path=a:_0,b:1;path=a:_0,b:2',
            # Sevastopol
            ['T87'] => 'city=revenue:yellow_30|green_40|brown_60|gray_80,slots:2;' \
                       'path=a:0,b:_0;path=a:_0,b:3;border=edge:5,type:province',
            # Lisboa (2 station slots; RCP home)
            ['Z1'] => 'city=revenue:yellow_40|green_50|brown_60|gray_80,slots:2;path=a:_0,b:4;' \
                      'path=a:_0,b:3;icon=image:port,sticky:1',
            ['AB87'] => 'offboard=revenue:yellow_30|green_50|brown_80|gray_120;path=a:1,b:_0;path=a:2,b:_0', # Levant
            ['AD1'] => 'offboard=revenue:green_40|brown_80|gray_120;path=a:4,b:_0;' \
                       'icon=image:port,sticky:1', # North Africa & The Americas
            ['AF5'] => 'offboard=revenue:yellow_30|green_40|brown_60|gray_80;path=a:3,b:_0', # Casablanca
            ['AF11'] => 'offboard=revenue:yellow_30|green_40|brown_40|gray_40;path=a:4,b:_0', # Melilla
            ['AF25'] => 'offboard=revenue:yellow_30|green_40|brown_60|gray_100;path=a:2,b:_0;path=a:3,b:_0;' \
                        'border=edge:3,type:province;border=edge:4,type:province;border=edge:5,type:province;' \
                        'icon=image:port,sticky:1', # Alger
            ['AG40'] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_80;path=a:3,b:_0;path=a:4,b:_0;' \
                        'border=edge:0,type:province;border=edge:1,type:province;icon=image:port,sticky:1', # Tunis
            ['AG88'] => 'offboard=revenue:green_50|brown_80|gray_120;path=a:1,b:_0;icon=image:port,sticky:1', # Alexandria & Suez
          },
          blue: {
            %w[
              A0 A2 A4 A6 A8 A10 A12 A14 A16 A22 A24 A26
              A28 A30 A32 A34 A40 B1 B3 B5 B7
              B9 B11 B13 B15 B17 B23 B25 B27 B29 B31 B33
              B59 B61 C0 C2 C4 C6 C8 C10 C12 C14 C16 C22
              C24 C26 C28 C30 C32 C34 C40 C60 C68 C70 D1
              D3 D5 D7 D9 D11 D13 D15 D17 D23 D27 D29 D31
              D33 D39 D63 D65 E0 E2 E4 E6 E8 E10 E12 E14
              E16 E22 E30 E32 E34 E40 E46 E64 F1 F3 F5 F7
              F9 F11 F13 F15 F17 F31 F33 F39 F41 F43 F45 F47
              F57 F65 F67 G0 G2 G4 G6 G8 G10 G12 G14
              G48 G58 H1 H3 H5 H7 H9 H11 H13
              H23 H31 H33 H49 H59 H61 I0 I2 I4 I6 I8
              I10 I12 I30 I32 I38 I40 I42 I54 I56 I60 I62
              J5 J7 J9 J11 J21 J31 J37 J39 J41 J43 J51 J53
              J55 J57 J61 K6 K8 K10 K12 K14 K16 K18 K20
              K38 K52 L1 L7 L9 L11 L13 L15 L17 L19 L21 M0
              M2 M8 M10 M12 M14 M16 M32 N7 N9 N11 N13 N15
              N23 N27 O0 O2 O20 O22 O26 P1 Q0 Q8 Q10 Q12
              Q14 Q16 Q18 R7 R9 R11 R13 R15 R17 R19 R21 S0
              S2 S8 S10 S12 S14 S16 S18 S20 S22 T1 T3 T9
              T11 T13 T15 T17 T19 T21 T83 T85 U0 U2 U4 U14
              U16 U18 U20 V1 V3 V49 W0 W2 W4 W50 W52 W80
              W82 W84 W86 W88 X1 X3 X31 X39 X51 X53 X81
              X83 X85 X87 Y0 Y30 Y32 Y34 Y36 Y52 Y54
              Y82 Y84 Y86 Y88 Z29 Z31 Z33 Z35 Z37 Z39 Z43 Z53
              Z55 Z57 Z59 Z83 Z85 Z87 AA0 AA24 AA30 AA32 AA34
              AA36 AA38 AA56 AA58 AA60 AA88 AB29 AB31 AB33 AB35
              AB37 AB43 AB45 AB47 AB49 AB73 AB75 AB79 AB81 AC0
              AC2 AC4 AC22 AC28 AC30 AC32 AC34 AC36 AC42 AC44 AC46 AC48
              AC50 AC52 AC70 AC72 AC74 AD3 AD19 AD21 AD23 AD29 AD31
              AD33 AD35 AD41 AD43 AD45 AD47 AD49 AD51 AD53 AD57 AD73
              AE0 AE2 AE4 AE8 AE14 AE16 AE18 AE20 AE22 AE28 AE30
              AE32 AE34 AE40 AE42 AE44 AE46 AE48 AE50 AE56
              AE76 AF1 AF3 AF7 AF9 AF15 AF17 AF19 AF21 AF23 AF29
              AF31 AF33 AF41 AF43 AF45 AF47 AF55 AF57 AF63 AF65 AF71
              AF75 AG0 AG2 AG4 AG6 AG8 AG14 AG16 AG18 AG20 AG22 AG28
              AG30 AG32 AG34 AG54 AG56 AG62 AG64
              AG66 AG72 AG74 AG80 AG82 AG84 AG86 AH1 AH3 AH5 AH7 AH13
              AH15 AH17 AH19 AH21 AH23 AH29 AH31 AH33 AH35 AH37 AH43 AH45
              AH47 AH49 AH51 AH53 AH55 AH57 AH63 AH65 AH67 AH69 AH71 AH73
              AH79 AH81 AH83 AH85 AH87
              ] => '',
            # Ferry routes (pre-printed track through sea hexes)
            ['N29'] => 'path=a:4,b:2',
            ['G22'] => 'path=a:0,b:4;border=edge:2,type:province',
            ['I22'] => 'path=a:1,b:5;path=a:1,b:4',
            ['I24'] => 'path=a:1,b:5;path=a:1,b:4',
            ['N25'] => 'path=a:0,b:3',
            ['AE6'] => 'town=revenue:20;path=a:0,b:3',
            ['AE12'] => 'path=a:3,b:5;border=edge:1,type:province',
            ['AF13'] => 'path=a:2,b:1',
            ['AB21'] => 'path=a:2,b:4',
            ['AB23'] => 'path=a:1,b:4',
            ['AB25'] => 'path=a:1,b:4;border=edge:5,type:province',
            ['Y38'] => 'path=a:4,b:2',
            ['AA44'] => 'path=a:1,b:4',
            ['AA46'] => 'path=a:1,b:3',
            ['AE54'] => 'path=a:3,b:0',
            ['AG42'] => 'path=a:4,b:1',
            ['AG44'] => 'path=a:4,b:1',
            ['AG46'] => 'path=a:4,b:1',
            ['AG48'] => 'path=a:4,b:1;path=a:3,b:1',
            ['AB59'] => 'path=a:1,b:4',
            ['AB61'] => 'path=a:1,b:5',
            ['AC62'] => 'path=a:2,b:5',
            ['AE66'] => 'path=a:1,b:4',
            ['AF73'] => 'path=a:2,b:3',
            ['AE74'] => 'town=revenue:20;path=a:0,b:_0;path=a:3,b:_0',
            ['AD75'] => 'path=a:0,b:4',
            ['AD77'] => 'path=a:1,b:4',
            ['Z81'] => 'path=a:5,b:2',
            ['Y80'] => 'path=a:5,b:2',
            ['X79'] => 'town=revenue:20;path=a:5,b:_0;path=a:1,b:_0;icon=image:port,sticky:1',
            ['G30'] => 'junction;path=a:4,b:_0',
            ['G32'] => 'path=a:1,b:4',
            ['G34'] => 'path=a:1,b:3',
            ['B39'] => 'path=a:0,b:4',
            ['J59'] => 'path=a:5,b:2',
            ['I58'] => 'path=a:5,b:2',
            ['H57'] => 'path=a:5,b:1',
            ['A58'] => 'path=a:1,b:4',
            ['A60'] => 'path=a:1,b:4',
            ['A62'] => 'path=a:1,b:4',
            ['C62'] => 'path=a:0,b:4',
            # Sea zone province borders
            ['AD25'] => 'border=edge:3,type:province;border=edge:4,type:province;border=edge:5,type:province',
            ['AE58'] => 'border=edge:4,type:province',
            ['AG58'] => 'border=edge:4,type:province',
            ['AE60'] => 'border=edge:0,type:province;border=edge:1,type:province;' \
                        'border=edge:2,type:province;border=edge:3,type:province',
            ['AG60'] => 'border=edge:0,type:province;border=edge:1,type:province;border=edge:2,type:province',
            ['F63'] => 'border=edge:0,type:province',
            ['G62'] => 'border=edge:2,type:province;border=edge:3,type:province',
            ['A18'] => 'border=edge:4,type:province',
            ['A20'] => 'border=edge:0,type:province;border=edge:1,type:province',
            ['A36'] => 'border=edge:4,type:province;border=edge:5,type:province',
            ['A38'] => 'border=edge:1,type:province',
            ['AA26'] => 'path=a:3,b:5;border=edge:4,type:province',
            ['AA28'] => 'border=edge:1,type:province',
            ['AA40'] => 'path=a:3,b:0;border=edge:4,type:province',
            ['AA42'] => 'path=a:0,b:4;border=edge:1,type:province',
            ['AC24'] => 'border=edge:4,type:province',
            ['AC26'] => 'path=a:3,b:5;border=edge:0,type:province;border=edge:1,type:province;border=edge:2,type:province',
            ['AC60'] => 'border=edge:0,type:province',
            ['AD27'] => 'path=a:0,b:2;border=edge:1,type:province',
            ['AD37'] => 'border=edge:5,type:province',
            ['AD59'] => 'border=edge:3,type:province;border=edge:4,type:province;border=edge:5,type:province',
            ['AD61'] => 'border=edge:0,type:province;border=edge:1,type:province;border=edge:5,type:province',
            ['AD63'] => 'path=a:2,b:5;border=edge:0,type:province;border=edge:5,type:province',
            ['AE10'] => 'border=edge:4,type:province',
            ['AE24'] => 'border=edge:4,type:province',
            ['AE26'] => 'path=a:3,b:0;border=edge:0,type:province;border=edge:1,type:province;border=edge:2,type:province',
            ['AE36'] => 'border=edge:4,type:province;border=edge:5,type:province',
            ['AE38'] => 'border=edge:1,type:province;border=edge:2,type:province',
            ['AE62'] => 'border=edge:2,type:province;border=edge:3,type:province',
            ['AE64'] => 'path=a:2,b:4;border=edge:2,type:province',
            ['AE78'] => 'border=edge:5,type:province',
            ['AF27'] => 'border=edge:1,type:province',
            ['AF35'] => 'border=edge:4,type:province',
            ['AF37'] => 'border=edge:0,type:province;border=edge:1,type:province;' \
                        'border=edge:2,type:province;border=edge:5,type:province',
            ['AF39'] => 'border=edge:0,type:province',
            ['AF59'] => 'border=edge:3,type:province;border=edge:4,type:province;border=edge:5,type:province',
            ['AF61'] => 'border=edge:1,type:province',
            ['AF77'] => 'border=edge:4,type:province;border=edge:5,type:province',
            ['AF79'] => 'border=edge:1,type:province;border=edge:2,type:province',
            ['AG10'] => 'border=edge:4,type:province;border=edge:5,type:province',
            ['AG12'] => 'border=edge:1,type:province',
            ['AG24'] => 'border=edge:4,type:province',
            ['AG26'] => 'border=edge:0,type:province;border=edge:1,type:province;border=edge:2,type:province',
            ['AG36'] => 'border=edge:3,type:province',
            ['AG38'] => 'border=edge:2,type:province;border=edge:3,type:province;border=edge:4,type:province',
            ['AG76'] => 'border=edge:4,type:province;border=edge:5,type:province',
            ['AG78'] => 'border=edge:1,type:province;border=edge:2,type:province',
            ['AH11'] => 'border=edge:1,type:province;border=edge:2,type:province',
            ['AH25'] => 'border=edge:3,type:province;border=edge:4,type:province',
            ['AH27'] => 'border=edge:1,type:province',
            ['AH39'] => 'border=edge:3,type:province;border=edge:4,type:province',
            ['AH41'] => 'border=edge:1,type:province',
            ['AH59'] => 'border=edge:3,type:province;border=edge:4,type:province',
            ['AH61'] => 'border=edge:1,type:province',
            ['AH75'] => 'border=edge:4,type:province',
            ['AH77'] => 'border=edge:1,type:province;border=edge:2,type:province',
            ['AH9'] => 'border=edge:4,type:province',
            ['B19'] => 'border=edge:3,type:province;border=edge:4,type:province;border=edge:5,type:province',
            ['B21'] => 'border=edge:1,type:province',
            ['B35'] => 'border=edge:4,type:province',
            ['B37'] => 'border=edge:0,type:province;border=edge:1,type:province;border=edge:2,type:province',
            ['C18'] => 'border=edge:4,type:province',
            ['C20'] => 'border=edge:0,type:province;border=edge:1,type:province;border=edge:2,type:province',
            ['C36'] => 'border=edge:3,type:province;border=edge:4,type:province;border=edge:5,type:province',
            ['C38'] => 'path=a:0,b:3;border=edge:1,type:province',
            ['D19'] => 'border=edge:3,type:province;border=edge:4,type:province;border=edge:5,type:province',
            ['D21'] => 'border=edge:1,type:province',
            ['D35'] => 'border=edge:4,type:province',
            ['D37'] => 'path=a:0,b:3;border=edge:0,type:province;border=edge:1,type:province;border=edge:2,type:province',
            ['D59'] => 'path=a:1,b:4;border=edge:5,type:province',
            ['D61'] => 'path=a:1,b:3;border=edge:0,type:province',
            ['E18'] => 'border=edge:4,type:province',
            ['E20'] => 'border=edge:0,type:province;border=edge:1,type:province;border=edge:2,type:province',
            ['E36'] => 'path=a:0,b:3;border=edge:3,type:province;border=edge:4,type:province;border=edge:5,type:province',
            ['E38'] => 'border=edge:1,type:province',
            ['E60'] => 'border=edge:2,type:province;border=edge:3,type:province;' \
                       'border=edge:4,type:province;border=edge:5,type:province',
            ['E62'] => 'border=edge:1,type:province',
            ['F19'] => 'border=edge:3,type:province;border=edge:4,type:province',
            ['F21'] => 'border=edge:1,type:province;border=edge:5,type:province',
            ['F35'] => 'path=a:0,b:3;border=edge:4,type:province',
            ['F37'] => 'border=edge:0,type:province;border=edge:1,type:province;border=edge:2,type:province',
            ['F59'] => 'border=edge:4,type:province',
            ['F61'] => 'border=edge:0,type:province;border=edge:1,type:province;' \
                       'border=edge:2,type:province;border=edge:5,type:province',
            ['G36'] => 'border=edge:3,type:province;border=edge:4,type:province;border=edge:5,type:province',
            ['G38'] => 'border=edge:0,type:province;border=edge:1,type:province;border=edge:5,type:province',
            ['G40'] => 'border=edge:0,type:province;border=edge:5,type:province',
            ['G42'] => 'border=edge:0,type:province',
            ['G60'] => 'border=edge:3,type:province',
            ['H35'] => 'border=edge:4,type:province;border=edge:5,type:province',
            ['H37'] => 'border=edge:1,type:province;border=edge:2,type:province;border=edge:3,type:province',
            ['H39'] => 'border=edge:2,type:province;border=edge:3,type:province',
            ['H41'] => 'border=edge:2,type:province;border=edge:3,type:province',
            ['I34'] => 'border=edge:4,type:province;border=edge:5,type:province',
            ['I36'] => 'border=edge:1,type:province;border=edge:2,type:province',
            ['J1'] => 'border=edge:0,type:province;border=edge:5,type:province',
            ['K0'] => 'border=edge:3,type:province',
            ['J3'] => 'border=edge:0,type:province',
            ['J33'] => 'border=edge:4,type:province;border=edge:5,type:province',
            ['J35'] => 'border=edge:1,type:province;border=edge:2,type:province',
            ['K2'] => 'border=edge:2,type:province;border=edge:3,type:province;border=edge:4,type:province',
            ['K32'] => 'border=edge:4,type:province;border=edge:5,type:province',
            ['K34'] => 'border=edge:0,type:province;border=edge:1,type:province;' \
                       'border=edge:2,type:province;border=edge:5,type:province',
            ['K36'] => 'border=edge:0,type:province',
            ['K4'] => 'border=edge:0,type:province;border=edge:1,type:province',
            ['L3'] => 'border=edge:3,type:province;border=edge:4,type:province',
            ['L33'] => 'border=edge:2,type:province;border=edge:3,type:province',
            ['L35'] => 'border=edge:2,type:province;border=edge:3,type:province',
            ['L5'] => 'border=edge:0,type:province;border=edge:1,type:province',
            ['M18'] => 'border=edge:5,type:province',
            ['M20'] => 'border=edge:0,type:province;border=edge:5,type:province',
            ['M4'] => 'border=edge:3,type:province;border=edge:4,type:province;border=edge:5,type:province',
            ['M6'] => 'border=edge:1,type:province',
            ['N17'] => 'border=edge:4,type:province;border=edge:5,type:province',
            ['N19'] => 'border=edge:1,type:province;border=edge:2,type:province;border=edge:3,type:province',
            ['N21'] => 'border=edge:2,type:province',
            ['N3'] => 'border=edge:4,type:province',
            ['N5'] => 'border=edge:0,type:province;border=edge:1,type:province;border=edge:2,type:province',
            ['O10'] => 'border=edge:0,type:province;border=edge:5,type:province',
            ['O12'] => 'border=edge:0,type:province;border=edge:5,type:province',
            ['O14'] => 'border=edge:0,type:province;border=edge:5,type:province',
            ['O16'] => 'border=edge:0,type:province;border=edge:4,type:province;border=edge:5,type:province',
            ['O18'] => 'border=edge:0,type:province;border=edge:1,type:province;border=edge:2,type:province',
            ['O4'] => 'border=edge:3,type:province;border=edge:4,type:province;border=edge:5,type:province',
            ['O6'] => 'border=edge:0,type:province;border=edge:1,type:province;border=edge:5,type:province',
            ['O8'] => 'border=edge:0,type:province;border=edge:5,type:province',
            ['P11'] => 'border=edge:2,type:province;border=edge:3,type:province',
            ['P13'] => 'border=edge:2,type:province;border=edge:3,type:province',
            ['P15'] => 'border=edge:2,type:province;border=edge:3,type:province',
            ['P17'] => 'border=edge:2,type:province;border=edge:3,type:province',
            ['P3'] => 'border=edge:4,type:province',
            ['P5'] => 'border=edge:0,type:province;border=edge:1,type:province;' \
                      'border=edge:2,type:province;border=edge:3,type:province',
            ['P7'] => 'border=edge:2,type:province;border=edge:3,type:province',
            ['P9'] => 'border=edge:2,type:province;border=edge:3,type:province',
            ['Q2'] => 'border=edge:0,type:province;border=edge:5,type:province',
            ['Q4'] => 'border=edge:0,type:province;border=edge:3,type:province;' \
                      'border=edge:4,type:province;border=edge:5,type:province',
            ['Q6'] => 'border=edge:1,type:province',
            ['R1'] => 'border=edge:3,type:province',
            ['R3'] => 'border=edge:2,type:province;border=edge:3,type:province;border=edge:4,type:province',
            ['R5'] => 'border=edge:0,type:province;border=edge:1,type:province;border=edge:2,type:province',
            ['S4'] => 'border=edge:3,type:province;border=edge:4,type:province',
            ['S6'] => 'border=edge:0,type:province;border=edge:1,type:province',
            ['T5'] => 'border=edge:3,type:province;border=edge:4,type:province',
            ['T7'] => 'border=edge:1,type:province',
            ['U82'] => 'border=edge:0,type:province;border=edge:5,type:province',
            ['U84'] => 'border=edge:0,type:province;border=edge:5,type:province',
            ['U86'] => 'border=edge:0,type:province;border=edge:4,type:province;border=edge:5,type:province',
            ['V81'] => 'border=edge:3,type:province',
            ['V83'] => 'border=edge:2,type:province;border=edge:3,type:province',
            ['V85'] => 'border=edge:2,type:province;border=edge:3,type:province',
            ['U88'] => 'border=edge:1,type:province;border=edge:2,type:province',
            ['V87'] => 'border=edge:2,type:province',
            ['X41'] => 'border=edge:5,type:province',
            ['Y40'] => 'path=a:5,b:1;border=edge:4,type:province',
            ['Y42'] => 'border=edge:1,type:province;border=edge:2,type:province',
          },
        }.freeze

        SEA_ZONES = {
          'Celtic Sea' => %w[
            A2 A4 A6 A8 A10 A12 A14 A16 A18 B1 B3 B5
            B7 B9 B11 B13 B15 B17 B19 C2 C4 C6 C8 C10
            C12 C14 C16 C18 D1 D3 D5 D7 D9 D11 D13 D15
            D17 D19 E2 E4 E6 E8 E10 E12 E14 E16 E18 F1
            F3 F5 F7 F9 F11 F13 F15 F17 F19 G2 G4 G6
            G8 G10 G12 G14 G22 H1 H3 H5 H7 H9 H11 H13
            H23 I2 I4 I6 I8 I10 I12 I22 I24 J1 J3 J5
            J7 J9 J11 J21 K4 K6 K8 K10 K12 K14 K16 K18
            K20 L5 L7 L9 L11 L13 L15 L17 L19 L21 M6 M8
            M10 M12 M14 M16 M18 M20 N5 N7 N9 N11 N13 N15
            N17 O6 O8 O10 O12 O14 O16
          ].freeze,
          'North Atlantic Ocean' => %w[
            K2 L1 L3 M2 M4 N1 N3 O2 O4 P1 P3 Q2 Q4
          ].freeze,
          'North Atlantic (Silver Coast)' => %w[
            R1 R3 S2 S4 T1 T3 T5 U2 U4 V1 V3 W2
            W4 X1 X3
          ].freeze,
          'Bay of Biscay' => %w[
            P5 P7 P9 P11 P13 P15 P17 Q6 Q8 Q10 Q12 Q14
            Q16 Q18 R5 R7 R9 R11 R13 R15 R17 R19 R21 S6
            S8 S10 S12 S14 S16 S18 S20 S22 T7 T9 T11 T13
            T15 T17 T19 T21 U14 U16 U18 U20
          ].freeze,
          'English Channel' => %w[
            L33 L35 M32 N19 N21 N23 N25 N27 N29 O18 O20 O22
            O26
          ].freeze,
          'North Sea' => %w[
            A20 A22 A24 A26 A28 A30 A32 A34 A36 B21 B23 B25
            B27 B29 B31 B33 B35 C20 C22 C24 C26 C28 C30 C32
            C34 C36 D21 D23 D27 D29 D31 D33 D35 E20 E22 E30
            E32 E34 E36 F21 F31 F33 F35 G30 G32 G34 G36 H31
            H33 H35 I30 I32 I34 J31 J33 K32
          ].freeze,
          'Skagerrak' => %w[
            A38 A40 B37 B39 B43 C38 C40 D37 D39 E38 E40 E46 F37 F39
            F41 F43 F45 F47 G38 G40 G42 G48 H49
          ].freeze,
          'German Bight' => %w[
            H37 H39 H41 I36 I38 I40 I42 J35 J37 J39 J41 J43
            K34 K36 K38
          ].freeze,
          'Baltic Sea' => %w[
            E60 F57 F59 G58 G60 G62 H57 H59 H61 I54 I56 I58 I60
            I62 J51 J53 J55 J57 J59 J61 K52
          ].freeze,
          'Gulf of Finland' => %w[
            A58 A60 A62 B59 B61 C60 C62 C68 C70 D59 D61 D63
            D65 E62 E64 F61 F63 F65 F67
          ].freeze,
          'Strait of Gibraltar' => %w[
            AC2 AC4 AD1 AD3 AE2 AE4 AE6 AE8 AE10 AF1 AF3 AF7 AF9
            AG2 AG4 AG6 AG8 AG10 AH1 AH3 AH5 AH7 AH9
          ].freeze,
          'Balearic Sea' => %w[
            AA24 AA26 AB21 AB23 AB25 AC22 AC24 AD19 AD21 AD23 AD25 AE12
            AE14 AE16 AE18 AE20 AE22 AE24 AF13 AF15 AF17 AF19 AF21 AF23
            AG12 AG14 AG16 AG18 AG20 AG22 AG24 AH11 AH13 AH15 AH17 AH19
            AH21 AH23 AH25 AF25
          ].freeze,
          'Sea of Sardinia' => %w[
            X31 X39 Y30 Y32 Y34 Y36 Y38 Y40 Z29 Z31 Z33 Z35
            Z37 Z39 AA28 AA30 AA32 AA34 AA36 AA38 AA40 AB29 AB31 AB33
            AB35 AB37 AC26 AC28 AC30 AC32 AC34 AC36 AD27 AD29 AD31
            AD33 AD35 AD37 AE26 AE28 AE30 AE32 AE34 AE36 AF27 AF29 AF31
            AF33 AF35 AG26 AG28 AG30 AG32 AG34 AG36 AG38 AH27 AH29 AH31
            AH33 AH35 AH37 AH39
            X41
          ].freeze,
          'Tyrrhenian Sea' => %w[
            Y42 Z43 AA42 AA44 AA46 AB43 AB45 AB47 AB49 AC42 AC44
            AC46 AC48 AC50 AC52 AD41 AD43 AD45 AD47 AD49 AD51 AD53 AD57
            AD59 AE38 AE40 AE42 AE44 AE46 AE48 AE50 AE54 AE56 AE58 AF37
            AF39 AF41 AF43 AF45 AF47 AF55 AF57 AF59 AG42 AG44 AG46 AG48
            AG40 AG54 AG56 AG58 AH41 AH43 AH45 AH47 AH49 AH51 AH53 AH55 AH57
            AH59
          ].freeze,
          'Adriatic Sea' => %w[
            V49 W50 W52 X51 X53 Y52 Y54 Z53 Z55 Z57 Z59 AA56
            AA58 AA60 AB59 AB61 AC60 AC62 AD61 AD63
          ].freeze,
          'Aegean Sea' => %w[
            AB73 AB75 AB79 AB81 AC70 AC72 AC74 AD73 AD75 AD77 AE60 AE62 AE64
            AE66 AE74 AE76 AE78 AF61 AF63 AF65 AF71 AF73 AF75 AF77 AG60 AG62
            AG64 AG66 AG72 AG74 AG76 AH61 AH63 AH65 AH67 AH69 AH71 AH73
            AH75
          ].freeze,
          'Levantine Sea' => %w[
            AF79 AG78 AG80 AG82 AG84 AG88 AH77 AH79 AH81 AH83 AH85
          ].freeze,
          'Black Sea' => %w[
            V81 V83 V85 V87 W80 W82 W84 W86 X79 X81 X83 X85
            X87 Y80 Y82 Y84 Y86 Z81 Z83 Z85 Z87
            U88
          ].freeze,
          'Karkinitsky Bay' => %w[
            T83 T85 T87 U82 U84 U86
          ].freeze,
        }.freeze
      end
    end
  end
end
