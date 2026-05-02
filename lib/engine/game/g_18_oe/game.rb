# frozen_string_literal: true

require_relative 'meta'
require_relative 'entities'
require_relative 'map'
require_relative '../base'
require_relative 'round/consolidation'
require_relative 'step/consolidate'

module Engine
  module Game
    module G18OE
      class Game < Game::Base
        include_meta(G18OE::Meta)
        include G18OE::Entities
        include G18OE::Map
        attr_accessor :minor_regional_order, :minor_available_regions, :minor_floated_regions, :regional_corps_floated,
                      :consolidation_triggered, :consolidation_done

        MARKET = [
          ['', '110', '120C', '135', '150', '165', '180', '200', '225', '250', '280', '310', '350', '390', '440', '490', '550'],
          %w[90p 100 110C 120 135 150 165 180 200 225 250 280 310 350 390 440 490],
          %w[80p 90 100C 110 120 135 150 165 180 200 225 250 280 310],
          %w[75p 80 90C 100 110 120 135 150 165 180 200],
          %w[70p 75 80C 90 100 110 120 135 150],
          %w[65p 70 75C 80 90 100 110],
          %w[60p 65 70 75 80],
          %w[50 60 65 70],
        ].freeze
        CERT_LIMIT = { 2 => 99, 3 => 48, 4 => 36, 5 => 29, 6 => 24, 7 => 20 }.freeze
        # Standard game: £5,400 total / num_players, rounded up to nearest £5.
        # 2-player variant uses without-concessions formula (£5,200 / 2 = £2,600).
        STARTING_CASH = { 2 => 2600, 3 => 1800, 4 => 1350, 5 => 1080, 6 => 900, 7 => 775 }.freeze
        BANK_CASH = 54_000
        CAPITALIZATION = :incremental
        SELL_BUY_ORDER = :sell_buy
        MUST_SELL_IN_BLOCKS = false
        HOME_TOKEN_TIMING = :float
        TILE_UPGRADES_MUST_USE_MAX_EXITS = [:cities].freeze

        STOCKMARKET_COLORS = {
          par: :blue,
          convert_range: :red,
        }.freeze

        MARKET_TEXT = {
          par: 'Regional par values',
          convert_range: 'Major par values',
        }.freeze

        PHASES = [
          {
            name: '2',
            train_limit: { minor: 2, regional: 2, major: 4 },
            tiles: [:yellow],
            operating_rounds: 2,
            status: ['train_obligation'],
          },
          {
            name: '3',
            on: '3',
            train_limit: { minor: 2, regional: 2, major: 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['train_obligation'],
          },
          {
            name: '4',
            on: '4',
            train_limit: { minor: 1, regional: 1, major: 3, national: 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_trains_from_others'],
          },
          {
            name: '5',
            on: '5',
            train_limit: { minor: 1, regional: 1, major: 3, national: 4 },
            tiles: %i[yellow green brown],
            operating_rounds: 2,
            status: ['can_buy_trains_from_others'],
          },
          {
            name: '6',
            on: '6',
            train_limit: { major: 2, national: 3 },
            tiles: %i[yellow green brown],
            operating_rounds: 2,
            status: ['can_buy_trains_from_others'],
          },
          {
            name: '7',
            on: '7+7',
            train_limit: { major: 2, national: 3 },
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
            status: ['can_buy_trains_from_others'],
          },
          {
            name: '8',
            on: '8+8',
            train_limit: { major: 2, national: 3 },
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
            status: ['can_buy_trains_from_others'],
          },
        ].freeze

        TRAINS = [
          # Level 2 — yellow; rusts when first Level 4 train is bought
          {
            name: '2+2',
            distance: [{ 'nodes' => ['town'], 'pay' => 2, 'visit' => 99 },
                       { 'nodes' => %w[city offboard town], 'pay' => 2, 'visit' => 2 }],
            price: 100,
            rusts_on: '4',
            num: 35,
          },
          # Level 3 — green double-sided (3 / 3+3); rust at Level 6
          {
            name: '3',
            distance: [{ 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 },
                       { 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 }],
            price: 200,
            rusts_on: '6',
            variants: [{
              name: '3+3',
              distance: [{ 'nodes' => ['town'], 'pay' => 3, 'visit' => 99 },
                         { 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 }],
              price: 225,
              rusts_on: '6',
            }],
            num: 24,
          },
          # Level 4 — green double-sided (4 / 4+4); rust at Level 8
          {
            name: '4',
            distance: [{ 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 },
                       { 'nodes' => %w[city offboard town], 'pay' => 4, 'visit' => 4 }],
            price: 300,
            rusts_on: '8+8',
            variants: [{
              name: '4+4',
              distance: [{ 'nodes' => ['town'], 'pay' => 4, 'visit' => 99 },
                         { 'nodes' => %w[city offboard town], 'pay' => 4, 'visit' => 4 }],
              price: 350,
              rusts_on: '8+8',
            }],
            num: 14,
          },
          # Level 5 — brown double-sided (5 / 5+5); permanent
          {
            name: '5',
            distance: [{ 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 },
                       { 'nodes' => %w[city offboard town], 'pay' => 5, 'visit' => 5 }],
            price: 400,
            variants: [{
              name: '5+5',
              distance: [{ 'nodes' => ['town'], 'pay' => 5, 'visit' => 99 },
                         { 'nodes' => %w[city offboard town], 'pay' => 5, 'visit' => 5 }],
              price: 475,
            }],
            num: 11,
            events: [{ 'type' => 'consolidation_triggered' }],
          },
          # Level 6 — brown double-sided (6 / 6+6); permanent
          {
            name: '6',
            distance: [{ 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 },
                       { 'nodes' => %w[city offboard town], 'pay' => 6, 'visit' => 6 }],
            price: 525,
            variants: [{
              name: '6+6',
              distance: [{ 'nodes' => ['town'], 'pay' => 6, 'visit' => 99 },
                         { 'nodes' => %w[city offboard town], 'pay' => 6, 'visit' => 6 }],
              price: 600,
            }],
            num: 9,
          },
          # Level 7 — gray double-sided (7+7 / 4D); permanent
          # NOTE: Level 8 trains become available only after the 4th Level 7 purchase
          {
            name: '7+7',
            distance: [{ 'nodes' => ['town'], 'pay' => 7, 'visit' => 99 },
                       { 'nodes' => %w[city offboard town], 'pay' => 7, 'visit' => 7 }],
            price: 750,
            variants: [{
              name: '4D',
              distance: [{ 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 },
                         { 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 99 }],
              price: 850,
            }],
            num: 17,
          },
          # Level 8 — gray double-sided (8+8 / 5D); permanent
          {
            name: '8+8',
            distance: [{ 'nodes' => ['town'], 'pay' => 8, 'visit' => 99 },
                       { 'nodes' => %w[city offboard town], 'pay' => 8, 'visit' => 8 }],
            price: 900,
            variants: [{
              name: '5D',
              distance: [{ 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 },
                         { 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 99 }],
              price: 1000,
            }],
            num: 11,
          },
        ].freeze

        CORPORATIONS_TRACK_RIGHTS = {
          # United Kingdom
          'LNWR' => 'UK',
          'GWR' => 'UK',
          'GSWR' => 'UK',
          # France / Belgium
          'PLM' => 'FR',
          'MIDI' => 'FR',
          'OU' => 'FR',
          'BEL' => 'FR',
          # Prussia / Holland / Switzerland
          'BHB' => 'PHS',
          'POB' => 'PHS',
          'KSS' => 'PHS',
          'KBS' => 'PHS',
          # Austria-Hungary
          'SB' => 'AH',
          'MAV' => 'AH',
          # Italy
          'SFAI' => 'IT',
          'SFR' => 'IT',
          # Spain / Portugal
          'CHN' => 'SP',
          'MZA' => 'SP',
          'RCP' => 'SP',
          # Russia
          'MSP' => 'RU',
          'MKV' => 'RU',
          'LRZD' => 'RU',
          'WW' => 'RU',
          # Scandinavia
          'DSJ' => 'SC',
          'BJV' => 'SC',
        }.freeze

        NATIONAL_REGION_HEXES = {
          # United Kingdom / Ireland
          'UK' => %w[D25 E24 E26 E28 F23 F25 F27 F29 G16 G18 G20 G24 G26 G28
                     H15 H17 H19 H21 H25 H27 H29 I14 I16 I18 I20 I26 I28
                     J13 J15 J17 J19 J23 J25 J27 J29 K22 K24 K26 K28 K30
                     L23 L25 L27 L29 L31 M22 M24 M26 M28 M30],
          # Scandinavia (Sweden / Norway / Denmark)
          'SC' => %w[A42 A44 A46 A48 A50 A52 A54 A56 B41 B43 B45 B47 B49 B51 B53 B55 B57
                     C42 C44 C46 C48 C50 C52 C54 C56 C58 D41 D43 D45 D47 D49 D51 D53 D55 D57
                     E42 E44 E48 E50 E52 E54 E56 E58 F49 F51 F53 F55
                     G44 G46 G50 G52 G54 G56 H43 H45 H47 H51 H53 H55 I44 I46 I48 I50 I52],
          # France / Belgium
          'FR' => %w[N31 N33 N35 N37 O24 O28 O30 O32 O34 O36 O38
                     P19 P21 P23 P25 P27 P29 P31 P33 P35 P37
                     Q20 Q22 Q24 Q26 Q28 Q30 Q32 Q34 Q36 Q38
                     R23 R25 R27 R29 R31 R33 R35 R37 R39
                     S24 S26 S28 S30 S32 S34 S36 S38 T23 T25 T27 T29 T31 T33 T35 T37
                     U22 U24 U26 U28 U30 U32 U34 U36 U38
                     V21 V23 V25 V27 V29 V31 V33 V35 V37
                     W22 W24 W26 W28 W30 W32 W34 W36 W38
                     X25 X27 X29 X33 X35 X37 Y28 Z41 AF25],
          # Prussia / Holland / Switzerland
          'PHS' => %w[I64 J45 J47 J49 J63 J65 K40 K42 K44 K46 K48 K50 K54 K56 K58 K60 K62 K64
                      L37 L39 L41 L43 L45 L47 L49 L51 L53 L55 L57 L59 L61
                      M34 M36 M38 M40 M42 M44 M46 M48 M50 M52 M54 M56 M58
                      N37 N39 N41 N43 N45 N47 N49 N51 N53 N55 N57
                      O38 O40 O42 O44 O46 O48 O50 O52 O54 O56 O58
                      P39 P41 P43 P45 P47 P49 Q38 Q40 Q42 Q44 Q46 Q48 Q50
                      R39 R41 R43 R45 R47 R49 R51 S38 S40 S42 S44 S46 S48
                      T37 T39 T41 T43 U38 U40 U42],
          # Austria-Hungary
          'AH' => %w[O52 O54 P49 P51 P53 P55 P57 P59 P61 P63 P65 P67 P69 P71 P73
                     Q50 Q52 Q54 Q56 Q58 Q60 Q62 Q64 Q66 Q68 Q70 Q72 Q74
                     R51 R53 R55 R57 R59 R61 R63 R65 R67 R69 R71 R73
                     S44 S46 S48 S50 S52 S54 S56 S58 S60 S62 S64 S66 S68 S70 S72 S74
                     T45 T47 T49 T51 T53 T55 T57 T59 T61 T63 T65 T67 T69 T71 T73 T75
                     U50 U52 U54 U56 U58 U60 U62 U64 U66 U68 U70 U72 U74
                     V51 V53 V55 V57 V59 V61 V63 V65 V67 V69
                     W54 W56 W58 W60 X55 X57 X59 X61 Y56 Y58 Y60 Y62],
          # Italy
          'IT' => %w[U38 U40 U42 U44 U46 U48 V37 V39 V41 V43 V45 V47
                     W38 W40 W42 W44 W46 W48 X43 X45 X47 X49 Y44 Y46 Y48 Y50
                     Z45 Z47 Z49 Z51 AA48 AA50 AA52 AA54
                     AB39 AB41 AB51 AB53 AB55 AB57 AC38 AC40 AC54 AC56 AC58
                     AD39 AD55 AE52 AF49 AF51 AF53 AG40 AG50 AG52],
          # Spain / Portugal
          'SP' => %w[U6 U8 U10 U12 V5 V7 V9 V11 V13 V15 V17 V19
                     W6 W8 W10 W12 W14 W16 W18 W20 W22
                     X5 X7 X9 X11 X13 X15 X17 X19 X21 X23 X25
                     Y2 Y4 Y6 Y8 Y10 Y12 Y14 Y16 Y18 Y20 Y22 Y24 Y26 Y28
                     Z1 Z3 Z5 Z7 Z9 Z11 Z13 Z15 Z17 Z19 Z21 Z23 Z25 Z27
                     AA2 AA4 AA6 AA8 AA10 AA12 AA14 AA16 AA18 AA20 AA22
                     AB1 AB3 AB5 AB7 AB9 AB11 AB13 AB15 AB17 AB19
                     AC6 AC8 AC10 AC12 AC14 AC16 AC18 AC20
                     AD1 AD5 AD7 AD9 AD11 AD13 AD15 AD17 AF5 AF11],
          # Russia
          'RU' => %w[A64 A66 A68 A70 A72 A74 B63 B65 B67 B69 B71 B73 B75 B77 B79 B81 B83
                     C64 C66 C72 C74 C76 C78 C80 C82 D67 D69 D71 D73 D75 D77 D79 D81 D83 D85
                     E66 E68 E70 E72 E74 E76 E78 E80 E82 E84 E86
                     F69 F71 F73 F75 F77 F79 F81 F83 F85 F87
                     G64 G66 G68 G70 G72 G74 G76 G78 G80 G82 G84 G86 G88
                     H63 H65 H67 H69 H71 H73 H75 H77 H79 H81 H83 H85 H87
                     I64 I66 I68 I70 I72 I74 I76 I78 I80 I82 I84 I86
                     J67 J69 J71 J73 J75 J77 J79 J81 J83 J85 J87
                     K64 K66 K68 K70 K72 K74 K76 K78 K80 K82 K84 K86
                     L61 L63 L65 L67 L69 L71 L73 L75 L77 L79 L81 L83 L85 L87
                     M58 M60 M62 M64 M66 M68 M70 M72 M74 M76 M78 M80 M82 M84 M86
                     N59 N61 N63 N65 N67 N69 N71 N73 N75 N77 N79 N81 N83 N85 N87
                     O58 O60 O62 O64 O66 O68 O70 O72 O74 O76 O78 O80 O82 O84 O86
                     P73 P75 P77 P79 P81 P83 P85 P87 Q74 Q76 Q78 Q80 Q82 Q84 Q86
                     R75 R77 R79 R81 R83 R85 R87 S76 S78 S80 S82 S84 S86 S88 T79 T81 T87 U80],
        }.freeze

        # Cities that sit on a national-zone border hex (hex listed in two zones).
        # All other cities belong unambiguously to one zone; only these two need an explicit override.
        CITY_NATIONAL_ZONE = {
          'Q38' => 'FR',  # Nancy   — FR/PHS border hex
          'O52' => 'PHS', # Dresden — PHS/AH border hex
        }.freeze

        # Cities excluded from minor home-token placement regardless of zone membership.
        # These are Balkan / Ottoman / south-east European cities outside the concession
        # railroad system. Most are already outside all zone hex lists; S76 (Jassy) is the
        # only one currently inside a zone (RU) that requires active filtering.
        # AA82 (Constantinople) is also excluded via metropolis_hex? but listed here for clarity.
        MINOR_EXCLUDED_HOME_CITIES = %w[
          S76 W64 W74 Y70
          AA62 AB69 AD79 AE72 AA82
        ].freeze

        TRACK_RIGHTS_COST = {
          'UK' => 40,
          'PHS' => 40,
          'FR' => 20,
          'AH' => 20,
          'IT' => 10,
          'SP' => 10,
          'RU' => 10,
          'SC' => 10,
        }.freeze

        MAX_FLOATED_REGIONALS = 18

        # still need green+ OE specific track tiles
        TILES = {
          '3' => 14,
          '4' => 25,
          '5' => 25,
          '6' => 15,
          '7' => 14,
          '8' => 99,
          '9' => 99,
          '12' => 10,
          '13' => 8,
          '57' => 19,
          '58' => 25,
          '80' => 5,
          '81' => 5,
          '82' => 20,
          '83' => 20,
          '141' => 15,
          '142' => 15,
          '143' => 5,
          '144' => 5,
          '145' => 13,
          '146' => 21,
          '147' => 13,
          '201' => 9,
          '202' => 18,
          '205' => 17,
          '206' => 17,
          '207' => 12,
          '208' => 9,
          '544' => 8,
          '545' => 8,
          '546' => 7,
          '621' => 12,
          '622' => 9,
          'OE1' =>
            {
              'count' => 4,
              'color' => 'yellow',
              'code' => 'town=revenue:10;town=revenue:10;path=a:0,b:_0;path=a:_0,b:_1;path=a:_1,b:3',
            },
          'OE2' =>
            {
              'count' => 6,
              'color' => 'yellow',
              'code' => 'town=revenue:10;town=revenue:10;path=a:0,b:_0;path=a:_0,b:_1;path=a:_1,b:2',
            },
          'OE3' =>
            {
              'count' => 2,
              'color' => 'yellow',
              'code' => 'town=revenue:10;town=revenue:10;path=a:0,b:_0;path=a:_0,b:_1;path=a:_1,b:1',
            },
          'OE4' =>
            {
              'count' => 5,
              'color' => 'yellow',
              'code' => 'city=revenue:30;city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_2;label=ABP',
            },
          'OE5' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:_0,b:1;path=a:5,b:_1;path=a:_1,b:3;label=C',
            },
          'OE6' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:5,b:_0;path=a:2,b:_1;path=a:4,b:_1;label=L',
            },
          'OE7' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:4,b:_1;label=N',
            },
          'OE8' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:5,b:_1;label=S',
            },
          # 'OE9' => 3, green, double town
          # 'OE10' => 3, green, double town
          # 'OE11' => 3, green, double town
          'OE12' =>
            {
              'count' => 3,
              'color' => 'green',
              'code' => 'city=revenue:50;city=revenue:50;city=revenue:50;path=a:0,b:_0;path=a:_0,b:3;'\
                        'path=a:2,b:_1;path=a:_1,b:5;path=a:4,b:_2;path=a:_2,b:1;label=A',
            },
          'OE13' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:60;city=revenue:60;city=revenue:60;path=a:0,b:_0;path=a:_0,b:3;'\
                        'path=a:2,b:_1;path=a:_1,b:5;path=a:4,b:_2;path=a:_2,b:1;label=B',
            },
          'OE14' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:50;city=revenue:50,slots:2;path=a:0,b:_0;path=a:_0,b:1;path=a:5,b:_1;path=a:_1,b:3;label=C',
            },
          'OE15' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:60,slots:2;city=revenue:60,slots:2;path=a:1,b:_0;path=a:5,b:_0;'\
                        'path=a:2,b:_1;path=a:3,b:_1;path=a:4,b:_1;label=L',
            },
          'OE16' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:50,slots:2;city=revenue:50;path=a:1,b:_0;path=a:_0,b:3;path=a:4,b:_1;path=a:_1,b:2;label=N',
            },
          'OE17' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:50;city=revenue:50;city=revenue:50;path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_2;label=P',
            },
          'OE18' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:50;city=revenue:50,slots:2;path=a:0,b:_0;path=a:_0,b:2;path=a:5,b:_1;path=a:_1,b:3;label=S',
            },
          # 'OE20' => 3, brown, two towns
          # 'OE21' => 2, brown, two towns
          # 'OE22' => 6, brown, two towns
          'OE23' =>
            {
              'count' => 12,
              'color' => 'brown',
              'code' => 'city=revenue:40;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            },
          'OE24' =>
            {
              'count' => 20,
              'color' => 'brown',
              'code' => 'city=revenue:40;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0',
            },
          'OE25' =>
            {
              'count' => 12,
              'color' => 'brown',
              'code' => 'city=revenue:40;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            },
          'OE26' =>
            {
              'count' => 5,
              'color' => 'brown',
              'code' => 'city=revenue:80,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                        'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=ACS',
            },
          'OE27' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                        'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=B',
            },
          'OE28' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:90,slots:4;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=L',
            },
          'OE29' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:80,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=N',
            },
          'OE30' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:80;city=revenue:80;city=revenue:80;path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_1;'\
                        'path=a:3,b:_2;path=a:4,b:_2;path=a:5,b:_0;label=P',
            },
          'OE31' =>
            {
              'count' => 3,
              'color' => 'brown',
              'code' => 'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;label=Y',
            },
          'OE32' =>
            {
              'count' => 3,
              'color' => 'brown',
              'code' => 'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=Y',
            },
          'OE33' =>
            {
              'count' => 11,
              'color' => 'brown',
              'code' => 'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                        'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Y',
            },
          'OE34' =>
            {
              'count' => 5,
              'color' => 'gray',
              'code' => 'city=revenue:60;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0',
            },
          'OE35' =>
            {
              'count' => 6,
              'color' => 'gray',
              'code' => 'city=revenue:60;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            },
          'OE36' =>
            {
              'count' => 16,
              'color' => 'gray',
              'code' => 'city=revenue:60;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            },
          'OE37' =>
            {
              'count' => 5,
              'color' => 'gray',
              'code' => 'city=revenue:100,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                        'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=APS',
            },
          'OE38' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' => 'city=revenue:120,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                        'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=B',
            },
          'OE39' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' => 'city=revenue:100,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                        'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=B',
            },
          'OE40' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' => 'city=revenue:120,slots:4;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=L',
            },
          'OE41' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' => 'city=revenue:100,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=N',
            },
          'OE42' =>
            {
              'count' => 3,
              'color' => 'gray',
              'code' => 'city=revenue:80,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;label=Y',
            },
          'OE43' =>
            {
              'count' => 3,
              'color' => 'gray',
              'code' => 'city=revenue:80,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=Y',
            },
          'OE44' =>
            {
              'count' => 11,
              'color' => 'gray',
              'code' => 'city=revenue:80,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                        'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Y',
            },
        }.freeze

        def setup
          super
          @minor_regional_order = []
          # Derive available regions from the regional corporations actually defined,
          # using only zones present in CORPORATIONS_TRACK_RIGHTS. This is failsafe:
          # zones not yet in NATIONAL_REGION_HEXES are simply skipped at token placement.
          @minor_available_regions = corporations
            .select { |c| c.type == :regional }
            .map { |c| CORPORATIONS_TRACK_RIGHTS[c.id] }
            .compact
          @minor_floated_regions = {}
          @regional_corps_floated = 0

          corporations.each do |corp|
            corp.par_via_exchange = companies.find { |c| c.sym == corp.id } if corp.type == :minor
          end
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end

        # True once MAX_FLOATED_REGIONALS have been floated and the 6 remaining
        # unfloated regionals have been closed. This is the correct trigger for
        # "Major Railroad Phase" entry: conversions and secondary-share purchases
        # become available from this point on.
        def major_phase?
          @regional_corps_floated >= self.class::MAX_FLOATED_REGIONALS
        end

        def operating_order
          @minor_regional_order + @corporations.select { |c| %i[major national].include?(c.type) }.sort
        end

        def hex_within_national_region?(entity, hex)
          region = self.class::CORPORATIONS_TRACK_RIGHTS[entity.id] || @minor_floated_regions[entity.id]
          hexes = self.class::NATIONAL_REGION_HEXES[region]
          hexes&.include?(hex.coordinates) || false
        end

        def home_token_locations(corporation)
          available_regions = self.class::NATIONAL_REGION_HEXES.select { |key, _| @minor_available_regions.include?(key) }
          region_hexes = available_regions.values.flatten

          @hexes
            .select { |hex| region_hexes.include?(hex.coordinates) }
            .select { |hex| hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) } }
            .reject { |hex| metropolis_hex?(hex) }
            .reject { |hex| self.class::MINOR_EXCLUDED_HOME_CITIES.include?(hex.coordinates) }
        end

        def metropolis_hex?(hex)
          %w[A56 B41 C74 F87 K26 M28 M50 Q30 R55 Y14 AA82 AB51].include?(hex.name.to_s)
        end

        def metropolis_tile?(tile)
          %w[OE4 OE5 OE6 OE7 OE8 OE12 OE13 OE14 OE15 OE16 OE17
             OE18 OE26 OE27 OE28 OE29 OE30 OE37 OE38 OE39 OE40 OE41].include?(tile.name.to_s)
        end

        def can_buy_train_from_others?
          @phase.status.include?('can_buy_trains_from_others')
        end

        # UP movement at end of SR: only for majors and nationals that are fully player-held
        def sold_out_increase?(corporation)
          %i[major national].include?(corporation.type)
        end

        def event_consolidation_triggered!
          @consolidation_triggered = true
          @log << '-- Event: Consolidation phase triggered --'
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Operating
              if @consolidation_triggered && !@consolidation_done
                @log << '-- Consolidation Phase --'
                new_consolidation_round
              else
                super
              end
            when Round::G18OE::Consolidation
              @consolidation_done = true
              @turn += 1
              new_stock_round
            else
              super
            end
        end

        def new_consolidation_round
          Round::G18OE::Consolidation.new(self, [
            G18OE::Step::Consolidate,
          ])
        end

        def upgrades_to_correct_label?(from, to)
          return true if from.label == to.label
          return false if from.label && !to.label

          case from.hex.name
          when 'K26', 'Y14', 'R55'
            to.label.to_s.include?('A')
          when 'M50'
            to.label.to_s.include?('B')
          when 'AA82'
            to.label.to_s.include?('C')
          when 'AB51'
            to.label.to_s.include?('N')
          when 'Q30'
            to.label.to_s.include?('P')
          when 'C74'
            to.label.to_s.include?('S')
          end
        end

        def company_becomes_minor?(company)
          corp = @corporations.find { |c| c.name == company.sym }
          return false unless corp

          corp.type == :minor
        end

        def form_button_text(_entity)
          'Float'
        end

        def after_par(corporation)
          super
          # Spend the track rights zone fee when a regional pars.
          # Zones not yet in TRACK_RIGHTS_COST (or not in NATIONAL_REGION_HEXES) are skipped safely.
          region = CORPORATIONS_TRACK_RIGHTS[corporation.id]
          cost = TRACK_RIGHTS_COST[region]
          corporation.spend(cost, @bank) if cost&.positive?
        end

        # Override stock price movement according to 18OE rules
        # - Minors & Regionals: no movement
        # - Majors & Nationals:
        #   * revenue >= share price -> move right
        #   * revenue between 0 and share price -> no move
        #   * revenue = 0 -> move left
        def change_share_price(entity, revenue)
          return if entity.type == :minor || entity.type == :regional

          share_price = entity.share_price.price
          if revenue >= share_price
            @stock_market.move_right(entity)
          elsif revenue.zero?
            @stock_market.move_left(entity)
          end
        end

        def issuable_shares(entity)
          return [] if !entity.corporation? || entity.type != :major

          bundles_for_corporation(entity, entity)
            .select { |bundle| @share_pool.fit_in_bank?(bundle) }
        end

        def value_for_dumpable(player, corporation)
          return 0 if corporation.type == :regional

          super
        end

        def stock_round
          Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G18OE::Step::HomeToken,
            G18OE::Step::BuySellParShares,
          ])
        end

        def new_auction_round
          Round::Auction.new(self, [
            G18OE::Step::WaterfallAuction,
          ])
        end

        def operating_round(round_num)
          Round::G18OE::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::DiscardTrain,
            Engine::Step::HomeToken,
            G18OE::Step::Track,
            G18OE::Step::Token,
            Engine::Step::Route,
            G18OE::Step::Dividend,
            G18OE::Step::BuyTrain,
            # Convert step to do national conversions at 4/6/8?
            Engine::Step::IssueShares,
          ], round_num: round_num)
        end
      end
    end
  end
end
