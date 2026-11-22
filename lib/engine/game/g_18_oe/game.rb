# frozen_string_literal: true

require_relative 'meta'
require_relative 'entities'
require_relative 'map'
require_relative 'stock_market'
require_relative 'graph'
require_relative 'sea_routes'
require_relative 'nationals'
require_relative 'train'
require_relative '../base'
require_relative 'depot'
require_relative 'round/consolidation'
require_relative 'round/concession'
require_relative 'round/fast_start'
require_relative 'step/assign'
require_relative 'step/consolidate'
require_relative 'step/fast_start_capital'
require_relative 'step/form_national'
require_relative 'step/merge_discard_train'
require_relative 'step/national_buy_trains'
require_relative 'step/merge_minor'
require_relative 'step/merge_offer'
require_relative 'step/merge_token'
require_relative 'step/concession'
require_relative 'step/choose_operating_position'
require_relative 'step/reserve_share'
require_relative 'step/orient_express_bonus'
require_relative 'step/transfer_tokens'
require_relative 'step/route'
require_relative 'step/special_choose'
require_relative 'step/special_token'
require_relative 'step/buy_port_authority'

module Engine
  module Game
    module G18OE
      class Game < Game::Base
        include_meta(G18OE::Meta)
        include G18OE::Entities
        include G18OE::Map
        include G18OE::SeaRoutes
        include G18OE::Nationals
        attr_accessor :minor_regional_order, :minor_available_regions, :minor_floated_regions,
                      :consolidation_triggered, :consolidation_complete
        attr_reader :fast_start_minors, :concessions, :merged_minors, :wcf_placeholder, :minor_c_ability,
                    :hochberg_token_hex, :swift_metropolitan_train

        PATRONAGE_DRAWS = [{ group: :pink, count: 3 }, { group: :yellow, count: 3 },
                           { group: :white, count: 3 }, { group: :green, count: 8 }].freeze

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

        PASS_THROUGH_TOKENS = {
          'SHTC' => { logo: '/logos/18_oe/shtc.svg', port: true },
          'CCTC' => { logo: '/logos/18_oe/cctc.svg', port: false },
        }.freeze

        CERT_LIMIT = { 2 => 99, 3 => 48, 4 => 36, 5 => 29, 6 => 24, 7 => 20 }.freeze
        # Standard game: £5,400 total / num_players, rounded up to nearest £5.
        # 2-player variant uses without-concessions formula (£5,200 / 2 = £2,600).
        STARTING_CASH = { 2 => 2600, 3 => 1800, 4 => 1350, 5 => 1080, 6 => 900, 7 => 775 }.freeze
        STARTING_CASH_NO_CONCESSIONS = { 2 => 2600, 3 => 1735, 4 => 1300, 5 => 1040, 6 => 870, 7 => 745 }.freeze
        BANK_CASH = 54_000
        CURRENCY_FORMAT_STR = '£%s'
        CAPITALIZATION = :incremental
        SELL_BUY_ORDER = :sell_buy
        EBUY_FROM_OTHERS = :never
        EBUY_CAN_SELL_SHARES = false
        BANKRUPTCY_ALLOWED = false
        FORCED_NATIONAL_CHOICE = 'national'
        MUST_SELL_IN_BLOCKS = false
        HOME_TOKEN_TIMING = :float
        TILE_RESERVATION_BLOCKS_OTHERS = :always
        REVISITABLE_NODES = %w[town double_town].freeze
        # bank-break ends current OR; first level-8 purchase ends after one more full OR set
        GAME_END_CHECK = { bank: :current_or, final_phase: :one_more_full_or_set }.freeze
        # Physical game includes 20×£5,000 notes set aside at setup; injected when first level-8 bought
        REMAINDER_CASH = 100_000
        ABANDONED_MINOR_PRICE = 60
        TRAIN_CLASS = G18OE::Train
        DEPOT_CLASS = G18OE::Depot
        PULLMAN = 'Pullman'
        PULLMAN_BONUS_PER_LEVEL = 10
        NATIONAL_FILLER_CITY_REVENUE = 60
        NATIONAL_FILLER_TOWN_REVENUE = 10
        TRAIN_ADD_ONS = { pullman: 'Pullman', one_plus_one_marker: '+1+1 marker' }.freeze
        PULLMAN_ROYALTY = 15
        PULLMAN_TRANSFER_PRICE = 75

        STOCKMARKET_COLORS = {
          par: :blue,
          convert_range: :red,
        }.freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'pullmans_available' => ['Pullmans Available', 'Pullman cars may be bought; Minor M receives one free'],
          'minor_d_token' => ['Minor D +£40 Token', 'Minor D\'s +£20 token is removed; its +£40 token may be placed'],
          'level_8_available' => ['Level 8 Trains Available', 'Level 8 trains may be bought'],
          'consolidation_triggered' => [
            'Consolidation Round',
            'Consolidation round follows at end of current OR set; minors and regionals must merge or be abandoned',
          ],
          'remainder_cash_added' => [
            'Remainder Cash Added',
            '£100,000 remainder cash injected into bank; game ends after one more full OR set',
          ]
        ).freeze

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
            status: [],
          },
          {
            name: '5',
            on: '5',
            train_limit: { minor: 1, regional: 1, major: 3, national: 4 },
            tiles: %i[yellow green brown],
            operating_rounds: 2,
            status: [],
          },
          {
            name: '6',
            on: '6',
            train_limit: { major: 2, national: 3 },
            tiles: %i[yellow green brown],
            operating_rounds: 2,
            status: [],
          },
          {
            name: '7',
            on: '7+7',
            train_limit: { major: 2, national: 3 },
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
            status: [],
          },
          {
            name: '8',
            on: '8+8',
            train_limit: { major: 2, national: 3 },
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
            status: [],
          },
        ].freeze

        TRAINS = [
          # Level 2 — yellow; rusts when first Level 4 train is bought
          {
            name: '2+2',
            level: 2,
            distance: [{ 'nodes' => ['town'], 'pay' => 2, 'visit' => 99 },
                       { 'nodes' => %w[city offboard town], 'pay' => 2, 'visit' => 2 }],
            price: 100,
            rusts_on: '4',
            num: 30,
          },
          # Level 3 — green double-sided (3 / 3+3); rust at Level 6
          {
            name: '3',
            level: 3,
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
            num: 20,
          },
          # Level 4 — green double-sided (4 / 4+4); rust at Level 8
          {
            name: '4',
            level: 4,
            distance: [{ 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 },
                       { 'nodes' => %w[city offboard town], 'pay' => 4, 'visit' => 4 }],
            price: 300,
            rusts_on: '8+8',
            events: [{ 'type' => 'pullmans_available' }],
            variants: [{
              name: '4+4',
              distance: [{ 'nodes' => ['town'], 'pay' => 4, 'visit' => 99 },
                         { 'nodes' => %w[city offboard town], 'pay' => 4, 'visit' => 4 }],
              price: 350,
              rusts_on: '8+8',
            }],
            num: 10,
          },
          # Level 5 — brown double-sided (5 / 5+5); permanent
          {
            name: '5',
            level: 5,
            distance: [{ 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 },
                       { 'nodes' => %w[city offboard town], 'pay' => 5, 'visit' => 5 }],
            price: 400,
            variants: [{
              name: '5+5',
              distance: [{ 'nodes' => ['town'], 'pay' => 5, 'visit' => 99 },
                         { 'nodes' => %w[city offboard town], 'pay' => 5, 'visit' => 5 }],
              price: 475,
            }],
            num: 8,
            events: [{ 'type' => 'consolidation_triggered' }, { 'type' => 'minor_d_token' }],
          },
          # Level 6 — brown double-sided (6 / 6+6); permanent
          {
            name: '6',
            level: 6,
            distance: [{ 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 },
                       { 'nodes' => %w[city offboard town], 'pay' => 6, 'visit' => 6 }],
            price: 525,
            variants: [{
              name: '6+6',
              distance: [{ 'nodes' => ['town'], 'pay' => 6, 'visit' => 99 },
                         { 'nodes' => %w[city offboard town], 'pay' => 6, 'visit' => 6 }],
              price: 600,
            }],
            num: 6,
          },
          # Level 7 — gray double-sided (7+7 / 4D); permanent
          # NOTE: Level 8 trains become available only after the 4th Level 7 purchase
          {
            name: '7+7',
            level: 7,
            distance: [{ 'nodes' => ['town'], 'pay' => 7, 'visit' => 99 },
                       { 'nodes' => %w[city offboard town], 'pay' => 7, 'visit' => 7 }],
            price: 750,
            variants: [{
              name: '4D',
              distance: [{ 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 },
                         { 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 }],
              multiplier: 2,
              price: 850,
            }],
            num: 14,
            events: [{ 'type' => 'level_8_available', 'when' => 4 }],
          },
          # Level 8 — gray double-sided (8+8 / 5D); permanent
          # NOTE: purchase of the FIRST level-8 triggers game end
          {
            name: '8+8',
            level: 8,
            distance: [{ 'nodes' => ['town'], 'pay' => 8, 'visit' => 99 },
                       { 'nodes' => %w[city offboard town], 'pay' => 8, 'visit' => 8 }],
            price: 900,
            variants: [{
              name: '5D',
              distance: [{ 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 },
                         { 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 }],
              multiplier: 2,
              price: 1000,
            }],
            num: 8,
            available_on: '7',
            events: [{ 'type' => 'remainder_cash_added' }],
          },
          { name: PULLMAN, distance: 0, price: 150, num: 10, available_on: '4', extra: true },
        ].freeze

        # 2 chits per zone; 16 total for 12 minors.
        # Asterisked zones (UK/PHS/FR): 6 chits combined but capped at 4 selections —
        # when the 4th is taken the remaining chits for those zones are removed from play.
        MINOR_TRACK_RIGHTS_CHITS = {
          'UK' => 2,
          'PHS' => 2,
          'FR' => 2,
          'AH' => 2,
          'IT' => 2,
          'SP' => 2,
          'SC' => 2,
          'RU' => 2,
        }.freeze
        ASTERISKED_ZONES = %w[UK PHS FR].freeze
        ASTERISKED_ZONES_CAP = 4

        ZONE_DISCOUNT_ZONES         = %w[SP IT SC RU].freeze
        ZONE_DISCOUNT_RATE          = 0.2 # 20% §11.1.5
        ZONE_TERRAIN_DISCOUNT_RATE  = 0.5 # 50% §11.1.5; E/F augment zone discount to this rate
        TERRAIN_COST_MULTIPLIER = 0.67
        NATIONAL_FORMATION_PHASES = %w[4 6 8].freeze
        TILE_POINT_BUDGET = { minor: 3, regional: 3, major: 6, national: 9 }.freeze
        MINOR_MAX_TREASURY = 180
        TILE_FEE_PER_WATER_DISTANCE = 5
        TOKEN_FEE_PER_WATER_DISTANCE = 20
        BLUE_TERRAIN = %i[water river lake].freeze
        GREEN_TERRAIN = %i[mountain hill].freeze
        SEA_CHANNEL_PASSAGE_COST = 20
        SEA_REDUCTION_BY_PHASE = { '2' => 1, '3' => 1, '4' => 1, '5' => 1, '6' => 1, '7' => 2, '8' => 2 }.freeze

        PORT_AUTHORITY_COST = 125
        PORT_AUTHORITY_REDUCTION = 2
        PORT_AUTHORITIES = { north_sea: 8, mediterranean: 8 }.freeze
        PORT_AUTHORITY_NAMES = { north_sea: 'North Sea', mediterranean: 'Mediterranean' }.freeze
        PORT_AUTHORITY_LIMIT = 1

        TOKEN_TRANSFER_FEES = { normal: 20, grand: 40, metropolis: 60 }.freeze

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
                     G44 G46 G50 G52 G54 G56 H43 H45 H47 H51 H53 H55 I44 I46 I48 I50 I52 J49],
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
          'PHS' => %w[I64 J45 J47 J63 J65 K40 K42 K44 K46 K48 K50 K54 K56 K58 K60 K62 K64
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
        ORIENT_EXPRESS_ORIGINS = %w[Paris London Berlin Madrid Sankt-Peterburg].freeze
        ORIENT_EXPRESS_DESTINATIONS = %w[Constantinople].freeze
        MINOR_D_20_TOKEN = 'D+20'
        MINOR_D_40_TOKEN = 'D+40'
        MINOR_D_BONUS = { MINOR_D_20_TOKEN => 20, MINOR_D_40_TOKEN => 40 }.freeze
        HOCHBERG_TOKEN = 'HMLC'
        HOCHBERG_MIN_TERRAIN_COST = 45
        HOCHBERG_REVENUE = { '2' => 10, '3' => 20, '4' => 20, '5' => 40, '6' => 40, '7' => 60, '8' => 60 }.freeze
        ASSIGNMENT_TOKENS = {
          HOCHBERG_TOKEN => '/logos/18_oe/hmlc.svg',
          MINOR_D_20_TOKEN => '/icons/18_oe/plus_twenty.svg',
          MINOR_D_40_TOKEN => '/icons/18_oe/plus_forty.svg',
        }.freeze
        ORIENT_EXPRESS_BONUS = { '2' => 30, '3' => 30, '4' => 30, '5' => 60, '6' => 60, '7' => 100, '8' => 100 }.freeze
        CONVERSION_NEW_SHARES = 6
        MAJOR_MAX_OWNERSHIP_PERCENT = 60
        TWO_PLAYER_MAX_OWNERSHIP_PERCENT = 70
        EXTENDED_FINAL_OPERATING_ROUNDS = 3

        FAST_START_PACKETS = {
          3 => [
            { companies: %w[RSC WS SHTC HMLC A D H J], cash: 920 },
            { companies: %w[BBBT CCTC BBE B E G K], cash: 920 },
            { companies: %w[PeC WCF SML C F L M], cash: 920 },
          ],
          4 => [
            { companies: %w[BBBT CCTC WCF A H J], cash: 680 },
            { companies: %w[WS BBE C G K], cash: 700 },
            { companies: %w[SHTC HMLC B F L], cash: 700 },
            { companies: %w[RSC PeC SML D E M], cash: 680 },
          ],
          5 => [
            { companies: %w[SHTC C J K], cash: 540 },
            { companies: %w[PeC WS BBE G M], cash: 560 },
            { companies: %w[RSC BBBT HMLC A H], cash: 580 },
            { companies: %w[WCF B F L], cash: 540 },
            { companies: %w[CCTC SML D E], cash: 540 },
          ],
          6 => [
            { companies: %w[BBE C K], cash: 460 },
            { companies: %w[HMLC G M], cash: 480 },
            { companies: %w[BBBT WCF A H], cash: 460 },
            { companies: %w[WS CCTC B L], cash: 460 },
            { companies: %w[RSC PeC SHTC F J], cash: 460 },
            { companies: %w[SML D E], cash: 440 },
          ],
          7 => [
            { companies: %w[WS BBE K], cash: 425 },
            { companies: %w[HMLC SML G], cash: 365 },
            { companies: %w[RSC PeC A H], cash: 405 },
            { companies: %w[BBBT L M], cash: 405 },
            { companies: %w[SHTC F J], cash: 385 },
            { companies: %w[CCTC D E], cash: 385 },
            { companies: %w[WCF B C], cash: 385 },
          ],
        }.freeze

        def setup
          super
          @minor_regional_order = []
          @minor_available_regions = self.class::MINOR_TRACK_RIGHTS_CHITS.transform_values(&:itself)
          @minor_asterisked_selected = 0
          @minor_floated_regions = {}
          @merged_minors = Hash.new { |hash, corporation| hash[corporation] = [] }
          @minor_charter_assets = {}
          @removed_regional_zones = []
          @orient_express_markers = []
          @swift_metropolitan_train = nil
          @port_authorities = Hash.new { |hash, corporation| hash[corporation] = [] }
          @removed_port_authorities = Hash.new(0)
          @concessions = companies.select { |company| concession?(company) }
          @fulfilled_train_obligation = Set.new
          @first_or_complete = false
          @reserved_shares = []
          @face_down_privates = []
          @hochberg_token_hex = nil
          @hochberg_printed_revenue = {}
          setup_nationals

          corporations.each do |corp|
            corp.par_via_exchange = companies.find { |c| c.sym == corp.id } if corp.type == :minor
          end

          setup_fast_start! if fast_start?
          setup_patronage_tiles!
          place_wcf_placeholder!
          @pass_through_tokens = {}
          setup_minor_k!
          @minor_c_ability = corporation_by_id('C')&.abilities&.first
          @minor_g_ability = corporation_by_id('G')&.abilities&.first
          @minor_b_ability = corporation_by_id('B')&.abilities&.first
          @minor_e_ability = corporation_by_id('E')&.abilities&.first
          @minor_f_ability = corporation_by_id('F')&.abilities&.first
          @minor_h_ability = corporation_by_id('H')&.abilities&.first
          @minor_l_ability = corporation_by_id('L')&.abilities&.first
          @minor_d_ability = minor_d_private&.abilities&.first
          @minor_d_token = self.class::MINOR_D_20_TOKEN
        end

        def setup_minor_k!
          mail = company_by_id('MAIL')
          minor_k = corporation_by_id('K')
          mail.owner = minor_k
          minor_k.companies << mail
        end

        def initial_auction_companies
          @companies.select(&:auction_row)
        end

        def companies_to_payout(ignore: [])
          super.reject do |company|
            owner = company.owner
            owner.corporation? && (!owner.floated? || abandoned_minor?(owner))
          end
        end

        def place_wcf_placeholder!
          @wcf_placeholder = Engine::Token.new(nil, price: 0, logo: '/logos/18_oe/wcf_reserved.svg', type: :neutral)
          lille_city.exchange_token(@wcf_placeholder, extra_slot: true)
        end

        def wcf_position_token?(corporation)
          lille_city.extra_tokens.any? { |token| token.corporation == corporation && token.type != :pass_through }
        end

        def pass_through_token_definitions
          self.class::PASS_THROUGH_TOKENS
        end

        def port_hex?(hex)
          (self.class::PORTS[hex.id] || {}).values.any? { |entry| entry[:port] }
        end

        def pass_through_token_company?(company)
          !!company&.company? && pass_through_token_definitions.key?(company.sym)
        end

        def pass_through_token_logo(company)
          pass_through_token_definitions[company.sym][:logo]
        end

        def pass_through_hex?(company, hex)
          !hex.tile.cities.empty? && port_hex?(hex) == pass_through_token_definitions[company.sym][:port]
        end

        def pass_through_cities(corporation)
          @pass_through_tokens.values.filter_map { |token| token.city if token.corporation == corporation }
        end

        def pass_through_city?(city, corporation)
          pass_through_cities(corporation).include?(city)
        end

        def port_token_city?(city, corporation)
          return false unless city_tokened_by?(city, corporation)

          @pass_through_tokens.none? do |company, token|
            token.city == city && token.corporation == corporation && !pass_through_token_definitions[company.sym][:port]
          end
        end

        def skip_token?(_graph, corporation, city)
          pass_through_city?(city, corporation)
        end

        def counted_stops(route)
          stops = without_pass_through_cities(visited_stops(route), route.corporation)
          return stops if !hochberg_token_hex || hochberg_owner_route?(route)

          stops.reject { |stop| stop == hochberg_town }
        end

        def hochberg_owner_route?(route)
          company = hochberg_private
          !hochberg_token_hex.nil? && !company.owner.nil? && route.corporation&.owner == company.owner
        end

        def hochberg_bonus(route, stops)
          return 0 if !hochberg_owner_route?(route) || !stops.include?(hochberg_town)

          self.class::HOCHBERG_REVENUE[route.phase.name]
        end

        def without_pass_through_cities(stops, corporation)
          cities = pass_through_cities(corporation)
          cities.empty? ? stops : stops.reject { |stop| cities.include?(stop) }
        end

        def revenue_stops(route)
          counted_stops(route)
        end

        def check_distance(route, visits, train = nil)
          super(route, without_pass_through_cities(visits, route.corporation), train)
        end

        def check_route_token(route, _token)
          super(route, counted_stops(route).find { |stop| city_tokened_by?(stop, route.corporation) })
        end

        def place_pass_through_token!(company, corporation, city)
          token = Engine::Token.new(
            corporation,
            price: 0,
            logo: pass_through_token_logo(company),
            type: :pass_through,
          )
          city.exchange_token(token, extra_slot: true)
          @pass_through_tokens[company] = token
          hex = city.hex
          @log << "#{corporation.name} (#{company.sym}) places the #{company.name} token on "\
                  "#{hex.name} (#{hex.location_name})"
          clear_graph_for_entity(corporation)
        end

        def pass_through_token_lines(corporation)
          @pass_through_tokens.filter_map do |company, token|
            next unless token.corporation == corporation

            hex = token.city.hex
            ["#{company.name} token: #{hex.name} (#{hex.location_name})"]
          end
        end

        def setup_fast_start!
          @fast_start_minors = []
          fast_start_packets.sort_by { rand }.zip(@players).each do |packet, player|
            @bank.spend(packet[:cash], player)
            packet[:companies].each do |sym|
              company = company_by_id(sym)
              company.owner = player
              player.companies << company
              next unless company_becomes_minor?(company)

              minor = corporation_by_id(company.sym)
              @bank.spend(company.value, minor)
              @fast_start_minors << minor
            end
            names = packet[:companies].map { |sym| company_by_id(sym).name }.join('; ')
            @log << "#{player.name} receives #{names} and #{format_currency(packet[:cash])}"
          end
        end

        def fast_start_extra_cash_limit(minor)
          self.class::MINOR_MAX_TREASURY - company_by_id(minor.id).value
        end

        def add_fast_start_cash!(minor, amount)
          player = company_by_id(minor.id).owner
          if amount.positive?
            player.spend(amount, minor)
            @log << "#{player.name} adds #{format_currency(amount)} to #{minor.name}'s treasury"
          else
            @log << "#{player.name} adds nothing to #{minor.name}'s treasury"
          end
        end

        def fast_start_packets
          self.class::FAST_START_PACKETS[players.size]
        end

        def setup_patronage_tiles!
          drawn = self.class::PATRONAGE_DRAWS.flat_map do |draw|
            candidates = self.class::PATRONAGE_TILES.select do |_hex_id, data|
              data[:group] == draw[:group] && (draw[:zone].nil? || data[:zone] == draw[:zone])
            end
            candidates.keys.sort_by { rand }.take(draw[:count])
          end
          drawn.each { |hex_id| place_patronage_tile!(hex_id) }

          entries = drawn.map do |id|
            "#{hex_by_id(id).location_name} (#{id}) #{self.class::PATRONAGE_TILES[id][:payouts].values.join('/')}"
          end
          @log << "Patronage tiles: #{entries.join(', ')}"
        end

        def place_patronage_tile!(hex_id)
          hex_by_id(hex_id).tile.patronage = self.class::PATRONAGE_TILES[hex_id][:payouts]
        end

        def patronage_color
          @phase.tiles.last
        end

        def remove_patronage!(hex)
          payouts = hex.tile.patronage
          hex.tile.patronage = nil
          payouts
        end

        def fulfill_patronage!(entity, hex)
          payouts = remove_patronage!(hex)
          return unless payouts

          amount = payouts[patronage_color]
          @bank.spend(amount, entity)
          @log << "#{entity.name} fulfills the #{hex.location_name} patronage tile and receives #{format_currency(amount)}"
        end

        def medium_start?
          @optional_rules.include?(:medium_start)
        end

        def fast_start?
          @optional_rules.include?(:fast_start)
        end

        def long_endgame?
          @optional_rules.include?(:long_endgame)
        end

        def concessions?
          !medium_start? && !fast_start? && players.size > 2
        end

        def concession?(company)
          company.type == :concession
        end

        def init_starting_cash(players, bank)
          return if fast_start?

          cash = medium_start? ? self.class::STARTING_CASH_NO_CONCESSIONS : self.class::STARTING_CASH
          players.each { |player| bank.spend(cash[players.size], player) }
        end

        def init_round
          fast_start? ? new_fast_start_round : super
        end

        def round_description(name, round_number = nil)
          return @round.name if name == 'FastStart'

          super
        end

        def init_companies(players)
          companies = super
          concessions? ? companies : companies.reject { |company| concession?(company) }
        end

        def num_certs(entity)
          super - entity.companies.count { |company| concession?(company) || face_down_private?(company) }
        end

        public :companies_sort

        def private_company?(company)
          !company_becomes_minor?(company) && !concession?(company)
        end

        def face_down_private?(company)
          @face_down_privates.include?(company)
        end

        def flip_private!(company)
          @face_down_privates << company
          company.revenue = 0
        end

        def company_status_str(company)
          'Face down' if face_down_private?(company)
        end

        def player_value(player)
          super - player.companies.select { |company| face_down_private?(company) }.sum(&:value)
        end

        def remove_private!(company)
          @face_down_privates.delete(company)
          company.close!
        end

        def init_stock_market
          G18OE::StockMarket.new(game_market, self.class::CERT_LIMIT_TYPES,
                                 multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end

        # True once MAX_FLOATED_REGIONALS have been floated and the 6 remaining
        # unfloated regionals have been closed. This is the correct trigger for
        # "Major Railroad Phase" entry: conversions and secondary-share purchases
        # become available from this point on.
        def major_phase?
          return false if @corporations.any? { |corporation| corporation.type == :regional && !corporation.floated? }

          total_minors = corporations.count { |c| c.type == :minor }
          @minor_floated_regions.size >= total_minors
        end

        def can_hold_above_corp_limit?(_entity)
          true
        end

        def fulfilled_train_obligation?(entity)
          !phase.status.include?('train_obligation') || @fulfilled_train_obligation.include?(entity.id)
        end

        def fulfill_train_obligation!(entity)
          @fulfilled_train_obligation.add(entity.id)
        end

        def non_starter_trains_available?
          major_phase? && @first_or_complete
        end

        def operating_order
          floated_minors_and_regionals = @minor_regional_order.select(&:floated?)
          floated_minors_and_regionals + @corporations.select { |c| %i[major national].include?(c.type) && c.floated? }.sort
        end

        def hex_within_national_region?(entity, hex)
          return true if entity.type == :major

          region = self.class::CORPORATIONS_TRACK_RIGHTS[entity.id] || @minor_floated_regions[entity.id]
          hexes = self.class::NATIONAL_REGION_HEXES[region]
          hexes&.include?(hex.coordinates) || false
        end

        def city_in_track_rights?(entity, hex)
          return true if entity.type == :major

          region_for_hex(hex) == entity_track_rights_zone(entity)
        end

        def region_for_hex(hex)
          national_region_by_coordinates[hex.coordinates]
        end

        def region_available?(region)
          @minor_available_regions.key?(region)
        end

        def track_rights_cost(region)
          self.class::TRACK_RIGHTS_COST[region] || 0
        end

        def claim_region!(entity, region)
          @minor_floated_regions[entity.id] = region
          @minor_available_regions[region] -= 1
          @minor_available_regions.delete(region) if @minor_available_regions[region].zero?

          return unless self.class::ASTERISKED_ZONES.include?(region)

          @minor_asterisked_selected += 1
          return unless @minor_asterisked_selected >= self.class::ASTERISKED_ZONES_CAP

          self.class::ASTERISKED_ZONES.each { |z| @minor_available_regions.delete(z) }
        end

        def home_token_locations(corporation)
          available_regions = self.class::NATIONAL_REGION_HEXES.select { |key, _| @minor_available_regions.include?(key) }
          region_hexes = available_regions.values.flatten

          @hexes
            .select { |hex| region_hexes.include?(hex.coordinates) }
            .reject { |hex| (z = self.class::CITY_TOWN_NATIONAL_ZONE[hex.coordinates]) && !@minor_available_regions.key?(z) }
            .select { |hex| hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) } }
            .reject { |hex| metropolis_hex?(hex) }
            .reject { |hex| self.class::MINOR_EXCLUDED_HOME_CITIES.include?(hex.coordinates) }
            .reject { |hex| railroad_home_hexes.include?(hex.coordinates) }
            .reject { |hex| minor_tokened?(hex) }
        end

        def railroad_home_hexes
          @corporations.reject { |c| c.type == :minor }.map(&:coordinates)
        end

        def minor_tokened?(hex)
          hex.tile.cities.any? { |city| city.tokens.any? { |token| token&.corporation&.type == :minor } }
        end

        def metropolis_hex?(hex)
          %w[A56 B41 C74 F87 K26 M28 M50 Q30 R55 Y14 AA82 AB51].include?(hex.coordinates)
        end

        def metropolis_tile?(tile)
          %w[OE4 OE5 OE6 OE7 OE8 OE12 OE13 OE14 OE15 OE16 OE17
             OE18 OE26 OE27 OE28 OE29 OE30 OE37 OE38 OE39 OE40 OE41].include?(tile.name.to_s)
        end

        def tile_point_budget(entity)
          budget = self.class::TILE_POINT_BUDGET[entity.type] || 0
          return budget if national?(entity)

          entity.abilities.include?(@minor_g_ability) ? budget + 2 : budget
        end

        def tile_point_cost(entity, old_tile:)
          upgrade = old_tile.color != :white
          return 1 if upgrade && old_tile.cities.empty? && entity.abilities.include?(@minor_b_ability)

          base_cost = upgrade ? 2 : 1
          base_cost *= 2 if metropolis_hex?(old_tile.hex)
          return base_cost unless terrain_point_ability(entity, old_tile)

          base_cost - 1
        end

        def zero_point_tile_lays_available?(entity)
          !terrain_point_abilities(entity).empty?
        end

        def terrain_point_abilities(entity)
          { blue: @minor_e_ability, green: @minor_f_ability }.select do |_, ability|
            ability && entity.abilities.include?(ability) && ability_usable_this_or?(ability)
          end
        end

        def minor_h_reduction?(corporation)
          !@minor_h_ability.nil? && corporation.abilities.include?(@minor_h_ability)
        end

        def terrain_point_ability(entity, tile)
          return unless tile.color == :white

          terrain_point_abilities(entity).find do |color, _|
            terrain = color == :blue ? self.class::BLUE_TERRAIN : self.class::GREEN_TERRAIN
            tile.terrain.intersect?(terrain)
          end&.last
        end

        def after_lay_tile(entity, old_tile, tile)
          return unless tile.color == :yellow

          terrain_point_ability(entity, old_tile)&.use!
        end

        def can_buy_train_from_others?
          major_phase?
        end

        def train_obligation_active?
          phase.status.include?('train_obligation')
        end

        def upgrade_cost(tile, hex, entity, spender)
          return 0 if national?(entity)

          base_cost = tile.upgrades.sum(&:cost)
          return super if base_cost.zero?

          zone_match = track_rights_zones(entity).any? do |zone|
            self.class::ZONE_DISCOUNT_ZONES.include?(zone) &&
              self.class::NATIONAL_REGION_HEXES[zone].include?(hex.coordinates)
          end

          terrain_minor = terrain_discount_minor(entity, tile)
          return super if !zone_match && !terrain_minor

          multiplier = if zone_match
                         1 - (terrain_minor ? self.class::ZONE_TERRAIN_DISCOUNT_RATE : self.class::ZONE_DISCOUNT_RATE)
                       else
                         self.class::TERRAIN_COST_MULTIPLIER
                       end
          cost = (base_cost * multiplier).floor
          discount = base_cost - cost
          if discount.positive?
            pct = (100 - (multiplier * 100)).to_i
            source = [zone_match ? 'zone' : nil, terrain_minor&.name].compact.join('+')
            label = "#{pct}% #{source}"
            @log << "#{spender.name} receives a #{label} discount of #{format_currency(discount)}"
          end
          cost
        end

        def entity_track_rights_zone(entity)
          corp = owning_corporation(entity)
          return nil unless corp

          self.class::CORPORATIONS_TRACK_RIGHTS[corp.id] || @minor_floated_regions[corp.id]
        end

        def track_rights_zones(entity)
          corp = owning_corporation(entity)
          return [] unless corp

          merged_zones = @merged_minors.fetch(corp, []).map { |minor| @minor_floated_regions[minor.id] }
          ([entity_track_rights_zone(corp)] + merged_zones).compact.uniq
        end

        def merge_candidates(player, minor)
          return [] unless @phase.available?('3')
          return [] if minor.type != :minor || !minor.floated? || minor.owner != player

          @corporations.select do |corporation|
            %i[major national].include?(corporation.type) &&
              corporation.floated? &&
              corporation.president?(player) &&
              !@round.merged_majors.include?(corporation)
          end
        end

        def merge_targets(player, minor)
          merge_candidates(player, minor).select do |corporation|
            merge_share(corporation) || @loading || merge_connected?(minor, corporation)
          end
        end

        def merge_graph
          @merge_graph ||= Engine::Graph.new(self, no_blocking: true, check_tokens: true)
        end

        def merge_connected?(minor, major)
          nodes = merge_graph.connected_nodes(major)
          minor.placed_tokens.any? { |token| nodes.key?(token.city) }
        end

        def merge_share(major)
          major.treasury_shares.find { |share| !share.president } ||
            @share_pool.shares_by_corporation[major].first
        end

        def abandoned_minor_price
          self.class::ABANDONED_MINOR_PRICE
        end

        def abandoned_minors
          @corporations.select { |corporation| abandoned_minor?(corporation) }
        end

        def abandoned_minor?(corporation)
          corporation.type == :minor && corporation.floated? && !corporation.owner
        end

        def corporation_show_shares?(corporation)
          return false if abandoned_minor?(corporation)

          super
        end

        def abandon_minor!(minor)
          @log << "#{minor.name} is abandoned"
          minor.trains.reject { |train| pullman?(train) }.each { |train| @depot.reclaim_train(train) }
          minor.placed_tokens.each(&:remove!)
          return_minor_d_token!(minor)
          minor.spend(minor.cash, @bank) if minor.cash.positive?
          @share_pool.transfer_shares(minor.presidents_share.to_bundle, minor.ipo_owner, allow_president_change: false)
          minor.presidents_share.buyable = false
          minor.owner = nil
          @minor_regional_order.delete(minor)
          clear_graph
        end

        def merge_offer_majors(minor)
          owner = minor.owner
          @players.rotate(@players.index(owner) + 1).reject { |player| player == owner }.flat_map do |player|
            @corporations.select do |corporation|
              corporation.type == :major &&
                corporation.floated? &&
                corporation.president?(player) &&
                corporation.treasury_shares.any? { |share| !share.president } &&
                !@round.merged_majors.include?(corporation)
            end
          end
        end

        def add_minor_charter!(minor, major)
          @merged_minors[major] << minor
          unless minor.trains.empty?
            trains = transfer(:trains, minor, major)
            @log << "#{major.name} takes #{trains.map(&:name).join(', ')} from #{minor.name}"
          end
          discard_pullman!(major) if major.trains.count { |train| pullman?(train) } > 1
          return unless major.type == :major

          pay_minor_a_bonus!(minor, major) if minor.id == 'A'
          @minor_charter_assets[minor] = { abilities: minor.abilities.dup, companies: minor.companies.dup }
          minor.abilities.dup.each do |ability|
            minor.remove_ability(ability)
            major.add_ability(ability)
          end
          minor.companies.dup.each do |company|
            minor.companies.delete(company)
            company.owner = major
            major.companies << company
          end
        end

        def pay_minor_a_bonus!(minor, major)
          ability = minor.abilities.first
          return if !ability || ability.used?

          amount = major.share_price.price
          @bank.spend(amount, major)
          ability.use!
          @log << "#{major.name} receives #{format_currency(amount)} from the bank for #{minor.name}"
        end

        def rust(train)
          owner = train.owner
          if owner&.corporation? && national?(owner)
            train.rusted = true
            return
          end

          @rusted_at_phase_change[owner] << train if owner&.corporation?
          train.rusted = true
          @depot.reclaim_train(train)
        end

        def acquire_swift_metropolitan_train!(corporation)
          train = @depot.rusted_trains.find { |t| t.name == '2+2' }
          raise GameError, 'No rusted 2+2 remains in the Locomotive Works' unless train

          buy_train(corporation, train, :free)
          train.rusted = false
          train.operated = false
          train.extra = true
          @swift_metropolitan_train = train
          @log << "#{corporation.name} acquires an extra #{train.name} from the Swift Metropolitan Line"
        end

        def rust?(train, purchased_train)
          return false if extra_train?(train)

          super
        end

        def discountable_trains_for(corporation)
          national?(corporation) ? national_train_exchanges(corporation) : super
        end

        def discard_discount(train, price)
          return 0 if train.rusted

          super
        end

        def pullman?(train)
          train.name == self.class::PULLMAN
        end

        def pullman(corporation)
          corporation.trains.find { |train| pullman?(train) }
        end

        def discard_pullman!(corporation)
          @depot.reclaim_train(pullman(corporation))
          @log << "#{corporation.name} discards its #{self.class::PULLMAN} to the Open Market"
        end

        def trainless?(corporation)
          corporation.trains.all? { |train| extra_train?(train) }
        end

        def forced_train_price(corporation)
          train = @depot.min_depot_train
          return unless train

          train.min_price(ability: abilities(corporation, :train_discount))
        end

        def route_trains(entity)
          super.reject { |train| pullman?(train) }
        end

        def pullman_bonus_per_level
          self.class::PULLMAN_BONUS_PER_LEVEL
        end

        def pullman_royalty
          self.class::PULLMAN_ROYALTY
        end

        def pullman_transfer_price
          self.class::PULLMAN_TRANSFER_PRICE
        end

        def pay_pullman_royalty!
          holder = minor_m_holder
          return unless holder

          @bank.spend(pullman_royalty, holder)
          @log << "#{holder.name} receives #{format_currency(pullman_royalty)} #{self.class::PULLMAN} royalty"
        end

        def minor_m
          corporation_by_id('M')
        end

        def minor_m_holder
          m = minor_m
          merged_into = @merged_minors.find { |_major, minors| minors.include?(m) }&.first
          return merged_into if merged_into

          m if m.floated? && m.owner
        end

        def event_pullmans_available!
          holder = minor_m_holder
          return unless holder

          pullman_card = @depot.upcoming.find { |train| pullman?(train) }
          return unless pullman_card

          buy_train(holder, pullman_card, :free)
          @log << "#{holder.name} receives a free #{self.class::PULLMAN}"
        end

        def level8_train_available?
          @level_8_available || false
        end

        def event_level_8_available!
          @level_8_available = true
          @log << '-- Event: Level 8 trains are now available --'
        end

        def event_remainder_cash_added!
          return if @remainder_cash_added

          @remainder_cash_added = true
          remainder = self.class::REMAINDER_CASH
          @bank.add_cash(remainder)
          @log << "-- Event: #{format_currency(remainder)} remainder cash added to bank;" \
                  ' game ends after one more full OR set (sooner if bank breaks) --'
        end

        # UP movement at end of SR: only for majors and nationals that are fully player-held
        def sold_out_increase?(corporation)
          %i[major national].include?(corporation.type)
        end

        def event_consolidation_triggered!
          @consolidation_triggered = true
          @log << '-- Event: Consolidation phase triggered --'
        end

        def consolidation_round_finished!
          @consolidation_complete = true
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Operating
              @first_or_complete = true # Rule 8.3/11.6: level 3+ trains unblocked after first OR
              if @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              elsif @consolidation_triggered && !@consolidation_complete
                @turn += 1
                or_round_finished
                or_set_finished
                @log << '-- Consolidation Phase --'
                new_consolidation_round
              else
                @turn += 1
                or_round_finished
                or_set_finished
                new_stock_round
              end
            when Engine::Round::Auction
              init_round_finished
              reorder_players(silent: concessions.any?)
              concessions.any? ? new_concession_round : new_stock_round
            when Round::G18OE::Concession
              reorder_players_after_concessions!
              new_stock_round
            when Round::G18OE::FastStart
              new_stock_round
            when Engine::Round::Stock
              @reserved_shares = []
              remove_major_par_markers!
              round = super
              @operating_rounds = final_operating_rounds if @turn == @final_turn
              round
            else
              super
            end
        end

        def after_phase_change(name)
          super
          start_national_formation!(@round.current_operator&.owner) if national_formation_phase?(name) && @round.operating?
          return unless name == self.class::PHASES.last[:name]

          @final_set_extended = @round.is_a?(Engine::Round::Operating) && final_or_in_set?(@round)
        end

        def final_operating_rounds
          @final_set_extended ? self.class::EXTENDED_FINAL_OPERATING_ROUNDS : super
        end

        def abbreviated_operating_round?(round_num = @round.round_num)
          !long_endgame? && @turn == @final_turn && round_num == @operating_rounds
        end

        def repeat_last_revenue?(entity)
          return false unless abbreviated_operating_round?
          return false unless (info = last_revenue_info(entity))
          return true if national?(entity)

          ran = info.routes.keys.flat_map { |train| component_trains(train) }
          ran.map(&:id).sort == entity.trains.reject { |train| pullman?(train) }.map(&:id).sort
        end

        def last_revenue_info(entity)
          entity.operating_history[[@turn, @round.round_num - 1]]
        end

        def component_trains(train)
          train.sym.include?('_') ? train.sym.split('_').map { |id| train_by_id(id) } : [train]
        end

        def major_max_ownership_percent
          @players.size == 2 ? self.class::TWO_PLAYER_MAX_OWNERSHIP_PERCENT : self.class::MAJOR_MAX_OWNERSHIP_PERCENT
        end

        def place_major_par_marker!(corporation)
          corporation.max_ownership_percent = major_max_ownership_percent
          corporation.always_market_price = false
        end

        def remove_major_par_markers!
          @corporations.each { |c| c.always_market_price = true if c.type == :major }
        end

        def regionals_in_play
          @corporations.count { |corporation| corporation.type == :regional && corporation.ipoed }
        end

        def removable_regional?(corporation)
          return false if corporation.type != :regional || corporation.ipoed
          return false unless @corporations.count { |c| c.type == :regional } > self.class::MAX_FLOATED_REGIONALS

          !@removed_regional_zones.include?(self.class::CORPORATIONS_TRACK_RIGHTS[corporation.id])
        end

        def remove_regional!(corporation)
          @removed_regional_zones << self.class::CORPORATIONS_TRACK_RIGHTS[corporation.id]
          close_corporation(corporation)
        end

        def parred_regional?(corporation)
          corporation.type == :regional && corporation.ipoed && !corporation.floated?
        end

        def reserved_shares?
          @players.size > 2
        end

        def reserved_share(corporation)
          return unless corporation.type == :regional

          @reserved_shares.find { |share| share.corporation == corporation && share.owner == corporation.ipo_owner }
        end

        def can_reserve_regional?(player, corporation)
          reserved_shares? &&
            @turn == 1 &&
            corporation.type == :regional &&
            corporation.president?(player) &&
            @reserved_shares.none? { |share| share.corporation.owner == player } &&
            corporation.ipo_shares.count { |share| !share.president } == 2
        end

        def reserve_share!(corporation)
          @reserved_shares << corporation.ipo_shares.reject(&:president).last
        end

        def status_str(corporation)
          "Share reserved by #{corporation.owner.name}" if reserved_share(corporation)
        end

        def status_array(corporation)
          lines = []
          lines << ["National (#{entity_track_rights_zone(corporation)})"] if national?(corporation)
          lines << ['Orient Express marker'] if orient_express_marker?(corporation)
          port_authorities(corporation).each { |sea| lines << [port_authority_name(sea)] }
          lines.concat(pass_through_token_lines(corporation))
          lines unless lines.empty?
        end

        def port_authority_cost
          self.class::PORT_AUTHORITY_COST
        end

        def port_authority_count(sea)
          self.class::PORT_AUTHORITIES[sea]
        end

        def port_authority_reduction
          self.class::PORT_AUTHORITY_REDUCTION
        end

        def port_authority_limit
          self.class::PORT_AUTHORITY_LIMIT
        end

        def port_authority_seas
          self.class::PORT_AUTHORITIES.keys
        end

        def port_authority_sea_name(sea)
          self.class::PORT_AUTHORITY_NAMES[sea]
        end

        def port_authority_name(sea)
          "#{port_authority_sea_name(sea)} port authority"
        end

        def port_authorities(corporation)
          @port_authorities.fetch(corporation, [])
        end

        def port_authorities_left(sea)
          port_authority_count(sea) - @port_authorities.values.count { |seas| seas.include?(sea) } -
            @removed_port_authorities[sea]
        end

        def timeline
          left = port_authority_seas.map { |sea| "#{port_authority_sea_name(sea)} #{port_authorities_left(sea)}" }
          ["Port authorities left: #{left.join(', ')}"]
        end

        def can_buy_port_authority?(corporation, sea)
          corporation.type == :major &&
            port_authorities(corporation).size < port_authority_limit &&
            !port_authorities(corporation).include?(sea) &&
            port_authorities_left(sea).positive? &&
            corporation.cash >= port_authority_cost
        end

        def buy_port_authority!(corporation, sea)
          @log << "#{corporation.name} buys a #{port_authority_name(sea)} for #{format_currency(port_authority_cost)}"
          corporation.spend(port_authority_cost, @bank)
          @port_authorities[corporation] << sea
          clear_graph_for_entity(corporation)
        end

        def port_authority_sales(buyer)
          return [] if !buyer.corporation? || buyer.type != :major
          return [] if port_authorities(buyer).size >= port_authority_limit
          return [] if buyer.cash < port_authority_cost

          sales = []
          corporations.each do |seller|
            next if seller == buyer || seller.type != :major

            port_authorities(seller).each do |sea|
              sales << [seller, sea] unless port_authorities(buyer).include?(sea)
            end
          end
          sales
        end

        def port_authority_sale_key(seller, sea)
          "#{seller.id}:#{sea}"
        end

        def transfer_port_authority!(buyer, seller, sea)
          price = format_currency(port_authority_cost)
          @log << "#{buyer.name} buys a #{port_authority_name(sea)} from #{seller.name} for #{price}"
          buyer.spend(port_authority_cost, seller)
          @port_authorities[seller].delete(sea)
          @port_authorities[buyer] << sea
          clear_graph_for_entity(buyer)
        end

        def port_authority_sale(buyer, choice)
          port_authority_sales(buyer).find { |seller, sea| port_authority_sale_key(seller, sea) == choice }
        end

        def consenter_for_choice(entity, choice, _label)
          sale = port_authority_sale(entity, choice)
          return super unless sale

          seller_owner = sale.first.owner
          seller_owner if seller_owner != entity.owner
        end

        def orient_express_marker?(corporation)
          @orient_express_markers.include?(corporation)
        end

        def place_orient_express_marker!(corporation)
          @orient_express_markers << corporation unless orient_express_marker?(corporation)
        end

        def float_corporation(corporation)
          super
          return unless corporation.type == :regional

          pay_home_token_cost!(corporation)
        end

        def new_fast_start_round
          Round::G18OE::FastStart.new(self, [G18OE::Step::FastStartCapital])
        end

        def new_concession_round
          @log << '-- Concession RR Phase --'
          Round::G18OE::Concession.new(self, [
            G18OE::Step::HomeToken,
            G18OE::Step::Concession,
          ])
        end

        def reorder_players_after_concessions!
          @players.rotate!(@players.index(@round.entities.last) + 1)
          @log << "#{@players.first.name} has priority deal"
        end

        def new_consolidation_round
          @merge_graph&.clear
          Round::G18OE::Consolidation.new(self, [
            Engine::Step::DiscardTrain,
            G18OE::Step::MergeToken,
            G18OE::Step::MergeDiscardTrain,
            G18OE::Step::MergeMinor,
            G18OE::Step::MergeOffer,
            G18OE::Step::Consolidate,
          ])
        end

        def upgrades_to_correct_label?(from, to)
          return true if from.label == to.label
          return false if from.label && !to.label

          case from.hex.coordinates
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

        def legal_tile_rotation?(_entity, hex, tile)
          return false unless super
          return true unless %i[brown gray].include?(tile.color)

          old_tile = hex.tile
          requires_all_exits = !old_tile.double_towns.empty? || old_tile.label.to_s == 'Y' ||
                               (tile.color == :gray && !old_tile.cities.empty? && !old_tile.label)
          !requires_all_exits || (hex.neighbors.keys - tile.exits).empty?
        end

        def company_becomes_minor?(company)
          corp = @corporations.find { |c| c.name == company.sym }
          return false unless corp

          corp.type == :minor
        end

        def form_button_text(_entity)
          'Float'
        end

        def token_transfer_fees
          self.class::TOKEN_TRANSFER_FEES
        end

        def token_transfer_fee(city)
          hex = city.hex
          return token_transfer_fees[:metropolis] if metropolis_hex?(hex)

          token_transfer_fees[hex.tile.label.to_s == 'Y' ? :grand : :normal]
        end

        def transferable_token?(buyer, token)
          return false if !token.used || !token.city || token.type != :normal

          seller = token.corporation
          return false if buyer.type != :major || seller.type != :major
          return false if seller == buyer || seller.owner != buyer.owner || token == seller.tokens.first

          hex = token.city.hex
          hex.tile.cities.none? { |city| city.tokened_by?(buyer) } && city_in_track_rights?(buyer, hex)
        end

        def transfer_token!(buyer, new_token, old_token, fee)
          seller = old_token.corporation
          city = old_token.city
          extra_slot = city.extra_tokens.include?(old_token)
          slot = city.tokens.index(old_token)
          old_token.remove!
          new_token.place(city, extra: extra_slot)
          extra_slot ? city.extra_tokens << new_token : city.tokens[slot] = new_token
          buyer.spend(new_token.price, @bank)
          buyer.spend(fee, seller)
          return_token_to_charter!(seller, old_token)
          clear_graph_for_entity(buyer)
          hex = city.hex
          @log << "#{buyer.name} buys #{seller.name}'s token in #{hex.location_name} (#{hex.name}) for "\
                  "#{format_currency(new_token.price)} (bank) + #{format_currency(fee)} (#{seller.name})"
        end

        def return_token_to_charter!(seller, returned)
          placed = seller.tokens.select { |token| token.used && token != seller.tokens.first }
          highest = placed.max_by(&:price)
          return if highest.nil? || highest.price <= returned.price

          highest.price, returned.price = returned.price, highest.price
        end

        def pay_home_token_cost!(corporation)
          cost = TRACK_RIGHTS_COST[CORPORATIONS_TRACK_RIGHTS[corporation.id]]
          corporation.spend(cost, @bank) if cost&.positive?
        end

        def add_new_share(share)
          owner = share.owner
          corporation = share.corporation
          corporation.share_holders[owner] += share.percent if owner
          owner.shares_by_corporation[corporation] << share
          @_shares[share.id] = share
        end

        def issuable_shares(entity)
          return [] if !entity.corporation? || entity.type != :major

          bundles_for_corporation(entity, entity)
            .select { |bundle| @share_pool.fit_in_bank?(bundle) }
        end

        def redeemable_shares(entity)
          return [] if !entity.corporation? || entity.type != :major

          bundles_for_corporation(@share_pool, entity)
            .reject { |bundle| entity.cash < bundle.price }
        end

        def value_for_dumpable(player, corporation)
          return 0 if corporation.type == :regional

          super
        end

        def stock_round
          @merge_graph&.clear
          Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G18OE::Step::HomeToken,
            G18OE::Step::MergeToken,
            G18OE::Step::MergeDiscardTrain,
            G18OE::Step::MergeMinor,
            G18OE::Step::ReserveShare,
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
            G18OE::Step::SpecialChoose,
            G18OE::Step::ChooseOperatingPosition,
            G18OE::Step::BuyPortAuthority,
            Engine::Step::Exchange,
            G18OE::Step::FormNational,
            Engine::Step::DiscardTrain,
            Engine::Step::HomeToken,
            G18OE::Step::Assign,
            G18OE::Step::Track,
            G18OE::Step::SpecialToken,
            G18OE::Step::Token,
            G18OE::Step::Route,
            G18OE::Step::Dividend,
            G18OE::Step::OrientExpressBonus,
            G18OE::Step::TransferTokens,
            G18OE::Step::BuyTrain,
            G18OE::Step::NationalBuyTrains,
            G18OE::Step::IssueShares,
          ], round_num: round_num)
        end

        def token_owner(entity)
          return @round.current_operator if entity&.company? && entity.owner&.player? && @round.operating?

          super
        end

        def cross_water_tile_fee(corporation, hex, tile)
          return 0 if national?(corporation)

          (@graph.sea_connectivity(corporation).tile_cost(hex, tile) || 0) * self.class::TILE_FEE_PER_WATER_DISTANCE
        end

        def cross_water_token_fee(corporation, city)
          (@graph.sea_connectivity(corporation).city_cost(city) || 0) * self.class::TOKEN_FEE_PER_WATER_DISTANCE
        end

        def init_graph
          G18OE::Graph.new(self, check_tokens: true)
        end

        def check_other(route)
          super

          if counted_stops(route).size < 2 && !route.connection_data.empty? && !route.train.local?
            raise RouteTooShort, 'Route must have at least 2 stops'
          end

          hexes = route.visited_stops.reject(&:town?).map(&:hex)
          raise GameError, 'Route visits same city hex twice' if hexes.size != hexes.uniq.size

          check_sea_crossing_separation(route)
          if orient_express_run?(route) && !route.chains.empty? && route.chains.all? { |chain| chain[:paths].empty? }
            raise GameError, 'An Orient Express run may not consist entirely of sea crossings'
          end
          return unless combined_train?(route.train)

          raise GameError, 'Combined trains may only run an Orient Express route' unless orient_express_run?(route)
        end

        def double_head_candidates(corporation)
          return [] if !corporation.corporation? || corporation.type != :major
          return [] if corporation.trains.any? { |train| combined_train?(train) }

          corporation.trains.reject { |train| train.operated || !train.rusts_on || extra_train?(train) }
        end

        def non_permanent_trains?
          @depot.trains.any? { |train| train.rusts_on && !train.rusted }
        end

        def combined_train?(train)
          @round.respond_to?(:combined_trains) && @round.combined_trains.key?(train)
        end

        def distance(train)
          [train.distance[1]['pay'], train.distance[0]['pay']]
        end

        def orient_express_origin_hexes
          @orient_express_origin_hexes ||=
            location_hexes(self.class::ORIENT_EXPRESS_ORIGINS).select { |hex| hex.tile.offboards.empty? }
        end

        def orient_express_destination_hexes
          @orient_express_destination_hexes ||= location_hexes(self.class::ORIENT_EXPRESS_DESTINATIONS)
        end

        def orient_express_reachable?(corporation)
          connected = graph_for_entity(corporation).connected_nodes(corporation).keys.map(&:hex)
          connected.intersect?(orient_express_origin_hexes) && connected.intersect?(orient_express_destination_hexes)
        end

        def orient_express_run?(route)
          return false unless route.corporation&.type == :major

          visited = route.visited_stops.map(&:hex)
          visited.intersect?(orient_express_destination_hexes) && visited.intersect?(orient_express_origin_hexes)
        end

        def orient_express_route(routes)
          routes.find { |route| orient_express_run?(route) }
        end

        def orient_express_train_revenue(routes)
          routes.select { |route| orient_express_run?(route) }.map do |route|
            bonus = orient_express_bonus_route?(route) ? 0 : self.class::ORIENT_EXPRESS_BONUS[route.phase.name]
            route.revenue + bonus
          end.max
        end

        def revenue_for(route, stops)
          revenue = super - one_plus_one_marker_undoubled_revenue(route, stops)
          revenue += self.class::ORIENT_EXPRESS_BONUS[route.phase.name] if orient_express_bonus_route?(route)
          revenue + pullman_bonus(route) + minor_d_bonus(route) + hochberg_bonus(route, stops)
        end

        def minor_d_private
          company_by_id('D')
        end

        def minor_d_city?(hex)
          !hex.tile.cities.empty? && !metropolis_hex?(hex)
        end

        def minor_d_token_placeable?(entity)
          minor_d_private&.owner == entity && !abilities(minor_d_private, :assign_hexes, time: 'any').nil?
        end

        def track_token_placeable?(entity)
          minor_d_token_placeable?(entity) || hochberg_token_placeable?(entity)
        end

        def hochberg_private
          company_by_id(self.class::HOCHBERG_TOKEN)
        end

        def hochberg_token_placeable?(corporation)
          company = hochberg_private
          return false if !corporation || !company || !company.owner&.player? || national?(corporation)
          return false unless corporation.owner == company.owner

          !abilities(company, :assign_hexes, time: 'any').nil?
        end

        def hochberg_town
          hochberg_token_hex&.tile&.towns&.first
        end

        def hochberg_hex?(hex)
          return false if hochberg_token_hex
          return false unless hex.original_tile.upgrades.any? do |upgrade|
            upgrade.cost >= self.class::HOCHBERG_MIN_TERRAIN_COST && upgrade.terrains.intersect?(self.class::GREEN_TERRAIN)
          end

          tile = hex.tile
          return false if !tile.cities.empty? || !tile.offboards.empty? || !tile.double_towns.empty?
          return false if tile.towns.size > 1
          return true if !tile.towns.empty? || tile.exits.empty?

          !hochberg_town_tile(tile).nil?
        end

        def place_hochberg_token!(hex)
          @hochberg_token_hex = hex
          tile = hex.tile
          if tile.towns.one?
            zero_hochberg_town!(tile)
          elsif tile.exits.empty?
            town = Engine::Part::Town.new('0')
            town.tile = tile
            tile.towns << town
            tile.city_towns << town
          else
            replacement, turn = hochberg_town_tile(tile)
            replacement.rotate!(turn)
            update_tile_lists(replacement, tile)
            hex.lay(replacement)
          end
          hex.assign!(self.class::HOCHBERG_TOKEN)
          abilities(hochberg_private, :assign_hexes, time: 'any').use!
          flip_private!(hochberg_private) unless face_down_private?(hochberg_private)
          clear_graph
          @log << "#{hochberg_private.owner.name} places the Hochberg Mining and Lumber Company token in #{hex.name}"
        end

        def update_tile_lists(tile, old_tile)
          super
          return if !hochberg_token_hex || old_tile.hex != hochberg_token_hex

          printed = @hochberg_printed_revenue.delete(old_tile.id)
          old_tile.towns.first.revenue = old_tile.towns.first.parse_revenue(printed) if printed
          zero_hochberg_town!(tile)
        end

        def minor_d_token_hex
          hexes.find { |hex| hex.assigned?(@minor_d_token) }
        end

        def minor_d_token_name
          "+#{format_currency(self.class::MINOR_D_BONUS[@minor_d_token])}"
        end

        def place_minor_d_token!(hex)
          hex.assign!(@minor_d_token)
          @minor_d_ability.use!
          @log << "#{minor_d_private.owner.name} places Minor D's #{minor_d_token_name} token in #{hex.name}"
        end

        def minor_d_bonus(route)
          return 0 if minor_d_private&.owner != route.train.owner
          return 0 unless route.visited_stops.any? { |stop| stop.hex.assigned?(@minor_d_token) }

          self.class::MINOR_D_BONUS[@minor_d_token] * (route.train.multiplier || 1)
        end

        def hochberg_town_tile(tile)
          exits = tile.exits.sort
          @tiles.each do |candidate|
            next if candidate.color != tile.color || !candidate.towns.one? || !candidate.cities.empty?
            next if !candidate.double_towns.empty? || !candidate.offboards.empty?

            edges = candidate.edges.map(&:num)
            turn = (0..5).find { |t| edges.map { |e| (e + t) % 6 }.uniq.sort == exits }
            return [candidate, turn] if turn
          end
          nil
        end

        def zero_hochberg_town!(tile)
          town = tile.towns.first
          return unless town

          printed = town.revenue_to_render
          @hochberg_printed_revenue[tile.id] =
            printed.is_a?(Hash) ? printed.map { |phase, value| "#{phase}_#{value}" }.join('|') : printed.to_s
          town.revenue = town.parse_revenue('0')
        end

        def add_minor_d_ability!
          @minor_d_ability = Engine::Ability::AssignHexes.new(type: 'assign_hexes', hexes: [], count: 1, when: 'track',
                                                              owner_type: 'corporation')
          minor_d_private.add_ability(@minor_d_ability)
        end

        def remove_minor_d_token!
          hex = minor_d_token_hex
          return unless hex

          hex.remove_assignment!(@minor_d_token)
          @log << "Minor D's #{minor_d_token_name} token is removed from #{hex.name}"
        end

        def event_minor_d_token!
          return if !minor_d_private || minor_d_private.closed?

          remove_minor_d_token!
          minor_d_private.remove_ability(@minor_d_ability)
          @minor_d_token = self.class::MINOR_D_40_TOKEN
          add_minor_d_ability!
        end

        def return_minor_d_token!(minor)
          return if minor_d_private&.owner != minor || !minor_d_token_hex

          remove_minor_d_token!
          add_minor_d_ability!
        end

        def compute_stops(route, train = nil)
          train ||= route.train
          previous = @one_plus_one_city_limit
          marked = add_on_train?(:one_plus_one_marker, train) && (train.multiplier || 1) > 1
          @one_plus_one_city_limit = marked ? one_plus_one_city_limit(route, train) : nil
          super
        ensure
          @one_plus_one_city_limit = previous
        end

        def one_plus_one_marker?(corporation)
          !@minor_l_ability.nil? && corporation.abilities.include?(@minor_l_ability)
        end

        def train_add_ons(entity)
          add_ons = []
          add_ons << :pullman if pullman(entity)
          add_ons << :one_plus_one_marker if one_plus_one_marker?(entity)
          add_ons
        end

        def train_add_on_name(type)
          self.class::TRAIN_ADD_ONS[type]
        end

        def train_add_on_names(train)
          self.class::TRAIN_ADD_ONS.keys.select { |type| add_on_train?(type, train) }.map { |type| train_add_on_name(type) }
        end

        def add_on_train(type)
          @round.add_on_trains[type] if @round.respond_to?(:add_on_trains)
        end

        def add_on_train?(type, train)
          !train.nil? && add_on_train(type) == train
        end

        def train_distance(train)
          distance = train.distance
          return distance if distance.is_a?(Numeric) || !add_on_train?(:one_plus_one_marker, train)

          distance.map do |row|
            extended = row.dup
            if row['nodes'].include?('city')
              extended['visit'] = (row['visit'] || row['pay']) + 1
              extended['pay'] = row['pay'] + 1
            elsif row['nodes'] == ['town']
              extended['pay'] = row['pay'] + 1
            end
            extended
          end
        end

        def one_plus_one_marker_undoubled_revenue(route, stops)
          train = route.train
          multiplier = train.multiplier || 1
          return 0 if multiplier <= 1 || !add_on_train?(:one_plus_one_marker, train)

          towns, cities = stops.partition(&:town?)
          limit = @one_plus_one_city_limit || one_plus_one_city_limit(route, train)
          single = towns.map { |stop| stop.route_base_revenue(route.phase, train) }
          single << cities.map { |stop| stop.route_base_revenue(route.phase, train) }.min if !cities.empty? && cities.size > limit
          (multiplier - 1) * single.sum
        end

        def one_plus_one_city_limit(route, train)
          city_row = route_train_distance(route, train).find { |row| row['nodes'].include?('city') }
          city_row['pay'] - 1
        end

        def pullman_bonus(route)
          return 0 unless add_on_train?(:pullman, route.train)

          route.train.level * pullman_bonus_per_level
        end

        def routes_revenue(routes)
          check_sea_pool_coverage!(routes)
          super
        end

        def revenue_str(route)
          str = super
          str = "#{str} + Orient Express" if orient_express_bonus_route?(route)
          add_on_train?(:pullman, route.train) ? "#{str} + Pullman" : str
        end

        def check_connected(route, corporation)
          route.connection_data.each_cons(2) do |a, b|
            next if !a[:chain][:paths].empty? && !b[:chain][:paths].empty?

            raise GameError, 'Route is not connected' if a[:right].blocks?(corporation)
          end

          connected = land_stretches(route).all? do |paths|
            paths.each_cons(2).all? do |a, b|
              (wcf_restricted?(corporation) && wcf_pass?(a, b)) || a.connects_to?(b, corporation)
            end
          end
          raise GameError, 'Route is not connected' unless connected
        end

        def wcf_pass?(entering, leaving)
          [entering, leaving].all? { |path| path.nodes.include?(lille_city) } &&
            [entering, leaving].any? { |path| wcf_path?(path) }
        end

        def lille_city
          hex_by_id('N31').tile.cities.first
        end

        def wcf_path?(path)
          path.exits.include?(self.class::PORTS['N31'].keys.first)
        end

        def wcf_restricted?(corporation)
          wcf_placeholder && lille_city.blocks?(corporation)
        end

        def remove_wcf_placeholder!
          @wcf_placeholder.remove!
          @wcf_placeholder = nil
        end

        def sea_zone(hex_id)
          @sea_zone_by_hex ||= self.class::SEA_ZONES.each_with_object({}) do |(zone, data), by_hex|
            data[:hexes].each { |id| by_hex[id] = zone }
          end
          @sea_zone_by_hex[hex_id]
        end

        def sea(zone)
          self.class::SEA_ZONES[zone][:sea]
        end

        def port_sea_zone(hex_id, exit)
          return sea_zone(self.class::PORTS[hex_id][:offshore][:hex]) if exit == :offshore

          neighbor = hex_by_id(hex_id).all_neighbors[exit]
          neighbor && sea_zone(neighbor.id)
        end

        def sea_zone_neighbors
          @sea_zone_neighbors ||= begin
            neighbors = self.class::SEA_ZONES.keys.to_h { |zone| [zone, []] }
            self.class::SEA_ZONES.each do |zone, data|
              data[:hexes].each do |id|
                next unless (hex = hex_by_id(id))

                hex.all_neighbors.each_value do |neighbor|
                  other = sea_zone(neighbor.id)
                  neighbors[zone] << other if other && other != zone
                end
              end
            end
            self.class::CHANNEL_PASSAGES.each do |a, b|
              neighbors[a] << b
              neighbors[b] << a
            end
            neighbors.transform_values(&:uniq)
          end
        end

        def sea_zone_distance(from_zone, to_zone)
          @sea_zone_distances ||= {}
          @sea_zone_distances[from_zone] ||= begin
            distance = { from_zone => 1 }
            queue = [from_zone]
            until queue.empty?
              zone = queue.shift
              sea_zone_neighbors[zone].each do |other|
                next if distance.key?(other)

                distance[other] = distance[zone] + 1
                queue << other
              end
            end
            distance
          end
          @sea_zone_distances[from_zone][to_zone]
        end

        def port_distance(from_port, to_port)
          sea_zone_distance(port_sea_zone(*from_port), port_sea_zone(*to_port))
        end

        private

        def location_hexes(names)
          self.class::LOCATION_NAMES.filter_map { |id, name| hex_by_id(id) if names.include?(name) }
        end

        def orient_express_bonus_route?(route)
          orient_express_run?(route) && route.equal?(orient_express_route(route.routes.empty? ? [route] : route.routes))
        end

        def terrain_discount_minor(entity, tile)
          corp = owning_corporation(entity)
          return unless corp

          return corporation_by_id('E') if corp.abilities.include?(@minor_e_ability) &&
                                          tile.terrain.intersect?(self.class::BLUE_TERRAIN)

          return unless corp.abilities.include?(@minor_f_ability)
          return unless tile.terrain.intersect?(self.class::GREEN_TERRAIN)

          corporation_by_id('F')
        end

        def owning_corporation(entity)
          resolved = entity.corporation? ? entity : entity.owner
          resolved&.corporation? ? resolved : nil
        end
      end
    end
  end
end
