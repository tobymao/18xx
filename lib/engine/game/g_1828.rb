# frozen_string_literal: true

require_relative '../config/game/g_1828'
require_relative 'base'

module Engine
  module Game
    class G1828 < Base
      register_colors(hanBlue: '#446CCF',
                      steelBlue: '#4682B4',
                      brick: '#9C661F',
                      powderBlue: '#B0E0E6',
                      khaki: '#F0E68C',
                      darkGoldenrod: '#B8860B',
                      yellowGreen: '#9ACD32',
                      gray70: '#B3B3B3',
                      khakiDark: '#BDB76B',
                      thistle: '#D8BFD8',
                      lightCoral: '#F08080',
                      tan: '#D2B48C',
                      gray50: '#7F7F7F',
                      cinnabarGreen: '#61B329',
                      tomato: '#FF6347',
                      plum: '#DDA0DD',
                      lightGoldenrod: '#EEDD82')

      load_from_json(Config::Game::G1828::JSON)

      DEV_STAGE = :prealpha

      GAME_LOCATION = 'North East, USA'
      GAME_RULES_URL = 'https://kanga.nu/~claw/1828/1828-Rules.pdf'
      GAME_PUBLISHER = nil
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1828'

      MUST_BID_INCREMENT_MULTIPLE = true
      SELL_BUY_ORDER = :sell_buy_sell

      def stock_round
        Round::Stock.new(self, [
          Step::DiscardTrain,
          Step::BuySellParShares,
        ])
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::DiscardTrain,
          Step::SpecialTrack,
          Step::BuyCompany,
          Step::Track,
          Step::Token,
          Step::Route,
          Step::Dividend,
          Step::BuyTrain,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end
    end
  end
end
