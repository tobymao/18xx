# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../g_1867/game'

module Engine
  module Game
    module G1861
      class Game < G1867::Game
        include_meta(G1861::Meta)
        include Entities
        include Map

        CURRENCY_FORMAT_STR = '%s₽'

        PHASES = [
          {
            name: '2',
            train_limit: { minor: 2 },
            tiles: [:yellow],
            operating_rounds: 2,
          },
          {
            name: '3',
            train_limit: { minor: 2, major: 4 },
            tiles: %i[yellow green],
            status: ['can_buy_companies'],
            on: '3',
            operating_rounds: 2,
          },
          {
            name: '4',
            train_limit: { minor: 1, major: 3, national: 99 },
            tiles: %i[yellow green],
            status: %w[can_buy_companies national_operates],
            on: '4',
            operating_rounds: 2,
          },
          {
            name: '5',
            train_limit: { minor: 1, major: 3, national: 99 },
            tiles: %i[yellow green brown],
            status: %w[can_buy_companies national_operates],
            on: '5',
            operating_rounds: 2,
          },
          {
            name: '6',
            train_limit: { minor: 1, major: 2, national: 99 },
            tiles: %i[yellow green brown gray],
            on: '6',
            operating_rounds: 2,
            status: ['national_operates'],
          },
          {
            name: '7',
            train_limit: { minor: 1, major: 2, national: 99 },
            tiles: %i[yellow green brown gray],
            on: '7',
            operating_rounds: 2,
            status: ['national_operates'],
          },
          {
            name: '8',
            train_limit: { major: 2, national: 99 },
            tiles: %i[yellow green brown gray],
            on: '8',
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 100,
            rusts_on: '4',
            num: 10,
          },
          {
            name: '3',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 225,
            rusts_on: '6',
            num: 7,
            events: [{ 'type' => 'green_minors_available' }],
          },
          {
            name: '4',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 350,
            rusts_on: '8',
            num: 4,
            events: [{ 'type' => 'majors_can_ipo' },
                     { 'type' => 'trainless_nationalization' }],
          },
          {
            name: '5',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 550,
            num: 4,
            events: [{ 'type' => 'minors_cannot_start' }],
          },
          {
            name: '6',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 650,
            num: 2,
            events: [{ 'type' => 'nationalize_companies' },
                     { 'type' => 'trainless_nationalization' }],
          },
          {
            name: '7',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 7, 'visit' => 7 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 800,
            num: 2,
          },
          {
            name: '8',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 8, 'visit' => 8 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 1000,
            num: 20,
            events: [{ 'type' => 'signal_end_game' },
                     { 'type' => 'minors_nationalized' },
                     { 'type' => 'trainless_nationalization' }],
          },
          {
            name: '2+2',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            multiplier: 2,
            price: 600,
            num: 20,
            available_on: '8',
          },
          {
            name: '5+5E',
            distance: [{ 'nodes' => ['offboard'], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => %w[city town], 'pay' => 0, 'visit' => 99 }],
            multiplier: 2,
            price: 1500,
            num: 20,
            available_on: '8',
          },
        ].freeze

        GAME_END_REASONS_TIMING_TEXT = Base::GAME_END_REASONS_TIMING_TEXT.merge(
          one_more_full_or_set:
            'If the first 8-train is purchased in the first OR of a set the ' \
            'game finishes at the end of the current OR set, otherwise the ' \
            'game ends at the end of the next OR set. In both cases the ' \
            'last OR set is extended to three ORs.',
        ).freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'national_operates' => ['National railway operates',
                                  'After the minors and majors operates the national runs trains, '\
                                  'withholds and buys as many trains as possible'],
        ).freeze
        GREEN_CORPORATIONS = %w[MB Y V TR SV E].freeze

        BONUS_CAPITALS = %w[H8].freeze
        BONUS_REVENUE = 'Q3'
        NATIONAL_RESERVATIONS = %w[E1 H8].freeze

        def game_market
          @optional_rules&.include?(:column_market) ? self.class::COLUMN_MARKET : self.class::GRID_MARKET
        end

        def all_corporations
          corporations + [@national]
        end

        def unstarted_corporation_summary
          unipoed = (@corporations + @future_corporations).reject(&:ipoed)
          minor = unipoed.select { |c| c.type == :minor }
          major = unipoed.select { |c| c.type == :major }
          ["#{major.size} major", [@national] + minor]
        end

        def init_loans
          @loan_value = 50
          # 16 minors * 2, 8 majors * 5
          # The national can take an infinite (100)
          Array.new(172) { |id| Loan.new(id, @loan_value) }
        end

        def home_token_locations(corporation)
          # Can only place home token in cities that have no other tokens.
          open_locations = hexes.select do |hex|
            hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) && city.tokens.none? }
          end

          unconnected_hexes(open_locations)
        end

        def place_rsr_home_token
          # RSR on first run places their home token...
          # unless RSR already has a token due to SPW nationalization,
          # in which case the reservation on the other city is removed
          tile = hex_by_id('E1').tile
          return unless @national_reservations.include?(tile.hex.id)
          return if tile.cities.any? { |c| c.tokened_by?(@national) }

          return unless (new_token = @national.next_token)

          @log << "#{@national.name} places a token on #{tile.hex.location_name}"
          @national_reservations.delete(tile.hex.id)
          # St Petersburg slot is the 2nd one
          tile.cities.last.place_token(@national, new_token, check_tokenable: false)
        end

        def nationalization_loan_movement(corporation)
          corporation.loans.each do
            stock_market.move_left(corporation)
          end
        end

        def nationalization_transfer_assets(corporation)
          receiving = []
          companies = transfer(:companies, corporation, @national).map(&:name)
          receiving << "companies (#{companies.join(', ')})" unless companies.empty?

          trains = transfer(:trains, corporation, @national).map(&:name)
          receiving << "trains (#{trains})" unless trains.empty?
          receiving << 'and' unless receiving.empty?
          receiving << format_currency(corporation.cash).to_s
          corporation.spend(corporation.cash, @national) if corporation.cash.positive?
          @log << "#{@national.id} received #{receiving} from #{corporation.id}"
        end

        def maximum_loans(entity)
          entity.type == :national ? 100 : super
        end

        def operating_order
          minors, majors = @corporations.select(&:floated?).sort.partition { |c| c.type == :minor }
          minors + majors + [@national]
        end

        def operated_operators
          (@corporations + [@national]).select(&:operated?)
        end

        def add_neutral_tokens(_hexes)
          # 1861 doesn't have neutral tokens
          @green_tokens = []
        end

        def stock_round
          G1867::Round::Stock.new(self, [
            G1867::Step::MajorTrainless,
            Engine::Step::DiscardTrain,
            Engine::Step::HomeToken,
            G1861::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          @national.owner = priority_deal_player
          @log << "#{@national.name} run by #{@national.owner.name}, as they have priority deal"
          calculate_interest
          G1861::Round::Operating.new(self, [
            G1867::Step::MajorTrainless,
            G1861::Step::BuyCompany,
            G1867::Step::RedeemShares,
            G1861::Step::Track,
            G1861::Step::Token,
            G1861::Step::Route,
            G1861::Step::Dividend,
            # The blocking buy company needs to be before loan operations
            [G1861::Step::BuyCompanyPreloan, { blocks: true }],
            G1867::Step::LoanOperations,
            Engine::Step::DiscardTrain,
            G1861::Step::BuyTrain,
            [G1861::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def or_round_finished; end

        def event_signal_end_game!
          if @round.round_num == 1
            # If first round
            # The current OR now has 3 rounds and finishes
            @operating_rounds = @final_operating_rounds = 3
            @final_turn = @turn
            @log << "First 8 train bought/exported, ending game at the end of #{@turn}.#{@final_operating_rounds},"\
                    ' skipping the next OR and SR'
          else
            # Else finish this OR, do the stock round then 3 more ORs
            @final_operating_rounds = 3
            @log << "First 8 train bought/exported, ending game at the end of #{@turn + 1}.#{@final_operating_rounds}"
          end

          # Hit the game end check now to set the correct turn
          game_end_check
        end
      end
    end
  end
end
