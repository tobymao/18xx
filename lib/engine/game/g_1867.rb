# frozen_string_literal: true

require_relative '../config/game/g_1867'
require_relative '../loan.rb'
require_relative 'base'
require_relative 'interest_on_loans'

module Engine
  module Game
    class G1867 < Base
      register_colors(black: '#16190e',
                      blue: '#165633',
                      brightGreen: '#0a884b',
                      brown: '#984573',
                      gold: '#904098',
                      gray: '#984d2d',
                      green: '#bedb86',
                      lavender: '#e96f2c',
                      lightBlue: '#bedef3',
                      lightBrown: '#bec8cc',
                      lime: '#00afad',
                      navy: '#003d84',
                      natural: '#e31f21',
                      orange: '#f2a847',
                      pink: '#ee3e80',
                      red: '#ef4223',
                      turquoise: '#0095da',
                      violet: '#e48329',
                      white: '#fff36b',
                      yellow: '#ffdea8')

      load_from_json(Config::Game::G1867::JSON)

      GAME_LOCATION = 'Canada'
      GAME_RULES_URL = 'https://boardgamegeek.com/filepage/212807/18611867-rulebook'
      GAME_DESIGNER = 'Ian D. Wilson'
      GAME_PUBLISHER = :grand_trunk_games
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1867'

      HOME_TOKEN_TIMING = :float
      MUST_BID_INCREMENT_MULTIPLE = true
      MUST_BUY_TRAIN = :always # mostly true, needs custom code
      POOL_SHARE_DROP = :each
      SELL_MOVEMENT = :left_block_pres
      ALL_COMPANIES_ASSIGNABLE = true
      SELL_AFTER = :operate
      DEV_STAGE = :prealpha
      SELL_BUY_ORDER = :sell_buy

      ASSIGNMENT_TOKENS = {
        'bridge' => '/icons/1817/bridge_token.svg',
        'mine' => '/icons/1817/mine_token.svg',
      }.freeze

      GAME_END_CHECK = { bank: :current_or, custom: :one_more_full_or_set }.freeze

      HEX_WITH_O_LABEL = %w[J12].freeze
      HEX_UPGRADES_FOR_O = %w[201 202 203 207 208 622 623 801 X8].freeze

      CERT_LIMIT_CHANGE_ON_BANKRUPTCY = true

      # Two lays with one being an upgrade, second tile costs 20
      TILE_LAYS = [{ lay: true, upgrade: true }, { lay: true, upgrade: :not_if_upgraded, cost: 20 }].freeze

      LIMIT_TOKENS = 8

      EVENTS_TEXT = Base::EVENTS_TEXT.merge('signal_end_game' => ['Signal End Game',
                                                                  'Game Ends 3 ORs after purchase/export'\
                                                                  ' of first 8 train'],
                                            'green_minors_available' => ['Green Minors become available'],
                                            'majors_can_ipo' => ['Majors can be ipoed'],
                                            'minors_cannot_start' => ['Minors cannot start'],
                                            'minors_nationalized' => ['Minors are nationalized'],
                                            'trainless_nationalization' =>
                                            ['Trainless Nationalization',
                                             'Operating Trainless Minors are nationalized'\
                                             ', Operating Trainless Majors may nationalize']).freeze
      MARKET_TEXT = Base::MARKET_TEXT.merge(par_1: 'Minor Corporation Par',
                                            par_2: 'Major Corporation Par',
                                            par: 'Major/Minor Corporation Par',
                                            convert_range: 'Price range to convert minor to major',
                                            max_price: 'Maximum price for a minor').freeze
      STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(par_1: :orange, par_2: :green).freeze
      CORPORATION_SIZES = { 2 => :small, 5 => :medium, 10 => :large }.freeze
      include InterestOnLoans

      # Minors are done as corporations with a size of 2

      attr_reader :loan_value, :trainless_major

      def ipo_name(_entity = nil)
        'Treasury'
      end

      def interest_rate
        5 # constant
      end

      def interest_owed_for_loans(loans)
        interest_rate * loans
      end

      def interest_owed(entity)
        interest_owed_for_loans(entity.loans.size)
      end

      def maximum_loans(entity)
        entity.type == :major ? 5 : 2
      end

      def home_token_locations(corporation)
        open_locations = hexes.select do |hex|
          hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) }
        end

        return open_locations if corporation.type == :minor

        # @todo: this may need optimizing when changing connections for loading.
        unconnected = open_locations.select { |hex| hex.connections.none? }
        if unconnected.none?
          open_locations
        else
          unconnected
        end
      end

      def redeemable_shares(entity)
        return [] unless entity.corporation?

        bundles_for_corporation(share_pool, entity)
          .reject { |bundle| entity.cash < bundle.price }
      end

      def bundles_for_corporation(share_holder, corporation, shares: nil)
        super(
          share_holder,
          corporation,
          shares: shares || share_holder.shares_of(corporation).select { |share| share.percent.positive? },
        )
      end

      def take_loan(entity, loan)
        game_error("Cannot take more than #{maximum_loans(entity)} loans") unless can_take_loan?(entity)
        name = entity.name
        amount = loan.amount - 5
        @log << "#{name} takes a loan and receives #{format_currency(amount)}"
        @bank.spend(amount, entity)
        entity.loans << loan
        @loans.delete(loan)
      end

      def repay_loan(entity, loan)
        @log << "#{entity.name} pays off a loan for #{format_currency(amount)}"
        entity.spend(amount, bank)

        entity.loans.delete(loan)
        @game.loans << loan
      end

      def can_take_loan?(entity)
        entity.corporation? &&
          entity.loans.size < maximum_loans(entity) &&
          @loans.any?
      end

      def buying_power(entity, full = false)
        return entity.cash unless full
        return entity.cash unless entity.corporation?

        # Loans are actually generate $5 less than when taken out.
        entity.cash + ((maximum_loans(entity) - entity.loans.size) * @loan_value - 5)
      end

      def nationalize!(corporation)
        @log << "#{corporation.name} is nationalized"

        repay_loan(corporation, corporation.loan.first) while corporation.cash > @loan_value && corporation.loans.any?

        # Move once automatically
        price = corporation.share_price.price
        stock_market.move_left(corporation)

        corporation.loans.each do
          stock_market.move_left(corporation)
          stock_market.move_left(corporation)
        end
        log_share_price(corporation, price)

        # Payout players for shares
        per_share = corporation.share_price.price
        total_payout = corporation.total_shares * per_share
        payouts = {}
        @players.each do |player|
          amount = player.num_shares_of(corporation) * per_share
          next if amount.zero?

          payouts[player] = amount
          @bank.spend(amount, player)
        end

        if payouts.any?
          receivers = payouts
                        .sort_by { |_r, c| -c }
                        .map { |receiver, cash| "#{format_currency(cash)} to #{receiver.name}" }.join(', ')

          @log << "#{corporation.name} settles with shareholders #{format_currency(total_payout)} = "\
                          "#{format_currency(per_share)} (#{receivers})"
        end

        # Close corp (minors close, majors reset)
        if corporation.type == :minor
          close_corporation(corporation)
        else
          reset_corporation(corporation)
        end
      end

      def revenue_for(route, stops)
        revenue = super

        game_error('Route visits same hex twice') if route.hexes.size != route.hexes.uniq.size

        route.corporation.companies.each do |company|
          company.abilities(:hex_bonus) do |ability|
            revenue += stops.map { |s| s.hex.id }.uniq.sum { |id| ability.hexes.include?(id) ? ability.amount : 0 }
          end
        end

        # Quebec, Montreal and Toronto
        capitals = stops.find { |stop| %w[F16 L12 O7].include?(stop.hex.name) }
        # Timmins
        timmins = stops.find { |stop| stop.hex.name == 'D2' }

        revenue += 40 if capitals && timmins

        revenue
      end

      def can_go_bankrupt?(player, corporation)
        total_emr_buying_power(player, corporation).negative?
      end

      def total_emr_buying_power(player, _corporation)
        liquidity(player, emergency: true)
      end

      def total_rounds(name)
        # Return the total number of rounds for those with more than one.
        # Merger exists twice since it's logged as the long form, but shown on the UI in the short form
        @operating_rounds if ['Operating', 'Merger', 'Merger and Conversion', 'Acquisition'].include?(name)
      end

      def corporation_size(entity)
        # For display purposes is a corporation small, medium or large
        CORPORATION_SIZES[entity.total_shares]
      end

      def upgrades_to?(from, to, special = false)
        # O labelled tile upgrades to Ys until Grey
        return super unless HEX_WITH_O_LABEL.include?(from.hex.name)

        return false unless HEX_UPGRADES_FOR_O.include?(to.name)

        super(from, to, true)
      end

      def compute_stops(route)
        # 1867 should always have two distances, one with a pay of zero, the other with the full distance.
        visits = route.visited_stops
        distance = route.train.distance
        return [] if visits.empty?

        mandatory_distance = distance.find { |d| d['pay'].positive? }

        # Find all the mandatory stops
        mandatory_stops, optional_stops = visits.partition { |node| mandatory_distance['nodes'].include?(node.type) }

        # Only both with the extra step if it's not all mandatory
        return mandatory_stops if mandatory_stops.size == mandatory_distance['pay']

        need_token = mandatory_stops.none? { |stop| stop.tokened_by?(route.corporation) }

        remaining_stops = mandatory_distance['pay'] - mandatory_stops.size

        # Allocate optional stops
        stops, revenue = optional_stops.combination(remaining_stops.to_i).map do |stops|
          # Make sure this set of stops is legal
          # 1) At least one stop must have a token (for 5+5E train)
          next if need_token && stops.none? { |stop| stop.tokened_by?(route.corporation) }

          all_stops = mandatory_stops + stops
          [all_stops, revenue_for(route, all_stops)]
        end.compact.max_by(&:last)

        revenue ||= 0

        return stops if revenue.positive?
      end

      def post_train_buy
        postevent_trainless_nationalization! if @trainless_nationalization
      end

      private

      def new_auction_round
        Round::Auction.new(self, [
          Step::G1867::SingleItemAuction,
        ])
      end

      def stock_round
        Round::G1867::Stock.new(self, [
          Step::G1867::MajorTrainless,
          Step::DiscardTrain,
          Step::HomeToken,
          Step::G1867::BuySellParShares,
        ])
      end

      def operating_round(round_num)
        Round::G1867::Operating.new(self, [
          Step::G1867::MajorTrainless,
          Step::DiscardTrain,
          Step::BuyCompany,
          Step::G1867::RedeemShares,
          Step::G1867::Track,
          Step::G1867::Token,
          Step::Route,
          Step::G1867::Dividend,
          Step::G1867::LoanOperations,
          Step::G1867::BuyTrain,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def or_round_finished
        current_phase = phase.name.to_i
        depot.export! if current_phase >= 4 && current_phase <= 7
      end

      def new_or!
        if @round.round_num < @operating_rounds
          new_operating_round(@round.round_num + 1)
        else
          @turn += 1
          or_set_finished
          new_stock_round
        end
      end

      def next_round!
        @round =
          case @round
          when Round::Stock
            @operating_rounds = @final_operating_rounds || @phase.operating_rounds
            reorder_players
            new_operating_round
          when Round::Operating
            or_round_finished
            if phase.name.to_i <= 3
              new_or!
            else
              @log << "-- #{round_description('Merger', @round.round_num)} --"
              Round::G1867::Merger.new(self, [
                # Step::G1817::ReduceTokens, #@todo
                Step::G1867::MajorTrainless,
                Step::DiscardTrain,
                Step::G1867::PostMergerShares,
                Step::G1867::Merge,
              ], round_num: @round.round_num)
            end
          when Round::G1867::Merger
            new_or!
          when init_round.class
            reorder_players
            new_stock_round
          end
      end

      def init_loans
        @loan_value = 50
        # 16 minors * 2, 8 majors * 5
        72.times.map { |id| Loan.new(id, @loan_value) }
      end

      def round_end
        Round::G1867::Merger
      end

      def custom_end_game_reached?
        @final_operating_rounds
      end

      def final_operating_rounds
        @final_operating_rounds || super
      end

      def setup
        # Hide the special 3 company
        @hidden_company = company_by_id('3')
        @companies.delete(@hidden_company)

        # CN corporation only exists to hold tokens
        @cn_corporation = corporation_by_id('CN')
        @corporations.delete(@cn_corporation)

        @green_tokens = []
        @hexes.each do |hex|
          case hex.id
          when 'D2'
            token = Token.new(@cn_corporation, price: 0, logo: '/logos/1867/neutral.svg', type: :neutral)
            @cn_corporation.tokens << token
            hex.tile.cities.first.exchange_token(token)
            @green_tokens << token
          when 'L12'
            token = Token.new(@cn_corporation, price: 0, logo: '/logos/1867/neutral.svg', type: :neutral)
            @cn_corporation.tokens << token
            hex.tile.cities.last.exchange_token(token)
            @green_tokens << token
          when 'F16'
            hex.tile.cities.first.exchange_token(@cn_corporation.tokens.first)
          end
        end

        # Set minors maximum share price
        max_price = @stock_market.market.first.find { |stockprice| stockprice.types.include?(:max_price) }
        @corporations.select { |c| c.type == :minor }.each { |c| c.max_share_price = max_price }

        # Move green and majors out of the normal list
        green = COLORS[:green]
        @corporations, @future_corporations = @corporations.partition do |corporation|
          corporation.type == :minor && corporation.color != green
        end
      end

      def event_green_minors_available!
        @log << 'Green minors are now available'

        # Can now lay on the 3
        @hidden_company.close!
        # Remove the green tokens
        @green_tokens.map(&:remove!)

        # All the corporations become available, as minors can now merge/convert to corporations
        @corporations += @future_corporations
        @future_corporations = []
      end

      def event_majors_can_ipo!
        @log << 'Majors can now be started via IPO'
        # Done elsewhere
      end

      def event_minors_cannot_start!
        @corporations, removed = @corporations.partition do |corporation|
          corporation.owned_by_player? || corporation.type != :minor
        end
        @log << 'Minors can no longer be started' if removed.any?
      end

      def event_minors_nationalized!
        # Given minors have a train limit of 1, this shouldn't cause the order to be disrupted.
        @corporations, removed = @corporations.partition do |corporation|
          corporation.type != :minor
        end
        @log << 'Minors nationalized' if removed.any?
        removed.each { |c| nationalize!(c) }
      end

      def event_signal_end_game!
        # There's always 3 ORs after the 8 train is bought
        @final_operating_rounds = 3

        @log << "First 8 train bought/exported, ending game at the end of #{@turn + 1}.#{@final_operating_rounds}"
      end

      def event_trainless_nationalization!
        # Store flag, has to be done after the trains are rusted
        @trainless_nationalization = true
      end

      def postevent_trainless_nationalization!
        trainless = @corporations.select { |c| c.operated? && c.trains.none? }

        @trainless_major = []
        trainless.each do |c|
          if c.type == :major
            @trainless_major << c
          else
            nationalize!(c)
          end
        end

        @trainless_major = @trainless_major.sort.reverse
        @trainless_nationalization = false
      end
    end
  end
end
