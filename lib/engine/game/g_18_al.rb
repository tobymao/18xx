# frozen_string_literal: true

require_relative '../config/game/g_18_al'
require_relative 'base'
require_relative 'company_price_50_to_150_percent'

module Engine
  module Game
    class G18AL < Base
      load_from_json(Config::Game::G18AL::JSON)
      AXES = { x: :number, y: :letter }.freeze

      DEV_STAGE = :production

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
        Step::SingleDepotTrainBuy::STATUS_TEXT
      ).freeze

      ROUTE_BONUSES = %i[atlanta_birmingham mobile_nashville].freeze

      STANDARD_YELLOW_CITY_TILES = %w[5 6 57].freeze

      OPTIONAL_RULES = [
        { sym: :double_yellow_first_or, short_name: 'Extra yellow', desc: '7a: Allow corporation to lay 2 yellows its first OR' },
        { sym: :LN_home_city_moved, short_name: 'Move L&N home', desc: '7b: Move L&N home city to Decatur - Nashville becomes off board hex' },
        { sym: :unlimited_4d, short_name: 'Unlimited 4D', desc: '7c: Unlimited number of 4D' },
        { sym: :hard_rust_t4, short_name: 'Hard rust', desc: '7d: Hard rust for 4 trains' },
      ].freeze

      ASSIGNMENT_TOKENS = {
        'SNAR' => '/icons/18_al/snar_token.svg',
      }.freeze
      include CompanyPrice50To150Percent

      def route_bonuses
        ROUTE_BONUSES
      end

      def setup
        @recently_floated = []

        setup_company_price_50_to_150_percent

        begin
          @log << 'Optional rule used in this game:'
          OPTIONAL_RULES.each do |o_r|
            next unless @optional_rules&.include?(o_r[:sym])

            @log << " * #{o_r[:short_name]} (#{o_r[:desc]})"
          end
          move_ln_corporation if @optional_rules&.include?(:LN_home_city_moved)
          add_extra_4d if @optional_rules&.include?(:unlimited_4d)
          change_4t_to_hardrust if @optional_rules&.include?(:hard_rust_t4)
        end if @optional_rules

        @corporations.each do |corporation|
          corporation.abilities(:assign_hexes) do |ability|
            ability.description = "Historical objective: #{get_location_name(ability.hexes.first)}"
          end
        end

        @green_m_tile ||= @tiles.find { |t| t.name == '443a' }
      end

      def south_and_north_alabama_railroad
        @south_and_north_alabama_railroad ||= company_by_id('SNAR')
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
          Step::SingleDepotTrainBuy,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def or_round_finished
        @recently_floated = []
      end

      def stock_round
        Round::Stock.new(self, [
          Step::DiscardTrain,
          Step::G18AL::BuySellParShares,
        ])
      end

      def revenue_for(route, stops)
        revenue = super

        route.corporation.abilities(:hexes_bonus) do |ability|
          revenue += stops.sum { |stop| ability.hexes.include?(stop.hex.id) ? ability.amount : 0 }
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
            assigned_hex = @hexes.find { |h| a.hexes.include?(h.name) }
            hex_name = assigned_hex.name
            assigned_hex.remove_assignment!(south_and_north_alabama_railroad.id)
            corporation.remove_ability(a)

            @log << "Warrior Coal Field token is removed from #{get_location_name(hex_name)} (#{hex_name})"
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

      def remove_mining_icons(hexes_to_clear)
        @hexes
          .select { |hex| hexes_to_clear.include?(hex.name) }
          .each { |hex| hex.tile.icons = [] }
      end

      def upgrades_to?(from, to, special = false)
        # Lumber terminal cannot be upgraded
        return false if from.name == '445'

        # If upgrading Montgomery (L5) to green, only M tile #443a is allowed
        return to.name == '443a' if from.color == :yellow && from.hex.name == 'L5'

        super
      end

      def float_corporation(corporation)
        @recently_floated << corporation

        super
      end

      def all_potential_upgrades(tile, tile_manifest: false)
        # Lumber terminal cannot be upgraded
        return [] if tile.name == '445'

        upgrades = super

        return upgrades unless tile_manifest

        # Tile manifest for yellow cities should show M tile as an option
        upgrades |= [@green_m_tile] if @green_m_tile && STANDARD_YELLOW_CITY_TILES.include?(tile.name)

        upgrades
      end

      def tile_lays(entity)
        return super if !@optional_rules&.include?(:double_yellow_first_or) ||
          !@recently_floated&.include?(entity)

        [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }]
      end

      private

      def route_bonus(route, type)
        route.corporation.abilities(type).sum do |ability|
          ability.hexes == (ability.hexes & route.hexes.map(&:name)) ? ability.amount : 0
        end
      end

      def move_ln_corporation
        ln = corporation_by_id('L&N')
        previous_hex = @hexes.find { |h| h.name == 'A4' }
        old_tile = previous_hex.tile
        tile_string = 'offboard=revenue:yellow_40|brown_50;path=a:0,b:_0;path=a:1,b:_0'
        previous_hex.tile = Tile.from_code(old_tile.name, old_tile.color, tile_string)

        ln.coordinates = 'C4'
      end

      def add_extra_4d
        diesel_trains = @depot.trains.select { |t| t.name == '4D' }
        diesel = diesel_trains.first
        (diesel_trains.length + 1).upto(8) do |i|
          new_4d = diesel.clone
          new_4d.index = i
          @depot.add_train(new_4d)
        end
      end

      def change_4t_to_hardrust
        @depot.trains
          .select { |t| t.name == '4' }
          .each do |t|
            t.rusts_on = t.obsolete_on
            t.obsolete_on = nil
          end
      end
    end
  end
end
