# frozen_string_literal: true

require_relative '../config/game/g_18_al'
require_relative 'base'
require_relative 'company_price_50_to_150_percent'

module Engine
  module Game
    class G18AL < Base
      load_from_json(Config::Game::G18AL::JSON)
      AXES = { x: :number, y: :letter }.freeze

      GAME_LOCATION = 'Alabama, USA'
      GAME_RULES_URL = 'http://www.diogenes.sacramento.ca.us/18AL_Rules_v1_64.pdf'
      GAME_DESIGNER = 'Mark Derrick'

      include CompanyPrice50To150Percent

      def setup
        setup_company_price_50_to_150_percent
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::DiscardTrain,
          Step::BuyCompany,
          Step::HomeToken,
          Step::Track,
          Step::Token,
          Step::Route,
          Step::Dividend,
          Step::SingleDepotTrainBuyBeforePhase4,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def revenue_for(route)
        ensure_terminus_first_or_last(route, %w[A4 Q2])

        super
      end

      private

      def ensure_terminus_first_or_last(route, termini)
        route.hexes[1...-1].each do |hex|
          next unless termini.include? hex.name

          raise GameError, "#{hex.location_name} must be first or last in route"
        end
      end
    end
  end
end
