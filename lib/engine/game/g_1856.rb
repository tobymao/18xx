# frozen_string_literal: true

require_relative '../config/game/g_1856'
require_relative '../loan.rb'
require_relative '../g_1856/corporation'
require_relative '../g_1856/share_pool'
require_relative 'base'

module Engine
  module Game
    class G1856 < Base
      register_colors(black: '#37383a',
                      orange: '#f48221',
                      brightGreen: '#76a042',

                      bbgPink: '#ffd9eb',
                      caRed: '#f72d2d',
                      cprPink: '#c474bc',
                      cvPurple: '#2d0047',
                      cgrBlack: '#000',
                      lpsBlue: '#c3deeb',
                      gtGreen: '#78c292',
                      gwGray: '#6e6966',
                      tgbOrange: '#c94d00',
                      thbYellow: '#ebff45',
                      wgbBlue: '#494d99',
                      wrBrown: '#54230e',

                      red: '#d81e3e',
                      turquoise: '#00a993',
                      blue: '#0189d1',
                      brown: '#7b352a')

      load_from_json(Config::Game::G1856::JSON)
      attr_reader :loan_value, :post_nationalization
      DEV_STAGE = :prealpha

      # These plain city hexes upgrade to L tiles in brown
      LAKE_HEXES = %w[B19 C14 F17 O18 P9 N3 L13].freeze
      BROWN_OO_TILES = %w[64 65 66 67 68].freeze

      # These cities upgrade to the common BarrieLondon green tile,
      #  but upgrade to specialized brown tiles
      BARRIE_HEX = 'M4'
      LONDON_HEX = 'F15'
      HAMILTON_HEX = 'L15'

      # This is unlimited in 1891
      # They're also 5% shares if there are more than 20 shares. It's weird.
      NATIONAL_MAX_SHARE_PERCENT_AWARDED = 200

      GAME_LOCATION = 'Ontario, Canada'
      GAME_RULES_URL = 'http://google.com'
      GAME_DESIGNER = 'Bill Dixon'
      GAME_INFO_URL = 'https://google.com'

      HOME_TOKEN_TIMING = :operating_round

      PRE_NATIONALIZATION_CERT_LIMIT = { 3 => 20, 4 => 16, 5 => 13, 6 => 11 }.freeze
      POST_NATIONALIZATION_CERT_LIMIT = {
        11 => { 3 => 28, 4 => 22, 5 => 18, 6 => 15 },
        10 => { 3 => 25, 4 => 20, 5 => 16, 6 => 14 },
        9 => { 3 => 22, 4 => 18, 5 => 15, 6 => 12 },
        8 => { 3 => 20, 4 => 16, 5 => 13, 6 => 11 },
        7 => { 3 => 18, 4 => 14, 5 => 11, 6 => 10 },
        6 => { 3 => 15, 4 => 12, 5 => 10, 6 => 8 },
        5 => { 3 => 13, 4 => 10, 5 => 8, 6 => 7 },
        4 => { 3 => 10, 4 => 8, 5 => 7, 6 => 6 },
        3 => { 3 => 10, 4 => 8, 5 => 7, 6 => 6 },
        2 => { 3 => 10, 4 => 8, 5 => 7, 6 => 6 },
        1 => { 3 => 10, 4 => 8, 5 => 7, 6 => 6 },
      }.freeze

      # TODO: Get a proper token
      ASSIGNMENT_TOKENS = {
        'GLSC' => '/icons/1846/sc_token.svg',
      }.freeze

      def national
        @national ||= corporation_by_id('CGR')
      end

      def gray_phase?
        @phase.tiles.include?('gray')
      end

      def revenue_for(route, stops)
        revenue = super

        revenue += 20 if route.corporation.assigned?(port.id) && stops.any? { |stop| stop.hex.assigned?(port.id) }

        # TODO: Add bridge and tunnel private revenue modifiers

        revenue
      end

      def port
        @port ||= company_by_id('GLSC')
      end

      def maximum_loans(entity)
        entity.num_player_shares
      end

      def interest_rate
        10
      end

      def interest_owed_for_loans(loans)
        interest_rate * loans
      end

      def interest_owed(entity)
        interest_owed_for_loans(entity.loans.size)
      end

      def take_loan(entity, loan)
        game_error('Cannot take loan') unless can_take_loan?(entity)
        name = entity.name
        loan_amount = @round.paid_interest[entity] ? 90 : 100
        @log << "#{name} takes a loan and receives #{format_currency(loan_amount)}"
        @bank.spend(loan_amount, entity)
        entity.loans << loan
        @loans.delete(loan)
      end

      def can_take_loan?(entity)
        entity.corporation? &&
          entity.loans.size < maximum_loans(entity) &&
          !@round.took_loan[entity] &&
          !@round.redeemed_loan[entity] &&
          @loans.any? &&
          !@post_nationalization
      end

      def init_loans
        @loan_value = 100
        110.times.map { |id| Loan.new(id, @loan_value) }
      end

      def can_pay_interest?(_entity, _extra_cash = 0)
        # TODO: A future PR may figure out how to implement buying_power
        #  that accounts for a corporations revenue.
        true
      end

      def init_corporations(stock_market)
        min_price = stock_market.par_prices.map(&:price).min

        self.class::CORPORATIONS.map do |corporation|
          Engine::G1856::Corporation.new(
            self,
            min_price: min_price,
            capitalization: nil,
            **corporation.merge(corporation_opts),
          )
        end
      end

      def setup
        @straight_city ||= @tiles.find { |t| t.name == '57' }
        @sharp_city ||= @tiles.find { |t| t.name == '5' }
        @gentle_city ||= @tiles.find { |t| t.name == '6' }

        @straight_track ||= @tiles.find { |t| t.name == '9' }
        @sharp_track ||= @tiles.find { |t| t.name == '7' }
        @gentle_track ||= @tiles.find { |t| t.name == '8' }

        @x_city ||= @tiles.find { |t| t.name == '14' }
        @k_city ||= @tiles.find { |t| t.name == '15' }

        @brown_london ||= @tiles.find { |t| t.name == '126' }
        @brown_barrie ||= @tiles.find { |t| t.name == '127' }

        @gray_hamilton ||= @tiles.find { |t| t.name == '123' }

        @post_nationalization = false
        @national_formed = false

        # These are already halved to account for the 2 to 1 tradeins, but don't reflect
        #  a 10 v 20 v more share national
        @pre_national_percent_by_player = {}
        @pre_national_market_percent = 0
      end

      def num_corporations
        # TODO: Update this with something more correct once nationalization is implemented
        @corporations.size - 1
      end

      def cert_limit
        return PRE_NATIONALIZATION_CERT_LIMIT[@players.size] unless @post_nationalization

        POST_NATIONALIZATION_CERT_LIMIT[num_corporations][@players.size]
      end

      #
      # Get the currently possible upgrades for a tile
      # from: Tile - Tile to upgrade from
      # to: Tile - Tile to upgrade to
      # special - ???
      def upgrades_to?(from, to, special = false)
        return false if from.name == '470'
        # double dits upgrade to Green cities in gray
        return gray_phase? if to.name == '14' && %w[55 1].include?(from.name)
        return gray_phase? if to.name == '15' && %w[56 2].include?(from.name)

        # yellow dits upgrade to yellow cities in gray
        return gray_phase? if to.name == '5' && from.name == '3'
        return gray_phase? if to.name == '57' && from.name == '4'
        return gray_phase? if to.name == '6' && from.name == '58'

        # yellow dits upgrade to plain track in gray
        return gray_phase? if to.name == '7' && from.name == '3'
        return gray_phase? if to.name == '9' && from.name == '4'
        return gray_phase? if to.name == '8' && from.name == '58'

        # Certain green cities upgrade to other labels
        return to.name == '127' if from.color == :green && from.hex.name == BARRIE_HEX
        return to.name == '126' if from.color == :green && from.hex.name == LONDON_HEX
        # You may lay the brown 5-spoke L if and only if it is laid on a L hex -
        # NOT EVEN IF YOU GREEN A DOUBLE DIT ON A LAKE EDTGE
        return to.name == '125' if from.color == :green && LAKE_HEXES.include?(from.hex.name)
        # The L hexes on the map start as plain yellow cities
        return %w[5 6 57].include?(to.name) if LAKE_HEXES.include?(from.hex.name) && from.color == 'white'
        # B,L to B-L
        return to.name == '121' if from.color == :yellow && [BARRIE_HEX, LONDON_HEX].include?(from.hex.name)
        # Hamilton OO upgrade is yet another case of ignoring labels in upgrades
        return to.name == '123' if from.color == :brown && from.hex.name == HAMILTON_HEX

        super
      end

      #
      # Get all possible upgrades for a tile
      # tile: The tile to be upgraded
      # tile_manifest: true/false Is this being called from the tile manifest screen
      #
      def all_potential_upgrades(tile, tile_manifest: false)
        upgrades = super
        return upgrades unless tile_manifest

        # In phase 6+ single dits may be turned into plain yellow track or yellow cities
        if gray_phase?
          upgrades |= [@straight_city, @straight_track] if tile.name == '4'
          upgrades |= [@gentle_city, @gentle_track] if tile.name == '58'
          upgrades |= [@sharp_city, @sharp_track] if tile.name == '3'
          # furthermore, double dits may be upgraded to green cities, if track can be preserved
          upgrades |= [@x_city] if tile.name == '55'
          upgrades |= [@x_city] if tile.name == '1'
          upgrades |= [@k_city] if tile.name == '56'
          upgrades |= [@k_city] if tile.name == '2'
        end
        upgrades |= [@brown_london] if tile.name == '121'
        upgrades |= [@brown_barrie] if tile.name == '121'
        upgrades |= [@gray_hamilton] if BROWN_OO_TILES.include?(tile.name)
        upgrades
      end

      def can_go_bankrupt?(player, corporation)
        # Corporation is nil in the case of interest / loan bankruptcies
        return liquidity(player, emergency: true).negative? unless corporation

        super
      end

      def float_corporation(corporation)
        corporation.float!
        super
      end

      def init_share_pool
        Engine::G1856::SharePool.new(self)
      end

      # Trying to do {static literal}.merge(super.static_literal) so that the capitalization shows up first.
      STATUS_TEXT = {
        'escrow' => [
          'Escrow Cap',
          'New corporations will be capitalized for the first 5 shares sold.'\
          ' The money for the last 5 shares is held in escrow until'\
          ' the corporation has destinated',
        ],
        'incremental' => [
          'Incremental Cap',
          'New corporations will be capitalized for all 10 shares as they are sold'\
          ' regardless of if a corporation has destinated',
        ],
        'fullcap' => [
          'Full Cap',
          'New corporations will be capitalized for 10 x par price when 60% of the IPO is sold',
        ],
        'facing_2' => [
          '20% to start',
          'An unstarted corporation needs 20% sold from the IPO to start for the first time',
        ],
        'facing_3' => [
          '30% to start',
          'An unstarted corporation needs 30% sold from the IPO to start for the first time',
        ],
        'facing_4' => [
          '40% to start',
          'An unstarted corporation needs 40% sold from the IPO to start for the first time',
        ],
        'facing_5' => [
          '50% to start',
          'An unstarted corporation needs 50% sold from the IPO to start for the first time',
        ],
        'facing_6' => [
          '60% to start',
          'An unstarted corporation needs 60% sold from the IPO to start for the first time',
        ],
      }.merge(Base::STATUS_TEXT)
      def operating_round(round_num)
        Round::G1856::Operating.new(self, [
          Step::G1856::Bankrupt,
          Step::G1856::CashCrisis,
          # No exchanges.
          Step::DiscardTrain,
          Step::G1856::Assign,
          Step::G1856::Loan,
          Step::SpecialTrack,
          Step::BuyCompany,
          Step::HomeToken,

          # Nationalization!!
          Step::G1856::NationalizationPayoff,
          Step::G1856::Track,
          Step::Token,
          Step::Route,
          # Interest - See Loan
          Step::G1856::Dividend,
          Step::G1856::BuyTrain,
          # Repay Loans - See Loan
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def stock_round
        Round::Stock.new(self, [
          Step::DiscardTrain,
          Step::Exchange,
          Step::SpecialTrack,
          Step::G1856::BuySellParShares,
        ])
      end

      # Nationalization Methods

      def event_nationalization!
        @post_nationalization = true
        @log << '-- Event: CGR merger --'
        corporations_repay_loans
        @nationalizables = nationalizable_corporations
        @log << "Merge candidates: #{present_nationalizables(@nationalizables)}" if @nationalizables.any?
        # starting with the player who bought the 6 train, go around the table repaying loans

        # player picks order of their companies.
        # set aside compnanies that do not repay succesfully

        # starting with the player who bought the 6 train, go around the table trading shares
        # trade all shares
      end

      # Raw from 18MEX

      def buy_first_6_train(player)
        @nationalization_trigger ||= player
      end

      def nationalizables
        @nationalizables ||= []
      end

      def corporations_repay_loans
        @corporations.each do |corp|
          next unless corp.floated? && corp.loans.size.positive?

          loans_repaid = [corp.loans.size, (corp.cash / 100).to_i].min
          amount_repaid = 100 * loans_repaid
          next unless amount_repaid.positive?

          corp.spend(amount_repaid, @bank)
          @loans << corp.loans.pop(loans_repaid)
          @log << "#{corp.name} repays #{format_currency(amount_repaid)} to redeem #{loans_repaid} loans"          
        end
      end

      def merge_major(major)
        @national_formed = true
        @log << "-- #{major.name} merges into #{@national.name} --"
        # Trains are transferred
        major.trains.clone.each do |t|
          national.buy_train(t, :free)
        end
        # Leftover cash is transferred
        major.spend(major.cash, national) if major.cash.positive?
        # Tunnel / Bridge rights are transferred
        # TODO: Implement tunnel / bridge rights

        # Tokens:
        # TODO: this should probably be after president is determined.

        # Shares
        merge_major_shares(major)
        major.close!
        @nationalizables.delete(major)
        post_corp_nationalization
      end

      def merge_major_shares(major)
        major.player_share_holders.each do |player, num|
          @pre_national_percent_by_player[player] ||= 0
          @pre_national_percent_by_player[player] += num
        end
        @pre_national_market_percent += (major.num_market_shares * 5)
        if total_national_percent_issued > 10 * @national.shares.count && @national.shares.count == 10
          @national.issue_shares!
        end
      end

      def total_national_percent_issued
        @pre_national_market_percent + @pre_national_percent_by_player.values.sum
      end

      # Called regardless of if president saved or merged corp
      def post_corp_nationalization
        puts 'post', nationalizables
      end

      def nationalizable_corporations
        floated_player_corps = @corporations.select { |c| c.floated? && c != @national }
        floated_player_corps.select! { |c| c.loans.size.positive? }
        # Sort eligible corporations so that they are in player order
        # starting with the player that bought the 6 train
        index_for_trigger = @players.index(@nationalization_trigger)
        # This is based off the code in 18MEX; 10 appears to be an arbitrarily large integer
        #  where the exact value doesn't really matter
        order = Hash[@players.each_with_index.map { |p, i| i < index_for_trigger ? [p, i + 10] : [p, i] }]
        floated_player_corps.sort_by! { |c| [order[c.player], @round.entities.index(c)] }
      end

      def present_nationalizables(nationalizables)
        last = nationalizables.last
        nationalizables.map do |c|
          "#{c.name} (#{c.player.name})"
        end.join(', ')
      end

      def nationalization_president_payoff(major, owed)
        major.owner.spend(owed, @bank)
        @loans << major.loans.pop(major.loans.size)
        @log << "#{major.owner.name} pays off the #{format_currency(owed)} debt for #{major.name}"
        major.issue_shares!
        @nationalizables.delete(major)
        post_corp_nationalization
      end
    end
  end
end
