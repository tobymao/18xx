# frozen_string_literal: true

require_relative '../g_1822/game'
require_relative 'entities'
require_relative 'map'
require_relative 'meta'

module Engine
  module Game
    module G1887
      class Game < G1822::Game
        include_meta(G1887::Meta)
        include G1887::Entities
        include G1887::Map

        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = 99_999

        CERT_LIMIT = { 3 => 18, 4 => 14, 5 => 11, 6 => 10 }.freeze

        STARTING_CASH = { 3 => 700, 4 => 525, 5 => 420, 6 => 350 }.freeze

        # Unlimited bid cubes
        BIDDING_TOKENS = { '3': 99, '4': 99, '5': 99, '6': 99 }.freeze
        BIDDING_TOKENS_PER_ACTION = 1

        BIDDING_BOX_MINOR_COUNT = 3
        BIDDING_BOX_START_MINOR = nil

        STARTING_COMPANIES = [
          *PRIVATES.map(&:first),
          *RAILROAD_MINORS.map { |id, *| "M#{id}" },
          *MAJORS.each_index.map { |i| "C#{i + 1}" },
        ].freeze

        STARTING_CORPORATIONS = [*RAILROAD_MINORS.map(&:first), *MAJORS.map(&:first)].freeze

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
          par_1: :blue,
          par: :yellow,
        ).freeze
        MARKET_TEXT = Base::MARKET_TEXT.merge(
          par_1: 'Par (majors, and minors from phase 3)',
          par: 'Par (minors)',
        )

        MARKET = [
          %w[30 35 40 45 50p 60x 70x 80x 90x 100x 115 130 150 175 200 230 260 300 350 400 450 500],
        ].freeze

        SELL_MOVEMENT = :left_per_10_if_pres_else_left_one

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
            on: '2D',
            train_limit: { minor: 2, major: 4 },
            tiles: [:yellow],
            status: %w[can_convert_concessions minor_float_phase2],
            operating_rounds: 2,
          },
          {
            name: '3',
            on: '3D',
            train_limit: { minor: 2, major: 4 },
            tiles: %i[yellow green],
            status: %w[can_buy_trains can_convert_concessions can_par minor_float_phase3on],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4D+',
            train_limit: { minor: 1, major: 3 },
            tiles: %i[yellow green],
            status: %w[can_buy_trains can_convert_concessions can_par minor_float_phase3on],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: { minor: 1, major: 3 },
            tiles: %i[yellow green brown],
            status: %w[can_buy_trains can_convert_concessions can_par minor_float_phase3on],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '6',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown],
            status: %w[can_buy_trains can_convert_concessions can_par minor_float_phase3on],
            operating_rounds: 2,
          },
          {
            name: '7',
            on: '7',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown gray],
            status: %w[can_buy_trains can_convert_concessions can_par minor_float_phase3on],
            operating_rounds: 2,
          },
        ].freeze

        L_DISTANCE = [
          { 'nodes' => ['city'], 'pay' => 1, 'visit' => 1 },
          { 'nodes' => ['town'], 'pay' => 1, 'visit' => 1 },
        ].freeze

        TRAINS = [
          {
            name: 'L',
            distance: L_DISTANCE,
            num: 19,
            price: 60,
            rusts_on: '3D',
            variants: [
              {
                name: '2D',
                distance: 2,
                price: 120,
                rusts_on: '4D+',
                available_on: '1',
              },
            ],
          },
          { name: '3D', distance: 3, num: 3, price: 160, rusts_on: '6' },
          { name: '3D+', distance: 3, num: 2, price: 160, rusts_on: '7' },
          { name: '4D+', distance: 4, num: 2, price: 240 },
          { name: '5', distance: 5, num: 3, price: 400 },
          { name: '6', distance: 6, num: 2, price: 500 },
          {
            name: '7',
            distance: 7,
            num: 'unlimited',
            price: 600,
            variants: [{ name: 'E', distance: 99, multiplier: 2, price: 1000 }],
          },
          { name: '2P', distance: 2, num: 1, price: 0 },
          { name: 'LP', distance: L_DISTANCE, num: 1, price: 0 },
          { name: 'P+', distance: L_DISTANCE, num: 1, price: 0 },
        ].freeze

        UPGRADE_COST_L_TO_2 = 80

        EXCHANGE_TOKENS = MAJORS.to_h { |sym, *| [sym, 0] }.freeze
        TWO_HOME_CORPORATION = 'NP'

        # 1822 private companies and hexes that 1887 does not have
        PRIVATE_TRAINS = %w[].freeze
        PRIVATE_MAIL_CONTRACTS = %w[].freeze
        PRIVATE_REMOVE_REVENUE = %w[].freeze
        PRIVATE_PHASE_REVENUE = %w[].freeze
        PRIVATE_COMPANIES_ACQUISITION = PRIVATES.to_h { |sym, *| [sym, { acquire: %i[major minor], phase: 1 }] }.freeze
        COMPANY_MTONR = nil
        COMPANY_LCDR = nil
        COMPANY_EGR = nil
        COMPANY_DOUBLE_CASH = nil
        COMPANY_GSWR = nil
        COMPANY_BER = nil
        COMPANY_LSR = nil
        COMPANY_10X_REVENUE = nil
        COMPANY_OSTH = nil
        COMPANY_LUR = nil
        COMPANY_CHPR = nil
        COMPANY_5X_REVENUE = nil
        COMPANY_HSBC = nil
        COMPANY_SHORT_NAMES = {
          **PRIVATES.to_h { |sym, name, _| [sym, "#{sym} (#{name})"] },
          **RAILROAD_MINORS.to_h { |id, *| ["M#{id}", id] },
          **MAJORS.each_with_index.to_h { |(sym, *), i| ["C#{i + 1}", "C#{i + 1} (#{sym})"] },
        }.freeze

        DOUBLE_HEX = %w[].freeze
        CARDIFF_HEX = nil
        LONDON_HEX = nil
        ENGLISH_CHANNEL_HEX = nil
        FRANCE_HEX = nil
        MERTHYR_TYDFIL_PONTYPOOL_HEX = nil
        MINOR_14_ID = nil
        PENDING_HOME_TOKENERS = [].freeze
        UPGRADEABLE_S_HEX_NAME = nil

        def setup_game_specific; end

        def company_tax_haven_bundle(choice); end

        def company_tax_haven_payout(entity, per_share); end

        def num_certs_modification(_entity) = 0

        def set_private_revenues; end

        def starting_companies
          self.class::STARTING_COMPANIES
        end

        # Yellow Seattle has separate Seattle and Ballard cities which merge
        # into a single city from green.
        def upgrade_ignore_num_cities(from)
          from.color == :yellow && from.label.to_s == 'S'
        end

        PRIVATES_IN_GAME = 12
        PRIVATE_MIN_BID = 20

        # Minors, concessions and privates are each shuffled into public stacks;
        # unlike 1822 nothing is fixed into the first bidbox. Five privates are
        # discarded unseen.
        def setup_companies
          @companies.sort_by! { rand }
          minors, rest = @companies.partition { |c| c.id[0] == self.class::COMPANY_MINOR_PREFIX }
          concessions, privates = rest.partition { |c| c.id[0] == self.class::COMPANY_CONCESSION_PREFIX }
          privates.pop(privates.size - self.class::PRIVATES_IN_GAME).each(&:close!)

          @companies.clear
          @companies.concat(minors, concessions, privates)
          @companies.each do |c|
            c.min_price = c.id[0] == self.class::COMPANY_PRIVATE_PREFIX ? self.class::PRIVATE_MIN_BID : c.value
            c.max_price = 10_000
          end
          @company_trains = {}
        end
      end
    end
  end
end
