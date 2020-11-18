# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength
# frozen_string_literal: true

require_relative '../config/game/g_1870'
require_relative 'base'
require_relative '../g_1870/stock_market'

module Engine
  module Game
    class G1870 < Base
      register_colors(black: '#37383a',
                      orange: '#f48221',
                      brightGreen: '#76a042',
                      red: '#d81e3e',
                      turquoise: '#00a993',
                      blue: '#0189d1',
                      brown: '#7b352a')

      load_from_json(Config::Game::G1870::JSON)

      GAME_LOCATION = 'Mississippi, USA'
      GAME_RULES_URL = 'http://www.hexagonia.com/rules/MFG_1870.pdf'
      GAME_DESIGNER = 'Bill Dixon'
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1870'

      EBUY_PRES_SWAP = false
      EBUY_OTHER_VALUE = false

      CLOSED_CORP_TRAINS = :discarded

      TILE_LAYS = [{ lay: true, upgrade: true, cost: 0 }, { lay: :not_if_upgraded, upgrade: false, cost: 0 }].freeze

      STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(unlimited: :green).merge(par: :white).merge(ignore_one_sale: :red).freeze

      EVENTS_TEXT = Base::EVENTS_TEXT.merge('remove_tokens' => ['Remove Tokens', 'Remove private company tokens']).freeze
      MARKET_TEXT = Base::MARKET_TEXT.merge(ignore_one_sale: 'Can only enter when 2 shares sold at the same time').freeze

      ASSIGNMENT_TOKENS = {
        'GSC' => '/icons/1846/mpc_token.svg',
        'SCC' => '/icons/1846/sc_token.svg',
      }.freeze

      def stock_round
        Round::Stock.new(self, [
          Step::DiscardTrain,
          Step::BuySellParShares,
          Step::G1870::PriceProtection,
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
          Step::G1870::Dividend,
          Step::BuyTrain,
          [Step::BuyCompany, blocks: true],
          # Step::ConnectionRun,
        ], round_num: round_num)
      end

      def init_stock_market
        Engine::G1870::StockMarket.new(self.class::MARKET, self.class::CERT_LIMIT_TYPES,
                                       multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
      end

      def corporation_opts
        { can_hold_above_max: true }
      end

      def sell_shares_and_change_price(bundle)
        @round.sell_queue << bundle

        @share_pool.sell_shares(bundle)
      end
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength
