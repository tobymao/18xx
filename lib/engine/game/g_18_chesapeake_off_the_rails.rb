# frozen_string_literal: true

require_relative '../config/game/g_18_chesapeake_off_the_rails'
require_relative 'g_18_chesapeake'

module Engine
  module Game
    class G18ChesapeakeOffTheRails < G18Chesapeake
      load_from_json(Config::Game::G18ChesapeakeOffTheRails::JSON)

      DEV_STAGE = :beta

      GAME_RULES_URL = 'https://www.dropbox.com/s/ivm4jsopnzabhru/18ChesOTR_Rules.png?dl=0'
      GAME_DESIGNER = 'Scott Petersen'

      SELL_BUY_ORDER = :sell_buy_sell

      GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_round, bank: :full_or }.freeze

      def self.title
        '18Chesapeake: Off the Rails'
      end

      def or_set_finished; end
    end
  end
end
