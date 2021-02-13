# frozen_string_literal: true

require_relative '../config/game/g_1830'
require_relative 'base'

module Engine
  module Game
    class G1830 < Base
      register_colors(red: '#d1232a',
                      orange: '#f58121',
                      black: '#110a0c',
                      blue: '#025aaa',
                      lightBlue: '#8dd7f6',
                      yellow: '#ffe600',
                      green: '#32763f',
                      brightGreen: '#6ec037')
      DEV_STAGE = :alpha
      GAME_LOCATION = 'Northeastern USA and Southeastern Canada'
      GAME_RULES_URL = 'https://lookout-spiele.de/upload/en_1830re.html_Rules_1830-RE_EN.pdf'
      GAME_PUBLISHER = :lookout
      GAME_DESIGNER = 'Francis Tresham'
      TRACK_RESTRICTION = :permissive
      SELL_BUY_ORDER = :sell_buy_sell
      load_from_json(Config::Game::G1830::JSON)

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::Exchange,
          Step::SpecialTrack,
          Step::SpecialToken,
          Step::BuyCompany,
          Step::HomeToken,
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
