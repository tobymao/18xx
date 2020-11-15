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
        @corporations.sort_by(&:name).each do |c|
          unless c.floated?
            @log << "#{c.name} does not receive any Civil War token as it has not floated yet"
            next
          end

          if c.trains.empty? && current_entity != c
            # No effect if corporation has no trains, current entity does not yet have
            # any trains as it is in the middle of a train purchase (which triggered the event)
            # but as it will have a train after the buy is completed it gets the token anyway.
            @log << "#{c.name} does not receive any Civil War token as it owns no trains" if c.floated?
            next
          end

          c.add_ability(Engine::Ability::Base.new(
            type: :civil_war,
            description: 'Civil War! (One time effect)',
            count: 1,
          ))
          @log << "#{c.name} receives a Civil War token which affects its next OR"
        end
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
