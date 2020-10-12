# frozen_string_literal: true

require_relative '../config/game/g_1817'
require_relative '../loan.rb'
require_relative 'base'

module Engine
  module Game
    class G1817 < Base
      register_colors(black: '#0a0a0a',
                      blue: '#0a70b3',
                      brightGreen: '#7bb137',
                      brown: '#881a1e',
                      gold: '#e09001',
                      gray: '#9a9a9d',
                      green: '#008f4f',
                      lavender: '#baa4cb',
                      lightBlue: '#37b2e2',
                      lightBrown: '#b58168',
                      lime: '#bdbd00',
                      navy: '#004d95',
                      natural: '#fbf4de',
                      orange: '#eb6f0e',
                      pink: '#ec767c',
                      red: '#dd0030',
                      turquoise: '#235758',
                      violet: '#4d2674',
                      white: '#ffffff',
                      yellow: '#fcea18')

      load_from_json(Config::Game::G1817::JSON)

      GAME_LOCATION = 'NYSE, USA'
      GAME_RULES_URL = 'https://drive.google.com/file/d/0B1SWz2pNe2eAbnI4NVhpQXV4V0k/view'
      GAME_DESIGNER = 'Craig Bartell, Tim Flowers'
      GAME_PUBLISHER = Publisher::INFO[:all_aboard_games]
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1817'

      MUST_BID_INCREMENT_MULTIPLE = true
      SEED_MONEY = 200
      MUST_BUY_TRAIN = :never
      EBUY_PRES_SWAP = false # allow presidential swaps of other corps when ebuying
      POOL_SHARE_DROP = :each
      SELL_MOVEMENT = :none
      ALL_COMPANIES_ASSIGNABLE = true
      SELL_AFTER = :operate
      DEV_STAGE = :alpha

      ASSIGNMENT_TOKENS = {
        'bridge' => '/icons/1817/bridge_token.svg',
        'mine' => '/icons/1817/mine_token.svg',
      }.freeze
      # @todo: this needs purchase of the 8 train
      GAME_END_CHECK = { bankrupt: :immediate, custom: :one_more_full_or_set }.freeze

      # Two lays with one being an upgrade, second tile costs 20
      TILE_LAYS = [{ lay: true, upgrade: true }, { lay: true, upgrade: :not_if_upgraded, cost: 20 }].freeze

      IPO_NAME = 'Treasury'

      LIMIT_TOKENS = 8

      EVENTS_TEXT = Base::EVENTS_TEXT.merge('signal_end_game' => ['Signal End Game',
                                                                  'Game Ends 3 ORs after purchase/export'\
                                                                  ' of first 8 train']).freeze

      attr_reader :loan_value, :owner_when_liquidated

      def bankruptcy_limit_reached?
        @players.reject(&:bankrupt).one?
      end

      def interest_rate
        @interest_fixed || [[5, ((loans_taken + 4) / 5).to_i * 5].max, 70].min
      end

      def interest_owed(entity)
        (interest_rate * entity.loans.size * @loan_value) / 100
      end

      def maximum_loans(entity)
        entity.total_shares
      end

      def home_token_locations(corporation)
        hexes.select do |hex|
          hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) }
        end
      end

      def redeemable_shares(entity)
        return [] unless entity.corporation?
        return [] unless round.steps.find { |step| step.class == Step::G1817::BuySellParShares }.active?

        bundles_for_corporation(share_pool, entity)
          .reject { |bundle| entity.cash < bundle.price }
      end

      def tokens_needed(corporation)
        tokens_needed = { 2 => 1, 5 => 2, 10 => 4 }[corporation.total_shares] - corporation.tokens.size
        tokens_needed += 1 if corporation.companies.any? { |c| c.id == 'TS' }
        tokens_needed
      end

      def size_corporation(corporation, size)
        shares = @_shares.values.select { |share| share.corporation == corporation }
        game_error('Can only convert 2 share corporation') unless corporation.total_shares == 2

        case size
        when 5
          shares[0].percent = 40
          shares = 3.times.map { |i| Share.new(corporation, percent: 20, index: i + 1) }
        when 10
          shares[0].percent = 20
          shares = 8.times.map { |i| Share.new(corporation, percent: 10, index: i + 1) }
        end

        shares.each do |share|
          corporation.shares_by_corporation[corporation] << share
          @_shares[share.id] = share
        end
      end

      def bundles_for_corporation(share_holder, corporation, shares: nil)
        super(
          share_holder,
          corporation,
          shares: shares || share_holder.shares_of(corporation).select { |share| share.percent.positive? },
        )
      end

      def convert(corporation)
        shares = @_shares.values.select { |share| share.corporation == corporation }

        corporation.share_holders.clear

        case corporation.total_shares
        when 2
          shares[0].percent = 40
          new_shares = 3.times.map { |i| Share.new(corporation, percent: 20, index: i + 1) }
        when 5
          shares.each { |share| share.percent = 10 }
          shares[0].percent = 20
          new_shares = 5.times.map { |i| Share.new(corporation, percent: 10, index: i + 4) }
        else
          game_error('Cannot convert 10 share corporation')
        end

        shares.each { |share| corporation.share_holders[share.owner] += share.percent }

        new_shares.each do |share|
          owner = share.owner
          corporation.share_holders[owner] += share.percent if owner
          corporation.shares_by_corporation[corporation] << share
          @_shares[share.id] = share
        end
      end

      def short(entity, corporation)
        price = corporation.share_price.price
        percent = corporation.share_percent

        index = corporation.share_holders.values.map(&:abs).sum / 10
        share = Share.new(corporation, percent: percent, index: index)
        short = Share.new(corporation, percent: -percent)
        short.buyable = false
        short.counts_for_limit = false

        @log << "#{entity.name} shorts a #{percent}% " \
          "share of #{corporation.name} for #{format_currency(price)}"

        @bank.spend(price, entity)
        corporation.share_holders[@share_pool] += percent
        corporation.share_holders[entity] -= percent
        entity.shares_by_corporation[corporation] << short
        @share_pool.shares_by_corporation[corporation] << share
      end

      def unshort(entity, bundle)
        share = bundle.shares[0]
        shares = entity.shares_of(bundle.corporation)
        shares.delete(share)
        shares.delete(shares.find { |s| s.percent == -bundle.percent })
      end

      def take_loan(entity, loan)
        game_error("Cannot take more than #{maximum_loans(entity)} loans") unless can_take_loan?(entity)
        price = entity.share_price.price
        name = entity.name
        name += " (#{entity.owner.name})" if @round.is_a?(Round::Stock)
        @log << "#{name} takes a loan and receives #{format_currency(loan.amount)}"
        @bank.spend(loan.amount, entity)
        @stock_market.move_left(entity)
        log_share_price(entity, price)
        entity.loans << loan
        @loans.delete(loan)
      end

      def can_take_loan?(entity)
        entity.corporation? &&
          entity.loans.size < maximum_loans(entity) &&
          @loans.any?
      end

      def buying_power(entity)
        return entity.cash unless entity.corporation?

        entity.cash + ((maximum_loans(entity) - entity.loans.size) * @loan_value)
      end

      def liquidate!(corporation)
        @owner_when_liquidated[corporation] = corporation.owner
        @stock_market.move(corporation, 0, 0, force: true)
      end

      def find_share_price(price)
        @stock_market
          .market[0]
          .reverse
          .find { |sp| sp.price <= price }
      end

      def revenue_for(route, stops)
        revenue = super

        revenue += 10 * stops.count { |stop| stop.hex.assigned?('bridge') }

        mine = 'mine'
        if route.hexes.first.assigned?(mine) || route.hexes.last.assigned?(mine)
          game_error('Route cannot start or end with a mine')
        end

        revenue += 10 * route.all_hexes.count { |hex| hex.assigned?(mine) }
        revenue
      end

      def can_go_bankrupt?(player, corporation)
        total_emr_buying_power(player, corporation).negative?
      end

      def total_emr_buying_power(player, _corporation)
        liquidity(player, emergency: true)
      end

      private

      def new_auction_round
        log << "Seed Money for initial auction is #{format_currency(SEED_MONEY)}" unless @round
        Round::Auction.new(self, [
          Step::G1817::SelectionAuction,
        ])
      end

      def stock_round
        @interest_fixed = nil
        @owner_when_liquidated = {}
        Round::G1817::Stock.new(self, [
          Step::DiscardTrain,
          Step::HomeToken,
          Step::G1817::BuySellParShares,
        ])
      end

      def operating_round(round_num)
        @interest_fixed = nil
        @interest_fixed = interest_rate
        # Don't clear when coming from a SR
        @owner_when_liquidated = {} unless round_num == 1
        # Revaluate if private companies are owned by corps with trains
        @companies.each do |company|
          next unless company.owner

          company.abilities(:revenue_change, 'has_train') do |ability|
            company.revenue = company.owner.trains.any? ? ability.revenue : 0
          end
        end

        Round::G1817::Operating.new(self, [
          Step::G1817::Bankrupt,
          Step::G1817::CashCrisis,
          Step::G1817::Loan,
          Step::G1817::SpecialTrack,
          Step::G1817::Assign,
          Step::DiscardTrain,
          Step::G1817::Track,
          Step::Token,
          Step::Route,
          Step::G1817::Dividend,
          Step::G1817::BuyTrain,
        ], round_num: round_num)
      end

      def or_round_finished
        if @depot.upcoming.first.name == '2'
          depot.export_all!('2')
        else
          depot.export!
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
            @log << "-- Merger and Conversion Round #{@turn}.#{@round.round_num} (of #{@operating_rounds}) --"
            Round::G1817::Merger.new(self, [
              Step::G1817::ReduceTokens,
              Step::DiscardTrain,
              Step::G1817::PostConversion,
              Step::G1817::Conversion,
            ], round_num: @round.round_num)
          when Round::G1817::Merger
            @log << "-- Acquisition Round #{@turn}.#{@round.round_num} (of #{@operating_rounds}) --"
            Round::G1817::Acquisition.new(self, [
              Step::G1817::ReduceTokens,
              Step::G1817::Bankrupt,
              Step::G1817::CashCrisis,
              Step::DiscardTrain,
              Step::G1817::Acquire,
            ], round_num: @round.round_num)
          when Round::G1817::Acquisition
            if @round.round_num < @operating_rounds
              new_operating_round(@round.round_num + 1)
            else
              @turn += 1
              or_set_finished
              new_stock_round
            end
          when init_round.class
            reorder_players
            new_stock_round
          end
      end

      def init_loans
        @loan_value = 100
        70.times.map { |id| Loan.new(id, @loan_value) }
      end

      def round_end
        Round::G1817::Acquisition
      end

      def custom_end_game_reached?
        @final_operating_rounds
      end

      def final_operating_rounds
        @final_operating_rounds || super
      end

      def event_signal_end_game!
        # If we're in round 1, we have another set of ORs with 2 ORs
        # If we're in round 2, we have another set of ORs with 3 ORs
        @final_operating_rounds = @round.round_num == 2 ? 3 : 2

        @log << "First 8 train bought/exported, ending game at the end of #{@turn + 1}.#{@final_operating_rounds}"
      end
    end
  end
end
