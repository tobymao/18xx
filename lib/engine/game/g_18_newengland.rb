# frozen_string_literal: true

require_relative '../config/game/g_18_newengland'
require_relative 'base'

module Engine
  module Game
    class G18NewEngland < Base
      load_from_json(Config::Game::G18NewEngland::JSON)

      def stock_round
        Round::Stock.new(@players, game: self, sell_buy_order: :sell_buy)
      end

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
