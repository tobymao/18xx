# frozen_string_literal: true

require_relative '../config/game/g_18_cz'
require_relative 'base'

module Engine
  module Game
    class G18CZ < Base

      register_colors(brightGreen: '#c2ce33', beige: '#e5d19e', lightBlue: '#1EA2D6', mintGreen: '#B1CEC7', yellow: '#ffe600', lightRed: '#F3B1B3')

      load_from_json(Config::Game::G18CZ::JSON)

      DEV_STAGE = :prealpha
      GAME_LOCATION = 'Czech Republic'
      GAME_RULES_URL = 'http://ohley.de/english/1848/1848-rules.pdf'
      GAME_DESIGNER = 'Leonhard Orgler and Helmut Ohley'
      GAME_PUBLISHER = :oo_games
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1848'

      # Two tiles can be laid at a time, with max one upgrade
      TILE_LAYS = [{ lay: true, upgrade: true }, { lay: true, upgrade: :not_if_upgraded }].freeze

      SELL_BUY_ORDER = :sell_buy
      SELL_MOVEMENT = :down_block

      HOME_TOKEN_TIMING = :operate

      PAR_RANGE = {
        1 => [50, 55, 60, 65, 70],
        2 => [60, 70, 880, 90, 100],
        3 => [90, 100, 110, 120]
        
      }.freeze

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
        'VBW' => 1
      }.freeze

      def setup
        @highest_layer = 1
      end

      def stock_round
        Round::Stock.new(self, [
          Step::DiscardTrain,
          Step::Exchange,
          Step::SpecialTrack,
          Step::G18CZ::BuySellParShares
        ])
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::Exchange,
          Step::DiscardTrain,
          Step::BuyCompany,
          Step::Track,
          Step::Token,
          Step::Route,
          Step::Dividend,
          Step::BuyTrain,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def init_stock_market
        StockMarket.new(self.class::MARKET, [], zigzag: true)
      end

      def sorted_corporations
        @corporations.sort_by { |c| corp_layer(c) }
      end

      def corporation_available?(entity)
        entity.corporation? && can_ipo?(entity)
      end

      def can_ipo?(corp)
        corp_layer(corp) <= current_layer
      end

      def corp_layer(corp)
        LAYER_BY_NAME[corp.name]
      end
      
      def par_prices(corp)
        par_nodes = stock_market.par_prices
        available_par_prices = PAR_RANGE[corp_layer(corp)]
        par_nodes.select { |par_node| available_par_prices.include?(par_node.price) }
      end

      def current_layer
        #todo fix for 18cz
        layers = LAYER_BY_NAME.select do |name, _layer|
          corp = @corporations.find { |c| c.name == name }
          corp.num_ipo_shares.zero? || corp.operated?
        end.values
        layers.empty? ? 1 : [layers.max + 1, 3].min
      end

      def or_set_finished
        check_new_layer
      end

      def check_new_layer
        layer = current_layer
        @log << "-- Layer #{layer} corporations now available --" if layer > @highest_layer
        @highest_layer = layer
      end
    end
  end
end
