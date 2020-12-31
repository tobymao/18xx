# frozen_string_literal: true

require_relative '../config/game/g_18_chesapeake_after_dark'
require_relative 'g_18_chesapeake'

module Engine
  module Game
    class G18ChesapeakeAfterDark < G18Chesapeake
      load_from_json(Config::Game::G18ChesapeakeAfterDark::JSON)

      DEV_STAGE = :alpha

      GAME_RULES_URL = 'https://docs.google.com/document/d/1HI9HyOoCamBEbuE_HCzr2b86xtRDI_hBI3Sbc53KxyA/edit'
      GAME_DESIGNER = 'Scott Petersen'

      SELL_BUY_ORDER = :sell_buy_sell

      def self.title
        '18Chesapeake After Dark'
      end

      def or_set_finished; end
    end
  end
end
