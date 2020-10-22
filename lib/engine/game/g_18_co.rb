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
      MUST_EMERGENCY_ISSUE_BEFORE_EBUY = true

      # Two tiles can be laid, only one upgrade
      # TODO: This changes in phase E to a single tile lay
      TILE_LAYS = [{ lay: true, upgrade: true }, { lay: true, upgrade: false }].freeze

      IPO_NAME = 'Treasury'

      # First 3 are Denver, Second 3 are CO Springs
      TILES_FIXED_ROTATION = %w[co1 co2 co3 co5 co6 co7].freeze

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

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'remove_mines' => ['Mines Close', 'Mine tokens removed from board and corporations']
        ).freeze

      include CompanyPrice50To150Percent

      def dsng
        @dsng ||= corporation_by_id('DSNG')
      end

      def setup
        setup_company_price_50_to_150_percent

        train = @depot.upcoming[0]
        train.buyable = false
        dsng.buy_train(train, :free)
      end

      def init_stock_market
        Engine::G18CO::StockMarket.new(
          self.class::MARKET,
          self.class::CERT_LIMIT_COLORS,
          multiple_buy_colors: self.class::MULTIPLE_BUY_COLORS
        )
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
        Step::Bankrupt,
        Step::DiscardTrain,
        Step::HomeToken,
        Step::BuyCompany,
        Step::G18CO::Track,
        Step::Token,
        Step::Route,
        Step::G18CO::Dividend,
        Step::BuyTrain,
        [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def stock_round
        Round::Stock.new(self, [
        Step::DiscardTrain,
        Step::G18CO::BuySellParShares,
        ])
      end

      def new_auction_round
        Round::Auction.new(self, [
          Step::G18CO::CompanyPendingPar,
          Step::WaterfallAuction,
        ])
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

      def all_potential_upgrades(tile, tile_manifest: false)
        upgrades = super

        return upgrades unless tile_manifest

        # TODO: co8 / co9 / co10 => 63 / co4

        upgrades
      end

      def event_remove_mines!
        @log << '-- Event: Mines close --'

        @log << 'Mines removed from board (TODO)'

        @companies.each do |company|
          @log << "Mines removed from  #{company.name} (TODO)"
        end
      end

      def sell_shares_and_change_price(bundle)
        corporation = bundle.corporation
        price = corporation.share_price.price
        was_president = corporation.president?(bundle.owner)
        @share_pool.sell_shares(bundle)

        return if !was_president && bundle.num_shares == 1

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
    end
  end
end
