# frozen_string_literal: true

require_relative '../g_1822/game'
require_relative 'meta'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G1822Africa
      class Game < G1822::Game
        include_meta(G1822Africa::Meta)
        include G1822Africa::Entities
        include G1822Africa::Map

        CERT_LIMIT = { 2 => 99, 3 => 99, 4 => 99 }.freeze

        BIDDING_TOKENS = {
          '2': 3,
          '3': 3,
          '4': 3,
        }.freeze

        EXCHANGE_TOKENS = {
          'NAR' => 2,
          'WAR' => 2,
          'EAR' => 2,
          'CAR' => 2,
          'SAR' => 2,
        }.freeze

        STARTING_CASH = { 2 => 500, 3 => 375, 4 => 300 }.freeze

        STARTING_COMPANIES = %w[P1 P2 P3 P4 P5 P6 P7 P8 P9 P10 P11 P12 C1 C2 C3 C4 C5
                                M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12].freeze

        STARTING_CORPORATIONS = %w[1 2 3 4 5 6 7 8 9 10 11 12
                                   NAR WAR EAR CAR SAR].freeze

        CURRENCY_FORMAT_STR = 'A%s'

        BANK_CASH = 99_999

        MARKET = [
          %w[40 50p 60xp 70xp 80xp 90m 100 110 120 135 150 165e],
        ].freeze

        MUST_SELL_IN_BLOCKS = true
        SELL_MOVEMENT = :left_per_10_if_pres_else_left_one

        GAME_END_CHECK = { stock_market: :current_or, custom: :full_or }.freeze
        GAME_END_REASONS_TEXT = Base::GAME_END_REASONS_TEXT.merge(
          custom: 'Cannot refill bid boxes'
        )

        EXTRA_TRAINS = %w[2P P+ LP].freeze
        EXTRA_TRAIN_PERMANENTS = %w[2P LP].freeze
        PRIVATE_TRAINS = %w[P1 P2 P3 P4 P5].freeze
        PRIVATE_MAIL_CONTRACTS = [].freeze # Stub
        PRIVATE_PHASE_REVENUE = %w[P16].freeze
        PRIVATE_REMOVE_REVENUE = %w[P13].freeze

        COMPANY_10X_REVENUE = 'P16'
        COMPANY_REMOVE_TOWN = 'P9'

        MINOR_BIDBOX_PRICE = 100
        BIDDING_BOX_MINOR_COUNT = 3

        STOCK_ROUND_NAME = 'Stock'
        STOCK_ROUND_COUNT = 2

        # Disable 1822-specific rules
        COMPANY_LCDR = nil
        COMPANY_EGR = nil
        COMPANY_DOUBLE_CASH = nil
        COMPANY_GSWR = nil
        COMPANY_GSWR_DISCOUNT = nil
        COMPANY_BER = nil
        COMPANY_LSR = nil
        COMPANY_OSTH = nil
        COMPANY_LUR = nil
        COMPANY_CHPR = nil
        COMPANY_5X_REVENUE = nil
        COMPANY_HSBC = nil
        BIDDING_BOX_START_PRIVATE = nil
        BIDDING_BOX_START_MINOR = nil
        DOUBLE_HEX = [].freeze

        PRIVATE_COMPANIES_ACQUISITION = {
          'P1' => { acquire: %i[major minor], phase: 1 },
          'P2' => { acquire: %i[major], phase: 2 },
          'P3' => { acquire: %i[major], phase: 2 },
          'P4' => { acquire: %i[major minor], phase: 3 },
          'P5' => { acquire: %i[major minor], phase: 3 },
          'P6' => { acquire: %i[major minor], phase: 3 },
          'P7' => { acquire: %i[major minor], phase: 3 },
          'P8' => { acquire: %i[major minor], phase: 1 },
          'P9' => { acquire: %i[major minor], phase: 2 },
          'P10' => { acquire: %i[major minor], phase: 3 },
          'P11' => { acquire: %i[major minor], phase: 3 },
          'P12' => { acquire: %i[major minor], phase: 1 },
          'P13' => { acquire: %i[major], phase: 5 },
          'P14' => { acquire: %i[major], phase: 3 },
          'P15' => { acquire: %i[major minor], phase: 1 },
          'P16' => { acquire: %i[major minor], phase: 2 },
          'P17' => { acquire: %i[major], phase: 2 },
          'P18' => { acquire: %i[major minor], phase: 3 },
        }.freeze

        COMPANY_SHORT_NAMES = {
          'P1' => 'P1 (Permanent L-train)',
          'P2' => 'P2 (Permanent 2-train)',
          'P3' => 'P3 (Permanent 2-train)',
          'P4' => 'P4 (Pullman)',
          'P5' => 'P5 (Pullman)',
          'P6' => 'P6 (Recycled train)',
          'P7' => 'P7 (Extra tile)',
          'P8' => 'P8 (Reserve Three Tiles)',
          'P9' => 'P9 (Remove Town)',
          'P10' => 'P10 (Game Reserve)',
          'P11' => 'P11 (Mountain Rebate)',
          'P12' => 'P12 (Fast Sahara Building)',
          'P13' => 'P13 (Station Swap)',
          'P14' => 'P14 (Gold Mine)',
          'P15' => 'P15 (Coffee Plantation)',
          'P16' => 'P16 (A10x Phase)',
          'P17' => 'P17 (Bank Share Buy)',
          'P18' => 'P18 (Safari Bonus)',
          'C1' => 'NAR',
          'C2' => 'WAR',
          'C3' => 'EAR',
          'C4' => 'CAR',
          'C5' => 'SAR',
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
        }.freeze

        EVENTS_TEXT = {
          'close_concessions' =>
            ['Concessions close', 'All concessions close without compensation, major companies float at 50%'],
          'full_capitalisation' =>
            ['Full capitalisation', 'Major companies receive full capitalisation when floated'],
        }.freeze

        MARKET_TEXT = G1822::Game::MARKET_TEXT.merge(max_price: 'Maximum price for a minor').freeze

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
            name: '5',
            on: '5/E',
            train_limit: { minor: 1, major: 3 },
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
            on: '6/E',
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
            num: 10,
            price: 50,
            rusts_on: '3',
            variants: [
              {
                name: '2',
                distance: 2,
                price: 100,
                rusts_on: '5/E',
                available_on: '1',
              },
            ],
          },
          {
            name: '3',
            distance: 3,
            num: 5,
            price: 160,
            rusts_on: '6/E',
          },
          {
            name: '5/E',
            distance: 5,
            num: 3,
            price: 350,
            events: [
              {
                'type' => 'close_concessions',
              },
            ],
          },
          {
            name: '6/E',
            distance: 6,
            num: 99,
            price: 400,
            events: [
              {
                'type' => 'full_capitalisation',
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

        UPGRADE_COST_L_TO_2 = 70

        @bidbox_cache = []
        @bidbox_companies_size = false

        def setup_companies
          minors = @companies.select { |c| minor?(c) }
          concessions = @companies.select { |c| concession?(c) }
          privates = @companies.select { |c| private?(c) }

          @companies.clear
          @companies.concat(minors)
          @companies.concat(concessions)
          @companies.concat(privates.sort_by! { rand }.take(10))

          # Randomize from preset seed to get same order
          @companies.sort_by! { rand }

          # Put closest concessions to slots 1 and 4 of timeline
          reordered_companies = reorder_on_concession(@companies)
          @companies = reordered_companies[0..2] + reorder_on_concession(reordered_companies[3..-1])

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
          @company_trains['P1'] = find_and_remove_train_by_id('LP-0', buyable: false)
          @company_trains['P2'] = find_and_remove_train_by_id('2P-0', buyable: false)
          @company_trains['P3'] = find_and_remove_train_by_id('2P-1', buyable: false)
          @company_trains['P4'] = find_and_remove_train_by_id('P+-0', buyable: false)
          @company_trains['P5'] = find_and_remove_train_by_id('P+-1', buyable: false)
        end

        def reorder_on_concession(companies)
          index = companies.find_index { |c| concession?(c) }

          # Only reorder if next concession is not the first company
          return companies if index.zero?

          head = companies[0..index - 1]
          tail = companies[index..-1]

          tail + head
        end

        def setup_bidboxes
          # Set the owner to bank for the companies up for auction this stockround
          bidbox_refill!
          bidbox.each do |minor|
            minor.owner = @bank
          end
        end

        def bidbox
          bank_companies.first(self.class::BIDDING_BOX_MINOR_COUNT)
        end

        def bank_companies
          @companies.select do |c|
            (!c.owner || c.owner == @bank) && !c.closed?
          end
        end

        def timeline
          timeline = []

          companies = bank_companies.map do |company|
            "#{self.class::COMPANY_SHORT_NAMES[company.id]}#{'*' if bidbox.any? { |c| c == company }}"
          end

          timeline << companies.join(', ') unless companies.empty?

          timeline
        end

        def unowned_purchasable_companies(_entity)
          bank_companies
        end

        def bidbox_refill!
          @bidbox_cache = bank_companies
                                        .first(self.class::BIDDING_BOX_MINOR_COUNT)
                                        .select { |c| minor?(c) }
                                        .map(&:id)

          # Set the reservation color of all the minors in the bid boxes
          @bidbox_cache.each do |company_id|
            corporation_by_id(company_id[1..-1]).reservation_color = self.class::BIDDING_BOX_MINOR_COLOR
          end

          @bidbox_companies_size = bidbox.length
        end

        def init_stock_market
          G1822Africa::StockMarket.new(game_market, [])
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
            G1822Africa::Step::MinorAcquisition,
            G1822::Step::PendingToken,
            G1822::Step::DiscardTrain,
            G1822::Step::IssueShares,
          ], round_num: round_num)
        end

        def stock_round(round_num = 1)
          G1822Africa::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G1822::Step::BuySellParShares,
          ], round_num: round_num)
        end

        def total_rounds(name)
          case name
          when self.class::OPERATING_ROUND_NAME
            @operating_rounds
          when self.class::STOCK_ROUND_NAME
            self.class::STOCK_ROUND_COUNT
          end
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Stock
              if @round.round_num == 1
                new_stock_round(@round.round_num + 1)
              else
                @operating_rounds = @phase.operating_rounds
                reorder_players
                new_operating_round
              end
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

        def new_stock_round(round_num = 1)
          @log << "-- #{round_description('Stock', round_num)} --"
          @round_counter += 1
          stock_round(round_num)
        end

        def concession?(company)
          company.id[0] == self.class::COMPANY_CONCESSION_PREFIX
        end

        def minor?(company)
          company.id[0] == self.class::COMPANY_MINOR_PREFIX
        end

        def private?(company)
          company.id[0] == self.class::COMPANY_PRIVATE_PREFIX
        end

        def compute_game_end
          return %i[custom full_or] if bidbox.length < self.class::BIDDING_BOX_MINOR_COUNT
          return %i[stock_market current_or] if @stock_market.max_reached?
        end

        def reset_sold_in_sr!
          @nothing_sold_in_sr = true
        end

        def must_remove_town?(entity)
          entity.id == self.class::COMPANY_REMOVE_TOWN
        end

        # Stubbed out because this game doesn't use it, but base 22 does
        def bidbox_minors = []
        def bidbox_concessions = []
        def bidbox_privates = []
        def company_tax_haven_bundle(choice); end
        def company_tax_haven_payout(entity, per_share); end
        def num_certs_modification(_entity) = 0

        def price_movement_chart
          [
            ['Action', 'Share Price Change'],
            ['Dividend 0 or withheld', '1 ←'],
            ['Dividend < share price', 'none'],
            ['Dividend ≥ share price, < 2x share price ', '1 →'],
            ['Dividend ≥ 2x share price', '2 →'],
            ['Minor company dividend > 0', '1 →'],
            ['Each share sold (if sold by director)', '1 ←'],
            ['One or more shares sold (if sold by non-director)', '1 ←'],
            ['Corporation sold out at end of SR', '1 →'],
          ]
        end
      end
    end
  end
end
