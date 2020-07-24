# frozen_string_literal: true

require_relative '../config/game/g_18_al'
require_relative 'base'
require_relative 'company_price_50_to_150_percent'
require_relative 'revenue_4d'
require_relative 'terminus_check'

module Engine
  module Game
    class G18AL < Base
      load_from_json(Config::Game::G18AL::JSON)
      AXES = { x: :number, y: :letter }.freeze

      DEV_STAGE = :alpha

      GAME_LOCATION = 'Alabama, USA'
      GAME_RULES_URL = 'http://www.diogenes.sacramento.ca.us/18AL_Rules_v1_64.pdf'
      GAME_DESIGNER = 'Mark Derrick'
      GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_or, bank: :current_or }.freeze

      include CompanyPrice50To150Percent
      include Revenue4D
      include TerminusCheck

      def setup
        setup_company_price_50_to_150_percent

        @corporations.each do |corporation|
          corporation.abilities(:assign_hexes) do |ability|
            historical_objective_city_name = @hexes.find { |h| h.name == ability.hexes.first }.location_name
            ability.description = "Historical objective: #{historical_objective_city_name}"
          end
        end
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::DiscardTrain,
          Step::BuyCompany,
          Step::HomeToken,
          Step::G18AL::Track,
          Step::G18AL::Token,
          Step::Route,
          Step::Dividend,
          Step::SingleDepotTrainBuyBeforePhase4,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def revenue_for(route)
        # Mobile and Nashville should not be possible to pass through
        ensure_termini_not_passed_through(route, %w[A4 Q2])

        adjust_revenue_for_4d_train(route, super)
      end
    end
  end
end
