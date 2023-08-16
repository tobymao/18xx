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

        CERT_LIMIT = { 2 => 16, 3 => 13, 4 => 10 }.freeze

        BIDDING_TOKENS = {
          '3': 6,
          '4': 5,
          '5': 4,
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
          %w[40 50p 60xp 70xp 80xp 90 100 110 120 135 150 165e],
        ].freeze

        MUST_SELL_IN_BLOCKS = true
        SELL_MOVEMENT = :left_per_10_if_pres_else_left_one
        GAME_END_CHECK = { stock_market: :current_or, custom: :full_or }.freeze

        PRIVATE_TRAINS = %w[].freeze
        EXTRA_TRAINS = %w[].freeze
        EXTRA_TRAIN_PERMANENTS = %w[].freeze
        PRIVATE_MAIL_CONTRACTS = %w[].freeze
        PRIVATE_PHASE_REVENUE = %w[].freeze # Stub for 1822 specific code

        LOCAL_TRAIN_CAN_CARRY_MAIL = true

        # Don't run 1822 specific code for the LCDR
        COMPANY_LCDR = nil

        BIDDING_BOX_MINOR_COUNT = 3

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
                rusts_on: '4',
                available_on: '1',
              },
            ],
          },
          {
            name: '3',
            distance: 3,
            num: 5,
            price: 160,
            rusts_on: '6',
          },
          {
            name: '5',
            distance: 5,
            num: 99,
            price: 350,
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

        # setup_companies from 1822 has too much 1822-specific stuff that doesn't apply to this game
        def setup_companies
          minors = @companies.select { |c| c.id[0] == self.class::COMPANY_MINOR_PREFIX }
          concessions = @companies.select { |c| c.id[0] == self.class::COMPANY_CONCESSION_PREFIX }
          privates = @companies.select { |c| c.id[0] == self.class::COMPANY_PRIVATE_PREFIX }

          @companies.clear
          @companies.concat(minors)
          @companies.concat(concessions)
          @companies.concat(privates.sort_by! { rand }.take(10))

          # Randomize from preset seed to get same order
          @companies.sort_by! { rand }

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

          @companies = put_concession_to_front(@companies)
        end

        def setup_bidboxes
          # Set the owner to bank for the companies up for auction this stockround
          bidbox_minors_refill!
          bidbox_minors.each do |minor|
            minor.owner = @bank
          end

          # Reset the choice for P9-M&GNR
          @double_cash_choice = nil
        end

        def put_concession_to_front(companies)
          first_concession_index = companies.find_index { |c| c.id[0] == self.class::COMPANY_CONCESSION_PREFIX }

          head = companies[0...first_concession_index]
          tail = companies[first_concession_index..-1]

          tail + head
        end

        def bidbox_minors
          bank_companies.first(self.class::BIDDING_BOX_MINOR_COUNT)
        end

        def bidbox_concessions = []
        def bidbox_privates = []

        def bank_companies
          @companies.select do |c|
            (!c.owner || c.owner == @bank) && !c.closed?
          end
        end

        def timeline
          timeline = []

          companies = bank_companies.map do |company|
            "#{self.class::COMPANY_SHORT_NAMES[company.id]}#{'*' if bidbox_minors.any? { |c| c == company }}"
          end

          timeline << companies.join(', ') unless companies.empty?

          timeline
        end

        def bidbox_minors_refill!
          @bidbox_minors_cache = bank_companies
                                   .first(self.class::BIDDING_BOX_MINOR_COUNT)
                                   .select { |c| c.id[0] == self.class::COMPANY_MINOR_PREFIX }
                                   .map(&:id)

          # Set the reservation color of all the minors in the bid boxes
          @bidbox_minors_cache.each do |company_id|
            corporation_by_id(company_id[1..-1]).reservation_color = self.class::BIDDING_BOX_MINOR_COLOR
          end
        end

        def next_round!
          if @round == G1822::Round::Choices && @round.round_num == 1
            @round = new_stock_round(@round.round_num + 1)
          else
            super
          end
        end

        def new_stock_round(round_num = 1)
          @round_counter += 1 if round_num == 2

          @log << "-- #{round_description('Stock', round_num)} --"
          stock_round
        end

        def round_description(name, round_number = 1)
          description = super

          description += ".#{round_number}" if name == 'Stock' && !round_number.nil?

          description.strip
        end

        def custom_end_game_reached?
          # End if bid boxes cannot be refilled AFTER SR
        end

        # Temporary stub
        def setup_exchange_tokens; end

        # Stubbed out because this game doesn't it, but base 22 does
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
