# frozen_string_literal: true

require_relative '../config/game/g_18_zoo'
require_relative 'base'

module Engine
  module Game
    class G18ZOO < Base
      load_from_json(Config::Game::G18ZOO::JSON)

      GAME_DESIGNER = 'Paolo Russo'

      # Game end after the ORs in the third turn, of if any company reach 24
      GAME_END_CHECK = { stock_market: :current_or, custom: :full_or }.freeze

      OPTIONAL_RULES = [
        { sym: :map_b, short_name: 'Map B', desc: '5 families', players: [2, 3, 4] },
        { sym: :map_c, short_name: 'Map C', desc: '5 families', players: [2, 3, 4] },
        { sym: :map_d, short_name: 'Map D', desc: '7 families', players: [2, 3, 4, 5] },
        { sym: :map_e, short_name: 'Map E', desc: '7 families', players: [2, 3, 4, 5] },
        { sym: :map_f, short_name: 'Map F', desc: '7 families', players: [2, 3, 4, 5] },
        { sym: :power_visible, short_name: 'Powers visible', desc: 'Next powers are visible since the beginning.' },
      ].freeze

      BANKRUPTCY_ALLOWED = false

      STARTING_CASH_SMALL_MAP = { 2 => 40, 3 => 28, 4 => 23, 5 => 22 }.freeze

      STARTING_CASH_BIG_MAP = { 2 => 48, 3 => 32, 4 => 27, 5 => 22 }.freeze

      TILE_Y = 'label=Y;city=revenue:yellow_30|green_40|brown_50,slots:1;offboard=revenue:yellow_20|brown_40,hide:1'
      HEXES_BY_MAP = {
        map_a: {
          gray: {
            %w[B9 C8 J5 L13] => '',
            [:M8] => 'path=a:0,b:1',
            [:F9] => 'path=a:0,b:3',
            [:H3] => 'path=a:0,b:4',
            [:A10] => 'path=a:0,b:5',
            [:K6] => 'path=a:1,b:3',
            [:G20] => 'path=a:2,b:3',
            [:J19] => 'path=a:2,b:4',
            [:A12] => 'path=a:3,b:5',
            [:G16] => 'path=a:1,b:4;path=a:3,b:5',
            [:L15] => 'path=a:0,b:4;path=a:1,b:4',
            [:J7] => 'path=a:0,b:4;path=a:4,b:5',
            [:D7] => 'offboard=revenue:0,hide:1;path=a:0,b:_0',
            %w[L3 N9] => 'offboard=revenue:0,hide:1;path=a:1,b:_0',
            %w[I6 K10] => 'offboard=revenue:0,hide:1;path=a:2,b:_0',
            [:F21] => 'offboard=revenue:0,hide:1;path=a:3,b:_0',
            [:L9] => 'offboard=revenue:0,hide:1;path=a:5,b:_0;path=a:2,b:4',
            [:K8] => 'offboard=revenue:0,hide:1;path=a:1,b:_0;path=a:2,b:5',
            [:H13] => 'offboard=revenue:0,hide:1;path=a:1,b:_0;path=a:0,b:4',
          },
          red: {
            %w[L5 M18] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;label=R',
            [:E8] => 'offboard=revenue:yellow_30|brown_60;path=a:4,b:_0;label=R',
            [:B17] => 'offboard=revenue:yellow_30|brown_60;path=a:3,b:_0;path=a:4,b:_0;label=R',
            [:H19] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=R',
          },
          white: {
            %w[I4 H5 F7 H7 G8 I8 C10 I10 F11 J11 L11 E12 G12 I12 K12 D13 F13 J13 C14 E14 B15 F15 C16 E16 I16 K16 H17
               L17 I18] => '',
            %w[J9 M10 J17 D15 G14] => 'city=revenue:0,slots:1',
            %w[B11 B13 E18 G10 H9 H11 I2 K14 M12 M14] => 'upgrade=cost:0,terrain:water',
            %w[C12 H15 I14 D17] => 'upgrade=cost:1,terrain:mountain',
            %w[D11 E10 F17 G18 J3 K18 M16] => 'upgrade=cost:2,terrain:mountain',
            %w[D9 F19 J15 K4] => TILE_Y,
          },
        },
        map_b: {
          gray: {
            %w[F14 L14] => '',
            %w[F4 H0 M9] => 'path=a:0,b:1',
            [:F10] => 'path=a:0,b:3',
            %w[F0] => 'path=a:0,b:5',
            ['H14'] => 'path=a:1,b:4',
            ['G21'] => 'path=a:2,b:3',
            ['J20'] => 'path=a:2,b:4',
            ['E5'] => 'path=a:4,b:5',
            ['L16'] => 'path=a:0,b:4;path=a:1,b:4',
            ['G17'] => 'path=a:1,b:4;path=a:3,b:5',
            ['J8'] => 'path=a:0,b:4;path=a:4,b:5',
            ['H4'] => 'junction;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0',
            %w[L4 N10] => 'offboard=revenue:0,hide:1;path=a:1,b:_0',
            ['K11'] => 'offboard=revenue:0,hide:1;path=a:2,b:_0',
            ['F22'] => 'offboard=revenue:0,hide:1;path=a:3,b:_0',
            ['K9'] => 'offboard=revenue:0,hide:1;path=a:1,b:_0;path=a:2,b:5',
            ['L10'] => 'offboard=revenue:0,hide:1;path=a:5,b:_0;path=a:2,b:4',
          },
          "red": {
            ['L6'] => 'offboard=revenue:yellow_30|brown_60;path=a:1,b:_0;path=a:2,b:_0;label=R',
            ['M19'] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;label=R',
            ['H20'] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=R',
          },
          "white": {
            %w[E7 F8 F12 F18 G5 G7 G9 G13 G15 H2 H8 H18 I5 I7 I9 I11 I13 I17 I19 J12 J14 K13 K17 L12 L18] => '',
            %w[G3 H6 J10 J18 M11] => 'city=revenue:0,slots:1',
            %w[F2 F16 G1 G11 H10 H12 I3 K15 M13 M15] => 'upgrade=cost:0,terrain:water',
            %w[H16 I15 J6] => 'upgrade=cost:1,terrain:mountain',
            %w[G19 J4 K7 K19 M17] => 'upgrade=cost:2,terrain:mountain',
            %w[F6 F20 J16
               K5] => TILE_Y,
          },
        },
        map_c: {
          gray: {
            %w[F3] => '',
            %w[D3 I0] => 'path=a:0,b:1',
            %w[F7] => 'path=a:1,b:4',
            [:G10] => 'path=a:0,b:3',
            %w[G0] => 'path=a:0,b:5',
            [:H21] => 'path=a:2,b:3',
            [:B13] => 'path=a:3,b:5',
            [:C4] => 'path=a:4,b:5',
            [:H17] => 'path=a:1,b:4;path=a:3,b:5',
            [:I4] => 'junction;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0',
            %w[A10] => 'offboard=revenue:0,hide:1;path=a:5,b:_0',
            %w[M4] => 'offboard=revenue:0,hide:1;path=a:1,b:_0',
            [:G22] => 'offboard=revenue:0,hide:1;path=a:3,b:_0',
            [:I14] => 'offboard=revenue:0,hide:1;path=a:1,b:_0;path=a:0,b:4',
          },
          red: {
            [:M6] => 'offboard=revenue:yellow_30|brown_60;path=a:1,b:_0;path=a:2,b:_0;label=R',
            [:E2] => 'offboard=revenue:yellow_30|brown_60;path=a:0,b:_0;label=R',
            [:C18] => 'offboard=revenue:yellow_30|brown_60;path=a:3,b:_0;path=a:4,b:_0;label=R',
            [:I20] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;path=a:3,b:_0;label=R',
          },
          white: {
            %w[C10 C16 D11 D15 D17 E4 E14 F5 F13 F15 F17 G4 G8 G12 G14 G16 H5 H7 H9 H13 I2 I8 I18 J5 J7] => '',
            %w[D5 E16 H3 H15 I6] => 'city=revenue:0,slots:1',
            %w[C12 C14 D9 E6 F19 G2 H1 H11 I10 I12 J3] => 'upgrade=cost:0,terrain:water',
            %w[D13 E18 F9 I16 K6] => 'upgrade=cost:1,terrain:mountain',
            %w[D7 E8 E12 F11 G18 H19 K4 L7] => 'upgrade=cost:2,terrain:mountain',
            %w[B11 E10 G6 G20
               L5] => TILE_Y,
          },
        },
        map_d: {
          gray: {
            %w[B10 C9 D6 L14] => '',
            %w[F4 H0 M9] => 'path=a:0,b:1',
            [:F10] => 'path=a:0,b:3',
            %w[A11 F0] => 'path=a:0,b:5',
            [:G21] => 'path=a:2,b:3',
            [:J20] => 'path=a:2,b:4',
            [:A13] => 'path=a:3,b:5',
            [:E5] => 'path=a:4,b:5',
            [:L16] => 'path=a:0,b:4;path=a:1,b:4',
            [:G17] => 'path=a:1,b:4;path=a:3,b:5',
            [:J8] => 'path=a:0,b:4;path=a:4,b:5',
            [:H4] => 'junction;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0',
            %w[L4 N10] => 'offboard=revenue:0,hide:1;path=a:1,b:_0',
            [:D8] => 'offboard=revenue:0,hide:1;path=a:0,b:_0',
            [:K11] => 'offboard=revenue:0,hide:1;path=a:2,b:_0',
            [:F22] => 'offboard=revenue:0,hide:1;path=a:3,b:_0',
            [:K9] => 'offboard=revenue:0,hide:1;path=a:1,b:_0;path=a:2,b:5',
            [:L10] => 'offboard=revenue:0,hide:1;path=a:5,b:_0;path=a:2,b:4',
            [:H14] => 'offboard=revenue:0,hide:1;path=a:1,b:_0;path=a:0,b:4',
          },
          red: {
            [:L6] => 'offboard=revenue:yellow_30|brown_60;path=a:1,b:_0;path=a:2,b:_0;label=R',
            [:M19] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;label=R',
            [:E9] => 'offboard=revenue:yellow_30|brown_60;path=a:4,b:_0;label=R',
            [:B18] => 'offboard=revenue:yellow_30|brown_60;path=a:3,b:_0;path=a:4,b:_0;label=R',
            [:H20] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=R',
          },
          white: {
            %w[B16 C11 C15 C17 D14 E7 E13 E15 E17 F8 F12 F14 F16 G5 G7 G9 G13 H2 H8 H18 I5 I7 I9 I11 I13 I17 I19 J12
               J14 K13 K17 L12 L18] => '',
            %w[D16 G3 G15 H6 J10 J18 M11] => 'city=revenue:0,slots:1',
            %w[B12 B14 E19 F2 G1 G11 H10 H12 I3 K15 M13 M15] => 'upgrade=cost:0,terrain:water',
            %w[C13 D18 H16 I15 J6] => 'upgrade=cost:1,terrain:mountain',
            %w[D12 E11 F18 G19 J4 K7 K19 M17] => 'upgrade=cost:2,terrain:mountain',
            %w[D10 F6 F20 J16
               K5] => TILE_Y,
          },
        },
        map_e: {
          gray: {
            %w[D6 E3 E15 L14] => '',
            %w[C3 H0 M9] => 'path=a:0,b:1',
            [:F10] => 'path=a:0,b:3',
            %w[F0] => 'path=a:0,b:5',
            [:G21] => 'path=a:2,b:3',
            [:J20] => 'path=a:2,b:4',
            [:L16] => 'path=a:0,b:4;path=a:1,b:4',
            [:B4] => 'path=a:4,b:5',
            [:G17] => 'path=a:1,b:4;path=a:3,b:5',
            [:J8] => 'path=a:0,b:4;path=a:4,b:5',
            [:H4] => 'junction;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0',
            %w[L4 N10] => 'offboard=revenue:0,hide:1;path=a:1,b:_0',
            [:K11] => 'offboard=revenue:0,hide:1;path=a:2,b:_0',
            [:F22] => 'offboard=revenue:0,hide:1;path=a:3,b:_0',
            [:E7] => 'offboard=revenue:0,hide:1;path=a:4,b:_0',
            [:K9] => 'offboard=revenue:0,hide:1;path=a:1,b:_0;path=a:2,b:5',
            [:L10] => 'offboard=revenue:0,hide:1;path=a:5,b:_0;path=a:2,b:4',
            [:H14] => 'offboard=revenue:0,hide:1;path=a:1,b:_0;path=a:0,b:4',
          },
          red: {
            [:L6] => 'offboard=revenue:yellow_30|brown_60;path=a:1,b:_0;path=a:2,b:_0;label=R',
            [:M19] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;label=R',
            [:D2] => 'offboard=revenue:yellow_30|brown_60;path=a:0,b:_0;label=R',
            [:H20] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=R',
          },
          white: {
            %w[D4 E5 F4 F8 F12 F14 F16 G5 G7 G9 G13 H2 H8 H18 I5 I7 I9 I11 I13 I17 I19 J12 J14 K13 K17 L12 L18] => '',
            %w[C5 G3 G15 H6 J10 J18 M11] => 'city=revenue:0,slots:1',
            %w[D6 E17 E19 F2 G1 G11 H10 H12 I3 K15 M13 M15] => 'upgrade=cost:0,terrain:water',
            %w[H16 I15 J6] => 'upgrade=cost:1,terrain:mountain',
            %w[C7 F18 G19 J4 K7 K19 M17] => 'upgrade=cost:2,terrain:mountain',
            %w[F6 F20 J16
               K5] => TILE_Y,
          },
        },
        map_f: {
          gray: {
            %w[F3] => '',
            %w[D3 I0] => 'path=a:0,b:1',
            %w[L11] => 'path=a:0,b:2;path=a:0,b:3',
            %w[G10 L13] => 'path=a:0,b:3',
            %w[G0 J15] => 'path=a:0,b:5',
            %w[K12] => 'path=a:1,b:3',
            %w[F7] => 'path=a:1,b:4',
            %w[J13] => 'path=a:1,b:4',
            %w[H21] => 'path=a:2,b:3',
            %w[B13] => 'path=a:3,b:5',
            %w[C4] => 'path=a:4,b:5',
            %w[H17] => 'path=a:1,b:4;path=a:3,b:5',
            %w[I4] => 'junction;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0',
            %w[M4] => 'offboard=revenue:0,hide:1;path=a:1,b:_0',
            %w[L19] => 'offboard=revenue:0,hide:1;path=a:2,b:_0',
            %w[G22] => 'offboard=revenue:0,hide:1;path=a:3,b:_0',
            %w[J11] => 'offboard=revenue:0,hide:1;path=a:4,b:_0',
            %w[A10] => 'offboard=revenue:0,hide:1;path=a:5,b:_0',
            %w[L9] => 'offboard=revenue:0,hide:1;path=a:1,b:2;path=a:2,b:0',
            %w[I14] => 'offboard=revenue:0,hide:1;path=a:1,b:_0;path=a:0,b:4',
          },
          red: {
            %w[M6] => 'offboard=revenue:yellow_30|brown_60;path=a:1,b:_0;path=a:2,b:_0;label=R',
            %w[E2] => 'offboard=revenue:yellow_30|brown_60;path=a:0,b:_0;label=R',
            %w[C18] => 'offboard=revenue:yellow_30|brown_60;path=a:3,b:_0;path=a:4,b:_0;label=R',
            %w[I20] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=R',
          },
          white: {
            %w[C10 C16 D11 D15 D17 E4 E14 F5 F13 F15 F17 G4 G8 G12 G14 G16 H5 H7 H9 H13 I2 I8 I18 J5 J7 J9 J17 J19 K8
               K14 L17] => '',
            %w[D5 E16 H3 H15 I6 K10 K18] => 'city=revenue:0,slots:1',
            %w[C12 C14 D9 E6 F19 G2 H1 H11 I10 I12 J3 L15 L17] => 'upgrade=cost:0,terrain:water',
            %w[D13 E18 F9 I16 K6] => 'upgrade=cost:1,terrain:mountain',
            %w[D7 E8 E12 F11 G18 H19 K4 L7] => 'upgrade=cost:2,terrain:mountain',
            %w[B11 E10 G6 G20 K16
               L5] => TILE_Y,
          },
        },
      }.freeze

      SMALL_MAP = %i[map_a map_b map_c].freeze

      CERT_LIMIT = {
        2 => { 5 => 10, 7 => 12 },
        3 => { 5 => 7, 7 => 9 },
        4 => { 5 => 5, 7 => 7 },
        5 => { 5 => 6, 7 => 6 },
      }.freeze

      CERT_LIMIT_INCLUDES_PRIVATES = false

      STOCKMARKET_COLORS = {
        par_1: :yellow,
        par_2: :green,
        par_3: :brown,
        endgame: :gray,
      }.freeze

      STOCKMARKET_THRESHOLD = [
        [100, 150, 150, 200, 200, 250, 250, 300, 350, 400, 450, 0],
        [100, 100, 150, 150, 200, 200, 250, 250, 300],
        [80, 100, 100, 150, 150, 200, 200],
        [50, 80, 100, 100, 150],
        [40, 50, 80],
        [30, 40],
      ].freeze

      STOCKMARKET_GAIN = [
        [1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 5, 6],
        [1, 1, 2, 2, 2, 2, 3, 3, 3],
        [1, 1, 2, 2, 2, 2, 2],
        [1, 1, 1, 2, 2],
        [0, 1, 1],
        [0, 0],
      ].freeze

      STOCKMARKET_OWNER_GAIN = [
        [0, 0, 0, 1, 2, 2, 2, 2, 3],
      ].freeze

      SELL_AFTER = :any_time

      SELL_BUY_ORDER = :sell_buy

      NEXT_SR_PLAYER_ORDER = :most_cash # TODO: check if a bug

      CORPORATIONS_BY_MAP = {
        map_a: %i[GI PB PE LI TI],
        map_b: %i[CR GI PB PE BB],
        map_c: %i[CR LI TI BB EL],
        map_d: %i[CR GI PB PE LI TI BB],
        map_e: %i[CR GI PB PE TI BB EL],
        map_f: %i[CR GI PE LI TI BB EL],
      }.freeze

      CORPORATION_COORDINATES_BY_MAP = {
        map_a: { GI: 'J9', PB: 'M10', PE: 'J17', LI: 'D15', TI: 'G14' },
        map_b: { CR: 'G3', GI: 'J10', PB: 'M11', PE: 'J18', BB: 'H6' },
        map_c: { CR: 'H3', LI: 'E16', TI: 'H15', BB: 'I6', EL: 'D5' },
        map_d: { CR: 'G3', GI: 'J10', PB: 'M11', PE: 'J18', LI: 'D16', TI: 'G15', BB: 'H6' },
        map_e: { CR: 'G3', GI: 'J10', PB: 'M11', PE: 'J18', TI: 'G15', BB: 'H6', EL: 'C5' },
        map_f: { CR: 'H3', GI: 'K10', PE: 'K18', LI: 'E16', TI: 'H15', BB: 'I6', EL: 'D5' },
      }.freeze

      LOCATION_NAMES_BY_MAP = {
        map_a: {
          "B11": 'O',
          "B13": 'O',
          "E18": 'O',
          "G10": 'O',
          "H9": 'O',
          "H11": 'O',
          "I2": 'O',
          "K14": 'O',
          "M12": 'O',
          "M14": 'O',
          "D11": 'MM',
          "E10": 'MM',
          "F17": 'MM',
          "G18": 'MM',
          "J3": 'MM',
          "K18": 'MM',
          "M16": 'MM',
          "C12": 'M',
          "H15": 'M',
          "I14": 'M',
          "D17": 'M',
        },
        map_b: {
          "F2": 'O',
          "F16": 'O',
          "G1": 'O',
          "G11": 'O',
          "H10": 'O',
          "H12": 'O',
          "I3": 'O',
          "K15": 'O',
          "M13": 'O',
          "M15": 'O',
          "H16": 'M',
          "I15": 'M',
          "J6": 'M',
          "G19": 'MM',
          "J4": 'MM',
          "K7": 'MM',
          "K19": 'MM',
          "M17": 'MM',
        },
        map_c: {
          "C12": 'O',
          "C14": 'O',
          "D9": 'O',
          "E6": 'O',
          "F19": 'O',
          "G2": 'O',
          "H1": 'O',
          "H11": 'O',
          "I10": 'O',
          "I12": 'O',
          "J3": 'O',
          "L15": 'O',
          "N13": 'O',
          "N15": 'O',
          "D13": 'M',
          "E18": 'M',
          "F9": 'M',
          "I16": 'M',
          "J15": 'M',
          "K6": 'M',
          "D7": 'MM',
          "E8": 'MM',
          "E12": 'MM',
          "F11": 'MM',
          "G18": 'MM',
          "H19": 'MM',
          "K4": 'MM',
          "L7": 'MM',
          "L19": 'MM',
          "N17": 'MM',
        },
        map_d: {
          "B12": 'O',
          "B14": 'O',
          "E19": 'O',
          "F2": 'O',
          "G1": 'O',
          "G11": 'O',
          "H10": 'O',
          "H12": 'O',
          "I3": 'O',
          "K15": 'O',
          "M13": 'O',
          "M15": 'O',
          "C13": 'M',
          "D18": 'M',
          "H16": 'M',
          "I15": 'M',
          "J6": 'M',
          "D12": 'MM',
          "E11": 'MM',
          "F18": 'MM',
          "G19": 'MM',
          "J4": 'MM',
          "K7": 'MM',
          "K19": 'MM',
          "M17": 'MM',
        },
        map_e: {
          "D6": 'O',
          "E17": 'O',
          "E19": 'O',
          "F2": 'O',
          "G1": 'O',
          "G11": 'O',
          "H10": 'O',
          "H12": 'O',
          "I3": 'O',
          "K15": 'O',
          "M13": 'O',
          "M15": 'O',
          "C13": 'M',
          "D18": 'M',
          "H16": 'M',
          "I15": 'M',
          "J6": 'M',
          "C7": 'MM',
          "D12": 'MM',
          "E11": 'MM',
          "F18": 'MM',
          "G19": 'MM',
          "J4": 'MM',
          "K7": 'MM',
          "K19": 'MM',
          "M17": 'MM',
        },
        map_f: {
          "C12": 'O',
          "C14": 'O',
          "D9": 'O',
          "E6": 'O',
          "F19": 'O',
          "G2": 'O',
          "H1": 'O',
          "H11": 'O',
          "I10": 'O',
          "I12": 'O',
          "J3": 'O',
          "L15": 'O',
          "L17": 'O',
          "D13": 'M',
          "E18": 'M',
          "F9": 'M',
          "I16": 'M',
          "K6": 'M',
          "D7": 'MM',
          "E8": 'MM',
          "E12": 'MM',
          "F11": 'MM',
          "G18": 'MM',
          "H19": 'MM',
          "K4": 'MM',
          "L7": 'MM',
        },
      }.freeze

      HOME_TOKEN_TIMING = :float

      MUST_BUY_TRAIN = :always

      # A yellow/upgrade and a yellow
      TILE_LAYS = [{ lay: true, upgrade: true }, { lay: true, upgrade: :not_if_upgraded }].freeze

      MARKET_TEXT = Base::MARKET_TEXT.merge(par_2: 'Can only enter during phase green',
                                            par_3: 'Can only enter during phase brown').freeze

      MARKET_SHARE_LIMIT = 80 # percent

      attr_reader :available_companies, :future_companies

      def setup
        @operating_rounds = 2 # 2 ORs on first and second round

        @available_companies = []
        @future_companies = []

        draw_size = players.size == 5 ? 6 : 4
        @companies_for_isr = @companies.first(draw_size)
        @companies_for_monday = @companies.drop(draw_size + 4).first(4)
        @companies_for_tuesday = @companies.drop(draw_size + 8).first(4)
        @companies_for_wednesday = @companies.drop(draw_size + 12).first(4)

        @available_companies.concat(@companies_for_isr)

        if @all_private_visible
          @log << 'All powers visible in the future deck'
          @future_companies.concat(@companies_for_monday + @companies_for_tuesday + @companies_for_wednesday)
        else
          @future_companies.concat(@companies_for_monday)
        end

        reserve_shares(false)
      end

      def init_optional_rules(optional_rules)
        rules = super

        maps = rules.select { |rule| rule.start_with?('map_') }
        raise GameError, 'Please select a single map.' unless maps.size <= 1

        @map = maps.empty? ? :map_a : maps.first

        @near_families = @players.size < 5
        @all_private_visible = rules.include?(:power_visible)

        rules
      end

      # use to modify hexes based on optional rules
      def optional_hexes
        self.class::HEXES_BY_MAP[@map]
      end

      # use to modify location names based on optional rules
      def location_name(coord)
        self.class::LOCATION_NAMES_BY_MAP[@map][coord]
      end

      def self.title
        '18ZOO'
      end

      def unowned_purchasable_companies(_entity)
        @available_companies + @future_companies
      end

      private

      def init_round
        Round::Draft.new(self, [Step::G18ZOO::SimpleDraft], reverse_order: true)
      end

      def num_trains(train)
        num_players = @players.size

        case train[:name]
        when '2S'
          num_players
        else
          super
        end
      end

      def init_corporations(stock_market)
        self.class::CORPORATIONS.select { |corporation| CORPORATIONS_BY_MAP[@map].include?(corporation[:sym]) }
                                .map do |corporation|
          Corporation.new(
            min_price: stock_market.par_prices.map(&:price).min,
            capitalization: self.class::CAPITALIZATION,
            coordinates: CORPORATION_COORDINATES_BY_MAP[@map][corporation[:sym]],
            **corporation.merge(corporation_opts),
          )
        end
      end

      def init_starting_cash(players, bank)
        hash = SMALL_MAP.include?(@map) ? self.class::STARTING_CASH_SMALL_MAP : self.class::STARTING_CASH_BIG_MAP
        cash = hash[players.size]

        players.each do |player|
          bank.spend(cash, player)
        end
      end

      def custom_end_game_reached?
        @turn == 3
      end

      def new_stock_round
        result = super

        add_cousins if @turn == 3

        update_current_and_future(@companies_for_monday, @companies_for_tuesday, 1)
        update_current_and_future(@companies_for_tuesday, @companies_for_wednesday, 2)
        update_current_and_future(@companies_for_wednesday, nil, 3)

        @available_companies.select { |c| c.owner.nil? }.each { |c| c.owner = @bank }

        result
      end

      def new_operating_round(round_num = 1)
        @operating_rounds = 3 if @turn == 3 # Last round has 3 ORs

        super
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Track,
          Step::Token,
        ], round_num: round_num)
      end

      def round_description(name, round_number = nil)
        round_number ||= @round.round_num
        day = case @turn
              when 1
                'Monday'
              when 2
                'Tuesday'
              when 3
                'Wednesday'
              end

        case name
        when 'Draft'
          name
        when 'Stock'
          "#{day} Stock"
        when 'Operating'
          "#{day} Operating Round (#{round_number} of #{@operating_rounds})"
        end
      end

      # Override this, and add elements (paragraphs of text) here to display it on Info page.
      def timeline
        @timeline.append("Game ends after OR #{@last_or}")
        @timeline.append("Next set of Operating Rounds will have #{OR_SETS[@turn - 1]} ORs")
      end

      def add_cousins
        @log << 'Cousins join families.'

        reserve_shares(true)
      end

      def reserve_shares(purchasable)
        @corporations.each { |c| c.shares.last.buyable = purchasable }
      end

      def update_current_and_future(to_current, to_future, turn)
        @available_companies.concat(to_current) if @turn == turn
        return unless !@all_private_visible && to_future && @turn == turn

        @log << "Powers #{to_future.map { |c| "\"#{c.name}\"" }.join(', ')} added to the future deck"
        @future_companies.concat(to_future)
      end
    end
  end
end
