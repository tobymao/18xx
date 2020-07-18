# frozen_string_literal: true

require_relative '../config/game/g_18_ga'
require_relative 'base'
require_relative 'company_price_50_to_150_percent'

module Engine
  module Game
    class G18GA < Base
      load_from_json(Config::Game::G18GA::JSON)

      GAME_LOCATION = 'Georgia, USA'
      GAME_RULES_URL = 'http://www.diogenes.sacramento.ca.us/18GA_Rules_v3_26.pdf'
      GAME_DESIGNER = 'Mark Derrick'

      include CompanyPrice50To150Percent

      def setup
        setup_company_price_50_to_150_percent
      end
    end
  end
end
