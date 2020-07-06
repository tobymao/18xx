# frozen_string_literal: true

require_relative '../config/game/g_18_ga'
require_relative 'base'

module Engine
  module Game
    class G18GA < Base
      load_from_json(Config::Game::G18GA::JSON)

      GAME_LOCATION = 'Georgia, USA'
      GAME_RULES_URL = 'http://www.diogenes.sacramento.ca.us/18GA_Rules_v3_26.pdf'
      GAME_DESIGNER = 'Mark Derrick'

      def operating_round(round_num)
        Round::G18GA::Operating.new(@corporations, game: self, round_num: round_num)
      end
    end
  end
end
