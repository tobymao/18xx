# frozen_string_literal: true

require_relative '../config/game/g_18_mex'
require_relative 'base'
require_relative 'company_price_50_to_150_percent'
require_relative 'revenue_4d'
require_relative 'terminus_check'
module Engine
  module Game
    class G18MEX < Base
      load_from_json(Config::Game::G18MEX::JSON)
      AXES = { x: :number, y: :letter }.freeze

      GAME_LOCATION = 'Mexico'
      GAME_RULES_URL = 'https://secure.deepthoughtgames.com/games/18MEX/rules.pdf'
      GAME_DESIGNER = 'Mark Derrick'
      GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_or, bank: :current_or }.freeze

      STATUS_TEXT = Base::STATUS_TEXT.merge(
        Step::SingleDepotTrainBuyBeforePhase4::STATUS_TEXT
      ).freeze

      include CompanyPrice50To150Percent
      include Revenue4D
      include TerminusCheck

      def setup
        setup_company_price_50_to_150_percent

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
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::DiscardTrain,
          Step::BuyCompany,
          Step::HomeToken,
          Step::SpecialTrack,
          Step::Track,
          Step::Token,
          Step::Route,
          Step::Dividend,
          Step::SingleDepotTrainBuyBeforePhase4,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def revenue_for(route)
        # Merida should not be possible to pass-through
        ensure_termini_not_passed_through(route, %w[Q14])

        adjust_revenue_for_4d_train(route, super)
      end
    end
  end
end
