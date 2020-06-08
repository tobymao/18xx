# frozen_string_literal: true

require_relative '../config/game/g_1882'
require_relative 'base'
require_relative '../publisher/all_aboard_games.rb'

module Engine
  module Game
    class G1882 < Base
      register_colors(green: '#237333',
                      gray: '#9a9a9d',
                      red: '#d81e3e',
                      blue: '#0189d1',
                      yellow: '#FFF500',
                      brown: '#7b352a')

      load_from_json(Config::Game::G1882::JSON)

      GAME_LOCATION = 'Assiniboia, Canada'
      GAME_RULES_URL = 'https://www.boardgamegeek.com/filepage/189409/1882-rules'
      GAME_DESIGNER = 'Marc Voyer'
      GAME_PUBLISHER = Publisher::AllAboardGames

      def stock_round
        Round::Stock.new(@players, game: self, sell_buy_order: :sell_buy_sell)
      end
    end
  end
end
