# frozen_string_literal: true

require_relative '../config/game/g_18_cz'
require_relative 'base'

module Engine
  module Game
    class G18CZ < Base
      register_colors(brightGreen: '#c2ce33', beige: '#e5d19e', lightBlue: '#1EA2D6', mintGreen: '#B1CEC7',
                      yellow: '#ffe600', lightRed: '#F3B1B3')

      load_from_json(Config::Game::G18CZ::JSON)

      DEV_STAGE = :prealpha
      GAME_LOCATION = 'Czech Republic'
      GAME_RULES_URL = 'https://www.lonny.at/app/download/9940504884/rules_English.pdf'
      GAME_DESIGNER = 'Leonhard Orgler'
      GAME_PUBLISHER = nil
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18CZ'

      SELL_BUY_ORDER = :sell_buy
      SELL_MOVEMENT = :down_block

      HOME_TOKEN_TIMING = :operate

      PAR_RANGE = {
        1 => [50, 55, 60, 65, 70],
        2 => [60, 70, 880, 90, 100],
        3 => [90, 100, 110, 120],

      }.freeze

      COMPANY_VALUES = [40, 45, 50, 55, 60, 65, 70, 75, 80, 90, 100, 110, 120].freeze

      LAYER_BY_NAME = {
        'SX' => 3,
        'BY' => 3,
        'PR' => 3,
        'kk' => 3,
        'Ug' => 3,
        'BN' => 2,
        'NWB' => 2,
        'ATE' => 2,
        'BTE' => 2,
        'KFN' => 2,
        'EKJ' => 1,
        'OFE' => 1,
        'BCB' => 1,
        'MW' => 1,
        'VBW' => 1,
      }.freeze

      def setup
        @or = 0
        @current_layer = 1
        @recently_floated = []
      end

      def init_round
        Round::Draft.new(self,
                         [Step::G18CZ::Draft],
                         snake_order: true)
      end

      def stock_round
        Round::Stock.new(self, [
          Step::DiscardTrain,
          Step::SpecialTrack,
          Step::G18CZ::BuySellParShares,
        ])
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::SpecialTrack,
          Step::BuyCompany,
          Step::Track,
          Step::Token,
          Step::Route,
          Step::Dividend,
          Step::DiscardTrain,
          Step::BuyTrain,
          [Step::BuyCompany, { blocks: true }],
        ], round_num: round_num)
      end

      def init_stock_market
        StockMarket.new(self.class::MARKET, [], zigzag: true)
      end

      def new_operating_round
        @or += 1
        @companies.each do |company|
          company.value = COMPANY_VALUES[@or - 1]
          company.min_price = 1
          company.max_price = company.value
        end

        super
      end

      def or_round_finished
        @recently_floated = []
      end

      def sorted_corporations
        @corporations.sort_by { |c| corp_layer(c) }
      end

      def corporation_available?(entity)
        entity.corporation? && can_ipo?(entity)
      end

      def can_ipo?(corp)
        corp_layer(corp) <= @current_layer
      end

      def corp_layer(corp)
        LAYER_BY_NAME[corp.name]
      end

      def par_prices(corp)
        par_nodes = stock_market.par_prices
        available_par_prices = PAR_RANGE[corp_layer(corp)]
        par_nodes.select { |par_node| available_par_prices.include?(par_node.price) }
      end

      def increase_layer
        @current_layer += 1
        @log << "-- Layer #{@current_layer} corporations now available --"
      end

      def event_middle_companies_available!
        increase_layer
      end

      def event_large_companies_available!
        increase_layer
      end

      def float_corporation(corporation)
        @recently_floated << corporation
        super
      end

      def tile_lays(entity)
        return super unless @recently_floated.include?(entity)

        [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }]
      end
    end
  end
end
