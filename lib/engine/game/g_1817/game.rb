# frozen_string_literal: true

require_relative 'meta'
require_relative 'map'
require_relative 'entities'
require_relative '../../loan'
require_relative '../base'
require_relative '../interest_on_loans'

module Engine
  module Game
    module G1817
      class Game < Game::Base
        include_meta(G1817::Meta)
        include G1817::Entities
        include G1817::Map

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

        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = 99_999

        CERT_LIMIT = { 3 => 21, 4 => 16, 5 => 13, 6 => 11, 7 => 9, 8 => 8, 9 => 7, 10 => 6, 11 => 6, 12 => 5 }.freeze

        STARTING_CASH = {
          3 => 420,
          4 => 315,
          5 => 252,
          6 => 210,
          7 => 180,
          8 => 158,
          9 => 140,
          10 => 126,
          11 => 115,
          12 => 105,
        }.freeze

        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = false

        TILE_UPGRADES_MUST_USE_MAX_EXITS = %i[cities].freeze

        MARKET = [
          %w[0l
             0a
             0a
             0a
             40
             45
             50p
             55s
             60p
             65p
             70s
             80p
             90p
             100p
             110p
             120s
             135p
             150p
             165p
             180p
             200p
             220
             245
             270
             300
             330
             360
             400
             440
             490
             540
             600],
           ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
            corporation_sizes: [2],
          },
          {
            name: '2+',
            on: '2+',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
            corporation_sizes: [2],
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            corporation_sizes: [2, 5],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            corporation_sizes: [5],
          },
          {
            name: '5',
            on: '5',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
            corporation_sizes: [5, 10],
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
            corporation_sizes: [10],
          },
          {
            name: '7',
            on: '7',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
            corporation_sizes: [10],
          },
          {
            name: '8',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            status: ['no_new_shorts'],
            operating_rounds: 2,
            corporation_sizes: [10],
          },
        ].freeze

        TRAINS = [{ name: '2', distance: 2, price: 100, rusts_on: '4', num: 40 },
                  { name: '2+', distance: 2, price: 100, obsolete_on: '4', num: 4 },
                  { name: '3', distance: 3, price: 250, rusts_on: '6', num: 12 },
                  { name: '4', distance: 4, price: 400, rusts_on: '8', num: 8 },
                  { name: '5', distance: 5, price: 600, num: 5 },
                  { name: '6', distance: 6, price: 750, num: 4 },
                  { name: '7', distance: 7, price: 900, num: 3 },
                  {
                    name: '8',
                    distance: 8,
                    price: 1100,
                    num: 40,
                    events: [{ 'type' => 'signal_end_game' }],
                  }].freeze

        TRAIN_STATION_PRIVATE_NAME = 'TS'

        MUST_BID_INCREMENT_MULTIPLE = true
        SEED_MONEY = 200
        MUST_BUY_TRAIN = :never
        EBUY_PRES_SWAP = false # allow presidential swaps of other corps when ebuying
        CERT_LIMIT_INCLUDES_PRIVATES = false
        POOL_SHARE_DROP = :each
        SELL_MOVEMENT = :none
        ALL_COMPANIES_ASSIGNABLE = true
        SELL_AFTER = :after_ipo
        OBSOLETE_TRAINS_COUNT_FOR_LIMIT = true
        BANKRUPTCY_ENDS_GAME_AFTER = :all_but_one

        ASSIGNMENT_TOKENS = {
          'bridge' => '/icons/1817/bridge_token.svg',
          'mine' => '/icons/1817/mine_token.svg',
          'ranch' => '/icons/1817/ranch_token.svg',
        }.freeze

        GAME_END_CHECK = { bankrupt: :immediate, final_phase: :one_more_full_or_set }.freeze

        CERT_LIMIT_CHANGE_ON_BANKRUPTCY = true

        # Two lays with one being an upgrade, second tile costs 20
        TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: true, upgrade: :not_if_upgraded, cost: 20, cannot_reuse_same_hex: true },
        ].freeze

        LIMIT_TOKENS_AFTER_MERGER = 8

        EVENTS_TEXT = Base::EVENTS_TEXT.merge('signal_end_game' => ['Signal End Game',
                                                                    'Game Ends 3 ORs after purchase/export'\
                                                                    ' of first 8 train']).freeze
        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'no_new_shorts' => ['Cannot gain new shorts', 'Short selling is not permitted, existing shorts remain'],
        ).freeze
        MARKET_TEXT = Base::MARKET_TEXT.merge(safe_par: 'Minimum Price for a 2($55), 5($70) and 10($120) share'\
                                                        ' corporation taking maximum loans to ensure it avoids acquisition',
                                              acquisition: 'Acquisition (Pay $40 dividend to move right, $80'\
                                                           ' to double jump)').freeze
        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(par: :gray).freeze
        MARKET_SHARE_LIMIT = 1000 # notionally unlimited shares in market
        CORPORATION_SIZES = { 2 => :small, 5 => :medium, 10 => :large }.freeze

        MIN_LOAN = 5
        MAX_LOAN = 70
        LOANS_PER_INCREMENT = 5
        LOAN_INTEREST_INCREMENTS = 5

        include InterestOnLoans
        attr_accessor :pittsburgh_private
        attr_reader :owner_when_liquidated, :stock_prices_start_merger

        def timeline
          @timeline = [
            'At the end of each OR the next available train will be exported
           (removed, triggering phase change as if purchased)',
          ]
        end

        def init_cert_limit
          @log << '1817 has not been tested thoroughly with more than seven players.' if @players.size > 7

          super
        end

        def game_companies
          companies = self.class::COMPANIES
          companies += self.class::VOLATILITY_COMPANIES if option_volatility_expansion?
          companies
        end

        def available_programmed_actions
          [Action::ProgramMergerPass, Action::ProgramBuyShares, Action::ProgramSharePass]
        end

        def merge_rounds
          [G1817::Round::Merger, G1817::Round::Acquisition]
        end

        def merge_corporations
          @corporations.select { |c| c.floated? && c.share_price.normal_movement? && !c.share_price.acquisition? }
        end

        def option_short_squeeze?
          @optional_rules&.include?(:short_squeeze)
        end

        def option_five_shorts?
          @optional_rules&.include?(:five_shorts)
        end

        def option_modern_trains?
          @optional_rules&.include?(:modern_trains)
        end

        def option_volatility_expansion?
          @optional_rules&.include?(:volatility)
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def init_stock_market
          @owner_when_liquidated = {}
          super
        end

        def setup_preround
          if option_volatility_expansion?
            city_tile_companies = @companies.select { |c| self.class::VOLATILITY_CITY_TILE_COMPANIES.include?(c.id) }
            city_tile_companies.sort_by! { rand }
            @pittsburgh_private = city_tile_companies.shift
            city_tile_companies.each do |c|
              c.close!
              @companies.delete(c)
            end
          else
            @pittsburgh_private = @companies.find { |c| c.id == 'PSM' }
          end
        end

        def loans_per_increment(_increment)
          self.class::LOANS_PER_INCREMENT
        end

        def loan_interest_increments
          self.class::LOAN_INTEREST_INCREMENTS
        end

        def min_loan
          self.class::MIN_LOAN
        end

        def max_loan
          self.class::MAX_LOAN
        end

        def init_loans
          total_loans = (min_loan..max_loan).step(loan_interest_increments).sum do |r|
            loans_per_increment(r)
          end

          @loan_value = 100
          Array.new(total_loans) { |id| Loan.new(id, @loan_value) }
        end

        def loan_value(_entity = nil)
          @loan_value
        end

        def cannot_pay_interest_str
          '(Liquidate)'
        end

        def future_interest_rate
          taken = loans_taken
          interest = (min_loan..max_loan).step(loan_interest_increments).find do |r|
            taken -= loans_per_increment(r)
            taken <= 0
          end || 0

          [[min_loan, interest].max, max_loan].min
        end

        def interest_rate
          @interest_fixed || future_interest_rate
        end

        def loans_due_interest(entity)
          entity.loans.size
        end

        def interest_owed_for_loans(loans)
          (interest_rate * loans * @loan_value) / 100
        end

        def interest_owed(entity)
          interest_owed_for_loans(entity.loans.size) + (entity.companies.include?(loan_shark_private) ? 10 : 0)
        end

        def log_interest_payment(entity, amount)
          amount_fmt = format_currency(amount)
          interest_sources = []
          if (loans_due = loans_due_interest(entity)).positive?
            interest_sources << "#{loans_due} loan#{loans_due > 1 ? 's' : ''}"
          end
          interest_sources << 'Loan Shark' if entity.companies.include?(loan_shark_private)
          @log << "#{entity.name} pays #{amount_fmt} interest for #{interest_sources.join(' and ')}"
        end

        def interest_change
          rate = future_interest_rate
          summary = []

          unless rate == min_loan
            loans = loans_taken - (min_loan...rate).step(loan_interest_increments).sum { |r| loans_per_increment(r) }
            s = loans == 1 ? '' : 's'
            summary << ["Interest if #{loans} more loan#{s} repaid", rate - loan_interest_increments]
          end
          loan_table = []
          if loans_taken.zero?
            loan_table << [rate, loans_per_increment(rate)]
            summary << ["Interest if #{loans_per_increment(rate) + 1} more loans taken", 10]
          elsif rate != max_loan
            loans = (min_loan..rate).step(loan_interest_increments).sum { |r| loans_per_increment(r) } - loans_taken
            loan_table << [rate, loans]
            s = loans == 1 ? '' : 's'
            summary << ["Interest if #{loans + 1} more loan#{s} taken", rate + loan_interest_increments]
          end

          (rate + loan_interest_increments..max_loan).step(loan_interest_increments) do |r|
            loan_table << [r, loans_per_increment(r)]
          end
          [summary, loan_table]
        end

        def maximum_loans(entity)
          entity.total_shares
        end

        def bidding_power(player)
          player.cash + player.companies.sum(&:value)
        end

        def operating_order
          super.reject { |c| c.share_price.liquidation? }
        end

        def tile_lays(entity)
          actions = super.map(&:dup)
          if entity.companies.include?(express_track_private) && entity.companies.include?(efficient_track_private)
            actions[1][:cost] = 0
          elsif entity.companies.include?(express_track_private)
            actions[0][:cost] = 10
            actions[1][:cost] = 0
          elsif entity.companies.include?(efficient_track_private)
            actions[1][:cost] = 10
          end
          actions
        end

        def home_token_locations(corporation)
          hexes.select do |hex|
            hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) }
          end
        end

        def redeemable_shares(entity)
          return [] unless entity.corporation?
          return [] unless round.steps.find { |step| step.is_a?(Engine::Step::BuySellParShares) }.active?
          return [] if entity.share_price.acquisition? || entity.share_price.liquidation?

          bundles_for_corporation(share_pool, entity)
            .reject { |bundle| entity.cash < bundle.price }
        end

        def tokens_needed(corporation)
          tokens_needed = { 2 => 1, 5 => 2, 10 => 4 }[corporation.total_shares] - corporation.tokens.size
          tokens_needed += 1 if corporation.companies.any? { |c| c.id == 'TS' }
          tokens_needed
        end

        def size_corporation(corporation, size)
          original_shares = shares_for_corporation(corporation)
          raise GameError, 'Can only convert 2 share corporation' unless corporation.total_shares == 2

          corporation.share_holders.clear

          case size
          when 5
            original_shares[0].percent = 40
            shares = Array.new(3) { |i| Share.new(corporation, percent: 20, index: i + 1) }
          when 10
            original_shares[0].percent = 20
            shares = Array.new(8) { |i| Share.new(corporation, percent: 10, index: i + 1) }
          end

          original_shares.each { |share| corporation.share_holders[share.owner] += share.percent }

          corporation.max_ownership_percent = 60 unless size == 2

          shares.each do |share|
            add_new_share(share)
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
            new_shares = Array.new(3) { |i| Share.new(corporation, percent: 20, index: i + 1) }
          when 5
            shares.each { |share| share.percent = share.percent.positive? ? 10 : -10 }
            shares[0].percent = 20
            new_shares = Array.new(5) { |i| Share.new(corporation, percent: 10, index: i + 4) }
          else
            raise GameError, 'Cannot convert 10 share corporation'
          end

          corporation.max_ownership_percent = 60
          shares.each { |share| corporation.share_holders[share.owner] += share.percent }

          new_shares.each do |share|
            add_new_share(share)
          end
          new_shares
        end

        def available_shorts(corporation)
          return [0, 0] if corporation&.total_shares == 2

          [shorts(corporation).size, corporation.total_shares]
        end

        def shorts(corporation)
          shares = []

          @_shares.each do |_, share|
            shares << share if share.corporation == corporation && share.percent.negative?
          end

          shares
        end

        def entity_shorts(entity, corporation)
          entity.shares_of(corporation).select { |share| share.percent.negative? }
        end

        def close_market_shorts
          @corporations.each do |corporation|
            # Try closing shorts
            count = 0
            while entity_shorts(@share_pool, corporation).any? &&
              (market_shares = @share_pool.shares_of(corporation)
               .select { |share| share.percent.positive? && !share.president }).any?

              unshort(@share_pool, market_shares.first)
              count += 1
            end
            @log << "Market closes #{count} shorts for #{corporation.name}" if count.positive?
          end
        end

        def close_bank_shorts
          # Close out shorts in stock market with the bank buying shares from the treasury
          @corporations.each do |corporation|
            next unless corporation.share_price
            next if corporation.share_price.acquisition? || corporation.share_price.liquidation?

            count = 0
            while entity_shorts(@share_pool, corporation).any? &&
              corporation.shares.any?

              # Market buys the share
              share = corporation.shares.first
              @share_pool.buy_shares(@share_pool, share)

              # Then closes the share
              unshort(@share_pool, share)
              count += 1

            end
            @log << "Market closes #{count} shorts for #{corporation.name}" if count.positive?
          end
        end

        def sell_shares_and_change_price(bundle, allow_president_change: true, swap: nil)
          super
          close_market_shorts
        end

        def migrate_shares(corporation, other)
          # Migrate shares from a 5 & 5 corporation merger
          new_shares = convert(corporation)
          percentage = 10

          shares = @_shares.values.select { |share| share.corporation == other }
          surviving_shares = @_shares.values.select { |share| share.corporation == corporation }
          # Highest share (9 is all the potential 'normal' share certificates)
          highest_share = [surviving_shares.map(&:index).max, 9].max

          shares.each do |share|
            entity = share.owner
            entity = corporation if entity == other
            # convert each 20% in the old company into 10% in the new company
            (share.percent / 20).abs.times do
              if share.percent.positive?
                if new_shares.any?
                  # Use the 'normal' shares where possible until they run out.
                  new_share = new_shares.shift
                  new_share.transfer(entity)
                else
                  highest_share += 1
                  new_share = Share.new(corporation, owner: entity, percent: percentage, index: highest_share)
                  add_new_share(new_share)
                end
              else
                highest_share += 1
                short = Share.new(corporation, owner: entity, percent: -percentage, index: highest_share)
                short.buyable = false
                short.counts_for_limit = false
                add_new_share(short)
              end
            end
          end

          max_shares = corporation.player_share_holders.values.max

          # Check cross-short merge problem
          raise GameError, 'At least one player must have more than 20% to allow a merge' if max_shares < 20

          # Find the new president, tie break is the surviving corporation president
          # This is done before the cancelling to ensure the new president can cancel any shorts
          majority_share_holders = corporation
            .player_share_holders
            .select { |_, p| p == max_shares }
            .keys

          previous_president = corporation.owner

          if majority_share_holders.none? { |player| player == previous_president }
            president = majority_share_holders
              .select { |p| p.percent_of(corporation) >= corporation.presidents_percent }
              .min_by { |p| @share_pool.distance(previous_president, p) }

            president_share = previous_president.shares_of(corporation).find(&:president)
            corporation.owner = president
            @log << "#{president.name} becomes the president of #{corporation.name}"
            @share_pool.change_president(president_share, previous_president, president)
          end

          # Consolidate shorts with their share pair (including share pool shares)
          shares_for_corporation(corporation)
            .group_by(&:owner)
            .each do |owner, _shares_|
            shares = owner.shares_of(corporation)
            while shares.any? { |s| s.percent.negative? } && shares.any? { |s| s.percent == percentage }
              share = shares.find { |s| s.percent == percentage }
              unshort(owner, share)
            end
          end
        end

        def add_new_share(share)
          owner = share.owner
          corporation = share.corporation
          corporation.share_holders[owner] += share.percent if owner
          owner.shares_by_corporation[corporation] << share
          @_shares[share.id] = share
        end

        def remove_share(share)
          owner = share.owner
          corporation = share.corporation
          corporation.share_holders[owner] -= share.percent if owner
          owner.shares_by_corporation[corporation].delete(share)
          @_shares.delete(share.id)
        end

        def short(entity, corporation)
          price = corporation.share_price.price
          percent = corporation.share_percent

          shares = shares_for_corporation(corporation)

          # Highest share (9 is all the potential 'normal' share certificates)
          highest_share = [shares.map(&:index).max, 9].max

          share = Share.new(corporation, owner: @share_pool, percent: percent, index: highest_share + 1)
          short = Share.new(corporation, owner: entity, percent: -percent, index: highest_share + 2)
          short.buyable = false
          short.counts_for_limit = false

          @log << "#{entity.name} shorts a #{percent}% " \
                  "share of #{corporation.name} for #{format_currency(price)}"

          @bank.spend(price, entity)
          add_new_share(short)
          add_new_share(share)
        end

        def unshort(entity, share)
          # Share is the positive share bought to cancel the short.
          # The share should be owned by the entity

          shares = entity.shares_of(share.corporation)
          remove_share(share)

          short = shares.find { |s| s.percent == -share.percent }
          remove_share(short)
        end

        def take_loan(entity, _loan)
          raise GameError, "Cannot take more than #{maximum_loans(entity)} loans" unless can_take_loan?(entity)

          taken_loan = @loans.pop
          old_price = entity.share_price
          name = entity.name
          name += " (#{entity.owner.name})" if @round.is_a?(Engine::Round::Stock)
          @log << "#{name} takes a loan and receives #{format_currency(taken_loan.amount)}"
          @bank.spend(taken_loan.amount, entity)
          loan_taken_stock_market_movement(entity)
          log_share_price(entity, old_price)
          entity.loans << taken_loan
        end

        def loan_taken_stock_market_movement(entity)
          @stock_market.move_left(entity)
        end

        def payoff_loan(entity, _loan, adjust_share_price: true)
          raise GameError, "#{entity.name} does not have any loans" unless entity.loans.size.positive?

          paid_loan = entity.loans.pop
          amount = paid_loan.amount
          @log << "#{entity.name} pays off a loan for #{format_currency(amount)}"
          entity.spend(amount, @bank)

          @loans << paid_loan
          return unless adjust_share_price

          old_price = entity.share_price
          loan_payoff_stock_market_movement(entity)
          log_share_price(entity, old_price)
        end

        def loan_payoff_stock_market_movement(entity)
          @stock_market.move_right(entity)
        end

        def can_take_loan?(entity)
          entity.corporation? &&
            entity.loans.size < maximum_loans(entity) &&
            !@loans.empty?
        end

        def float_str(_entity)
          '2 shares to start'
        end

        def available_loans(entity, extra_loans)
          [maximum_loans(entity) - entity.loans.size, @loans.size + extra_loans].min
        end

        def buying_power(entity, extra_loans: 0, **)
          return entity.cash unless entity.corporation?

          entity.cash + (available_loans(entity, extra_loans) * @loan_value)
        end

        def unstarted_corporation_summary
          [(@corporations.count { |c| !c.ipoed }).to_s, []]
        end

        def liquidate!(corporation)
          return if corporation.owner == @share_pool

          @owner_when_liquidated[corporation] = corporation.owner
          @stock_market.move(corporation, [0, 0], force: true)
        end

        def train_help(_entity, _runnable_trains, routes)
          all_hexes = {}
          @companies.each do |company|
            abilities(company, :assign_hexes)&.hexes&.each do |hex|
              all_hexes[hex] = company
            end
          end
          warnings = []
          unless hexes.empty?

            routes.each do |route|
              route.stops.each do |stop|
                if (company = all_hexes[stop.hex.id])
                  warnings << "Using #{company.name} on #{stop.hex.id} will improve revenue"
                end
              end
            end
          end

          warnings
        end

        def pullman_train?(_train)
          false
        end

        def revenue_for(route, stops)
          revenue = super

          revenue += 10 * stops.count { |stop| stop.hex.assigned?('bridge') }

          raise GameError, 'Route visits same hex twice' if route.hexes.size != route.hexes.uniq.size

          mine = 'mine'
          if route.hexes.first.assigned?(mine) || route.hexes.last.assigned?(mine)
            raise GameError, 'Route cannot start or end with a mine'
          end

          ranch = 'ranch'
          if route.hexes.first.assigned?(ranch) || route.hexes.last.assigned?(ranch)
            raise GameError, 'Route cannot start or end with a ranch'
          end

          if option_modern_trains? && [7, 8].include?(route.train.distance)
            per_token = route.train.distance == 7 ? 10 : 20
            revenue += stops.sum do |stop|
              next per_token if stop.city? && stop.tokened_by?(route.train.owner)

              0
            end
          end

          revenue += 10 * route.all_hexes.count { |hex| hex.assigned?(mine) }
          revenue += 10 * route.all_hexes.count { |hex| hex.assigned?(ranch) }
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

        def corporation_size_name(entity)
          entity.total_shares.to_s
        end

        def empty_auction_slot
          @empty_auction_slot ||= Engine::Company.new(sym: '', name: '', value: nil, revenue: nil, desc: '', color: 'LightGrey')
        end

        def company_header(company)
          return 'EMPTY SLOT' if company == empty_auction_slot

          super
        end

        def mine_company?(company)
          self.class::MINE_COMPANIES.include?(company.id)
        end

        def ranch_company?(company)
          self.class::RANCH_COMPANIES.include?(company.id)
        end

        def b_city_tile?(tile)
          tile.label&.to_s == 'B'
        end

        def rust(train)
          owner = train.owner
          super
          return unless owner&.corporation?

          abilities(owner, :train_scrapper) do |a|
            if (scrap_value = a.scrap_value(train)).positive?
              @log << "#{owner.name} collects #{format_currency(scrap_value)} from #{a.owner.name} for #{train.name}"
              @bank.spend(scrap_value, owner)
            end
          end
        end

        def remove_train(train)
          inventor_payout(train)
          super
        end

        def loan_shark_private
          return unless option_volatility_expansion?

          @loan_share_private ||= company_by_id('P12')
        end

        def ponzi_scheme_private
          return unless option_volatility_expansion?

          @ponzi_scheme_private ||= company_by_id('P13')
        end

        def inventor_private
          return unless option_volatility_expansion?

          @inventor_private ||= company_by_id('P14')
        end

        def express_track_private
          return unless option_volatility_expansion?

          @express_track_private ||= company_by_id('P18')
        end

        def efficient_track_private
          return unless option_volatility_expansion?

          @efficient_track_private ||= company_by_id('P19')
        end

        def golden_parachute_private
          return unless option_volatility_expansion?

          @golden_parachute_private ||= company_by_id('P20')
        end

        def station_subsidy_private
          return unless option_volatility_expansion?

          @station_subsidy_private ||= company_by_id('P21')
        end

        def inventor_payout(train)
          return unless inventor_private&.owner&.corporation?

          @payouts ||= { '2' => 20, '3' => 30, '4' => 40, '5' => 50, '6' => 60, '7' => 70, '8' => 80 }
          return unless (payout = @payouts.delete(train.name))

          @log << "#{inventor_private.owner.name} collects #{format_currency(payout)} from #{inventor_private.name}"
          @bank.spend(payout, inventor_private.owner)
        end

        private

        def new_auction_round
          if !@round && !option_volatility_expansion?
            log << "Seed Money for initial auction is #{format_currency(self.class::SEED_MONEY)}"
          end
          Engine::Round::Auction.new(self, [
            G1817::Step::SelectionAuction,
          ])
        end

        def stock_round
          close_bank_shorts
          @interest_fixed = nil

          G1817::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::HomeToken,
            G1817::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          @interest_fixed = nil
          @interest_fixed = interest_rate
          # Revaluate if private companies are owned by corps with trains
          @companies.each do |company|
            next unless company.owner

            abilities(company, :revenue_change, time: 'has_train') do |ability|
              company.revenue = company.owner.trains.any? ? ability.revenue : 0
            end
          end

          G1817::Round::Operating.new(self, [
            G1817::Step::Bankrupt,
            G1817::Step::CashCrisis,
            G1817::Step::Loan,
            G1817::Step::SpecialTrack,
            G1817::Step::Assign,
            G1817::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G1817::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1817::Step::BuyTrain,
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
          clear_interest_paid
          @round =
            case @round
            when Engine::Round::Stock
              @operating_rounds = @final_operating_rounds || @phase.operating_rounds
              reorder_players
              new_operating_round
            when Engine::Round::Operating
              or_round_finished
              # Store the share price of each corp to determine if they can be acted upon in the AR
              @stock_prices_start_merger = @corporations.to_h { |corp| [corp, corp.share_price] }
              @log << "-- #{round_description('Merger and Conversion', @round.round_num)} --"
              G1817::Round::Merger.new(self, [
                Engine::Step::ReduceTokens,
                Engine::Step::DiscardTrain,
                G1817::Step::PostConversion,
                G1817::Step::PostConversionLoans,
                G1817::Step::Conversion,
              ], round_num: @round.round_num)
            when G1817::Round::Merger
              @log << "-- #{round_description('Acquisition', @round.round_num)} --"
              G1817::Round::Acquisition.new(self, [
                Engine::Step::ReduceTokens,
                G1817::Step::Bankrupt,
                G1817::Step::CashCrisis,
                Engine::Step::DiscardTrain,
                G1817::Step::Acquire,
              ], round_num: @round.round_num)
            when G1817::Round::Acquisition
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

        def round_end
          G1817::Round::Acquisition
        end

        def final_operating_rounds
          @final_operating_rounds || super
        end

        def event_signal_end_game!
          # If we're in round 1, we have another set of ORs with 2 ORs
          # If we're in round 2, we have another set of ORs with 3 ORs
          @final_operating_rounds = @round.round_num == 2 ? 3 : 2
          game_end_check
          @log << "First 8 train bought/exported, ending game at the end of #{@turn + 1}.#{@final_operating_rounds}"
        end
      end
    end
  end
end
