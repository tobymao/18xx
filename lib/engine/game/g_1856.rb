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
      attr_reader :post_nationalization, :bankrupted
      DEV_STAGE = :prealpha

      # These plain city hexes upgrade to L tiles in brown
      LAKE_HEXES = %w[B19 C14 F17 O18 P9 N3 L13].freeze
      BROWN_OO_TILES = %w[64 65 66 67 68].freeze
      PORT_HEXES = %w[C14 D19 E18 F17 F9 H17 H7 H5 J17 J5 K2 M18 O18].freeze

      # These cities upgrade to the common BarrieLondon green tile,
      #  but upgrade to specialized brown tiles
      BARRIE_HEX = 'M4'
      LONDON_HEX = 'F15'
      HAMILTON_HEX = 'L15'

      # This is unlimited in 1891
      # They're also 5% shares if there are more than 20 shares. It's weird.
      NATIONAL_MAX_SHARE_PERCENT_AWARDED = 200

      SELL_MOVEMENT = :down_per_10

      GAME_LOCATION = 'Ontario, Canada'
      GAME_RULES_URL = 'http://google.com'
      GAME_DESIGNER = 'Bill Dixon'
      GAME_INFO_URL = 'https://google.com'

      HOME_TOKEN_TIMING = :operating_round

      RIGHT_COST = 50

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

      EVENTS_TEXT = Base::EVENTS_TEXT.merge('remove_tokens' => ['Remove Port token']).freeze

      def national
        @national ||= corporation_by_id('CGR')
      end

      def gray_phase?
        @phase.tiles.include?('gray')
      end

      def revenue_for(route, stops)
        revenue = super

        revenue += 20 if route.corporation.assigned?(port.id) && stops.any? { |stop| stop.hex.assigned?(port.id) }

        route.corporation.companies.each do |company|
          abilities(company, :hex_bonus) do |ability|
            revenue += stops.map { |s| s.hex.id }.uniq.sum { |id| ability.hexes.include?(id) ? ability.amount : 0 }
          end
        end

        revenue
      end

      def port
        @port ||= company_by_id('GLSC')
      end

      def tunnel
        @tunnel ||= company_by_id('SCFTC')
      end

      def bridge
        @bridge ||= company_by_id('NFSBC')
      end

      def maximum_loans(entity)
        entity.num_player_shares
      end

      def loan_value
        100
      end

      def interest_rate
        10
      end

      def national_token_price
        100
      end

      def national_token_limit
        10
      end

      def interest_owed_for_loans(loans)
        interest_rate * loans
      end

      def interest_owed(entity)
        interest_owed_for_loans(entity.loans.size)
      end

      def take_loan(entity, loan)
        raise GameError, 'Cannot take loan' unless can_take_loan?(entity)

        name = entity.name
        loan_amount = @round.paid_interest[entity] ? loan_value - interest_rate : loan_value
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

      def num_loans
        # @corporations is not available at the time of init_loans
        110
      end

      def init_loans
        num_loans.times.map { |id| Loan.new(id, loan_value) }
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

        @pre_national_percent_by_player = {}
        @pre_national_market_percent = 0

        @pre_national_market_prices = {}
        @nationalized_corps = []

        @bankrupted = false

        # Is the president of the national a "false" president?
        # A false president gets the presidency with only one share; in this case the president gets
        # the full president's certificate but is obligated to buy up to the full presidency in the
        # following SR unless a different player becomes rightfully president during share exchange
        # It is impossible for someone who didn't become president in
        # exchange (1 share tops) to steal the presidency in the SR because
        # they'd have to buy 2 shares in one action which is a no-no
        # nil: Presidency not awarded yet at all
        # true: 1-share false presidency has been awarded
        # false: 2-share true presidency has been awarded
        @false_national_president = nil

        # 1 of each right is reserved w/ the private when it gets bought in. This leaves 2 extra to sell.
        @available_bridge_tokens = 2
        @available_tunnel_tokens = 2
      end

      def num_corporations
        # Before nationalization, the national is in @corporations but doesn't count
        # After nationalization, if the national is in corporations it does count
        @post_nationalization ? @corporations.size : @corporations.size - 1
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

      def can_par?(corporation, parrer)
        corporation == national ? national.ipoed : super
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

      def operating_order
        @corporations.select { |c| c.floated? || c.floatable? }.sort
      end

      def release_escrow!(corporation)
        @log << "Releasing #{format_currency(corporation.escrow)} from escrow for #{corporation.name}"
        corporation.cash += corporation.escrow
        corporation.escrow = nil
        corporation.capitalization = :incremental
      end

      def can_buy_tunnel_token?(entity)
        return false unless entity.corporation?
        return false if tunnel.owned_by_player?

        @available_tunnel_tokens.positive? && !tunnel?(entity) && buying_power(entity) >= RIGHT_COST
      end

      def can_buy_bridge_token?(entity)
        return false unless entity.corporation?
        return false if bridge.owned_by_player?

        @available_bridge_tokens.positive? && !bridge?(entity) && buying_power(entity) >= RIGHT_COST
      end

      def buy_tunnel_token(entity)
        seller = tunnel.closed? ? @bank : tunnel.owner
        seller_name = tunnel.closed? ? 'the bank' : tunnel.owner.name
        @log << "#{entity.name} buys a tunnel token from #{seller_name} for #{format_currency(RIGHT_COST)}"
        entity.spend(RIGHT_COST, seller)
        @available_tunnel_tokens -= 1
        grant_right(entity, :tunnel)
      end

      def buy_bridge_token(entity)
        seller = bridge.closed? ? @bank : bridge.owner
        seller_name = bridge.closed? ? 'the bank' : bridge.owner.name
        @log << "#{entity.name} buys a bridge token from #{seller_name} for #{format_currency(RIGHT_COST)}"
        entity.spend(RIGHT_COST, seller)
        @available_bridge_tokens -= 1
        grant_right(entity, :bridge)
      end

      def tunnel?(corporation)
        # abilities will return an array if many or an Ability if one. [*foo(bar)] gets around that
        corporation.all_abilities.any? { |ability| ability.type == :hex_bonus && ability.hexes.include?('B13') }
      end

      def bridge?(corporation)
        # abilities will return an array if many or an Ability if one. [*foo(bar)] gets around that
        corporation.all_abilities.any? { |ability| ability.type == :hex_bonus && ability.hexes.include?('P17') }
      end

      def grant_right(corporation, type)
        corporation.add_ability(Engine::Ability::HexBonus.new(
          type: :hex_bonus,
          description: "+10 bonus when running to #{type == :tunnel ? 'Sarnia' : 'Buffalo'}",
          hexes: type == :tunnel ? %w[B13] : %w[P17 P19],
          amount: 10,
          owner_type: :corporation
        ))
      end

      def event_close_companies!
        # The tokens reserved for the company's buyer are sent to the bank if closed before being bought in
        @available_bridge_tokens += 1 if bridge.owned_by_player?
        @available_tunnel_tokens += 1 if tunnel.owned_by_player?
        super
      end

      def company_bought(company, entity)
        grant_right(entity, :bridge) if company == bridge
        grant_right(entity, :tunnel) if company == tunnel
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
          Step::G1856::Assign,
          Step::G1856::Loan,
          Step::SpecialTrack,
          Step::BuyCompany,
          Step::HomeToken,

          # Nationalization!!
          Step::G1856::NationalizationPayoff,
          Step::G1856::SpecialBuy,
          Step::G1856::Track,
          Step::Token,
          Step::Route,
          # Interest - See Loan
          Step::G1856::Dividend,
          Step::DiscardTrain,
          Step::BuyTrain,
          # Repay Loans - See Loan
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def stock_round
        Round::G1856::Stock.new(self, [
          Step::DiscardTrain,
          Step::Exchange,
          Step::SpecialTrack,
          Step::G1856::BuySellParShares,
        ])
      end

      def event_remove_tokens!
        removals = Hash.new { |h, k| h[k] = {} }

        @corporations.each do |corp|
          corp.assignments.dup.each do |company, _|
            removals[company][:corporation] = corp.name
            corp.remove_assignment!(company)
          end
        end

        @hexes.each do |hex|
          hex.assignments.dup.each do |company, _|
            removals[company][:hex] = hex.name
            hex.remove_assignment!(company)
          end
        end

        self.class::PORT_HEXES.each do |hex|
          hex_by_id(hex).tile.icons.reject! do |icon|
            %w[port].include?(icon.name)
          end
        end

        removals.each do |company, removal|
          hex = removal[:hex]
          corp = removal[:corporation]
          @log << "-- Event: #{corp}'s #{company_by_id(company).name} token removed from #{hex} --"
        end
      end

      # Nationalization Methods

      def event_nationalization!
        @nationalization_trigger ||= @round.active_step.current_entity.owner
        @log << '-- Event: CGR merger --'
        corporations_repay_loans
        @nationalizables = nationalizable_corporations
        @log << "Merge candidates: #{present_nationalizables(nationalizables)}" if nationalizables.any?
        # starting with the player who bought the 6 train, go around the table repaying loans

        # player picks order of their companies.
        # set aside compnanies that do not repay succesfully

        # starting with the player who bought the 6 train, go around the table trading shares
        # trade all shares
      end

      def nationalizables
        @nationalizables ||= []
      end

      def max_national_shares
        20
      end

      def corporations_repay_loans
        @corporations.each do |corp|
          next unless corp.floated? && corp.loans.size.positive?

          loans_repaid = [corp.loans.size, (corp.cash / loan_value).to_i].min
          amount_repaid = loan_value * loans_repaid
          next unless amount_repaid.positive?

          corp.spend(amount_repaid, @bank)
          @loans << corp.loans.pop(loans_repaid)
          @log << "#{corp.name} repays #{format_currency(amount_repaid)} to redeem #{loans_repaid} loans"
        end
      end

      def merge_major(major)
        @national_formed = true
        @log << "-- #{major.name} merges into #{national.name} --"
        # Trains are transferred
        major.trains.dup.each do |t|
          buy_train(national, t, :free)
        end
        # Leftover cash is transferred
        major.spend(major.cash, national) if major.cash.positive?

        # Tunnel / Bridge rights are transferred
        if tunnel?(major)
          if tunnel?(national)
            @log << "#{national.name} already has a tunnel token, the token is returned to the bank pool"
            @available_tunnel_tokens += 1
          else
            @log << "#{national.name} gets #{major.name}'s tunnel token"
            grant_right(national, :tunnel)
          end
        end
        if bridge?(major)
          if bridge?(national)
            @log << "#{national.name} already has a bridge token, the token is returned to the bank pool"
            @available_bridge_tokens += 1
          else
            @log << "#{national.name} gets #{major.name}'s bridge token"
            grant_right(national, :bridge)
          end
        end

        # Tokens:
        # Remove reservations

        hexes.each do |hex|
          hex.tile.cities.each do |city|
            if city.tokened_by?(major)
              city.tokens.map! { |token| token&.corporation == major ? nil : token }
              city.reservations.delete(major)
            end
          end
        end

        # Shares
        merge_major_shares(major)
        @pre_national_market_prices[major.name] = major.share_price.price
        @nationalized_corps << major
        # Corporation will close soon, but not now. See post_corp_nationalization
        nationalizables.delete(major)
        post_corp_nationalization
      end

      def merge_major_shares(major)
        major.player_share_holders.each do |player, num|
          @pre_national_percent_by_player[player] ||= 0
          @pre_national_percent_by_player[player] += num
        end
        @pre_national_market_percent += major.num_market_shares * 10
      end

      # Issue more shares
      # Must be called while shares are still all in the IPO.
      def national_issue_shares!
        return unless national.total_shares == 10

        @log << "#{national.name} issues 10 more shares and all shares are now 5% shares"
        national.shares_by_corporation[national].each_with_index do |share, index|
          # Presidents cert is a 10% 2-share 1-cert paper, everything else is a 5% 1-share 0.5-cert paper
          share.percent = index.zero? ? 10 : 5
          share.cert_size = index.zero? ? 1 : 0.5
        end

        num_shares = national.total_shares
        10.times do |i|
          new_share = Share.new(national, percent: 5, index: num_shares + i, cert_size: 0.5)
          national.shares_by_corporation[national] << new_share
        end
      end

      def calculate_national_price
        prices = @pre_national_market_prices.values
        # If more than two companies merging in drop the lowest share price
        prices.delete_at(prices.index(prices.min)) if prices.size > 2

        # Average the values of the companies and round *down* to the nearest $5 increment
        ave = (0.2 * prices.sum / prices.size).to_i * 5

        # The value is 100 at the bare minimum
        # Also the stock market increases as such:
        # 90 > 100 > 110 > 125 > 150
        market_price = if ave < 105
                         100
                       # The next share value is 110
                       elsif ave <= 115
                         110
                       # everything else is multiples of 25
                       else
                         delta = ave % 25
                         delta < 12.5 ? ave - delta : ave - delta + 25
                       end

        # The stock market token is placed on the top row
        @stock_market.market[0].find { |p| p.price == market_price }
      end

      def float_str(entity)
        return 'Floats in phase 6' if entity == national

        super
      end

      def float_national
        national.float!
        @stock_market.set_par(national, calculate_national_price)
        national.ipoed = true
      end

      # Handles the share exchange in nationalization
      # Returns the president Player
      def national_share_swap
        index_for_trigger = @players.index(@nationalization_trigger)
        # This is based off the code in 18MEX; 10 appears to be an arbitrarily large integer
        #  where the exact value doesn't really matter
        players_in_order = (0..@players.count - 1).to_a.sort { |i| i < index_for_trigger ? i + 10 : i }
        # Determine the president before exchanging shares for ease of distribution
        shares_left_to_distribute = max_national_shares
        president_shares = 0
        president = nil
        players_in_order.each do |i|
          player = @players[i]
          next unless @pre_national_percent_by_player[player]

          shares_awarded = [(@pre_national_percent_by_player[player] / 20).to_i, shares_left_to_distribute].min
          # Single shares that are discarded to the market
          @pre_national_market_percent += @pre_national_percent_by_player[player] % 20
          shares_left_to_distribute -= shares_awarded
          @log << "#{player.name} gets #{shares_awarded} shares of #{national.name}"

          next unless shares_awarded > president_shares

          @log << "#{player.name} becomes president of the #{national.name}"
          if shares_awarded == 1
            @log << "#{player.name} will need to buy the 2nd share of the #{national.name} "\
              "president's cert in the next SR unless a new president is found"
            @false_national_president = true
          elsif @false_national_president
            @log << "Since #{president.name} is no longer president of the #{national.name} "\
              ' and is no longer obligated to buy a second share in the following SR'
            @false_national_president = false
          end
          president_shares = shares_awarded
          president = player
        end
        # Determine how many market shares need to be issued; this may trigger a second issue of national shares
        national_market_share_count = [(@pre_national_market_percent / 20).to_i, shares_left_to_distribute].min
        shares_left_to_distribute -= national_market_share_count
        # More than 10 shares were issued so issue the second set
        national_issue_shares! if shares_left_to_distribute < 10
        national_share_index = 1
        players_in_order.each do |i|
          player = @players[i]
          player_national_shares = (@pre_national_percent_by_player[player] / 20).to_i
          # We will distribute shares from the national starting with the second, skipping the presidency
          next unless player_national_shares.positive?

          if player == president
            if @false_national_president
              # TODO: Handle this case properly.
              @log << "#{player.name} is the president of the #{national.name} but is only awarded 1 share}"
              national.presidents_share.percent /= 2
              @share_pool.buy_shares(player, national.presidents_share, exchange: :free, exchange_price: 0)
              player_national_shares -= 1
            else # This player gets the presidency, which is 2 shares
              @share_pool.buy_shares(player, national.presidents_share, exchange: :free, exchange_price: 0)
              player_national_shares -= 2
            end
          end
          # not president, just give them shares
          while player_national_shares.positive?
            if national_share_index == max_national_shares
              @log << "#{national.name} is out of shares to issue, #{player.name} gets no more shares"
              player_national_shares = 0
            else
              @share_pool.buy_shares(
                player,
                national.shares_by_corporation[national].last,
                exchange: :free,
                exchange_price: 0
              )
              player_national_shares -= 1
              national_share_index += 1
            end
          end
        end
        # Distribute market shares to the market
        @share_pool.buy_shares(
          @share_pool,
          ShareBundle.new(national.shares_by_corporation[national][-1 * national_market_share_count..-1]),
          exchange: :free
        )
      end

      def national_token_swap
        # Token swap
        # The CGR has ten station markers. Up to ten station markers of the absorbed companies are exchanged for CGR
        # tokens. All home station markers must be replaced first. Then the other station markers are replaced in
        # whatever order the president chooses. Because the CGR cannot have two or more station markers on the same
        # tile, the president of the CGR may choose which one to use, except that exchanging a company's home station
        # marker must take precedence. All station markers that can be legally exchanged must be, even if the president
        # would rather not do so. Further station markers may be placed during operating rounds at a cost of $100 each.

        # Homes first, those are mandatory
        # The case where all 11 corporations are nationalized is undefined behavior in the rules;
        #  The national only has 10 tokens but home tokens are mandatory. This is exceedingly bad play
        #  so it shouldn't ever happen..
        home_bases = @nationalized_corps.map do |c|
          nationalize_home_token(c, create_national_token)
        end
        # So the national will get 11 tokens if and only if all 11 majors merge in
        remaining_tokens = [national_token_limit - home_bases.size, 0].max

        # Other tokens second, ignoring duplicates from the home token set
        @nationalized_corps.each do |corp|
          corp.tokens.each do |token|
            next if !token.city || home_bases.include?(token.city.hex)

            remove_duplicate_tokens(corp)
            replace_token(corp, token, create_national_token)
          end
        end

        # Then reduce down to limit
        # TODO: Possibly override ReduceTokens?
        if national.tokens.size > national_token_limit
          @log << "#{national.name} will is above token limit and must decide which tokens to remove"
          # TODO: implement this case, maybe use a varaiation of the below?
          # @round.corporations_removing_tokens = [buyer, acquired_corp]
        end

        @log << "#{national.name} has #{remaining_tokens} spare #{format_currency(national_token_price)} tokens"
        remaining_tokens.times { national.tokens << Engine::Token.new(@national, price: national_token_price) }
      end

      def declare_bankrupt(player)
        @bankrupted = true
        super
      end

      # Called regardless of if president saved or merged corp
      def post_corp_nationalization
        return unless nationalizables.empty?

        unless @national_formed
          @log << "#{national.name} does not form"
          national.close!
          return
        end
        float_national
        national_share_swap
        # Now that shares and president are determined, it's time to do presidential things
        national_token_swap
        # Close corporations now that trains, cash, rights, and tokens have been stripped
        @nationalized_corps.each do |c|
          close_corporation(c)
          # close_corporation does not close the corp from continuing acting in the round so we need close!
          c.close!
        end

        # Reduce the nationals train holding limit to the real value
        # (It was artificially high to avoid forced discard triggering early)
        # TODO: Do it.
        @post_nationalization = true
      end

      # Creates and returns a token for the national
      def create_national_token
        token = Engine::Token.new(national, price: national_token_price)
        national.tokens << token
        token
      end

      def remove_duplicate_tokens(corp)
        # If there are 2 station markers on the same city the
        # surviving company must remove one and place it on its charter.
        # In the case of OO and Toronto tiles this is ambigious and must be solved by the user

        cities = Array(corp).flat_map(&:tokens).map(&:city).compact
        @national.tokens.each do |token|
          city = token.city
          token.remove! if cities.include?(city)
        end
      end

      # Convert the home token of the corporation to one of the national's
      # Return the nationalized corps home hex
      def nationalize_home_token(corp, token)
        unless token
          # Why would this ever happen?
          @log << "#{national.name} is out of tokens and does not get a token for #{corp.name}'s home"
          return
        end
        # A nationalized corporation needs to have a loan which means it needs to have operated so it must have a home
        home_token = corp.tokens.first
        home_hex = home_token.city.hex

        replace_token(corp, home_token, token)
        home_hex
      end

      def replace_token(major, major_token, token)
        city = major_token.city
        @log << "#{major.name}'s token in #{city.hex.name} is replaced with a #{national.name} token"
        major_token.remove!
        city.place_token(national, token, check_tokenable: false)
      end

      def nationalizable_corporations
        floated_player_corps = @corporations.select { |c| c.floated? && c != national }
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
        nationalizables.map do |c|
          "#{c.name} (#{c.player.name})"
        end.join(', ')
      end

      def nationalization_president_payoff(major, owed)
        major.spend(major.cash, @bank)
        major.owner.spend(owed, @bank)
        @loans << major.loans.pop(major.loans.size)
        @log << "#{major.name} spends the remainder of its cash towards repaying loans"
        @log << "#{major.owner.name} pays off the #{format_currency(owed)} debt for #{major.name}"
        nationalizables.delete(major)
        post_corp_nationalization
      end
    end
  end
end
