# frozen_string_literal: true

require_relative '../config/game/g_18_tn'
require_relative '../g_18_tn/share_pool'
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
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18TN'

      STATUS_TEXT = Base::STATUS_TEXT.merge(
        'can_buy_companies_operation_round_one' =>
          ['Can Buy Companies OR 1', 'Corporations can buy companies for face value in OR 1'],
      ).merge(
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

        # Illinois Central has a 30% presidency share
        ic = @corporations.find { |c| c.id == 'IC' }
        presidents_share = ic.shares_by_corporation[ic].first
        presidents_share.percent = 30
        final_share = ic.shares_by_corporation[ic].last
        @share_pool.transfer_shares(final_share.to_bundle, @bank)
      end

      def operating_round(round_num)
        # For OR 1, set company buy price to face value only
        @companies.each do |company|
          company.min_price = company.value
          company.max_price = company.value
        end if @turn == 1

        # After OR 1, the company buy price is changed to 50%-150%
        setup_company_price_50_to_150_percent if @turn == 2 && round_num == 1

        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::DiscardTrain,
          Step::SpecialTrack,
          Step::G18TN::BuyCompany,
          Step::HomeToken,
          Step::G18TN::Track,
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

      def init_share_pool
        Engine::G18TN::SharePool.new(self)
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

      def lnr
        @lnr ||= company_by_id('LNR')
      end

      def label_check_override(existing_tile, upgrade_candidate)
        # This is needed to allow for Memphis (in green) to upgrade either to normal brown (63)
        # or to the P labeled brown (170)
        return false if existing_tile.hex.name != 'H3' || existing_tile.color != :green

        upgrade_candidate.name != '63' || upgrade_candidate.name != '170'
      end
    end
  end
end
