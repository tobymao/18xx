# frozen_string_literal: true

require_relative '../config/game/g_1861'
require_relative 'g_1867'

module Engine
  module Game
    class G1861 < G1867
      DEV_STAGE = :alpha
      load_from_json(Config::Game::G1861::JSON)

      STATUS_TEXT = Base::STATUS_TEXT.merge(
        'national_operates' => ['National railway operates',
                                'After the minors and majors operates the national runs trains, '\
                                'withholds and buys as many trains as possible'],
      ).freeze
      GAME_LOCATION = 'Russia'
      GREEN_CORPORATIONS = %w[MB Y V TR SV E].freeze

      # This is Kh in 1861
      HEX_WITH_O_LABEL = %w[G15].freeze
      HEX_UPGRADES_FOR_O = %w[201 202 207 208 621 622 623 801 640].freeze
      BONUS_CAPITALS = %w[H8].freeze
      BONUS_REVENUE = 'Q3'
      NATIONAL_RESERVATIONS = %w[E1 H8].freeze

      def self.title
        '1861'
      end

      def all_corporations
        corporations + [@national]
      end

      def unstarted_corporation_summary
        unipoed = @corporations.reject(&:ipoed)
        minor = unipoed.select { |c| c.type == :minor }
        major = unipoed.select { |c| c.type == :major }
        ["#{major.size} major", [@national] + minor]
      end

      def init_loans
        @loan_value = 50
        # 16 minors * 2, 8 majors * 5
        # The national can take an infinite (100)
        172.times.map { |id| Loan.new(id, @loan_value) }
      end

      def home_token_locations(corporation)
        # Can only place home token in cities that have no other tokens.
        open_locations = hexes.select do |hex|
          hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) && city.tokens.none? }
        end

        # @todo: this may need optimizing when changing connections for loading.
        unconnected = open_locations.select { |hex| hex.connections.none? }
        if unconnected.none?
          []
        else
          unconnected
        end
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

      def add_neutral_tokens
        # 1861 doesn't have neutral tokens
        @green_tokens = []
      end

      def stock_round
        Round::G1867::Stock.new(self, [
          Step::G1867::MajorTrainless,
          Step::DiscardTrain,
          Step::HomeToken,
          Step::G1861::BuySellParShares,
        ])
      end

      def operating_round(round_num)
        @national.owner = priority_deal_player
        @log << "#{@national.name} run by #{@national.owner.name}, as they have priority deal"
        calculate_interest
        Round::G1861::Operating.new(self, [
          Step::G1867::MajorTrainless,
          Step::G1861::BuyCompany,
          Step::G1867::RedeemShares,
          Step::G1861::Track,
          Step::G1861::Token,
          Step::G1861::Route,
          Step::G1861::Dividend,
          # The blocking buy company needs to be before loan operations
          [Step::G1861::BuyCompany, blocks: true],
          Step::G1867::LoanOperations,
          Step::DiscardTrain,
          Step::G1861::BuyTrain,
          [Step::G1861::BuyCompany, blocks: true],
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
