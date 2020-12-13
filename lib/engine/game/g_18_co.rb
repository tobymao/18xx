# frozen_string_literal: true

require_relative '../config/game/g_18_co'
require_relative '../g_18_co/stock_market'
require_relative 'base'
require_relative 'company_price_50_to_150_percent'

module Engine
  module Game
    class G18CO < Base
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

      # DEV_STAGE = :beta

      GAME_LOCATION = 'Colorado, USA'
      GAME_RULES_URL = 'https://drive.google.com/open?id=0B3lRHMrbLMG_eEp4elBZZ0toYnM'
      GAME_DESIGNER = 'R. Ryan Driskel'
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18CO:-Rock-&-Stock'

      SELL_BUY_ORDER = :sell_buy
      EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false
      MUST_EMERGENCY_ISSUE_BEFORE_EBUY = true
      MUST_BID_INCREMENT_MULTIPLE = true
      ONLY_HIGHEST_BID_COMMITTED = false

      CORPORATE_BUY_SHARE_SINGLE_CORP_ONLY = true
      CORPORATE_BUY_SHARE_ALLOW_BUY_FROM_PRESIDENT = true
      DISCARDED_TRAIN_DISCOUNT = 50

      # Two tiles can be laid, only one upgrade
      # TODO: This changes in phase E to a single tile lay
      TILE_LAYS = [{ lay: true, upgrade: true }, { lay: true, upgrade: false }].freeze

      # First 3 are Denver, Second 3 are CO Springs
      TILES_FIXED_ROTATION = %w[co1 co2 co3 co5 co6 co7].freeze
      GREEN_TOWN_TILES = %w[co8 co9 co10].freeze
      GREEN_CITY_TILES = %w[14 15].freeze
      BROWN_CITY_TILES = %w[co4 63].freeze

      STOCKMARKET_COLORS = {
        par: :yellow,
        acquisition: :red,
      }.freeze

      MARKET_TEXT = {
        par: 'Par: C [40, 50, 60, 75] - 40%, B/C [80, 90, 100, 110] - 50%, A/B/C: [120, 135, 145, 160] - 60%',
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

      EAST_HEXES = %w[A26 J26 E27 G27].freeze

      BASE_MINE_VALUE = 10

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'remove_mines' => ['Mines Close', 'Mine tokens removed from board and corporations']
        ).freeze

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
      end

      def setup_corporations
        # The DSNG comes with a 2P train
        train = @depot.upcoming[0]
        train.buyable = false
        dsng.buy_train(train, :free)
      end

      def init_stock_market
        Engine::G18CO::StockMarket.new(
          self.class::MARKET,
          self.class::CERT_LIMIT_TYPES,
          multiple_buy_types: self.class::MULTIPLE_BUY_TYPES
        )
      end

      def mines_count(entity)
        entity.abilities(:mine_income).sum(&:count_per_or)
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
        entity.abilities(:mine_income) do |ability|
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
        Step::DiscardTrain,
        Step::HomeToken,
        Step::G18CO::ReturnToken,
        Step::BuyCompany,
        Step::G18CO::RedeemShares,
        Step::CorporateBuyShares,
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
        Round::Stock.new(self, [
        Step::G18CO::Takeover,
        Step::DiscardTrain,
        Step::G18CO::BuySellParShares,
        ])
      end

      def new_auction_round
        Round::Auction.new(self, [
          Step::G18CO::CompanyPendingPar,
          Step::G18CO::MovingBidAuction,
        ])
      end

      def action_processed(action)
        super

        case action
        when Action::BuyCompany
          mine_update_text(action.entity) if action.company == imc && action.entity.corporation?
        end
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

        game_error('Towns on route ends are counted against city limit.')
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
        str = super

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

      def sell_shares_and_change_price(bundle)
        corporation = bundle.corporation
        price = corporation.share_price.price
        was_president = corporation.president?(bundle.owner)
        was_issued = bundle.owner == bundle.corporation

        @share_pool.sell_shares(bundle)

        return if !(was_president || was_issued) && bundle.num_shares == 1

        bundle.num_shares.times { @stock_market.move_down(corporation) }

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

      # Higher valued par groups require more shares to float. The float percent is adjusted upon parring.
      def par_change_float_percent(corporation)
        PAR_PRICE_GROUPS.each do |key, prices|
          next unless PAR_FLOAT_GROUPS[corporation.float_percent].include?(key)
          next unless prices.include?(corporation.par_price.price)

          if corporation.float_percent != PAR_GROUP_FLOATS[key]
            corporation.float_percent = PAR_GROUP_FLOATS[key]
            @log << "#{corporation.name} now requires #{corporation.float_percent}% to float"
          end

          break
        end
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
          .reject { |bundle| bundle.num_shares > 1 }
      end

      def redeemable_shares(entity)
        return [] unless entity.corporation?

        bundles_for_corporation(share_pool, entity)
          .reject { |bundle| entity.cash < bundle.price }
      end

      def purchasable_companies(entity = nil)
        @companies.select do |company|
          (company.owner&.player? || company.owner.nil?) &&
            (entity.nil? || entity != company.owner) &&
            !company.abilities(:no_buy)
        end
      end
    end
  end
end
