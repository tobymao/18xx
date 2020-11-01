# frozen_string_literal: true

require_relative '../config/game/g_18_new_england'
require_relative 'base'

module Engine
  module Game
    class G18NewEngland < Base
      load_from_json(Config::Game::G18NewEngland::JSON)

      GAME_LOCATION = 'Southern New England, USA'
      GAME_RULES_URL = 'https://docs.google.com/document/d/1hgh1_-RMgEnQI1XlodT_6UpPU5ZnEZtMT6Yg5TOuXOw'
      GAME_DESIGNER = 'Scott Petersen'
      GAME_PUBLISHER = :all_aboard_games

      SELL_BUY_ORDER = :sell_buy

      def setup
        @minors.each do |minor|
          train = @depot.upcoming[0]
          train.buyable = false
          minor.cash = 200
          minor.buy_train(train)
          hex = hex_by_id(minor.coordinates)
          hex.tile.cities[0].place_token(minor, minor.next_token)
        end
      end
    end
  end
end
