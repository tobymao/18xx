# frozen_string_literal: true

require_relative '../config/game/g_1836_jr30'
require_relative 'base'

module Engine
  module Game
    class G1836Jr30 < Base
      load_from_json(Config::Game::G1836Jr30::JSON)

      DEV_STAGE = :beta
      GAME_LOCATION = 'Netherlands'
      GAME_RULES_URL = 'https://boardgamegeek.com/filepage/114572/1836jr-30-rules'
      GAME_DESIGNER = 'David G. D. Hecht'

      SELL_BUY_ORDER = :sell_buy_sell
      TRACK_RESTRICTION = :permissive
      TILE_RESERVATION_BLOCKS_OTHERS = true

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Track,
          Step::Token,
          Step::Route,
          Step::Dividend,
          Step::G1836Jr30::Train,
        ], round_num: round_num)
      end
      def revenue_for(route)
        revenue = super

        stops = route.stops
        port = stops.find { |stop| stop.groups.include?('port') }

        if port
          raise GameError, "#{port.tile.location_name} must contain 2 other stops" if stops.size < 3

          per_token = port.route_revenue(route.phase, route.train)
          revenue -= per_token # It's already been counted, so remove

          revenue += stops.sum do |stop|
            next per_token if stop.city? && stop.tokened_by?(route.train.owner)

            0
          end
        end

        revenue
      end
    end
  end
end
