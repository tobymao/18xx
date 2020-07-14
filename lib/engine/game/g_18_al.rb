# frozen_string_literal: true

require_relative '../config/game/g_18_al'
require_relative 'base'
require_relative 'company_price_50_to_150_percent'

module Engine
  module Game
    class G18AL < Base
      load_from_json(Config::Game::G18AL::JSON)
      AXES = { x: :number, y: :letter }.freeze

      GAME_LOCATION = 'Alabama, USA'
      GAME_RULES_URL = 'http://www.diogenes.sacramento.ca.us/18AL_Rules_v1_64.pdf'
      GAME_DESIGNER = 'Mark Derrick'

      include CompanyPrice50To150Percent

      def operating_round(round_num)
        Round::G18AL::Operating.new(@corporations, game: self, round_num: round_num)
      end

      def revenue_for(route)
        revenue = super

        if route.train.name == '4D'
          revenue = 2 * revenue - route.stops
            .select { |stop| stop.hex.tile.towns.any? }
            .sum { |stop| stop.route_revenue(route.phase, route.train) }
        end

        revenue
      end
    end
  end
end
