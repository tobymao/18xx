# frozen_string_literal: true

require_relative '../config/game/g_18_co'
require_relative 'base'
require_relative 'company_price_50_to_150_percent'
require_relative 'revenue_4d'

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

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'remove_mines' => ['Mines Close', 'Mine tokens removed from board and corporations']
        ).freeze

      include CompanyPrice50To150Percent
      include Revenue4D

      def dsng
        @dsng ||= corporation_by_id('DSNG')
      end

      def setup
        setup_company_price_50_to_150_percent

        train = @depot.upcoming[0]
        train.buyable = false
        dsng.buy_train(train, :free)
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
        Step::Dividend,
        Step::BuyTrain,
        [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def stock_round
        Round::Stock.new(self, [
        Step::DiscardTrain,
        Step::BuySellParShares,
        ])
      end

      def adjust_revenue_for_5d_train(route, stops, revenue)
        return revenue unless route.train.name == '5D'

        2 * revenue - stops
          .select { |stop| stop.hex.tile.towns.any? }
          .sum { |stop| stop.route_revenue(route.phase, route.train) }
      end

      def revenue_for(route, stops)
        revenue = adjust_revenue_for_4d_train(route, stops, super)
        revenue = adjust_revenue_for_5d_train(route, stops, revenue)

        revenue
      end

      def routes_revenue(routes)
        total_revenue = super
        # TODO: East/SLC Bonus
        total_revenue
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

      private

      def route_bonus(route, type)
        # TODO: East / SLC Bonus
      end
    end
  end
end
