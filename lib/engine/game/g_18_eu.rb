# frozen_string_literal: true

require_relative '../config/game/g_18_eu'
require_relative 'base'

module Engine
  module Game
    class G18EU < Base
      load_from_json(Config::Game::G18EU::JSON)

      GAME_LOCATION = 'Europe'
      GAME_RULES_URL = 'http://www.deepthoughtgames.com/games/18EU/Rules.pdf'
      GAME_DESIGNER = 'David Hecht'

      HOME_TOKEN_TIMING = :float
      SELL_AFTER = :operate
      SELL_BUY_ORDER = :sell_buy

      def setup
        @minors.each do |minor|
          train = @depot.upcoming[0]
          minor.buy_train(train, :free)
        end
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::BuyCompany,
          Step::Track,
          Step::Token,
          Step::Route,
          Step::G18EU::Dividend,
          Step::BuyTrain,
          Step::IssueShares,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end
    end
  end
end
