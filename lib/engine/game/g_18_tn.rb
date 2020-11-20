# frozen_string_literal: true

require_relative '../config/game/g_18_tn'
require_relative '../g_18_tn/share_pool'
require_relative 'base'
require_relative 'company_price_50_to_150_percent'

module Engine
  module Game
    class G18TN < Base
      load_from_json(Config::Game::G18TN::JSON)

      DEV_STAGE = :production

      GAME_LOCATION = 'Tennessee, USA'
      GAME_RULES_URL = 'http://dl.deepthoughtgames.com/18TN-Rules.pdf'
      GAME_DESIGNER = 'Mark Derrick'
      GAME_PUBLISHER = :golden_spike
      GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_or, bank: :current_or }.freeze
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18TN'

      STATUS_TEXT = Base::STATUS_TEXT.merge(
        'can_buy_companies_operation_round_one' =>
          ['Can Buy Companies OR 1', 'Corporations can buy companies for face value in OR 1'],
      ).merge(
          Step::SingleDepotTrainBuy::STATUS_TEXT
        ).freeze

      # Two lays or one upgrade
      TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }].freeze

      HEX_WITH_P_LABEL = %w[F11 H3 H15].freeze
      STANDARD_YELLOW_CITY_TILES = %w[5 6 57].freeze
      GREEN_CITY_TILES = %w[14 15 619 TN1 TN2].freeze
      PREPRINT_COLOR_ON_BORDER = %w[C12 D11 G6].freeze

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
        @green_nashville_tile ||= @tiles.find { |t| t.name == 'TN2' }
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
          Step::G18TN::SpecialTrack,
          Step::G18TN::BuyCompany,
          Step::HomeToken,
          Step::G18TN::Track,
          Step::Token,
          Step::Route,
          Step::G18TN::Dividend,
          Step::SingleDepotTrainBuy,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def stock_round
        Round::Stock.new(self, [
          Step::BuySellParShares,
        ])
      end

      def routes_revenue(routes)
        total_revenue = super

        corporation = routes.first&.corporation

        abilities = corporation&.abilities(:civil_war)

        return total_revenue if !abilities || abilities.empty? || routes.size < corporation.trains.size

        # The train with the lowest revenue loses the income due to the war effort
        total_revenue - routes.map(&:revenue).min
      end

      def init_share_pool
        Engine::G18TN::SharePool.new(self)
      end

      def event_civil_war!
        @log << '-- Event: Civil War! --'

        # Corporations that are active and own trains does get a Civil War token.
        # The current entity might not have any, but the 3' train it bought that
        # triggered the Civil War will be part of the trains for it.
        # There is a possibility that the trains will not have a valid route but
        # that is handled in the route code.
        corps = @corporations.select do |c|
          (c == current_entity) || (c.floated? && c.trains.any?)
        end

        corps.each do |corp|
          corp.add_ability(Engine::Ability::Base.new(
            type: :civil_war,
            description: 'Civil War! (One time effect)',
            count: 1,
          ))
        end

        @log << "#{corps.map(&:name).sort.join(', ')} each receive a Civil War token which affects their next OR"
      end

      def lnr
        @lnr ||= company_by_id('LNR')
      end

      def upgrades_to?(from, to, special = false)
        # When upgrading from green to brown:
        #   If Memphis (H3), Chattanooga (H15), Nashville (F11)
        #   only brown P tile (#170) are allowed.
        return to.name == '170' if from.color == :green && HEX_WITH_P_LABEL.include?(from.hex.name)

        # When upgrading Nashville (F11) from yellow to green, only TN2 from green to brown:
        return to.name == 'TN2' if from.color == :yellow && from.hex.name == 'F11'

        super
      end

      def all_potential_upgrades(tile, tile_manifest: false)
        upgrades = super

        return upgrades unless tile_manifest

        # Tile manifest for yellow standard cities should show N tile (TN1) as an option
        upgrades |= [@green_nashville_tile] if @green_nashville_tile && STANDARD_YELLOW_CITY_TILES.include?(tile.name)

        # Tile manifest for green cities should show P tile as an option
        upgrades |= [@brown_p_tile] if @brown_p_tile && GREEN_CITY_TILES.include?(tile.name)

        upgrades
      end
    end
  end
end
