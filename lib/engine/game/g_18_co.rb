# frozen_string_literal: true

require_relative '../config/game/g_18_co'
require_relative '../g_18_co/share_pool'
require_relative '../g_18_co/stock_market'
require_relative 'base'
require_relative 'company_price_50_to_150_percent'

module Engine
  module Game
    class G18CO < Base
      attr_accessor :presidents_choice

      register_colors(green: '#237333',
                      red: '#d81e3e',
                      blue: '#0189d1',
                      lightBlue: '#a2dced',
                      yellow: '#FFF500',
                      orange: '#f48221',
                      brown: '#7b352a',
                      black: '#000000',
                      pink: '#FF0099',
                      purple: '#9900FF',
                      white: '#FFFFFF')
      load_from_json(Config::Game::G18CO::JSON)
      AXES = { x: :number, y: :letter }.freeze

      DEV_STAGE = :beta

      GAME_LOCATION = 'Colorado, USA'
      GAME_RULES_URL = 'https://drive.google.com/open?id=0B3lRHMrbLMG_eEp4elBZZ0toYnM'
      GAME_DESIGNER = 'R. Ryan Driskel'
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18CO:-Rock-&-Stock'

      SELL_BUY_ORDER = :sell_buy
      EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = true
      MUST_EMERGENCY_ISSUE_BEFORE_EBUY = true
      MUST_BID_INCREMENT_MULTIPLE = true
      ONLY_HIGHEST_BID_COMMITTED = false

      CORPORATE_BUY_SHARE_SINGLE_CORP_ONLY = true
      CORPORATE_BUY_SHARE_ALLOW_BUY_FROM_PRESIDENT = true
      VARIABLE_FLOAT_PERCENTAGES = true
      DISCARDED_TRAIN_DISCOUNT = 50
      MAX_SHARE_VALUE = 485

      # Two tiles can be laid, only one upgrade
      TILE_LAYS = [
        { lay: true, upgrade: true },
        { lay: true, upgrade: :not_if_upgraded, cannot_reuse_same_hex: true },
      ].freeze
      REDUCED_TILE_LAYS = [{ lay: true, upgrade: true }].freeze

      # First 3 are Denver, Second 3 are CO Springs
      TILES_FIXED_ROTATION = %w[co1 co2 co3 co5 co6 co7].freeze
      GREEN_TOWN_TILES = %w[co8 co9 co10].freeze
      GREEN_CITY_TILES = %w[14 15].freeze
      BROWN_CITY_TILES = %w[co4 63].freeze
      MAX_STATION_TILES = %w[14 15 co1 co2 co3 co4 co7 63].freeze

      STOCKMARKET_COLORS = {
        par: :blue,
        par_1: :purple,
        par_2: :yellow,
        acquisition: :red,
      }.freeze

      MARKET_TEXT = {
        par: 'Par: 40% - C',
        par_1: 'Par: 50% - B/C',
        par_2: 'Par: 60% - A/B/C',
        acquisition: 'Acquisition: Corporation assets will be auctioned if entering Stock Round',
      }.freeze

      PAR_FLOAT_GROUPS = {
        20 => %w[X],
        40 => %w[C B A],
        50 => %w[B A],
        60 => %w[A],
      }.freeze

      PAR_PRICE_GROUPS = {
        'X' => [75],
        'C' => [40, 50, 60, 75],
        'B' => [80, 90, 100, 110],
        'A' => [120, 135, 145, 160],
      }.freeze

      PAR_GROUP_FLOATS = {
        'X' => 20,
        'C' => 40,
        'B' => 50,
        'A' => 60,
      }.freeze

      EAST_HEXES = %w[B26 J26 E27 G27].freeze

      BASE_MINE_VALUE = 10

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'remove_mines' => ['Mines Close', 'Mine tokens removed from board and corporations'],
          'presidents_choice' => [
            'President\'s Choice Triggered',
            'President\'s choice round will occur at the beginning of the next Stock Round',
          ],
          'unreserve_home_stations' => [
            'Remove Reservations',
            'Home stations are no longer reserved for unparred corporations.',
          ]
        ).freeze

      STATUS_TEXT = Base::STATUS_TEXT.merge(
        'reduced_tile_lay' => ['Reduced Tile Lay', 'Corporations place only one tile per OR.'],
        'corporate_shares_open' => [
          'Corporate Shares Open',
          'All corporate shares are available for any player to purchase.',
        ],
        'closable_corporations' => [
          'Closable Corporations',
          'Unparred corporations are removed if there is no station available to place their home token. '\
          'Parring a corporation restores its home token reservation.',
        ]
      ).freeze

      OPTIONAL_RULES = [
        {
          sym: :priority_order_pass,
          short_name: 'Priority Order Pass',
          desc: 'Priority is awarded in pass order in both Auction and Stock Rounds.',
        },
        {
          sym: :pay_per_trash,
          short_name: 'Pay Per Trash',
          desc: 'Selling multiple shares before a corporation\'s first Operating Round returns the '\
                'amount listed in each movement down on the market, starting at the current share price.',
        },
        {
          sym: :major_investors,
          short_name: 'Major Investors',
          desc: 'The Presidency cannot be transferred to another player during Corporate Share Buying.',
        },
      ].freeze

      include CompanyPrice50To150Percent

      def ipo_name(_entity = nil)
        'Treasury'
      end

      def dsng
        @dsng ||= corporation_by_id('DSNG')
      end

      def drgr
        @drgr ||= company_by_id('DRGR')
      end

      def imc
        @imc ||= company_by_id('IMC')
      end

      def setup
        setup_company_price_50_to_150_percent
        setup_corporations
        @presidents_choice = nil
      end

      def next_sr_player_order
        return :first_to_pass if @optional_rules&.include?(:priority_order_pass)

        super
      end

      def setup_corporations
        # The DSNG comes with a 2P train
        train = @depot.upcoming[0]
        train.buyable = false
        buy_train(dsng, train, :free)
      end

      def init_share_pool
        Engine::G18CO::SharePool.new(self)
      end

      def init_stock_market
        Engine::G18CO::StockMarket.new(
          self.class::MARKET,
          self.class::CERT_LIMIT_TYPES,
          multiple_buy_types: self.class::MULTIPLE_BUY_TYPES
        )
      end

      def mines_count(entity)
        Array(abilities(entity, :mine_income)).sum(&:count_per_or)
      end

      def mine_multiplier(entity)
        imc.owner == entity ? 2 : 1
      end

      def mine_value(entity)
        BASE_MINE_VALUE * mine_multiplier(entity)
      end

      def mines_total(entity)
        mine_value(entity) * mines_count(entity)
      end

      def mines_remove(entity)
        abilities(entity, :mine_income) do |ability|
          entity.remove_ability(ability)
        end
      end

      def mines_add(entity, count)
        mine_create(entity, mines_count(entity) + count)
      end

      def mine_add(entity)
        mines_add(entity, 1)
      end

      def mine_update_text(entity)
        mine_create(entity, mines_count(entity))
      end

      def mine_create(entity, count)
        return unless count.positive?

        mines_remove(entity)
        total = count * mine_value(entity)
        entity.add_ability(Engine::Ability::Base.new(
              type: :mine_income,
              description: "#{count} mine#{count > 1 ? 's' : ''} x
                            #{format_currency(mine_value(entity))} =
                            #{format_currency(total)} to Treasury",
              count_per_or: count,
              remove: '6'
            ))
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
        Step::Bankrupt,
        Step::G18CO::Takeover,
        Step::G18CO::DiscardTrain,
        Step::G18CO::HomeToken,
        Step::G18CO::ReturnToken,
        Step::BuyCompany,
        Step::G18CO::RedeemShares,
        Step::G18CO::CorporateBuyShares,
        Step::G18CO::SpecialTrack,
        Step::G18CO::Track,
        Step::Token,
        Step::Route,
        Step::G18CO::Dividend,
        Step::G18CO::BuyTrain,
        Step::CorporateSellShares,
        Step::G18CO::IssueShares,
        [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def stock_round
        Round::G18CO::Stock.new(self, [
        Step::G18CO::Takeover,
        Step::G18CO::DiscardTrain,
        Step::G18CO::BuySellParShares,
        ])
      end

      def new_presidents_choice_round
        @log << '-- President\'s Choice --'
        Round::G18CO::PresidentsChoice.new(self, [
          Step::G18CO::PresidentsChoice,
        ])
      end

      def new_acquisition_round
        @log << '-- Acquisition Round --'
        Round::G18CO::Acquisition.new(self, [
          Step::G18CO::AcquisitionTakeover,
          Step::G18CO::AcquisitionAuction,
        ])
      end

      def new_auction_round
        Round::Auction.new(self, [
          Step::G18CO::CompanyPendingPar,
          Step::G18CO::MovingBidAuction,
        ])
      end

      def next_round!
        @round =
          case @round
          when Round::G18CO::Acquisition
            new_stock_round
          when Round::G18CO::PresidentsChoice
            if acquirable_corporations.any?
              new_acquisition_round
            else
              new_stock_round
            end
          when Round::Stock
            @operating_rounds = @phase.operating_rounds
            reorder_players
            new_operating_round
          when Round::Operating
            if @round.round_num < @operating_rounds
              or_round_finished
              new_operating_round(@round.round_num + 1)
            else
              @turn += 1
              or_round_finished
              or_set_finished
              if @presidents_choice == :triggered
                new_presidents_choice_round
              elsif acquirable_corporations.any?
                new_acquisition_round
              else
                new_stock_round
              end
            end
          when init_round.class
            init_round_finished
            reorder_players
            new_stock_round
          end
      end

      def acquirable_corporations
        corporations.select { |c| c&.share_price&.acquisition? }
      end

      def action_processed(action)
        super

        case action
        when Action::BuyCompany
          mine_update_text(action.entity) if action.company == imc && action.entity.corporation?
        when Action::PlaceToken
          remove_corporations_if_no_home(action.city) if @phase.status.include?('closable_corporations')
        when Action::Par
          rereserve_home_station(action.corporation) if @phase.status.include?('closable_corporations')
          remove_par_group_ability(action.corporation)
        end
      end

      def remove_par_group_ability(corporation)
        par_group = abilities(corporation, :description)

        corporation.remove_ability(par_group) if par_group
      end

      def remove_corporations_if_no_home(city)
        tile = city.tile

        return unless tile_has_max_stations(tile)

        @corporations.dup.each do |corp|
          next if corp.ipoed
          next unless corp.coordinates == tile.hex.name

          next if city.tokenable?(corp, free: true)

          log << "#{corp.name} closes as its home station can never be available"
          close_corporation(corp, quiet: true)
          corp.close!
        end
      end

      def tile_has_max_stations(tile)
        tile.color == :red || MAX_STATION_TILES.include?(tile.name)
      end

      def rereserve_home_station(corporation)
        return unless corporation.coordinates

        tile = hex_by_id(corporation.coordinates).tile
        city = tile.cities[corporation.city || 0]
        slot = city.get_slot(corporation)
        tile.add_reservation!(corporation, slot ? corporation.city : nil, slot)
        log << "#{corporation.name} reserves station on #{tile.hex.name}"\
          "#{slot ? '' : " which must be upgraded to place the #{corporation.name} home station"}"
      end

      def check_distance(route, visits)
        super

        distance = route.train.distance

        return if distance.is_a?(Numeric)

        cities_allowed = distance.find { |d| d['nodes'].include?('city') }['pay']
        cities_visited = visits.count { |v| v.city? || v.offboard? }
        start_at_town = visits.first.town? ? 1 : 0
        end_at_town = visits.last.town? ? 1 : 0

        return unless cities_allowed < (cities_visited + start_at_town + end_at_town)

        raise GameError, 'Towns on route ends are counted against city limit.'
      end

      def revenue_for(route, stops)
        revenue = super

        revenue += east_west_bonus(stops)[:revenue]

        revenue
      end

      def east_west_bonus(stops)
        bonus = { revenue: 0 }

        east = stops.find { |stop| EAST_HEXES.include?(stop.hex.name) }
        west = stops.find { |stop| stop.hex.name == 'E1' }

        if east && west
          bonus[:revenue] = 100
          bonus[:description] = 'E/W'
        end

        bonus
      end

      def revenue_str(route)
        str = route.stops.map { |s| s.hex.name }.join('-')

        bonus = east_west_bonus(route.stops)[:description]
        str += " + #{bonus}" if bonus

        str
      end

      def upgrades_to?(from, to, special = false)
        return true if special && from.hex.tile.color == :yellow && GREEN_CITY_TILES.include?(to.name)

        # Green towns can't be upgraded to brown cities unless the hex has the upgrade icon
        if GREEN_TOWN_TILES.include?(from.hex.tile.name)
          return BROWN_CITY_TILES.include?(to.name) if from.hex.tile.icons.any? { |icon| icon.name == 'upgrade' }

          return false
        end

        super
      end

      def all_potential_upgrades(tile, tile_manifest: false)
        upgrades = super

        return upgrades unless tile_manifest

        if GREEN_TOWN_TILES.include?(tile.name)
          brown_cityco4 = @tiles.find { |t| t.name == 'co4' }
          brown_city63 = @tiles.find { |t| t.name == '63' }
          upgrades |= [brown_cityco4] if brown_cityco4
          upgrades |= [brown_city63] if brown_city63
        end

        upgrades
      end

      def event_remove_mines!
        @log << '-- Event: Mines close --'

        hexes.each do |hex|
          hex.tile.icons.reject! { |icon| icon.name == 'mine' }
        end

        @corporations.each do |corporation|
          mines_remove(corporation)
        end
      end

      def event_unreserve_home_stations!
        @log << '-- Event: Home station reservations removed --'

        @corporations.each do |corporation|
          next if corporation.ipoed

          tile = hex_by_id(corporation.coordinates).tile
          city = tile.cities[corporation.city || 0]
          city.remove_reservation!(corporation)
        end
      end

      def tile_lays(_entity)
        return REDUCED_TILE_LAYS if @phase.status.include?('reduced_tile_lay')

        super
      end

      def event_presidents_choice!
        return if @presidents_choice

        @log << '-- Event: President\'s Choice --'
        @log << 'President\'s choice round will occur at the beginning of the next Stock Round'

        @presidents_choice = :triggered
      end

      def sell_shares_and_change_price(bundle, allow_president_change: true, swap: nil)
        corporation = bundle.corporation
        price = corporation.share_price.price
        was_president = corporation.president?(bundle.owner)
        was_issued = bundle.owner == bundle.corporation

        @share_pool.sell_shares(bundle, allow_president_change: allow_president_change, swap: swap)
        share_drop_num = bundle.num_shares - (swap ? 1 : 0)

        return if !(was_president || was_issued) && share_drop_num == 1

        share_drop_num.times { @stock_market.move_down(corporation) }

        log_share_price(corporation, price) if self.class::SELL_MOVEMENT != :none
      end

      def legal_tile_rotation?(_entity, _hex, tile)
        return false if TILES_FIXED_ROTATION.include?(tile.name) && tile.rotation != 0

        super
      end

      # Reduce the list of par prices available to just those corresponding to the corporation group
      def par_prices(corporation)
        par_nodes = @stock_market.par_prices
        available_par_groups = PAR_FLOAT_GROUPS[corporation.float_percent]
        available_par_prices = PAR_PRICE_GROUPS.values_at(*available_par_groups).flatten
        par_nodes.select { |par_node| available_par_prices.include?(par_node.price) }
      end

      def total_shares_to_float(corporation, price)
        find_par_float_percent(corporation, price) / corporation.share_percent
      end

      def find_par_float_percent(corporation, price)
        PAR_PRICE_GROUPS.each do |key, prices|
          next unless PAR_FLOAT_GROUPS[corporation.float_percent].include?(key)
          next unless prices.include?(price)

          return PAR_GROUP_FLOATS[key]
        end

        corporation.float_percent
      end

      # Higher valued par groups require more shares to float. The float percent is adjusted upon parring.
      def par_change_float_percent(corporation)
        new_par = find_par_float_percent(corporation, corporation.par_price.price)
        return if corporation.float_percent == new_par

        corporation.float_percent = new_par
        @log << "#{corporation.name} now requires #{corporation.float_percent}% to float"
      end

      def emergency_issuable_cash(corporation)
        emergency_issuable_bundles(corporation).max_by(&:num_shares)&.price || 0
      end

      def emergency_issuable_bundles(entity)
        issuable_shares(entity)
      end

      def issuable_shares(entity)
        return [] unless entity.corporation?
        return [] unless entity.num_ipo_shares

        bundles_for_corporation(entity, entity)
          .select { |bundle| @share_pool.fit_in_bank?(bundle) }
          .map { |bundle| reduced_bundle_price_for_market_drop(bundle) }
      end

      def redeemable_shares(entity)
        return [] unless entity.corporation?

        bundles_for_corporation(share_pool, entity)
          .reject { |bundle| entity.cash < bundle.price }
      end

      def sellable_bundles(player, corporation)
        bundles = super
        return bundles unless @optional_rules&.include?(:pay_per_trash)
        return bundles if corporation.operated?

        bundles.map { |bundle| reduced_bundle_price_for_market_drop(bundle) }
      end

      # we can use this same logic for issuing multiple shares
      def reduced_bundle_price_for_market_drop(bundle)
        return bundle if bundle.num_shares == 1

        new_price = (0..bundle.num_shares - 1).sum do |max_drops|
          @stock_market.find_share_price(bundle.corporation, (1..max_drops).map { |_| :up }).price
        end

        bundle.share_price = new_price / bundle.num_shares

        bundle
      end

      def all_bundles_for_corporation(share_holder, corporation, shares: nil)
        return [] unless corporation.ipoed
        return super unless corporation == dsng

        shares = (shares || share_holder.shares_of(corporation)).sort_by { |h| [h.president ? 1 : 0, h.price] }

        return [] if shares.empty?

        bundles = (1..shares.size).flat_map do |n|
          shares.combination(n).to_a.map { |ss| Engine::ShareBundle.new(ss) }
        end

        bundles.sort_by { |b| [b.presidents_share ? 1 : 0, b.percent, -b.shares.size] }.uniq(&:percent)
      end

      def buying_power(entity)
        entity.cash
      end

      def purchasable_companies(entity = nil)
        @companies.select do |company|
          !company.closed? &&
            (company.owner&.player? || company.owner.nil?) &&
            (entity.nil? || entity != company.owner) &&
            !abilities(company, :no_buy)
        end
      end

      def unowned_purchasable_companies(_entity)
        @companies.select { |company| !company.closed? && company.owner.nil? }
      end

      def entity_can_use_company?(entity, company)
        entity.corporation? && entity == company.owner
      end

      def player_value(player)
        value = player.value
        return value unless drgr&.owner == player

        value - drgr.value
      end

      def train_limit(entity)
        super + Array(abilities(entity, :train_limit)).sum(&:increase)
      end
    end
  end
end
