# frozen_string_literal: true

require_relative '../config/game/g_18_tn'
require_relative 'base'
require_relative 'company_price_50_to_150_percent'

module Engine
  module Game
    class G18TN < Base
      load_from_json(Config::Game::G18TN::JSON)

      GAME_LOCATION = 'Tennessee, USA'
      GAME_RULES_URL = 'http://dl.deepthoughtgames.com/18TN-Rules.pdf'
      GAME_DESIGNER = 'Mark Derrick'
      GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_or, bank: :current_or }.freeze

      STATUS_TEXT = Base::STATUS_TEXT.merge(
        Step::SingleDepotTrainBuyBeforePhase4::STATUS_TEXT
      ).freeze

      # Two lays or one upgrade
      TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }].freeze

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
        'civil_war' => ['Civil War', 'Companies with trains loose revenue of one train its next OR']
      ).freeze

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
          Step::G18TN::Dividend,
          Step::SingleDepotTrainBuyBeforePhase4,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def routes_revenue(routes)
        total_revenue = super

        abilities = routes.first&.corporation&.abilities(:civil_war)

        return total_revenue if !abilities || abilities.empty?

        total_revenue - routes.map(&:revenue).min
      end

      def event_civil_war!
        @log << '-- Event: Civil War! --'
        @corporations.each do |c|
          # No effect if corporation has no trains
          next if c.trains.empty?

          c.add_ability(Engine::Ability::Base.new(
            type: :civil_war,
            description: 'Civil War! (One time effect)',
            count: 1,
          ))
        end
      end
    end
  end
end
