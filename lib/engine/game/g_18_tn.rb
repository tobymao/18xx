# frozen_string_literal: true

require_relative '../config/game/g_18_tn'
require_relative '../g_18_tn/share_pool'
require_relative 'base'
require_relative 'company_price_50_to_150_percent'

module Engine
  module Game
    class G18TN < Base
      load_from_json(Config::Game::G18TN::JSON)

      DEV_STAGE = :alpha

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

      HEX_WITH_P_LABEL = %w[F11 H3 H15].freeze

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
        'civil_war' => ['Civil War', 'Companies with trains lose revenue of one train its next OR']
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

        @brown_p_tile ||= @tiles.find { |t| t.name == '170' }
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

      def upgrades_to?(from, to, special = false)
        return true if super

        # When upgrading from green to brown:
        #   Memphis (H3) has no label. P label or no label is OK.
        #   Chattanooga (H15) has C label. Only P label is OK.
        #   Nashville (F11) has N label. Only P label is OK.
        from.color == :green && HEX_WITH_P_LABEL.include?(from.hex.name) && to.color == :brown && to.label.to_s == 'P'
      end

      def all_potential_upgrades(tile)
        upgrades = super

        return upgrades << @brown_p_tile if
          @brown_p_tile &&
          (!tile.hex || HEX_WITH_P_LABEL.include?(tile.hex.name)) &&
          %w[14 15 619 TN1 TN2].include?(tile.name)

        upgrades
      end
    end
  end
end
