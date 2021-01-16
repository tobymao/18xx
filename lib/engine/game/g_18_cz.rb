# frozen_string_literal: true

require_relative '../config/game/g_18_cz'
require_relative 'base'
require_relative 'stubs_are_restricted'

module Engine
  module Game
    class G18CZ < Base
      register_colors(brightGreen: '#c2ce33',
                      beige: '#e5d19e',
                      lightBlue: '#1EA2D6',
                      mintGreen: '#B1CEC7',
                      yellow: '#ffe600',
                      lightRed: '#F3B1B3')

      load_from_json(Config::Game::G18CZ::JSON)

      GAME_LOCATION = 'Czech Republic'
      GAME_RULES_URL = 'https://www.lonny.at/app/download/9940504884/rules_English.pdf'
      GAME_DESIGNER = 'Leonhard Orgler'
      GAME_PUBLISHER = :lonny_games
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18CZ'

      SELL_BUY_ORDER = :sell_buy
      SELL_MOVEMENT = :down_block

      MUST_BUY_TRAIN = :always

      HOME_TOKEN_TIMING = :operate

      STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
        par: :red,
        par_2: :green,
        par_overlap: :blue
      ).freeze

      PAR_RANGE = {
        'small' => [50, 55, 60, 65, 70],
        'medium' => [60, 70, 80, 90, 100],
        'large' => [90, 100, 110, 120],
      }.freeze

      MARKET_TEXT = {
        par: 'Small Corporation Par',
        par_overlap: 'Medium Corporation Par',
        par_2: 'Large Corporation Par',
      }.freeze

      COMPANY_VALUES = [40, 45, 50, 55, 60, 65, 70, 75, 80, 90, 100, 110, 120].freeze

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
        'medium_corps_available' => ['Medium Corps Available',
                                     '5-share corps ATE, BN, BTE, KFN, NWB are available to start'],
        'large_corps_available' => ['Large Corps Available',
                                    '10-share corps By, kk, Sx, Pr, Ug are available to start']
      ).freeze

      def end_now?(_after)
        @or == @last_or
      end

      def timeline
        @timeline = [
          "Game ends after OR #{@last_or}",
        ]
        @timeline.append("Current value of each private company is #{COMPANY_VALUES[[0, @or - 1].max]}")
      end

      include StubsAreRestricted

      def setup
        @or = 0
        # We can modify COMPANY_VALUES if we want to support the shorter variant
        @last_or = COMPANY_VALUES.length
        @recently_floated = []

        # Only small companies are available until later phases
        @corporations, @future_corporations = @corporations.partition { |corporation| corporation.type == :small }

        block_lay_for_purple_tiles
      end

      def init_round
        Round::Draft.new(self,
                         [Step::G18CZ::Draft],
                         snake_order: true)
      end

      def stock_round
        Round::Stock.new(self, [
          Step::DiscardTrain,
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
          Step::G18CZ::Dividend,
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
        @recently_floated.clear
      end

      def par_prices(corp)
        par_nodes = stock_market.par_prices
        available_par_prices = PAR_RANGE[corp.type]
        par_nodes.select { |par_node| available_par_prices.include?(par_node.price) }
      end

      def event_medium_corps_available!
        medium_corps, @future_corporations = @future_corporations.partition { |corporation| corporation.type == :medium }
        @corporations.concat(medium_corps)
        @log << '-- Medium corporations now available --'
      end

      def event_large_corps_available!
        @corporations.concat(@future_corporations)
        @future_corporations.clear
        @log << '-- Large corporations now available --'
      end

      def float_corporation(corporation)
        @recently_floated << corporation
        super
      end

      def or_set_finished
        depot.export!
      end

      def tile_lays(entity)
        return super unless @recently_floated.include?(entity)

        [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }]
      end

      def block_lay_for_purple_tiles
        @tiles.each do |tile|
          tile.blocks_lay = true if tile.name.end_with?('p')
        end
      end
    end
  end
end
