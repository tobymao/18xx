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

      DEV_STAGE = :beta

      GAME_LOCATION = 'Alabama, USA'
      GAME_RULES_URL = 'http://www.diogenes.sacramento.ca.us/18AL_Rules_v1_64.pdf'
      GAME_DESIGNER = 'Mark Derrick'
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18AL'

      GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_or, bank: :current_or }.freeze

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
        'remove_tokens' => ['Remove Tokens', 'Warrior Coal Field token removed']
      ).freeze

      STATUS_TEXT = Base::STATUS_TEXT.merge(
        'can_buy_companies_from_other_players' => ['Interplayer Company Buy', 'Companies can be bought between players']
      ).merge(
        Step::SingleDepotTrainBuyBeforePhase4::STATUS_TEXT
      ).freeze

      ROUTE_BONUSES = %i[atlanta_birmingham mobile_nashville].freeze

      YELLOW_CITIES = %w[5 6 57].freeze

      include CompanyPrice50To150Percent
      include Revenue4D
      include TerminusCheck

      def route_bonuses
        ROUTE_BONUSES
      end

      def setup
        setup_company_price_50_to_150_percent

        @corporations.each do |corporation|
          corporation.abilities(:assign_hexes) do |ability|
            ability.description = "Historical objective: #{get_location_name(ability.hexes.first)}"
          end
        end

        @green_m_tile ||= @tiles.find { |t| t.name == '443a' }
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::DiscardTrain,
          Step::G18AL::Assign,
          Step::G18AL::BuyCompany,
          Step::HomeToken,
          Step::SpecialTrack,
          Step::Track,
          Step::G18AL::Token,
          Step::Route,
          Step::Dividend,
          Step::SpecialBuyTrain,
          Step::SingleDepotTrainBuyBeforePhase4,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def stock_round
        Round::Stock.new(self, [
          Step::DiscardTrain,
          Step::G18AL::BuySellParShares,
        ])
      end

      def revenue_for(route)
        # Mobile and Nashville should not be possible to pass through
        ensure_termini_not_passed_through(route, %w[A4 Q2])

        revenue = adjust_revenue_for_4d_train(route, super)

        route.corporation.abilities(:hexes_bonus) do |ability|
          revenue += route.stops.sum { |stop| ability.hexes.include?(stop.hex.id) ? ability.amount : 0 }
        end

        revenue
      end

      def routes_revenue(routes)
        total_revenue = super
        route_bonuses.each do |type|
          abilities = routes.first.corporation.abilities(type)
          return total_revenue if abilities.empty?

          total_revenue += routes.map { |r| route_bonus(r, type) }.max
        end if routes.any?
        total_revenue
      end

      def event_remove_tokens!
        @corporations.each do |corporation|
          corporation.abilities(:hexes_bonus) do |a|
            @log << "#{corporation.name} removes: #{a.description}"
            remove_mining_icons(a.hexes)
            corporation.remove_ability(a)
          end
        end
      end

      def event_close_companies!
        super

        # Remove mining icons if Warrior Coal Field has not been assigned
        @corporations.each do |corporation|
          next if corporation.abilities(:hexes_bonus).empty?

          @companies.each do |company|
            company.abilities(:assign_hexes) do |ability|
              remove_mining_icons(ability.hexes)
            end
          end
        end
      end

      def get_location_name(hex_name)
        @hexes.find { |h| h.name == hex_name }.location_name
      end

      def remove_mining_icons(hexes_to_clear, exclude: nil)
        @hexes
          .select { |hex| hexes_to_clear.include?(hex.name) && exclude != hex.name }
          .each { |hex| hex.tile.icons = [] }
      end

      def upgrades_to?(from, to, special = false)
        # When upgrading from yellow to green:
        #   Montgomery has no label in yellow. Green and brown tile for Montgomery
        #   has M label, and no other tiles are allowed.

        return super if from.color != :yellow || from.hex.name != 'L5'

        to.color == :green && to.label.to_s == 'M'
      end

      def all_potential_upgrades(tile)
        # Lumber terminal cannot be upgraded
        return [] if tile.name == '445'

        upgrades = super

        # Add M tile as upgrade posibility to yellow city tiles in the tile manifest
        return upgrades << @green_m_tile if
          (!tile.hex || tile.hex.name == 'A1') && # A1 seem to be default hex name for unlaid
          @green_m_tile &&
          YELLOW_CITIES.include?(tile.name)

        upgrades
      end

      private

      def route_bonus(route, type)
        route.corporation.abilities(type).sum do |ability|
          ability.hexes == (ability.hexes & route.hexes.map(&:name)) ? ability.amount : 0
        end
      end
    end
  end
end
