# frozen_string_literal: true

require_relative '../config/game/g_1835'
require_relative 'base'

module Engine
  module Game
    class G1835 < Base
      register_colors(black: '#37383a',
                      seRed: '#f72d2d',
                      bePurple: '#2d0047',
                      peBlack: '#000',
                      beBlue: '#c3deeb',
                      heGreen: '#78c292',
                      oegray: '#6e6966',
                      weYellow: '#ebff45',
                      beBrown: '#54230e',
                      gray: '#6e6966',
                      red: '#d81e3e',
                      turquoise: '#00a993',
                      blue: '#0189d1',
                      brown: '#7b352a')

      load_from_json(Config::Game::G1835::JSON)

      DEV_STAGE = :prealpha

      SELL_MOVEMENT = :down_per_10

      GAME_LOCATION = 'Germany'
      GAME_RULES_URL = 'http://google.com'
      GAME_DESIGNER = 'Michael Meier-Bachl, Francis Tresham'
      GAME_INFO_URL = 'https://google.com'

      HOME_TOKEN_TIMING = :operating_round

      def setup
        # 1 of each right is reserved w/ the private when it gets bought in. This leaves 2 extra to sell.
        @available_bridge_tokens = 2
        @available_tunnel_tokens = 2
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::Exchange,
          Step::BuyCompany,
          Step::SpecialTrack,
          Step::SpecialToken,
          Step::Track,
          Step::Token,
          Step::Route,
          Step::Dividend,
          Step::DiscardTrain,
          Step::BuyTrain,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end
    end
  end
end
