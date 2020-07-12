# frozen_string_literal: true

require_relative '../config/game/g_18_mex'
require_relative 'base'
require_relative 'company_price_50_to_150_percent'

module Engine
  module Game
    class G18MEX < Base
      load_from_json(Config::Game::G18MEX::JSON)
      AXES = { x: :number, y: :letter }.freeze

      GAME_LOCATION = 'Mexico'
      GAME_RULES_URL = 'https://secure.deepthoughtgames.com/games/18MEX/rules.pdf'
      GAME_DESIGNER = 'Mark Derrick'

      include CompanyPrice50To150Percent
      def setup
        @minors.each do |minor|
          train = @depot.upcoming[0]
          train.buyable = false
          minor.cash = 100
          minor.buy_train(train)
          hex = hex_by_id(minor.coordinates)
          hex.tile.cities[0].place_token(minor, minor.next_token)
        end
      end

      def operating_round(round_num)
        Round::G18MEX::Operating.new(@minors + @corporations, game: self, round_num: round_num)
      end
    end
  end
end
