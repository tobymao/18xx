# frozen_string_literal: true

require_relative '../config/game/g_18_newengland'
require_relative 'base'

module Engine
  module Game
    class G18NewEngland < Base
      register_colors(green: '#237333',
                      red: '#d81e3e',
                      blue: '#0189d1',
                      lightBlue: '#a2dced',
                      yellow: '#FFF500',
                      orange: '#f48221',
                      brown: '#7b352a')

      load_from_json(Config::Game::G18NewEngland::JSON)

      def stock_round
        Round::Stock.new(@players, game: self, sell_buy_order: :sell_buy)
      end
    end
  end
end
