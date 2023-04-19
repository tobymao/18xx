# frozen_string_literal: true

require_relative 'meta'
require_relative 'entities'
require_relative 'map'
require_relative '../base'
require_relative '../stubs_are_restricted'

module Engine
  module Game
    module G1822
      class Game < Game::Base
        include_meta(G1822::Meta)
        include G1822::Entities
        include G1822::Map

        register_colors(lnwrBlack: '#000',
                        gwrGreen: '#165016',
                        lbscrYellow: '#cccc00',
                        secrOrange: '#ff7f2a',
                        crBlue: '#5555ff',
                        mrRed: '#ff2a2a',
                        lyrPurple: '#5a2ca0',
                        nbrBrown: '#a05a2c',
                        swrGray: '#999999',
                        nerGreen: '#aade87',
                        black: '#000',
                        white: '#ffffff')

        BANKRUPTCY_ALLOWED = false

        CURRENCY_FORMAT_STR = '£%s'

        BANK_CASH = 12_000

        CERT_LIMIT = { 3 => 26, 4 => 20, 5 => 16, 6 => 13, 7 => 11 }.freeze

        EBUY_OTHER_VALUE = false

        STARTING_CASH = { 3 => 700, 4 => 525, 5 => 420, 6 => 350, 7 => 300 }.freeze

        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = false

        TILE_TYPE = :lawson

        TILE_UPGRADES_MUST_USE_MAX_EXITS = %i[cities].freeze

        PLAIN_SYMBOL_UPGRADES = {
          yellow: %w[S T],
        }.freeze

        GAME_END_CHECK = { bank: :full_or, stock_market: :current_or }.freeze

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
          par_1: :red,
          par: :peach,
        ).freeze
        MARKET_TEXT = Base::MARKET_TEXT.merge(
          par_1: 'Par (Majors and Minors, Phases 2-7)',
          par: 'Par (Minors only. Phases 1-7)',
        )
        MARKET = [
          ['', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '550', '600', '650', '700e'],
          ['', '', '', '', '', '', '', '', '', '', '', '', '', '330', '360', '400', '450', '500', '550', '600', '650'],
          ['', '', '', '', '', '', '', '', '', '200', '220', '245', '270', '300', '330', '360', '400', '450', '500',
           '550', '600'],
          %w[70 80 90 100 110 120 135 150 165 180 200 220 245 270 300 330 360 400 450 500 550],
          %w[60 70 80 90 100xp 110 120 135 150 165 180 200 220 245 270 300 330 360 400 450 500],
          %w[50 60 70 80 90xp 100 110 120 135 150 165 180 200 220 245 270 300 330],
          %w[45y 50 60 70 80xp 90 100 110 120 135 150 165 180 200 220 245],
          %w[40y 45y 50 60 70xp 80 90 100 110 120 135 150 165 180],
          %w[35y 40y 45y 50 60xp 70 80 90 100 110 120 135],
          %w[30y 35y 40y 45y 50p 60 70 80 90 100],
          %w[25y 30y 35y 40y 45y 50 60 70 80],
          %w[20y 25y 30y 35y 40y 45y 50y 60y],
          %w[15y 20y 25y 30y 35y 40y 45y],
          %w[10y 15y 20y 25y 30y 35y],
          %w[5y 10y 15y 20y 25y],
        ].freeze

        PHASES = [
          {
            name: '1',
            on: '',
            train_limit: { minor: 2, major: 4 },
            tiles: [:yellow],
            status: ['minor_float_phase1'],
            operating_rounds: 1,
          },
          {
            name: '2',
            on: %w[2 3],
            train_limit: { minor: 2, major: 4 },
            tiles: [:yellow],
            status: %w[can_convert_concessions minor_float_phase2],
            operating_rounds: 2,
          },
          {
            name: '3',
            on: '3',
            train_limit: { minor: 2, major: 4 },
            tiles: %i[yellow green],
            status: %w[can_buy_trains can_convert_concessions minor_float_phase3on],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: { minor: 1, major: 3 },
            tiles: %i[yellow green],
            status: %w[can_buy_trains can_convert_concessions minor_float_phase3on],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown],
            status: %w[can_buy_trains
                       can_acquire_minor_bidbox
                       can_par
                       minors_green_upgrade
                       minor_float_phase3on],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '6',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown],
            status: %w[can_buy_trains
                       can_acquire_minor_bidbox
                       can_par
                       full_capitalisation
                       minors_green_upgrade
                       minor_float_phase3on],
            operating_rounds: 2,
          },
          {
            name: '7',
            on: '7',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown gray],
            status: %w[can_buy_trains
                       can_acquire_minor_bidbox
                       can_par
                       full_capitalisation
                       minors_green_upgrade
                       minor_float_phase3on],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: 'L',
            distance: [
              {
                'nodes' => ['city'],
                'pay' => 1,
                'visit' => 1,
              },
              {
                'nodes' => ['town'],
                'pay' => 1,
                'visit' => 1,
              },
            ],
            num: 22,
            price: 60,
            rusts_on: '3',
            variants: [
              {
                name: '2',
                distance: 2,
                price: 120,
                rusts_on: '4',
                available_on: '1',
              },
            ],
          },
          {
            name: '3',
            distance: 3,
            num: 9,
            price: 200,
            rusts_on: '6',
          },
          {
            name: '4',
            distance: 4,
            num: 6,
            price: 300,
            rusts_on: '7',
          },
          {
            name: '5',
            distance: 5,
            num: 3,
            price: 500,
            events: [
              {
                'type' => 'close_concessions',
              },
            ],
          },
          {
            name: '6',
            distance: 6,
            num: 3,
            price: 600,
            events: [
              {
                'type' => 'full_capitalisation',
              },
            ],
          },
          {
            name: '7',
            distance: 7,
            num: 20,
            price: 750,
            variants: [
              {
                name: 'E',
                distance: 99,
                multiplier: 2,
                price: 1000,
              },
            ],
            events: [
              {
                'type' => 'phase_revenue',
              },
            ],
          },
          {
            name: '2P',
            distance: 2,
            num: 2,
            price: 0,
          },
          {
            name: 'LP',
            distance: [
              {
                'nodes' => ['city'],
                'pay' => 1,
                'visit' => 1,
              },
              {
                'nodes' => ['town'],
                'pay' => 1,
                'visit' => 1,
              },
            ],
            num: 1,
            price: 0,
          },
          {
            name: '5P',
            distance: 5,
            num: 1,
            price: 500,
          },
          {
            name: 'P+',
            distance: [
              {
                'nodes' => ['city'],
                'pay' => 99,
                'visit' => 99,
              },
              {
                'nodes' => ['town'],
                'pay' => 99,
                'visit' => 99,
              },
            ],
            num: 2,
            price: 0,
          },
        ].freeze

        LAYOUT = :flat

        SELL_MOVEMENT = :down_share

        HOME_TOKEN_TIMING = :operate
        MUST_BID_INCREMENT_MULTIPLE = true
        MUST_BUY_TRAIN = :always
        NEXT_SR_PLAYER_ORDER = :most_cash

        SELL_AFTER = :operate

        SELL_BUY_ORDER = :sell_buy

        EVENTS_TEXT = {
          'close_concessions' =>
            ['Concessions close', 'All concessions close without compensation, major companies float at 50%'],
          'full_capitalisation' =>
            ['Full capitalisation', 'Major companies receive full capitalisation when floated'],
          'phase_revenue' =>
            ['Phase revenue companies close', 'P15-HR and P20-C&WR close if not owned by a major company'],
        }.freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'can_buy_trains' => ['Buy trains', 'Can buy trains from other corporations'],
          'can_convert_concessions' => ['Convert concessions',
                                        'Can float a major company by converting a concession'],
          'can_acquire_minor_bidbox' => ['Acquire a minor from bidbox',
                                         'Can acquire a minor from bidbox for £200, must have connection '\
                                         'to start location'],
          'can_par' => ['Majors 50% float', 'Majors companies require 50% sold to float'],
          'full_capitalisation' => ['Full capitalisation', 'Majors receives full capitalisation '\
                                                           '(the remaining five shares are placed in the bank)'],
          'minor_float_phase1' => ['Minors receive £100 in capital', 'Minors receive 100 capital with 50 stock value'],
          'minor_float_phase2' => ['Minors receive 2X stock value in capital',
                                   'Minors receive 2X stock value as capital '\
                                   'and float at between 50 to 100 stock value based on bid'],
          'minor_float_phase3on' => ['Minors receive winning bid as capital',
                                     'Minors receive entire winning bid as capital '\
                                     'and float at between 50 to 100 stock value based on bid'],
        ).freeze

        BIDDING_BOX_MINOR_COUNT = 4
        BIDDING_BOX_CONCESSION_COUNT = 3
        BIDDING_BOX_PRIVATE_COUNT = 3

        BIDDING_BOX_MINOR_COLOR = '#c6e9af'

        BIDDING_BOX_START_MINOR = 'M24'
        BIDDING_BOX_START_CONCESSION = 'C1'
        BIDDING_BOX_START_PRIVATE = 'P1'

        TWO_HOME_CORPORATION = 'LNWR'

        BIDDING_TOKENS = {
          '2': 7,
          '3': 6,
          '4': 5,
          '5': 4,
          '6': 3,
          '7': 3,
        }.freeze

        BIDDING_TOKENS_PER_ACTION = 3

        COMPANY_CONCESSION_PREFIX = 'C'
        COMPANY_MINOR_PREFIX = 'M'
        COMPANY_PRIVATE_PREFIX = 'P'

        EXCHANGE_TOKENS = {
          'LNWR' => 4,
          'GWR' => 3,
          'LBSCR' => 3,
          'SECR' => 3,
          'CR' => 3,
          'MR' => 3,
          'LYR' => 3,
          'NBR' => 3,
          'SWR' => 3,
          'NER' => 3,
        }.freeze

        # These trains don't count against train limit, they also don't count as a train
        # against the mandatory train ownership. They cant the bought by another corporation.
        EXTRA_TRAINS = %w[2P P+ LP].freeze
        EXTRA_TRAIN_PULLMAN = 'P+'
        EXTRA_TRAIN_PERMANENTS = %w[2P LP].freeze
        LOCAL_TRAINS = %w[L LP].freeze
        E_TRAIN = 'E'

        # see https://github.com/tobymao/18xx/issues/8479#issuecomment-1336324812
        LOCAL_TRAIN_CAN_CARRY_MAIL = false

        LIMIT_TOKENS_AFTER_MERGER = 9

        DOUBLE_HEX = %w[D35 F7 H21 H37].freeze
        CARDIFF_HEX = 'F35'
        LONDON_HEX = 'M38'
        ENGLISH_CHANNEL_HEX = 'P43'
        FRANCE_HEX = 'Q44'
        FRANCE_HEX_BROWN_TILE = 'offboard=revenue:yellow_0|green_60|brown_90|gray_120,visit_cost:0;'\
                                'path=a:2,b:_0,lanes:2'

        COMPANY_MTONR = 'P2'
        COMPANY_LCDR = 'P5'
        COMPANY_EGR = 'P8'
        COMPANY_DOUBLE_CASH = 'P9'
        COMPANY_DOUBLE_CASH_REVENUE = [0, 0, 0, 20, 20, 40, 40, 60].freeze
        COMPANY_GSWR = 'P10'
        COMPANY_GSWR_DISCOUNT = 40
        COMPANY_BER = 'P11'
        COMPANY_LSR = 'P12'
        COMPANY_10X_REVENUE = 'P15'
        COMPANY_OSTH = 'P16'
        COMPANY_LUR = 'P17'
        COMPANY_CHPR = 'P18'
        COMPANY_5X_REVENUE = 'P20'
        COMPANY_HSBC = 'P21'
        COMPANY_HSBC_TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: true, upgrade: :not_if_upgraded, cannot_reuse_same_hex: true },
        ].freeze
        COMPANY_HSBC_TILES = %w[N21 N23].freeze

        COMPANY_SHORT_NAMES = {
          'P1' => 'P1 (5-Train)',
          'P2' => 'P2 (Remove Town)',
          'P3' => 'P3 (Permanent 2T)',
          'P4' => 'P4 (Permanent 2T)',
          'P5' => 'P5 (English Channel)',
          'P6' => 'P6 (Mail Contract)',
          'P7' => 'P7 (Mail Contract)',
          'P8' => 'P8 (Hill Discount)',
          'P9' => 'P9 (Double Cash)',
          'P10' => 'P10 (River Discount)',
          'P11' => 'P11 (Adv. Tile Lay)',
          'P12' => 'P12 (Extra Tile Lay)',
          'P13' => 'P13 (Pullman)',
          'P14' => 'P14 (Pullman)',
          'P15' => 'P15 (£10x Phase)',
          'P16' => 'P16 (Tax Haven)',
          'P17' => 'P17 (Move Card)',
          'P18' => 'P18 (Station Swap)',
          'P19' => 'P19 (Perm. L Train)',
          'P20' => 'P20 (£5x Phase)',
          'P21' => 'P21 (Grimsby/Hull Bridge)',
          'C1' => 'LNWR',
          'C2' => 'GWR',
          'C3' => 'LBSCR',
          'C4' => 'SECR',
          'C5' => 'CR',
          'C6' => 'MR',
          'C7' => 'LYR',
          'C8' => 'NBR',
          'C9' => 'SWR',
          'C10' => 'NER',
          'M1' => '1',
          'M2' => '2',
          'M3' => '3',
          'M4' => '4',
          'M5' => '5',
          'M6' => '6',
          'M7' => '7',
          'M8' => '8',
          'M9' => '9',
          'M10' => '10',
          'M11' => '11',
          'M12' => '12',
          'M13' => '13',
          'M14' => '14',
          'M15' => '15',
          'M16' => '16',
          'M17' => '17',
          'M18' => '18',
          'M19' => '19',
          'M20' => '20',
          'M21' => '21',
          'M22' => '22',
          'M23' => '23',
          'M24' => '24',
          'M25' => '25',
          'M26' => '26',
          'M27' => '27',
          'M28' => '28',
          'M29' => '29',
          'M30' => '30',
        }.freeze

        MAJOR_TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }].freeze

        MERTHYR_TYDFIL_PONTYPOOL_HEX = 'F33'

        MINOR_START_PAR_PRICE = 50
        MINOR_BIDBOX_PRICE = 200
        MINOR_GREEN_UPGRADE = %w[yellow green].freeze

        MINOR_14_ID = '14'
        MINOR_14_HOME_HEX = 'M38'

        PLUS_EXPANSION_BIDBOX_1 = %w[P1 P3 P4 P13 P14 P19].freeze
        PLUS_EXPANSION_BIDBOX_2 = %w[P2 P5 P8 P10 P11 P12 P21].freeze
        PLUS_EXPANSION_BIDBOX_3 = %w[P6 P7 P9 P15 P16 P17 P18 P20].freeze

        PRIVATE_COMPANIES_ACQUISITION = {
          'P1' => { acquire: %i[major], phase: 5 },
          'P2' => { acquire: %i[major minor], phase: 2 },
          'P3' => { acquire: %i[major], phase: 2 },
          'P4' => { acquire: %i[major], phase: 2 },
          'P5' => { acquire: %i[major], phase: 3 },
          'P6' => { acquire: %i[major], phase: 3 },
          'P7' => { acquire: %i[major], phase: 3 },
          'P8' => { acquire: %i[major minor], phase: 3 },
          'P9' => { acquire: %i[major minor], phase: 3 },
          'P10' => { acquire: %i[major minor], phase: 3 },
          'P11' => { acquire: %i[major minor], phase: 2 },
          'P12' => { acquire: %i[major minor], phase: 3 },
          'P13' => { acquire: %i[major minor], phase: 5 },
          'P14' => { acquire: %i[major minor], phase: 5 },
          'P15' => { acquire: %i[major minor], phase: 2 },
          'P16' => { acquire: %i[none], phase: 0 },
          'P17' => { acquire: %i[major], phase: 2 },
          'P18' => { acquire: %i[major], phase: 5 },
          'P19' => { acquire: %i[major minor], phase: 1 },
          'P20' => { acquire: %i[major minor], phase: 3 },
          'P21' => { acquire: %i[major minor], phase: 2 },
        }.freeze

        PRIVATE_CLOSE_AFTER_PASS = %w[P12 P21].freeze
        PRIVATE_MAIL_CONTRACTS = %w[P6 P7].freeze
        PRIVATE_REMOVE_REVENUE = %w[P5 P6 P7 P8 P10 P17 P18 P21].freeze
        PRIVATE_PHASE_REVENUE = %w[P15 P20].freeze
        PRIVATE_TRAINS = %w[P1 P3 P4 P13 P14 P19].freeze

        STARTING_COMPANIES = %w[P1 P2 P3 P4 P5 P6 P7 P8 P9 P10 P11 P12 P13 P14 P15 P16 P17 P18
                                C1 C2 C3 C4 C5 C6 C7 C8 C9 C10 M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12 M13 M14 M15
                                M16 16 M17 M18 M19 M20 M21 M22 M23 M24].freeze
        STARTING_COMPANIES_PLUS = %w[P1 P2 P3 P4 P5 P6 P7 P8 P9 P10 P11 P12 P13 P14 P15 P16 P17 P18 P19 P20 P21
                                     C1 C2 C3 C4 C5 C6 C7 C8 C9 C10 M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12 M13 M14 M15
                                     M16 16 M17 M18 M19 M20 M21 M22 M23 M24 M25 M26 M27 M28 M29 M30].freeze

        STARTING_CORPORATIONS = %w[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24
                                   LNWR GWR LBSCR SECR CR MR LYR NBR SWR NER].freeze
        STARTING_CORPORATIONS_PLUS = %w[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29
                                        30 LNWR GWR LBSCR SECR CR MR LYR NBR SWR NER].freeze

        TOKEN_PRICE = 100

        TRACK_PLAIN = %w[7 8 9 80 81 82 83 544 545 546 60 169].freeze
        TRACK_TOWN = %w[3 4 58 141 142 143 144 767 768 769 X17].freeze

        UPGRADABLE_S_YELLOW_CITY_TILE = '57'
        UPGRADABLE_S_YELLOW_ROTATIONS = [2, 5].freeze
        UPGRADABLE_S_HEX_NAME = 'D35'

        UPGRADE_COST_L_TO_2 = 80

        include StubsAreRestricted

        attr_accessor :bidding_token_per_player, :player_debts

        def bank_sort(corporations)
          corporations.reject { |c| c.type == :minor }.sort_by(&:name)
        end

        def can_par?(corporation, parrer)
          return false if corporation.type == :minor ||
            !(@phase.status.include?('can_convert_concessions') || @phase.status.include?('can_par'))

          super
        end

        def can_run_route?(entity)
          entity.trains.any? { |t| self.class::LOCAL_TRAINS.include?(t.name) } || super
        end

        def check_distance(route, visits)
          raise GameError, 'Cannot run Pullman train' if pullman_train?(route.train)

          english_channel_visit = english_channel_visit(visits)
          # Permanent local train cant run in the english channel
          if self.class::LOCAL_TRAINS.include?(route.train.name) && english_channel_visit.positive?
            raise GameError, 'Local train can not have a route over the english channel'
          end

          # Must visit both hex tiles to be a valid visit. If you are tokened out from france then you cant visit the
          # EC tile either.
          raise GameError, 'Must connect english channel to france' if english_channel_visit == 1

          # Special case when a train just runs english channel to france, this only counts as one visit
          raise GameError, 'Route must have at least 2 stops' if english_channel_visit == 2 && visits.size == 2

          super
        end

        def check_overlap(routes)
          # Tracks by e-train and normal trains
          tracks_by_type = Hash.new { |h, k| h[k] = [] }

          # Check local train not use the same token more then one time
          local_cities = []

          # Merthyr Tydfil and Pontypool
          merthyr_tydfil_pontypool = {}

          routes.each do |route|
            local_cities.concat(route.visited_stops.select(&:city?)) if route.train.local? && !route.chains.empty?

            route.paths.each do |path|
              a = path.a
              b = path.b

              tracks = tracks_by_type[train_type(route.train)]
              tracks << [path.hex, a.num, path.lanes[0][1]] if a.edge?
              tracks << [path.hex, b.num, path.lanes[1][1]] if b.edge?

              if b.edge? && a.town? && (nedge = a.tile.preferred_city_town_edges[a]) && nedge != b.num
                tracks << [path.hex, a, path.lanes[0][1]]
              end
              if a.edge? && b.town? && (nedge = b.tile.preferred_city_town_edges[b]) && nedge != a.num
                tracks << [path.hex, b, path.lanes[1][1]]
              end

              if path.hex.id == self.class::MERTHYR_TYDFIL_PONTYPOOL_HEX
                merthyr_tydfil_pontypool[a.num] = true if a.edge?
                merthyr_tydfil_pontypool[b.num] = true if b.edge?
              end
            end
          end

          tracks_by_type.each do |_type, tracks|
            tracks.group_by(&:itself).each do |k, v|
              raise GameError, "Route can't reuse track on #{k[0].id}" if v.size > 1
            end
          end

          local_cities.group_by(&:itself).each do |k, v|
            raise GameError, "Local train can only use each token on #{k.hex.id} once" if v.size > 1
          end

          # Check Merthyr Tydfil and Pontypool, only one of the 2 tracks may be used
          return if !merthyr_tydfil_pontypool[1] || !merthyr_tydfil_pontypool[2]

          raise GameError, 'May only use one of the tracks connecting Merthyr Tydfil and Pontypool'
        end

        def company_bought(company, entity)
          # On acquired abilities
          on_acquired_train(company, entity) if self.class::PRIVATE_TRAINS.include?(company.id)
          on_aqcuired_remove_revenue(company) if self.class::PRIVATE_REMOVE_REVENUE.include?(company.id)
          on_acquired_phase_revenue(company) if self.class::PRIVATE_PHASE_REVENUE.include?(company.id)
          on_aqcuired_double_cash(company) if self.class::COMPANY_DOUBLE_CASH == company.id
        end

        def company_status_str(company)
          bidbox_minors.each_with_index do |c, index|
            return "Bid box #{index + 1}" if c == company
          end

          bidbox_concessions.each_with_index do |c, index|
            return "Bid box #{index + 1}" if c == company
          end

          if optional_plus_expansion?
            bidbox_privates.each do |c|
              next unless c == company

              return 'Bid box 1' if self.class::PLUS_EXPANSION_BIDBOX_1.include?(c.id)
              return 'Bid box 2' if self.class::PLUS_EXPANSION_BIDBOX_2.include?(c.id)
              return 'Bid box 3' if self.class::PLUS_EXPANSION_BIDBOX_3.include?(c.id)
            end
          else
            bidbox_privates.each_with_index do |c, index|
              return "Bid box #{index + 1}" if c == company
            end
          end

          if self.class::PRIVATE_PHASE_REVENUE.include?(company.id) && company.owner&.player?
            return "(#{format_currency(@phase_revenue[company.id].cash)})"
          end

          if company.id == self.class::COMPANY_OSTH && company.owner&.player? && @tax_haven.value.positive?
            company.value = @tax_haven.value
            share = @tax_haven.shares.first
            return "(#{share.corporation.name})"
          end

          nil
        end

        def compute_other_paths(routes, route)
          routes.flat_map do |r|
            next if r == route || train_type(route.train) != train_type(r.train)

            r.paths
          end
        end

        def crowded_corps
          @crowded_corps ||= corporations.select do |c|
            trains = c.trains.count { |t| !extra_train?(t) }
            crowded = trains > train_limit(c)
            crowded |= extra_train_permanent_count(c) > 1
            crowded
          end
        end

        def discountable_trains_for(corporation)
          discount_info = super

          corporation.trains.select { |t| t.name == 'L' }.each do |train|
            discount_info << [train, train, '2', self.class::UPGRADE_COST_L_TO_2]
          end
          discount_info
        end

        def end_game!(player_initiated: false)
          finalize_end_game_values
          super
        end

        def finalize_end_game_values
          company = company_by_id(self.class::COMPANY_OSTH)
          return if !company || !@tax_haven.value.positive?

          # Make sure tax havens value is correct
          company.value = @tax_haven.value
        end

        def entity_can_use_company?(entity, company)
          entity == company.owner
        end

        def event_close_concessions!
          @log << '-- Event: Concessions close --'
          @companies.select { |c| c.id[0] == self.class::COMPANY_CONCESSION_PREFIX && !c.closed? }.each(&:close!)
          @corporations.select { |c| !c.floated? && c.type == :major }.each do |corporation|
            corporation.par_via_exchange = nil
            corporation.float_percent = 50
          end
        end

        def event_full_capitalisation!
          @log << '-- Event: Major companies receive full capitalisation when floated --'
          @corporations.select { |c| !c.floated? && c.type == :major }.each do |corporation|
            corporation.capitalization = :full
          end
        end

        def event_phase_revenue!
          @log << '-- Event: Phase revenue companies close with money returned to the bank --'
          self.class::PRIVATE_PHASE_REVENUE.each do |company_id|
            company = @companies.find { |c| c.id == company_id }
            next if !company || company&.closed? || !@phase_revenue[company_id]

            @log << "#{company.name} closes"
            @phase_revenue[company.id].spend(@phase_revenue[company.id].cash, @bank) if @phase_revenue[company.id].cash.positive?
            @phase_revenue[company.id] = nil
            company.close!
          end
        end

        def float_corporation(corporation)
          if @phase.status.include?('full_capitalisation') && corporation.type == :major
            # Transfer any money corporation have gotten during phase 5 with incremental floating
            corporation.spend(corporation.cash, @bank) if corporation.cash.positive?

            bundle = ShareBundle.new(corporation.shares_of(corporation))
            @share_pool.transfer_shares(bundle, @share_pool)
            @log << "#{corporation.name}'s remaining shares are transferred to the Market"
          end

          super

          # Make sure after its floated its incremental.
          corporation.capitalization = :incremental if corporation.type == :major
        end

        def home_token_locations(corporation)
          [hex_by_id(self.class::MINOR_14_HOME_HEX)] if corporation.id == self.class::MINOR_14_ID
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def issuable_shares(entity)
          return [] if !entity.corporation? || (entity.corporation? && entity.type != :major)
          return [] if entity.num_ipo_shares.zero? || entity.operating_history.size < 2

          bundles_for_corporation(entity, entity)
            .select { |bundle| @share_pool.fit_in_bank?(bundle) }
            .map { |bundle| reduced_bundle_price_for_market_drop(bundle) }
        end

        def choose_step
          [G1822::Step::Choose]
        end

        def next_round!
          @round =
            case @round
            when G1822::Round::Choices
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when Engine::Round::Stock
              G1822::Round::Choices.new(self, choose_step, round_num: @round.round_num)
            when Engine::Round::Operating
              if @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                new_stock_round
              end
            when init_round.class
              init_round_finished
              reorder_players
              new_stock_round
            end
        end

        def num_certs(entity)
          super + num_certs_modification(entity)
        end

        def num_certs_modification(entity)
          entity.companies.find { |c| c.id == self.class::COMPANY_OSTH } ? -1 : 0
        end

        def tile_lays(entity)
          return self.class::COMPANY_HSBC_TILE_LAYS if entity.id == self.class::COMPANY_HSBC

          operator = entity.company? ? entity.owner : entity
          return self.class::MAJOR_TILE_LAYS if @phase.name.to_i >= 3 && operator.corporation? && operator.type == :major

          super
        end

        def train_help(_entity, runnable_trains, _routes)
          return [] if runnable_trains.empty?

          entity = runnable_trains.first.owner

          # L - trains
          l_trains = runnable_trains.any? { |t| self.class::LOCAL_TRAINS.include?(t.name) }

          # Destination bonues
          destination_token = nil
          destination_token = entity.tokens.find { |t| t.used && t.type == :destination } if entity.type == :major

          # Mail contract
          mail_contracts = entity.companies.any? { |c| self.class::PRIVATE_MAIL_CONTRACTS.include?(c.id) }

          help = []
          if l_trains
            help << "L (local) trains run in a city which has a #{entity.name} token. "\
                    'They can additionally run to a single small station, but are not required to do so. '\
                    'They can thus be considered 1 (+1) trains. '\
                    'Only one L train may operate on each station token.'
          end

          if destination_token
            help << 'When a train runs between its home station token and its destination station token it doubles '\
                    'the value of its destination station. This only applies to one train per operating turn.'
          end

          if mail_contracts
            help << 'Mail contract(s) gives a subsidy equal to one half of the base value of the start and end '\
                    'stations from one of the trains operated. Doubled values (for E trains or destination tokens) '\
                    'do not count.'
          end
          help
        end

        def init_companies(players)
          game_companies.map do |company|
            next if players.size < (company[:min_players] || 0)
            next unless starting_companies.include?(company[:sym])

            Company.new(**company)
          end.compact
        end

        def init_company_abilities
          @companies.each do |company|
            next unless (ability = abilities(company, :exchange))
            next unless ability.from.include?(:par)

            exchange_corporations(ability).first.par_via_exchange = company
          end

          super
        end

        def init_corporations(stock_market)
          # Make sure we have the correct starting corporations
          starting_corporations = if optional_plus_expansion?
                                    self.class::STARTING_CORPORATIONS_PLUS
                                  else
                                    self.class::STARTING_CORPORATIONS
                                  end
          game_corporations.map do |corporation|
            next unless starting_corporations.include?(corporation[:sym])

            Corporation.new(
              min_price: stock_market.par_prices.map(&:price).min,
              capitalization: self.class::CAPITALIZATION,
              **corporation.merge(corporation_opts),
            )
          end.compact
        end

        def init_round
          stock_round
        end

        def init_stock_market
          G1822::StockMarket.new(game_market, self.class::CERT_LIMIT_TYPES,
                                 multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
        end

        def company_header(company)
          case company.id[0]
          when self.class::COMPANY_MINOR_PREFIX
            'MINOR RAILWAY'
          when self.class::COMPANY_CONCESSION_PREFIX
            'CONCESSION'
          else
            super
          end
        end

        def must_buy_train?(entity)
          entity.trains.none? { |t| !extra_train?(t) } &&
          !depot.depot_trains.empty?
        end

        # TODO: [1822] Make include with 1861, 1867
        def operating_order
          minors, majors = @corporations.select(&:floated?).sort.partition { |c| c.type == :minor }
          minors + majors
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            G1822::Step::PendingToken,
            G1822::Step::FirstTurnHousekeeping,
            Engine::Step::AcquireCompany,
            G1822::Step::DiscardTrain,
            G1822::Step::SpecialChoose,
            G1822::Step::SpecialTrack,
            G1822::Step::SpecialToken,
            G1822::Step::Track,
            G1822::Step::DestinationToken,
            G1822::Step::Token,
            G1822::Step::Route,
            G1822::Step::Dividend,
            G1822::Step::BuyTrain,
            G1822::Step::MinorAcquisition,
            G1822::Step::PendingToken,
            G1822::Step::DiscardTrain,
            G1822::Step::IssueShares,
          ], round_num: round_num)
        end

        def payout_companies
          set_private_revenues
          super
        end

        def set_private_revenues
          # Set the correct revenue of P15-HR, P20-C&WR and P9-M&GNR
          @companies.each do |c|
            next unless c.owner

            if self.class::PRIVATE_PHASE_REVENUE.include?(c.id)
              multiplier = case c.id
                           when self.class::COMPANY_10X_REVENUE
                             10
                           when self.class::COMPANY_5X_REVENUE
                             5
                           end
              revenue = @phase.name.to_i * multiplier
              c.revenue = revenue
              @bank.spend(revenue, @phase_revenue[c.id])
              @log << "#{c.name} collects #{format_currency(revenue)}"
            end

            if c.id == self.class::COMPANY_DOUBLE_CASH && c.owner.corporation?
              c.revenue = self.class::COMPANY_DOUBLE_CASH_REVENUE[@phase.name.to_i]
            end
          end
        end

        def place_home_token(corporation)
          return if corporation.tokens.first&.used

          super

          # Special for LNWR, it gets its destination token. But wont get the bonus until home
          # and destination is connected
          return unless corporation.id == self.class::TWO_HOME_CORPORATION

          hex = hex_by_id(corporation.destination_coordinates)
          token = corporation.find_token_by_type(:destination)
          place_destination_token(corporation, hex, token)
        end

        def player_value(player)
          player.value - @player_debts[player]
        end

        def purchasable_companies(entity = nil)
          return [] unless entity

          @companies.select do |company|
            company.owner&.player? && entity != company.owner && !company.closed? && !abilities(company, :no_buy) &&
              acquire_private_company?(entity, company)
          end
        end

        def redeemable_shares(entity)
          return [] if !entity.corporation? || (entity.corporation? && entity.type != :major)

          bundles_for_corporation(@share_pool, entity).reject { |bundle| entity.cash < bundle.price }
        end

        def reorder_players(_order = nil)
          current_order = @players.dup.reverse
          @players.sort_by! do |p|
            cash = p.cash
            cash *= 2 if @double_cash_choice == p
            [cash, current_order.index(p)]
          end.reverse!

          player_order = @players.map do |p|
            double = ' doubled' if @double_cash_choice == p
            "#{p.name} (#{format_currency(p.cash)}#{double})"
          end.join(', ')

          @log << "-- New player order: #{player_order}"

          # Reset the choice for P9-M&GNR
          @double_cash_choice = nil
        end

        def revenue_for(route, stops)
          if route.hexes.size != route.hexes.uniq.size &&
              route.hexes.none? { |h| self.class::DOUBLE_HEX.include?(h.name) }
            raise GameError, 'Route visits same hex twice'
          end

          revenue = if train_type(route.train) == :normal
                      super
                    else
                      entity = route.train.owner
                      france_stop = stops.find { |s| s.offboard? && s.hex.name == self.class::FRANCE_HEX }
                      stops.sum do |stop|
                        next 0 unless stop.city?

                        tokened = stop.tokened_by?(entity)
                        # If we got a token in English channel, calculate the revenue from the france offboard
                        if tokened && stop.hex.name == self.class::ENGLISH_CHANNEL_HEX
                          france_stop ? france_stop.route_revenue(route.phase, route.train) : 0
                        elsif tokened
                          stop.route_revenue(route.phase, route.train)
                        else
                          0
                        end
                      end
                    end
          destination_bonus = destination_bonus(route.routes)
          revenue += destination_bonus[:revenue] if destination_bonus && destination_bonus[:route] == route
          revenue
        end

        def revenue_str(route)
          str = super

          destination_bonus = destination_bonus(route.routes)
          str += " (#{format_currency(destination_bonus[:revenue])})" if destination_bonus && destination_bonus[:route] == route

          str
        end

        def routes_subsidy(routes)
          return 0 if routes.empty?

          mail_bonus = mail_contract_bonus(routes.first.train.owner, routes)
          return 0 if mail_bonus.empty?

          mail_bonus.sum do |v|
            v[:subsidy]
          end
        end

        def route_trains(entity)
          entity.runnable_trains.reject { |t| pullman_train?(t) }
        end

        def setup
          @game_end_reason = nil

          # Setup the bidding token per player
          @bidding_token_per_player = init_bidding_token

          # Initialize the player depts, if player have to take an emergency loan
          @player_debts = Hash.new { |h, k| h[k] = 0 }

          # Initialize a dummy player for phase revenue companies
          # to hold the cash it generates
          @phase_revenue = {}
          self.class::PRIVATE_PHASE_REVENUE.each do |company_id|
            @phase_revenue[company_id] = Engine::Player.new(-1, company_id)
          end

          # Randomize and setup the companies
          setup_companies

          # Actual bidbox setup happens in the stock round.
          @bidbox_minors_cache = []

          # Setup exchange token abilities for all corporations
          setup_exchange_tokens

          # Setup all the destination tokens, icons and abilities
          setup_destinations

          # Setup all the game specific things
          setup_game_specific
        end

        def setup_game_specific
          # Init all the special upgrades
          @sharp_city ||= @tiles.find { |t| t.name == '5' }
          @gentle_city ||= @tiles.find { |t| t.name == '6' }
          @green_s_tile ||= @tiles.find { |t| t.name == 'X3' }
          @green_t_tile ||= @tiles.find { |t| t.name == '405' }

          # Initialize the extra city which minor 14 might add
          @minor_14_city_exit = nil

          # Initialize a dummy player for Tax haven to hold the share and the cash it generates
          @tax_haven = Engine::Player.new(-1, 'Tax Haven')

          # Initialize the stock round choice for P9-M&GNR
          @double_cash_choice = nil
        end

        def sorted_corporations
          phase = @phase.status.include?('can_convert_concessions') || @phase.status.include?('can_par')
          return [] unless phase

          ipoed, others = @corporations.select { |c| c.type == :major }.partition(&:ipoed)
          ipoed.sort + others
        end

        def status_str(corporation)
          return if corporation.type != :minor || !corporation.share_price

          "Market value #{format_currency(corporation.share_price.price)}"
        end

        def stock_round
          G1822::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G1822::Step::BuySellParShares,
          ])
        end

        def timeline
          timeline = []

          minors = timeline_companies(self.class::COMPANY_MINOR_PREFIX, bidbox_minors)
          timeline << "Minors: #{minors.join(', ')}" unless minors.empty?

          concessions = timeline_companies(self.class::COMPANY_CONCESSION_PREFIX, bidbox_concessions)
          timeline << "Concessions: #{concessions.join(', ')}" unless concessions.empty?

          if optional_plus_expansion?
            b1_privates = timeline_companies_plus(self.class::COMPANY_PRIVATE_PREFIX,
                                                  self.class::PLUS_EXPANSION_BIDBOX_1)
            timeline << "Privates bidbox 1 : #{b1_privates.join(', ')}" unless b1_privates.empty?

            b2_privates = timeline_companies_plus(self.class::COMPANY_PRIVATE_PREFIX,
                                                  self.class::PLUS_EXPANSION_BIDBOX_2)
            timeline << "Privates bidbox 2: #{b2_privates.join(', ')}" unless b2_privates.empty?

            b3_privates = timeline_companies_plus(self.class::COMPANY_PRIVATE_PREFIX,
                                                  self.class::PLUS_EXPANSION_BIDBOX_3)
            timeline << "Privates bidbox 3: #{b3_privates.join(', ')}" unless b3_privates.empty?
          else
            privates = timeline_companies(self.class::COMPANY_PRIVATE_PREFIX, bidbox_privates)
            timeline << "Privates: #{privates.join(', ')}" unless privates.empty?
          end

          timeline
        end

        def timeline_companies(prefix, bidbox_companies)
          bank_companies(prefix).map do |company|
            "#{self.class::COMPANY_SHORT_NAMES[company.id]}#{'*' if bidbox_companies.any? { |c| c == company }}"
          end
        end

        def timeline_companies_plus(prefix, bidbox)
          first = true
          bank_companies(prefix).map do |company|
            next unless bidbox.include?(company.id)

            company_str = "#{self.class::COMPANY_SHORT_NAMES[company.id]}#{'*' if first}"
            first = false
            company_str
          end.compact
        end

        def unowned_purchasable_companies(_entity)
          minors = bank_companies(self.class::COMPANY_MINOR_PREFIX)
          concessions = bank_companies(self.class::COMPANY_CONCESSION_PREFIX)
          privates = bank_companies(self.class::COMPANY_PRIVATE_PREFIX)
          minors + concessions + privates
        end

        def upgrade_cost(tile, hex, entity, _spender)
          operator = entity.company? ? entity.owner : entity
          abilities = operator.all_abilities.select do |a|
            a.type == :tile_discount && (!a.hexes || a.hexes.include?(hex.name))
          end

          tile.upgrades.sum do |upgrade|
            total_cost = upgrade.cost
            abilities.each do |ability|
              discount = ability && upgrade.terrains.uniq == [ability.terrain] ? ability.discount : 0
              log_cost_discount(operator, ability, discount)
              total_cost -= discount
            end
            total_cost
          end
        end

        def upgrades_to?(from, to, _special = false, selected_company: nil)
          # This is needed because the S tile upgrade removes the town in yellow
          if self.class::UPGRADABLE_S_HEX_NAME == from.hex.name && from.color == :white
            return self.class::UPGRADABLE_S_YELLOW_CITY_TILE == to.name
          end

          # Special case for Middleton Railway where we remove a town from a tile
          if self.class::TRACK_TOWN.include?(from.name) && self.class::TRACK_PLAIN.include?(to.name)
            return Engine::Tile::COLORS.index(to.color) == (Engine::Tile::COLORS.index(from.color) + 1)
          end

          super
        end

        def acquire_private_company?(entity, company)
          company_acquisition = self.class::PRIVATE_COMPANIES_ACQUISITION[company.id]
          return false unless company_acquisition

          @phase.name.to_i >= company_acquisition[:phase] && company_acquisition[:acquire].include?(entity.type)
        end

        def add_exchange_token(entity)
          ability = entity.all_abilities.find { |a| a.type == :exchange_token }
          count = ability ? ability.count + 1 : 1
          new_ability = Ability::Base.new(
            type: 'exchange_token',
            description: "Exchange tokens: #{count}",
            count: count
          )
          entity.remove_ability(ability) if ability
          entity.add_ability(new_ability)
        end

        def add_interest_player_loans!
          @player_debts.each do |player, loan|
            next unless loan.positive?

            interest = player_loan_interest(loan)
            new_loan = loan + interest
            @player_debts[player] = new_loan
            @log << "#{player.name} increases their loan by 50% (#{format_currency(interest)}) to "\
                    "#{format_currency(new_loan)}"
          end
        end

        def after_place_pending_token(city)
          return unless city.hex.name == self.class::MINOR_14_HOME_HEX

          # Save the extra token city exit in london. We need this if we acquire the minor 14 and chooses to remove
          # the token from london. The city where the 14's home token used to be is now open for other companies to
          # token. If we do an upgrade to london, make sure this city still is open.  Save the exit instead of the
          # index because the index can change
          @minor_14_city_exit = city.hex.tile.paths.find { |p| p.city == city }.edges[0].num
        end

        def after_lay_tile(hex, old_tile, tile)
          if old_tile.label
            # add temporary label to plain tile lays on designated symbols
            if PLAIN_SYMBOL_UPGRADES.include?(tile.color) &&
               PLAIN_SYMBOL_UPGRADES[tile.color].include?(old_tile.label.to_s) &&
               !tile.label
              tile.label = old_tile.label.to_s
            end

            # remove the label when we upgrade a temporarily labelled tile
            if PLAIN_SYMBOL_UPGRADES.include?(old_tile.color) &&
               PLAIN_SYMBOL_UPGRADES[old_tile.color].include?(old_tile.label.to_s)
              old_tile.label = nil
            end
          end

          # If we upgraded london, check if we need to add the extra slot from minor 14
          upgrade_minor_14_home_hex(hex) if hex.name == self.class::MINOR_14_HOME_HEX

          # If we upgraded the english channel to brown, upgrade france as well since we got 2 lanes to france.
          return if hex.name != self.class::ENGLISH_CHANNEL_HEX || tile.color != :brown

          upgrade_france_to_brown
        end

        def after_track_pass(entity)
          # Special case of when we only used up one of the 2 track lays of
          # Leicester & Swannington Railway or Humber Suspension Bridge Company
          self.class::PRIVATE_CLOSE_AFTER_PASS.each do |company_id|
            company = entity.companies.find { |c| c.id == company_id }
            next unless company

            count = company.all_abilities.find { |a| a.type == :tile_lay }&.count
            next if !count || count == 2

            @log << "#{company.name} closes"
            company.close!
          end
        end

        def bank_companies(prefix)
          @companies.select do |c|
            c.id[0] == prefix && (!c.owner || c.owner == @bank) && !c.closed?
          end
        end

        def bidbox_minors
          bank_companies(self.class::COMPANY_MINOR_PREFIX)
            .first(self.class::BIDDING_BOX_MINOR_COUNT)
            .select do |company|
            @bidbox_minors_cache.include?(company.id)
          end
        end

        def bidbox_concessions
          bank_companies(self.class::COMPANY_CONCESSION_PREFIX).first(self.class::BIDDING_BOX_CONCESSION_COUNT)
        end

        def bidbox_privates
          if optional_plus_expansion?
            companies = bank_companies(self.class::COMPANY_PRIVATE_PREFIX)
            privates = []
            privates << companies.find { |c| self.class::PLUS_EXPANSION_BIDBOX_1.include?(c.id) }
            privates << companies.find { |c| self.class::PLUS_EXPANSION_BIDBOX_2.include?(c.id) }
            privates << companies.find { |c| self.class::PLUS_EXPANSION_BIDBOX_3.include?(c.id) }
            privates.compact
          else
            bank_companies(self.class::COMPANY_PRIVATE_PREFIX).first(self.class::BIDDING_BOX_PRIVATE_COUNT)
          end
        end

        def bidbox_minors_refill!
          @bidbox_minors_cache = bank_companies(self.class::COMPANY_MINOR_PREFIX)
                                   .first(self.class::BIDDING_BOX_MINOR_COUNT)
                                   .map(&:id)

          # Set the reservation color of all the minors in the bid boxes
          @bidbox_minors_cache.each do |company_id|
            corporation_by_id(company_id[1..-1]).reservation_color = self.class::BIDDING_BOX_MINOR_COLOR
          end
        end

        def bidbox_start_concession
          self.class::BIDDING_BOX_START_CONCESSION
        end

        def bidbox_start_minor
          self.class::BIDDING_BOX_START_MINOR
        end

        def bidbox_start_private
          self.class::BIDDING_BOX_START_PRIVATE
        end

        def can_gain_extra_train?(entity, train)
          if train.name == self.class::EXTRA_TRAIN_PULLMAN
            return false if entity.trains.any? { |t| t.name == self.class::EXTRA_TRAIN_PULLMAN }
          elsif self.class::EXTRA_TRAIN_PERMANENTS.include?(train.name)
            return false if entity.trains.any? { |t| self.class::EXTRA_TRAIN_PERMANENTS.include?(t.name) }
          end
          true
        end

        def calculate_destination_bonus(route)
          entity = route.train.owner
          # Only majors can have a destination token
          return nil unless entity.type == :major

          # Check if the corporation have placed its destination token
          destination_token = entity.tokens.find { |t| t.used && t.type == :destination }
          return nil unless destination_token

          # First token is always the hometoken
          home_token = entity.tokens.first
          token_count = 0
          route.visited_stops.each do |stop|
            next unless stop.city?

            token_count += 1 if stop.tokens.any? { |t| t == home_token || t == destination_token }
          end

          # Both hometoken and destination token must be in the route to get the destination bonus
          return nil unless token_count == 2

          { route: route, revenue: destination_token.city.route_revenue(route.phase, route.train) }
        end

        def choices_entities
          company = company_by_id(self.class::COMPANY_DOUBLE_CASH)
          return [] unless company&.owner&.player?

          [company.owner]
        end

        def player_loan_interest(loan)
          (loan * 0.5).ceil
        end

        def company_ability_extra_track?(company)
          company.id == self.class::COMPANY_LSR
        end

        def company_choices(company, time)
          case company.id
          when self.class::COMPANY_CHPR
            company_choices_chpr(company, time)
          when self.class::COMPANY_EGR
            company_choices_egr(company, time)
          when self.class::COMPANY_LCDR
            company_choices_lcdr(company, time)
          when self.class::COMPANY_LUR
            company_choices_lur(company, time)
          when self.class::COMPANY_DOUBLE_CASH
            company_choices_double_cash(company, time)
          when self.class::COMPANY_OSTH
            company_choices_osth(company, time)
          else
            {}
          end
        end

        def company_choices_chpr(company, time)
          return {} if !%i[token track].include?(time) || !company.owner&.corporation?

          choices = {}
          exchange_token_count = exchange_tokens(company.owner)
          choices['exchange'] = 'Move an exchange token to the available section' if exchange_token_count.positive?
          if !company.owner.tokens_by_type.empty? &&
            exchange_token_count < self.class::EXCHANGE_TOKENS[company.owner.id]
            choices['available'] = 'Move an available token to the exchange section'
          end
          choices
        end

        def company_choices_egr(company, time)
          return {} if !company.all_abilities.empty? || time != :special_choose

          choices = {}
          choices['token'] = 'Receive a discount token that can be used to pay the full cost of a single '\
                             'track tile lay on a rough terrain, hill or mountain hex.'
          choices['discount'] = 'Receive a £20 continuous discount off the cost of all hill and mountain terrain '\
                                '(i.e. NOT off the cost of rough terrain).'
          choices
        end

        def company_choices_lcdr(company, time)
          return {} if time != :token || !company.owner&.corporation?

          choices = {}
          if exchange_tokens(company.owner).positive?
            choices['exchange'] = 'Move an exchange station token to the available station token section'
          end
          choices
        end

        def company_choices_lur(company, time)
          return {} if time != :token && time != :track && time != :issue
          return {} unless company.owner&.corporation?

          exclude_minors = bidbox_minors
          exclude_concessions = bidbox_concessions
          exclude_privates = bidbox_privates

          minors_choices = company_choices_lur_companies(self.class::COMPANY_MINOR_PREFIX, exclude_minors)
          concessions_choices = company_choices_lur_companies(self.class::COMPANY_CONCESSION_PREFIX,
                                                              exclude_concessions)
          privates_choices = company_choices_lur_companies(self.class::COMPANY_PRIVATE_PREFIX, exclude_privates)

          choices = {}
          choices.merge!(minors_choices)
          choices.merge!(concessions_choices)
          choices.merge!(privates_choices)
          choices.compact
        end

        def company_choices_lur_companies(prefix, exclude_companies)
          choices = {}
          companies = bank_companies(prefix).reject do |company|
            exclude_companies.any? { |c| c == company }
          end
          companies.each do |company|
            choices["#{company.id}_top"] = "#{self.class::COMPANY_SHORT_NAMES[company.id]}-Top"
            choices["#{company.id}_bottom"] = "#{self.class::COMPANY_SHORT_NAMES[company.id]}-Bottom"
          end
          choices
        end

        def company_choices_double_cash(company, time)
          return {} if @double_cash_choice || !company.owner&.player? || time != :choose

          choices = {}
          choices['double'] = 'Double your actual cash holding when determining player turn order.'
          choices
        end

        def company_choices_osth(company, time)
          return {} if @tax_haven.value.positive? || !company.owner&.player? || time != :stock_round

          choices = {}
          @corporations.select { |c| c.type == :major }.each do |corporation|
            price = corporation.share_price&.price || 0
            next unless price.positive?

            if corporation.num_ipo_shares.positive?
              choices["#{corporation.id}_ipo"] = "#{corporation.id} IPO (#{format_currency(price)})"
            end
            if @share_pool.num_shares_of(corporation).positive?
              choices["#{corporation.id}_market"] = "#{corporation.id} Market (#{format_currency(price)})"
            end
          end
          choices
        end

        def company_made_choice(company, choice, time)
          case company.id
          when self.class::COMPANY_EGR
            company_made_choice_egr(company, choice, time)
          when self.class::COMPANY_DOUBLE_CASH
            company_made_choice_double_cash(company)
          when self.class::COMPANY_LCDR
            company_made_choice_lcdr(company)
          when self.class::COMPANY_LUR
            company_made_choice_lur(company, choice)
          when self.class::COMPANY_CHPR
            company_made_choice_chpr(company, choice)
          when self.class::COMPANY_OSTH
            company_made_choice_osth(company, choice)
          end
        end

        def company_made_choice_chpr(company, choice)
          if choice == 'exchange'
            move_exchange_token(company.owner)
            @log << "#{company.owner.name} moves an exchange token into to the available station token section"
          else
            corporation = company.owner
            corporation.find_token_by_type.destroy!
            add_exchange_token(corporation)
            @log << "#{company.owner.name} moves an available token into to the exchange station token section"
          end
          @log << "#{company.name} closes"
          company.close!
        end

        def company_made_choice_egr(company, choice, time)
          company.desc = company_choices(company, time)[choice]
          if choice == 'token'
            # Give the company a free tile lay.
            ability = Engine::Ability::TileLay.new(type: 'tile_lay', tiles: [], hexes: [], owner_type: 'corporation',
                                                   count: 1, closed_when_used_up: true, reachable: true, free: true,
                                                   special: false, when: 'track')
            company.add_ability(ability)
          else
            %w[mountain hill].each do |terrain|
              ability = Engine::Ability::TileDiscount.new(type: 'tile_discount', discount: 20, terrain: terrain)
              company.add_ability(ability)
            end
          end
        end

        def company_made_choice_lcdr(company)
          move_exchange_token(company.owner)
          @log << "#{company.owner.name} moves an exchange token into to the available station token section"
          @log << "#{company.name} closes"
          company.close!
        end

        def company_made_choice_lur(company, choice)
          choice_array = choice.split('_')
          selected_company = company_by_id(choice_array[0])
          top = choice_array[1] == 'top'

          @companies.delete(selected_company)
          if top
            last_bid_box_company = case selected_company.id[0]
                                   when self.class::COMPANY_MINOR_PREFIX
                                     bidbox_minors&.last
                                   when self.class::COMPANY_CONCESSION_PREFIX
                                     bidbox_concessions&.last
                                   else
                                     bidbox_privates&.last
                                   end
            index = @companies.index { |c| c == last_bid_box_company }
            @companies.insert(index + 1, selected_company)
          else
            @companies << selected_company
          end

          @log << "#{company.owner.name} moves #{selected_company.name} to the #{top ? 'top' : 'bottom'}"
          @log << "#{company.name} closes"
          company.close!
        end

        def company_made_choice_double_cash(company)
          @double_cash_choice = company.owner
          @log << "#{company.owner.name} chooses to double actual cash holding when determining player turn order."
        end

        def company_made_choice_osth(company, choice)
          spender = company.owner
          bundle = company_tax_haven_bundle(choice)
          corporation = bundle.corporation
          floated = corporation.floated?
          receiver = bundle.owner == @share_pool ? @bank : corporation
          @share_pool.transfer_shares(bundle, @tax_haven, spender: spender, receiver: receiver,
                                                          price: bundle.price, allow_president_change: false)
          @log << "#{spender.name} spends #{format_currency(bundle.price)} and tax haven gains a share of "\
                  "#{corporation.name}."
          float_corporation(corporation) if corporation.floatable && floated != corporation.floated?
        end

        def company_tax_haven_bundle(choice)
          choice_array = choice.split('_')
          corporation = corporation_by_id(choice_array[0])
          share = choice_array[1] == 'ipo' ? corporation.ipo_shares.first : @share_pool.shares_of(corporation).first
          ShareBundle.new(share)
        end

        def company_tax_haven_payout(entity, per_share)
          return unless @tax_haven.value.positive?

          amount = @tax_haven.num_shares_of(entity) * per_share
          return unless amount.positive?

          @bank.spend(amount, @tax_haven)
          @log << "#{entity.name} pays out #{format_currency(amount)} to tax haven"
        end

        def destination_bonus(routes)
          return nil if routes.empty?

          # If multiple routes gets destination bonus, get the biggest one. If we got E trains
          # this is bigger then normal train.
          destination_bonus = routes.map { |r| calculate_destination_bonus(r) }.compact
          destination_bonus.sort_by { |v| v[:revenue] }.reverse&.first
        end

        def english_channel_visit(visits)
          visits.count { |v| v.hex.name == self.class::ENGLISH_CHANNEL_HEX || v.hex.name == self.class::FRANCE_HEX }
        end

        def exchange_tokens(entity)
          return 0 unless entity.corporation?

          ability = entity.all_abilities.find { |a| a.type == :exchange_token }
          return 0 unless ability

          ability.count
        end

        def extra_train?(train)
          self.class::EXTRA_TRAINS.include?(train.name)
        end

        def extra_train_permanent?(train)
          self.class::EXTRA_TRAIN_PERMANENTS.include?(train.name)
        end

        def extra_train_permanent_count(corporation)
          corporation.trains.count { |train| extra_train_permanent?(train) }
        end

        def find_corporation(company)
          corporation_id = company.id[1..-1]
          corporation_by_id(corporation_id)
        end

        def init_bidding_token
          self.class::BIDDING_TOKENS[@players.size.to_s]
        end

        def minor_14_token_ability
          Engine::Ability::Token.new(type: 'token', hexes: [], price: 20)
        end

        def mail_contract_bonus(entity, routes)
          mail_contracts = entity.companies.count { |c| self.class::PRIVATE_MAIL_CONTRACTS.include?(c.id) }
          return [] unless mail_contracts.positive?

          mail_bonuses = routes.map do |r|
            stops = r.visited_stops
            next if stops.size.zero?
            next if stops.size < 2 && !self.class::LOCAL_TRAIN_CAN_CARRY_MAIL

            first = stops.first.route_base_revenue(r.phase, r.train) / 2
            last = stops.size < 2 ? 0 : stops.last.route_base_revenue(r.phase, r.train) / 2
            { route: r, subsidy: first + last }
          end.compact
          mail_bonuses.sort_by { |v| v[:subsidy] }.reverse.take(mail_contracts)
        end

        def move_exchange_token(entity)
          remove_exchange_token(entity)
          entity.tokens << Engine::Token.new(entity, price: self.class::TOKEN_PRICE)
        end

        def on_acquired_phase_revenue(company)
          revenue_player = @phase_revenue[company.id]
          @log << "#{company.owner.name} gains #{format_currency(revenue_player.cash)}"
          revenue_player.spend(revenue_player.cash, company.owner)
          @phase_revenue[company.id] = nil
          @log << "#{company.name} closes"
          company.close!
        end

        def on_aqcuired_double_cash(company)
          company.revenue = self.class::COMPANY_DOUBLE_CASH_REVENUE[@phase.name.to_i]
        end

        def on_aqcuired_remove_revenue(company)
          company.revenue = 0
        end

        def on_acquired_train(company, entity)
          train = @company_trains[company.id]

          unless can_gain_extra_train?(entity, train)
            raise GameError, "Can't gain an extra #{train.name}, already have a permanent 2P, LP, or P+"
          end

          buy_train(entity, train, :free)
          @log << "#{entity.name} gains a #{train.name} train"

          # Company closes after it is flipped into a train
          company.close!
          @log << "#{company.name} closes"
        end

        def optional_plus_expansion?
          @optional_rules&.include?(:plus_expansion)
        end

        def payoff_player_loan(player)
          # Pay full or partial of the player loan. The money from loans is outside money, doesnt count towards
          # the normal bank money.
          if player.cash >= @player_debts[player]
            player.cash -= @player_debts[player]
            @log << "#{player.name} pays off their loan of #{format_currency(@player_debts[player])}"
            @player_debts[player] = 0
          else
            @player_debts[player] -= player.cash
            @log << "#{player.name} decreases their loan by #{format_currency(player.cash)} "\
                    "(#{format_currency(@player_debts[player])})"
            player.cash = 0
          end
        end

        def check_destination_duplicate(entity, hex); end

        def place_destination_token(entity, hex, token)
          check_destination_duplicate(entity, hex)
          city = hex.tile.cities.first
          city.place_token(entity, token, free: true, check_tokenable: false, cheater: true)
          hex.tile.icons.reject! { |icon| icon.name == "#{entity.id}_destination" }

          ability = entity.all_abilities.find { |a| a.type == :destination }
          entity.remove_ability(ability)

          @graph.clear

          @log << "#{entity.name} places its destination token on #{hex.name}"
        end

        def player_debt(player)
          @player_debts[player] || 0
        end

        def pullman_train?(train)
          train.name == self.class::EXTRA_TRAIN_PULLMAN
        end

        def reduced_bundle_price_for_market_drop(bundle)
          directions = (1..bundle.num_shares).map { |_| :down }
          bundle.share_price = @stock_market.find_share_price(bundle.corporation, directions).price
          bundle
        end

        def setup_bidboxes
          # Set the owner to bank for the companies up for auction this stockround
          bidbox_minors_refill!
          bidbox_minors.each do |minor|
            minor.owner = @bank
          end

          bidbox_concessions.each do |concessions|
            concessions.owner = @bank
          end

          bidbox_privates.each do |company|
            company.owner = @bank
          end

          # Reset the choice for P9-M&GNR
          @double_cash_choice = nil
        end

        def starting_companies
          return self.class::STARTING_COMPANIES_PLUS if optional_plus_expansion?

          self.class::STARTING_COMPANIES
        end

        def remove_exchange_token(entity)
          ability = entity.all_abilities.find { |a| a.type == :exchange_token }
          ability.use!
          ability.description = "Exchange tokens: #{ability.count}"
        end

        def take_player_loan(player, loan)
          # Give the player the money. The money for loans is outside money, doesnt count towards the normal bank money.
          player.cash += loan

          # Add interest to the loan, must atleast pay 150% of the loaned value
          @player_debts[player] += loan + player_loan_interest(loan)
        end

        def train_type(train)
          train.name == 'E' ? :etrain : :normal
        end

        def upgrade_france_to_brown
          france_tile = Engine::Tile.from_code(self.class::FRANCE_HEX, :gray, self.class::FRANCE_HEX_BROWN_TILE)
          france_tile.location_name = 'France'
          hex_by_id(self.class::FRANCE_HEX).tile = france_tile
        end

        def upgrade_minor_14_home_hex(hex)
          return unless @minor_14_city_exit

          extra_city = hex.tile.paths.find { |p| p.edges[0].num == @minor_14_city_exit }.city
          return unless extra_city.tokens.size == 1

          extra_city.tokens[extra_city.normal_slots] = nil
        end

        # If this city is where M14 was placed, their minimum number of slots goes up by 1.
        def min_city_slots(city)
          return city.normal_slots unless city.hex.name == self.class::MINOR_14_HOME_HEX

          if city.hex.tile.paths.find { |p| p.city == city }.edges[0].num == @minor_14_city_exit
            city.normal_slots + 1
          else
            city.normal_slots
          end
        end

        def can_only_lay_plain_or_towns?(entity)
          entity.id == self.class::COMPANY_BER
        end

        def can_upgrade_one_phase_ahead?(entity)
          entity.id == self.class::COMPANY_BER
        end

        def must_be_on_terrain?(entity)
          entity.id == self.class::COMPANY_EGR
        end

        def must_remove_town?(entity)
          entity.id == self.class::COMPANY_MTONR
        end

        def home_token_counts_as_tile_lay?(entity)
          entity.id == self.class::MINOR_14_ID
        end

        def game_end_check
          # Once the game end has been determined, it's set in stone
          @game_end_reason ||= compute_game_end
        end

        def compute_game_end
          return [:bank, @round.is_a?(Engine::Round::Operating) ? :full_or : :current_or] if @bank.broken?

          return %i[stock_market current_or] if @stock_market.max_reached?
        end

        private

        def find_and_remove_train_by_id(train_id, buyable: true)
          train = train_by_id(train_id)
          @depot.remove_train(train)
          train.buyable = buyable
          train.reserved = true
          train
        end

        def setup_companies
          # Randomize from preset seed to get same order
          @companies.sort_by! { rand }

          minors = @companies.select { |c| c.id[0] == self.class::COMPANY_MINOR_PREFIX }
          concessions = @companies.select { |c| c.id[0] == self.class::COMPANY_CONCESSION_PREFIX }
          privates = @companies.select { |c| c.id[0] == self.class::COMPANY_PRIVATE_PREFIX }

          # Always set the P1, C1 and M24 in the first biddingbox
          if bidbox_start_minor
            m24 = minors.find { |c| c.id == bidbox_start_minor }
            minors.delete(m24)
            minors.unshift(m24)
          end

          c1 = concessions.find { |c| c.id == bidbox_start_concession }
          concessions.delete(c1)
          concessions.unshift(c1)

          p1 = privates.find { |c| c.id == bidbox_start_private }
          privates.delete(p1)
          privates.unshift(p1)

          # If have have activated 1822+, 3 companies will be removed from the game
          if optional_plus_expansion?
            # Make sure we have correct order of the bidboxes
            bid_box_1 = privates.map { |c| c if self.class::PLUS_EXPANSION_BIDBOX_1.include?(c.id) }.compact
            bid_box_2 = privates.map { |c| c if self.class::PLUS_EXPANSION_BIDBOX_2.include?(c.id) }.compact
            bid_box_3 = privates.map { |c| c if self.class::PLUS_EXPANSION_BIDBOX_3.include?(c.id) }.compact
            privates = bid_box_1 + bid_box_2 + bid_box_3

            # Remove one of the bidbid 2 privates, except London, Chatham and Dover Railway
            company = privates.find do |c|
              c.id != self.class::COMPANY_LCDR && self.class::PLUS_EXPANSION_BIDBOX_2.include?(c.id)
            end
            privates.delete(company)
            @log << "#{company.name} have been removed from the game"

            # Remove two of the bidbox 3 privates
            2.times.each do |_|
              company = privates.find { |c| self.class::PLUS_EXPANSION_BIDBOX_3.include?(c.id) }
              privates.delete(company)
              @log << "#{company.name} have been removed from the game"
            end
          end

          # Clear and add the companies in the correct randomize order sorted by type
          @companies.clear
          @companies.concat(minors)
          @companies.concat(concessions)
          @companies.concat(privates)

          # Set the min bid on the Concessions and Minors
          @companies.each do |c|
            c.min_price = case c.id[0]
                          when self.class::COMPANY_CONCESSION_PREFIX, self.class::COMPANY_MINOR_PREFIX
                            c.value
                          else
                            0
                          end
            c.max_price = 10_000
          end

          # Setup company abilities
          @company_trains = {}
          @company_trains['P3'] = find_and_remove_train_by_id('2P-0', buyable: false)
          @company_trains['P4'] = find_and_remove_train_by_id('2P-1', buyable: false)
          @company_trains['P1'] = find_and_remove_train_by_id('5P-0')
          @company_trains['P13'] = find_and_remove_train_by_id('P+-0', buyable: false)
          @company_trains['P14'] = find_and_remove_train_by_id('P+-1', buyable: false)
          @company_trains['P19'] = find_and_remove_train_by_id('LP-0', buyable: false)
        end

        def setup_destinations
          @corporations.each do |c|
            next unless c.destination_coordinates

            description = if c.id == self.class::TWO_HOME_CORPORATION
                            "Gets destination token at #{c.destination_coordinates} when floated"
                          else
                            "Connect to #{c.destination_coordinates} for your destination token"
                          end
            ability = Ability::Base.new(
              type: 'destination',
              description: description
            )
            c.add_ability(ability)
            c.tokens << Engine::Token.new(c, logo: "../#{c.destination_icon}.svg",
                                             simple_logo: "../#{c.destination_icon}.svg",
                                             type: :destination)
            hex_by_id(c.destination_coordinates).tile.icons << Part::Icon.new("../#{c.destination_icon}", "#{c.id}_destination")
          end
        end

        def setup_exchange_tokens
          self.class::EXCHANGE_TOKENS.each do |corp, token_count|
            ability = Ability::Base.new(
              type: 'exchange_token',
              description: "Exchange tokens: #{token_count}",
              count: token_count
            )
            corporation = corporation_by_id(corp)
            corporation.add_ability(ability)
          end
        end

        def price_movement_chart
          [
            ['Action', 'Share Price Change'],
            ['Dividend 0 or withheld', '1 ←'],
            ['Dividend < share price', 'none'],
            ['Dividend ≥ share price, < 2x share price ', '1 →'],
            ['Dividend ≥ 2x share price', '2 →'],
            ['Minor company dividend > 0', '1 →'],
            ['Each share sold', '1 ↓'],
            ['Corporation sold out at end of SR (including Tax Haven shares) ', '1 ↑'],
          ]
        end

        def port_tile?(hex)
          hex.tile.color == :blue && !hex.tile.cities.empty?
        end
      end
    end
  end
end
