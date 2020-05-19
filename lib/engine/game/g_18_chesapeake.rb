# frozen_string_literal: true

require_relative '../config/game/g_18_chesapeake'
require_relative 'base'

module Engine
  module Game
    class G18Chesapeake < Base
      load_from_json(Config::Game::G18Chesapeake::JSON)

      DEV_STAGE = :alpha

      def or_set_finished
        depot.export! if %w[2 3 4].include?(@depot.upcoming.first.name)
      end

      def stock_round
        Round::Stock.new(@players, game: self, sell_buy_order: :sell_buy)
      end
    end
  end
end
