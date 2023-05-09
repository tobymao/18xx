# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'share_pool'
require_relative '../base'
require_relative '../company_price_50_to_150_percent'
require_relative '../cities_plus_towns_route_distance_str'
module Engine
  module Game
    module G18MEX
      class Game < Game::Base
        include_meta(G18MEX::Meta)
        include CitiesPlusTownsRouteDistanceStr
        include Entities
        include Map

        attr_reader :merged_major

        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = 9000

        CERT_LIMIT = { 3 => 19, 4 => 14, 5 => 11 }.freeze

        STARTING_CASH = { 3 => 625, 4 => 500, 5 => 450 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false
        EBUY_OTHER_VALUE = false

        MARKET = [
          %w[60 65 70 75 80p 90p 100 110 120 130 140 150 165 180 200e],
          %w[55 60 65 70p 75p 80 90 100 110 120 130 140 150 165 180],
          %w[50 55 60p 65 70 75 80 90 100 110 120 130 140 150],
          %w[45 50 55 60 65 70 75 80 90 100 110 120],
          %w[40y 45 50 55 60 65 70 75 80],
          %w[30y 40y 45y 50y 55y],
          %w[20y 30y 40y 45y 50y],
          %w[10y],
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 3,
            tiles: [:yellow],
            status: %w[can_buy_companies_from_other_players
                       limited_train_buy
                       ndm_unavailable],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: 3,
            tiles: %i[yellow green],
            status: %w[can_buy_companies
                       can_buy_companies_from_other_players
                       limited_train_buy
                       ndm_unavailable],
            operating_rounds: 2,
          },
          {
            name: '3½',
            on: "3'",
            train_limit: 3,
            tiles: %i[yellow green],
            status: %w[can_buy_companies
                       can_buy_companies_from_other_players
                       limited_train_buy],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: 2,
            tiles: %i[yellow green],
            status: %w[can_buy_companies can_buy_companies_from_other_players],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '6½',
            on: "6'",
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '4D',
            on: '4D',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 100,
            num: 9,
            rusts_on: '4',
          },
          {
            name: '3',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 180,
            num: 4,
            rusts_on: '6',
            events: [{ 'type' => 'companies_buyable' }],
          },
          {
            name: "3'",
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 180,
            num: 2,
            rusts_on: '6',
            events: [{ 'type' => 'minors_closed' }],
          },
          {
            name: '4',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 300,
            num: 3,
            obsolete_on: "6'",
          },
          {
            name: '5',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 450,
            num: 2,
            events: [{ 'type' => 'close_companies' }, { 'type' => 'ndm_merger' }],
          },
          {
            name: '6',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 600,
            num: 1,
          },
          {
            name: "6'",
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 600,
            num: 1,
          },
          {
            name: '4D',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4, 'multiplier' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 700,
            num: 7,
          },
        ].freeze

        GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_or, bank: :current_or }.freeze

        # Sell of one 5% NdM share wont affect stock price.
        # Actually neither should sell of 2 5% but they will
        # always be sold just one at a time.
        SELL_MOVEMENT = :down_per_10

        TRACK_RESTRICTION = :city_permissive

        OPTION_REMOVE_HEXES = ['I4'].freeze
        OPTION_ADD_HEXES = {
          gray: { ['H3'] => 'city=revenue:30,loc:center;town=revenue:20,loc:3;path=a:5,b:_0;path=a:_0,b:_1;' },
          red: { ['I4'] => 'city=revenue:yellow_30|brown_40;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0' },
        }.freeze

        STANDARD_GREEN_CITY_TILES = %w[14 15 619].freeze
        CURVED_YELLOW_CITY = %w[5 6].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'companies_buyable' => ['Companies become buyable', 'All companies may now be bought in by corporation'],
          'minors_closed' => ['Minors closed',
                              'Minors closed, NdM becomes available for buy & sell during stock round'],
          'ndm_merger' => ['NdM merger', 'Potential NdM merger if NdM has floated']
        ).freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'can_buy_companies_from_other_players' => ['Interplayer Company Buy',
                                                     'Companies can be bought between players']
        ).merge(
          Engine::Step::SingleDepotTrainBuy::STATUS_TEXT
        ).merge(
          'ndm_unavailable' => ['NdM unavailable', 'NdM shares unavailable during stock round'],
        ).freeze

        def baja_variant?
          @baja_variant ||= @optional_rules&.include?(:baja_variant)
        end

        def early_buy_of_kcmo?
          @early_buy_of_kcmo ||= @optional_rules&.include?(:early_buy_of_kcmo)
        end

        def p1_5_company
          @p1_5_company ||= company_by_id('CdB')
        end

        def p2_company
          @p2_company ||= company_by_id('KCMO')
        end

        def a_company
          @a_company ||= company_by_id('A')
        end

        def b_company
          @b_company ||= company_by_id('B')
        end

        def c_company
          @c_company ||= company_by_id('C')
        end

        def ndm
          @ndm_corporation ||= corporation_by_id('NdM')
        end

        def minor_a_reserved_share
          @minor_a_reserved_share ||= ndm.shares[7]
        end

        def minor_b_reserved_share
          @minor_b_reserved_share ||= ndm.shares[8]
        end

        def ndm_merge_share
          @ndm_merge_share ||= ndm.shares.last
        end

        def fcp
          @fcp_corporation ||= corporation_by_id('FCP')
        end

        def tm
          @tm_corporation ||= corporation_by_id('TM')
        end

        def udy
          @udy_corporation ||= corporation_by_id('UdY')
        end

        def minor_c_reserved_share
          @minor_c_reserved_share ||= udy.shares.last
        end

        def minor_a
          @minor_a ||= minor_by_id('A')
        end

        def minor_b
          @minor_b ||= minor_by_id('B')
        end

        def minor_c
          @minor_c ||= minor_by_id('C')
        end

        # Set to 1 if no-one accepts NdM merge
        def cert_limit_adjust
          @cert_limit_adjust ||= 0
        end

        def cert_limit(_player = nil)
          super + cert_limit_adjust
        end

        include CompanyPrice50To150Percent

        def setup
          setup_company_price_50_to_150_percent

          @minors.each do |minor|
            train = @depot.upcoming[0]
            train.buyable = false
            buy_train(minor, train, :free)
            hex = hex_by_id(minor.coordinates)
            hex.tile.cities[0].place_token(minor, minor.next_token, free: true)
          end

          # Needed for special handling of minors in case inital auction not completed
          @stock_round_initiated = false

          @gray_tile ||= @tiles.find { |t| t.name == '455' }
          @green_l_tile ||= @tiles.find { |t| t.name == '475' }

          # The NdM 5% shares are trade-ins, that cannot be bought beforehand
          # And they are not counted towards the cert limit. (Paragraph 3.3b)
          minor_a_reserved_share.buyable = false
          minor_a_reserved_share.counts_for_limit = false
          minor_b_reserved_share.buyable = false
          minor_b_reserved_share.counts_for_limit = false

          # The last UdY 10% share is a trade-in for Minor C. Non-buyable before minor merge.
          minor_c_reserved_share.buyable = false

          # The last NdM 10% share is used for trade-in during NdM merge.
          # Before the NdM merge event it cannot be bought.
          ndm_merge_share.buyable = false

          # Remember the price for the last token; exchange tokens have the same.
          @ndm_exchange_token_price = ndm.tokens.last.price

          # Rest is needed for optional rules

          @recently_floated = []
          change_4t_to_hardrust if @optional_rules&.include?(:hard_rust_t4)
          @minor_close = false

          if early_buy_of_kcmo?
            p2_company.min_price = 1
            p2_company.max_price = p2_company.value
          end
          p1_5_company.max_price = p1_5_company.value if baja_variant?
        end

        def init_companies(_players)
          companies = super
          companies.reject! { |c| c.sym == 'CdB' } unless baja_variant?
          companies
        end

        def optional_hexes
          return self.class::HEXES unless baja_variant?

          new_hexes = {}
          HEXES.keys.each do |color|
            new_map = self.class::HEXES[color].transform_keys do |coords|
              coords - OPTION_REMOVE_HEXES
            end
            OPTION_ADD_HEXES[color]&.each { |coords, tile_str| new_map[coords] = tile_str }
            new_hexes[color] = new_map
          end

          new_hexes
        end

        def init_share_pool
          G18MEX::SharePool.new(self)
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            G18MEX::Step::Assign,
            Engine::Step::SpecialToken,
            G18MEX::Step::BuyCompany,
            Engine::Step::HomeToken,
            G18MEX::Step::Merge,
            G18MEX::Step::SpecialTrack,
            G18MEX::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G18MEX::Step::Dividend,
            Engine::Step::DiscardTrain,
            G18MEX::Step::SingleDepotTrainBuy,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def or_round_finished
          @recently_floated = []
        end

        def new_auction_round
          Round::Auction.new(self, [
            Engine::Step::CompanyPendingPar,
            G18MEX::Step::WaterfallAuction,
          ])
        end

        def stock_round
          Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G18MEX::Step::BuySellParShares,
          ])
        end

        def new_stock_round
          # Needed for special handling of minors in case inital auction not completed
          @stock_round_initiated = true

          # Trigger possible delayed close of minors
          event_minors_closed! if @minor_close

          super
        end

        def ipo_reserved_name(_entity = nil)
          'Trade-in'
        end

        def float_corporation(corporation)
          @recently_floated << corporation

          super
        end

        def num_certs(entity)
          entity.companies.size + entity.shares.count do |s|
            s.corporation.counts_for_limit && s.counts_for_limit && (s.corporation != ndm || s.percent > 5)
          end
        end

        # In case of selling NdM, split 5% share in separate bundle and regular
        # shares in other. This means that each 5% need to be sold separately,
        # one at a time. (Even in the extremly rare case of selling 2 5% this
        # is done in two separate sell to simplify implementation.) Now the extra
        # sell actions does not matter as the stock price are not affect by sell
        # of any 5% shares.
        def bundles_for_corporation(player, corporation)
          return super unless ndm == corporation

          # Handle bundles with half shares and non-half shares separately.
          regular_shares, half_shares = player.shares_of(ndm).partition { |s| s.percent > 5 }

          # Need only one bundle with half shares. Player will have to sell twice if s/he want to sell both.
          # This is to simplify other implementation - only handle sell bundles with one half share.
          half_shares = [half_shares.first] if half_shares.any?

          regular_bundles = super(player, ndm, shares: regular_shares)
          half_bundles = super(player, ndm, shares: half_shares)
          regular_bundles.concat(half_bundles)
        end

        def value_for_sellable(player, corporation)
          max_bundle = all_bundles_for_corporation(player, corporation)
            .select { |bundle| @round.active_step&.can_sell?(player, bundle) }
            .max_by(&:price)
          max_bundle&.price || 0
        end

        def value_for_dumpable(player, corporation)
          max_bundle = all_bundles_for_corporation(player, corporation)
            .select { |bundle| bundle.can_dump?(player) && @share_pool&.fit_in_bank?(bundle) }
            .max_by(&:price)
          max_bundle&.price || 0
        end

        def payout_companies
          super

          return if @stock_round_initiated

          # This is when an initial auction has all passes but not all privates sold.
          # Now any minors bought should run, but having an Operating Round would require
          # a bigger redesign. Instead let us give an expected $30 revenue (50-50) for
          # any floated/bought minors and be done with it...
          default_revenue_minor = 15
          revenue = format_currency(default_revenue_minor)
          @minors.select(&:floated?).each do |minor|
            @bank.spend(default_revenue_minor, minor.owner)
            @bank.spend(default_revenue_minor, minor)
            @log << "Minor #{minor.name} receives #{revenue}, as does its owner #{minor.owner.name}"
          end
        end

        def place_home_token(entity)
          super
          return if entity.minor?

          entity.trains.empty? ? handle_no_mail(entity) : handle_mail(entity)
        end

        def all_corporations
          @minors + @corporations
        end

        def event_companies_buyable!
          setup_company_price_50_to_150_percent
          p1_5_company.max_price = p1_5_company.value if baja_variant?
        end

        def purchasable_companies(entity = nil)
          return [] if entity&.minor?

          return super if @phase.current[:name] != '2' || !(early_buy_of_kcmo? || baja_variant?)

          companies = []
          companies << p2_company if early_buy_of_kcmo?
          companies << p1_5_company if baja_variant?
          companies.select(&:owned_by_player?)
        end

        def event_minors_closed!
          if !@minor_close && @optional_rules&.include?(:delay_minor_close)
            @log << 'Close of minors delayed to next stock round'
            @minor_close = true
            return
          end
          @minor_close = false
          merge_and_close_minor(a_company, minor_a, ndm, minor_a_reserved_share)
          merge_and_close_minor(b_company, minor_b, ndm, minor_b_reserved_share)
          merge_and_close_minor(c_company, minor_c, udy, minor_c_reserved_share)
          remove_ability(ndm, :no_buy)
        end

        def event_ndm_merger!
          @log << "-- Event: #{ndm.name} merger --"
          remove_ability(fcp, :base)
          remove_ability(tm, :base)
          unless ndm.floated?
            @log << "No merge occur as #{ndm.name} has not floated!"
            return merge_major
          end

          @mergeable_candidates = mergeable_corporations
          @log << "Merge candidates: #{present_mergeable_candidates(@mergeable_candidates)}" if @mergeable_candidates.any?
          possible_auto_merge
        end

        def decline_merge(major)
          @log << "#{major.name} declines"
          @mergeable_candidates.delete(major)
          possible_auto_merge
        end

        # Called to perform the merge. If called without any major, this means
        # that there is noone that can or want to merge, which is handled here
        # as well.
        def merge_major(major = nil)
          @mergeable_candidates = []

          # Make reserved share available
          ndm_merge_share.buyable = true

          unless major
            # Rule 5i: no merge? increase cert limit, and remove extra tokens from NdM
            @log << "-- #{ndm.name} does not merge - certificate limit increases by one --"
            @cert_limit_adjust += 1
            return
          end

          @merged_major = major
          @log << "-- #{major.name} merges into #{ndm.name} --"

          # Rule 5e: Any other shares are sold off for half market price
          refund = major.ipoed ? (major.share_price.price / 2.0) : 0
          @players.each do |p|
            refund_amount = 0.0
            p.shares_of(major).dup.each do |s|
              next unless s

              if s.president
                # Rule 5d: Give owner of presidency share (if any) the reserved share
                # Might trigger presidency change in NdM
                @share_pool.buy_shares(major.owner, ndm_merge_share, exchange: :free, exchange_price: 0)
              else
                # Refund 10% share (as it is never NdM)
                refund_amount += refund
              end
              s.transfer(major)
            end
            # Transfer bank pool shares to IPO
            @share_pool.shares_of(major).dup.each do |s|
              s.transfer(major)
            end
            next unless refund_amount.positive?

            refund_amount = refund_amount.ceil
            @bank.spend(refund_amount, p)
            @log << "#{p.name} receives #{format_currency(refund_amount)} in share compensation"
          end

          # Rule 5f: Handle tokens. NdM gets two exchange tokens. The first exchange token will be used
          # to replace the home token, even if merged company isn't floated. This placement is free.
          # Note! If NdM already have a token in that hex, the home token is just removed.
          #
          # If company has tokened more, NdM president get to choose which one to keep, and this is swapped
          # (for free) with the second exchange token, and the remaining tokens for the merged corporation
          # is removed from the board.
          #
          # Any remaining exchange tokens will be added to the charter, and have a cost of $80.

          (1..2).each do |_|
            ndm.tokens << Engine::Token.new(ndm)
            ndm.tokens.last.price = @ndm_exchange_token_price
          end
          exchange_tokens = [ndm.tokens[-2], ndm.tokens.last]

          home_token = major.tokens.first
          if home_token.city
            home_token.city.remove_reservation!(major)
            if ndm.tokens.find { |t| t.city == home_token.city }
              @log << "#{major.name}'s home token is removed as #{ndm.name} already has a token there"
              home_token.remove!
            else
              replace_token(major, home_token, exchange_tokens)
            end
          else
            hex = hex_by_id(major.coordinates)
            tile = hex.tile
            cities = tile.cities
            city = cities.find { |c| c.reserved_by?(major) } || cities.first
            city.remove_reservation!(major)
            tile.reservations.delete(major)
            if ndm.tokens.find { |t| t.city == city }
              @log << "#{ndm.name} does not place token in #{city.hex.name} as it already has a token there"
            else
              @log << "#{ndm.name} places an exchange token in #{major.name}'s home location in #{city.hex.name}"
              ndm_replacement = exchange_tokens.first
              city.place_token(ndm, ndm_replacement, free: true)
              exchange_tokens.delete(ndm_replacement)
            end
          end
          major.tokens.select(&:city).dup.each do |t|
            if ndm.tokens.find { |n| n.city == t.city }
              @log << "#{major.name}'s token in #{t.city.hex.name} is removed as #{ndm.name} already has a token there"
              t.remove!
            end
          end
          remaining_tokens = major.tokens.select(&:city).reject { |t| t == home_token }.dup
          if remaining_tokens.size <= exchange_tokens.size
            remaining_tokens.each { |t| replace_token(major, t, exchange_tokens) }
            @merged_cities_to_select = []
          else
            @merged_cities_to_select = remaining_tokens
          end

          # Rule 5g: transfer money and trains
          if major.cash.positive?
            treasury = format_currency(major.cash)
            @log << "#{ndm.name} receives the #{major.name} treasury of #{treasury}"
            major.spend(major.cash, ndm)
          end
          if major.trains.any?
            trains_transfered = transfer(:trains, major, ndm).map(&:name)
            @log << "#{ndm.name} receives the trains: #{trains_transfered}"
          end

          major.close!
        end

        def rust?(train, _purchased_train)
          return false if @optional_rules&.include?(:delay_minor_close) && train.name == '2' && train.owner.minor?

          super
        end

        def buy_first_5_train(player)
          @ndm_merge_trigger ||= player
        end

        def merge_decider
          candidate = @mergeable_candidates.first
          candidate.floated? ? candidate : ndm
        end

        def mergeable_candidates
          @mergeable_candidates ||= []
        end

        def merged_cities_to_select
          @merged_cities_to_select ||= []
        end

        def select_ndm_city(target)
          @merged_cities_to_select.each do |t|
            if t.city.hex == target
              @log << "#{t.corporation.name}'s token in #{t.city.hex.name} is replaced with an #{ndm.name} token"
              t.swap!(ndm.tokens.last)
            else
              @log << "#{t.corporation.name}'s token is removed in #{t.city.hex.name}"
              t.remove!
            end
          end
          @merged_cities_to_select = []
        end

        def upgrades_to?(from, to, _special = false, selected_company: nil)
          # Copper Canyon cannot be upgraded
          return false if from.name == '470'

          super
        end

        def all_potential_upgrades(tile, tile_manifest: false, selected_company: nil)
          # Copper Canyon cannot be upgraded
          return [] if tile.name == '470'

          super
        end

        def tile_lays(entity)
          return [{ lay: true, upgrade: false }] if entity.minor?

          lays = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }]
          if @optional_rules&.include?(:triple_yellow_first_or) && @recently_floated&.include?(entity)
            lays << { lay: :not_if_upgraded, upgrade: false }
          end
          lays
        end

        def train_limit(entity)
          super + Array(abilities(entity, :train_limit)).sum(&:increase)
        end

        def action_processed(action)
          case action
          when Action::LayTile
            return unless action.hex.id == 'F5'
            return if p2_company.closed? || action.entity == p2_company

            p2_company.remove_ability(p2_company.all_abilities.first)
            @log << "#{p2_company.name} loses the ability to lay F5"
          end
        end

        private

        def handle_no_mail(entity, trainless: true)
          reason = trainless ? 'it has no trains' : 'home location has no value'
          @log << "#{entity.name} receives no mail income as #{reason}"
        end

        def handle_mail(entity)
          hex = hex_by_id(entity.coordinates)
          income = hex.tile.city_towns.first.route_base_revenue(@phase, entity.trains.first)
          # Income is zero in case home location has no revenue center
          return handle_no_mail(entity, trainless: false) unless income.positive?

          @bank.spend(income, entity)
          @log << "#{entity.name} receives #{format_currency(income)} in mail"
        end

        def merge_and_close_minor(company, minor, major, share)
          transfer = minor.cash.positive? ? " who receives the treasury of #{format_currency(minor.cash)}" : ''
          @log << "-- Minor #{minor.name} merges into #{major.name}#{transfer} --"

          share.buyable = true
          @share_pool.buy_shares(minor.player, share, exchange: :free, exchange_price: 0)

          hexes.each do |hex|
            hex.tile.cities.each do |city|
              if city.tokened_by?(minor)
                city.tokens.map! { |token| token&.corporation == minor ? nil : token }
                city.reservations.delete(minor)
              end
            end
          end

          minor.spend(minor.cash, major) if minor.cash.positive?
          hexes.each do |hex|
            hex.tile.cities.each do |city|
              if city.tokened_by?(minor)
                city.tokens.map! { |token| token&.corporation == minor ? nil : token }
              end
            end
          end

          # Delete train so it wont appear in rust message
          train = minor.trains.first
          remove_train(train)
          trains.delete(train)

          minor.close!
          company.close!
        end

        def mergeable_corporations
          corporations = @corporations
            .reject { |c| c.player == ndm.player }
            .reject { |c| %w[FCP TM].include? c.name }
          floated_player_corps, other_corps = corporations.partition { |c| c.owned_by_player? && c.floated? }

          # Sort eligible corporations so that they are in player order
          # starting with the player to the left of the one that bought the 5 train
          index_for_trigger = @players.index(@ndm_merge_trigger)
          order = @players.each_with_index.to_h { |p, i| i <= index_for_trigger ? [p, i + 10] : [p, i] }
          floated_player_corps.sort_by! { |c| [order[c.player], @round.entities.index(c)] }

          # If any non-floated corporation has not yet been ipoed
          # then only non-ipoed corporations must be chosen
          other_corps.reject!(&:ipoed) if other_corps.any? { |c| !c.ipoed }

          # The players get the first choice, otherwise a non-floated corporation must be chosen
          floated_player_corps.concat(other_corps)
        end

        def possible_auto_merge
          # Decline merge if no candidates left
          return merge_major if @mergeable_candidates.empty?

          # Auto merge single if it is non-floated
          candidate = @mergeable_candidates.first
          merge_major(candidate) if @mergeable_candidates.one? && !candidate.floated?
        end

        def replace_token(major, major_token, exchange_tokens)
          city = major_token.city
          @log << "#{major.name}'s token in #{city.hex.name} is replaced with an #{ndm.name} token"
          ndm_replacement = exchange_tokens.first
          major_token.remove!
          city.place_token(ndm, ndm_replacement, free: true, check_tokenable: false)
          exchange_tokens.delete(ndm_replacement)
        end

        def change_4t_to_hardrust
          @depot.trains
            .select { |t| t.name == '4' }
            .each { |t| update_end_of_life(t, t.obsolete_on, nil) }
        end

        def update_end_of_life(t, rusts_on, obsolete_on)
          t.rusts_on = rusts_on
          t.obsolete_on = obsolete_on
          t.variants.each { |_, v| v.merge!(rusts_on: rusts_on, obsolete_on: obsolete_on) }
        end

        def remove_ability(corporation, ability_name)
          abilities(corporation, ability_name) do |ability|
            corporation.remove_ability(ability)
          end
        end

        def present_mergeable_candidates(mergeable_candidates)
          last = mergeable_candidates.last
          mergeable_candidates.map do |c|
            controller_name = if c.floated?
                                # Floated means president gets to merge/decline
                                c.player.name
                              elsif c == last
                                # Non-floated and last will be automatically chosen
                                'automatic'
                              else
                                # If several non-floated candidates NdM gets to choose
                                ndm.player.name
                              end
            "#{c.name} (#{controller_name})"
          end.join(', ')
        end
      end
    end
  end
end
