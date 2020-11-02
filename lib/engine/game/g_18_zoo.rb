# frozen_string_literal: true

require_relative '../config/game/g_18_zoo'
require_relative 'base'

module Engine
  module Game
    class G18ZOO < Base
      load_from_json(Config::Game::G18ZOO::JSON)

      GAME_DESIGNER = 'Paolo Russo'

      #Game end after the ORs in the third turn, of if any company reach 24
      GAME_END_CHECK = {stock_market: :current_or, custom: :full_or}.freeze

      OPTIONAL_RULES = [
          {sym: :map_a, short_name: 'Map A', desc: '5 families'},
          # {sym: :map_b, short_name: 'Map B', desc: '5 families'}, TODO: unblock after the map creation
          # {sym: :map_c, short_name: 'Map C', desc: '5 families'}, TODO: unblock after the map creation
          # {sym: :map_d, short_name: 'Map D', desc: '5 families'}, TODO: unblock after the map creation
          # {sym: :map_e, short_name: 'Map E', desc: '5 families'}, TODO: unblock after the map creation
          # {sym: :map_f, short_name: 'Map F', desc: '5 families'}, TODO: unblock after the map creation
          {sym: :power_visible, short_name: 'Poteri scoperti', desc: 'Poteri scoperti'},
      ].freeze

      BANKRUPTCY_ALLOWED = false

      HOME_TOKEN_TIMING = :float

      SELL_BUY_ORDER = :sell_buy

      # Two lays or one upgrade
      TILE_LAYS = [{lay: true, upgrade: true}, {lay: :not_if_upgraded, upgrade: false}].freeze

      def init_optional_rules(optional_rules)
        optional_rules = super

        maps = optional_rules.select { |rule| rule.start_with?('map_') }
        raise GameError, 'Please select a single map.' unless maps.size == 1

        @map = maps.first
        raise GameError, 'Please select map D, E or F to play with five players.' if @players.size == 5 and [:map_a, :map_b, :map_c].include?(@map)

        @real_map = case (@map)
                    when :map_a then
                      Engine::Game::G18ZOO::MapA.new(@names)
                    when :map_b then
                    when :map_c then
                    when :map_d then
                    when :map_e then
                    when :map_f then
                    end
        @map_for_rules = [:map_a, :map_b, :map_c].include?(@map) ? :small : :large

        optional_rules
      end

      def init_cert_limit
        @real_map.init_cert_limit
      end

      def init_starting_cash(players, bank)
        @real_map.init_starting_cash(players, bank)
      end

      def init_corporations(stock_market)
        @real_map.init_corporations(stock_market)
      end

      def init_hexes(companies, corporations)
        @real_map.init_hexes(companies, corporations)
      end

      def setup
        #Assign ZOOTickets to each player
        numTicketZoo = @players.size == 5 ? 2 : 3
        @players.each do |player, index|
          tickets = (1..numTicketZoo).map { |i| Company.new(
              sym: "T#{i}-P#{index}",
              name: "ZOOTicket #{i}",
              value: 4,
              desc: 'Can be sold to gain money.'
          ) }
          tickets.each { |ticket|
            ticket.owner = player
            player.companies << ticket
          }

          @log << "#{player.name} got #{numTicketZoo} ZOOTickets"
        end

        @operating_rounds = 2 #2 ORs on first and second round
      end

      def num_certs(entity)
        entity.companies.count { |c| !c.name.start_with?('ZOOTicket') } + entity.shares.count { |s| s.corporation.counts_for_limit && s.counts_for_limit }
      end

      def init_round
        Round::Draft.new(self, [Step::G18ZOO::SimpleDraft], reverse_order: true)
      end

      # Only buy and sell par shares is possible action during SR
      def stock_round
        Round::Stock.new(self, [
            Step::G18ZOO::BuySellParShares,
        ])
      end

      def new_operating_round
        @operating_rounds = 3 if @turn == 3 # Last round has 3 ORs

        super
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
            Step::Track,
        # Step::Token, TODO: add and test
        # Step::Route, TODO: add and test
        # Step::Dividend, TODO: add and test
        # Step::BuyTrain TODO: add and test
        ], round_num: round_num)
      end

      # Game will end at the end of the ORs in the third turn
      def custom_end_game_reached?
        @turn == 3
      end

      def round_description(name, _round_num)
        message = super
        day = case @turn
              when 1
                "Monday"
              when 2
                "Tuesday"
              when 3
                "Wednesday"
              end

        case name
        when 'Draft'
          name
        when 'Stock'
          "#{day} Stock"
        when 'Operating'
          "#{day} #{message}"
        end
      end

      def reorder_players
        return if @round.is_a?(Engine::Round::Draft)

        current_order = @players.dup
        @players.sort_by! { |p| [-p.cash, current_order.index(p)] }
        @log << "Priority order: #{@players.reject(&:bankrupt).map(&:name).join(', ')}"
      end

      # def upgrades_to?(from, to, _special = false)
      #   # Only allow tile gray tile (446) in Montgomery (E11) or Birmingham (C9)
      #   return to.name == '446' if from.color == :brown && HEXES_FOR_GRAY_TILE.include?(from.hex.name)
      #
      #   # Only allow tile Mobile City brown tile in Mobile City hex (H6)
      #   return to.name == 'X31b' if from.color == :green && from.hex.name == 'H6'
      #
      #   super
      # end
      #
      # def all_potential_upgrades(tile, tile_manifest: false)
      #   upgrades = super
      #
      #   return upgrades unless tile_manifest
      #
      #   # Tile manifest for tile 15 should show brown Mobile City as a potential upgrade
      #   upgrades |= [@mobile_city_brown] if @mobile_city_brown && tile.name == '15'
      #
      #   # Tile manifest for tile 63 should show 446 as a potential upgrade
      #   upgrades |= [@gray_tile] if @gray_tile && tile.name == '63'
      #
      #   upgrades
      # end

      def game_end_check
        triggers = {
            stock_market: @stock_market.max_reached?,
            custom: custom_end_game_reached?,
        }.select { |_, t| t }

        %i[immediate current_round current_or full_or one_more_full_or_set].each do |after|
          triggers.keys.each do |reason|
            if game_end_check_values[reason] == after
              (@turn == (@final_turn ||= @turn + 1)) if after == :one_more_full_or_set
              return [reason, after]
            end
          end
        end

        nil
      end

      private

      class MapA < Base
        load_from_json(Config::Game::G18ZOO::JSON_MAP_A, Config::Game::G18ZOO::JSON_MAP_SMALL, Config::Game::G18ZOO::JSON)
      end

      class MapB < Base
        load_from_json(Config::Game::G18ZOO::JSON_MAP_B, Config::Game::G18ZOO::JSON_MAP_SMALL, Config::Game::G18ZOO::JSON)
      end

      class MapC < Base
        load_from_json(Config::Game::G18ZOO::JSON_MAP_C, Config::Game::G18ZOO::JSON_MAP_SMALL, Config::Game::G18ZOO::JSON)
      end

      class MapD < Base
        load_from_json(Config::Game::G18ZOO::JSON_MAP_D, Config::Game::G18ZOO::JSON_MAP_LARGE, Config::Game::G18ZOO::JSON)
      end

      class MapE < Base
        load_from_json(Config::Game::G18ZOO::JSON_MAP_E, Config::Game::G18ZOO::JSON_MAP_LARGE, Config::Game::G18ZOO::JSON)
      end

      class MapF < Base
        load_from_json(Config::Game::G18ZOO::JSON_MAP_F, Config::Game::G18ZOO::JSON_MAP_LARGE, Config::Game::G18ZOO::JSON)
      end
    end
  end
end
