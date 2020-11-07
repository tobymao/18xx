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
          {sym: :map_d, short_name: 'Map D', desc: '7 families'},
          # {sym: :map_e, short_name: 'Map E', desc: '5 families'}, TODO: unblock after the map creation
          # {sym: :map_f, short_name: 'Map F', desc: '5 families'}, TODO: unblock after the map creation
          {sym: :power_visible, short_name: 'Poteri scoperti', desc: 'Poteri scoperti'},
      ].freeze

      BANKRUPTCY_ALLOWED = false

      HOME_TOKEN_TIMING = :float

      SELL_BUY_ORDER = :sell_buy

      # Two lays or one upgrade
      TILE_LAYS = [{lay: true, upgrade: true}, {lay: :not_if_upgraded, upgrade: false}].freeze

      MARKET_PLAYER = Player.new("Market")

      attr_reader :companies_for_isr

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
                      Engine::Game::G18ZOO::MapD.new(@names)
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
        @players.each_with_index do |player, index|
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

      def create_zooticket(ticket, value)
        new_ticket = Company.new(
            sym: ticket.sym,
            name: ticket.name,
            value: value,
            desc: ticket.desc
        )
        new_ticket.owner = ticket.owner
        new_ticket.owner.companies << new_ticket
        ticket.close!
        new_ticket
      end

      def update_zootickets_value(turn, round_num = 1)
        new_value = case "#{turn}-#{round_num}"
                    when "1-0"
                      4 #"Monday Stock"
                    when "1-1"
                      5 #"Monday OR 1"
                    when "1-2"
                      6 #"Monday OR 2"
                    when "2-0"
                      7 #"Tuesday Stock"
                    when "2-1"
                      8 #"Tuesday OR 1"
                    when "2-2"
                      9 #"Tuesday OR 2"
                    when "3-0"
                      10 #"Wednesday Stock"
                    when "3-1"
                      12 #"Wednesday OR 1"
                    when "3-2"
                      15 #"Wednesday OR 2"
                    when "3-3"
                      18 #"Wednesday OR 3"
                    when "4-0"
                      20 #"End of game"
                    end
        @players.each { |player| player.companies.select { |c| c.name.start_with?('ZOOTicket') }.map { |c| create_zooticket(c, new_value) } }
      end

      def init_companies(_players)
        super.sort_by { @game.rand }
      end

      def draw_size
        @players.size == 5 ? 6 : 4
      end

      def init_round
        @companies_for_isr = @companies.first(draw_size)
        @companies_for_monday = @companies.drop(draw_size + 4).first(4)
        @companies_for_tuesday = @companies.drop(draw_size + 8).first(4)
        @companies_for_wednesday = @companies.drop(draw_size + 12).first(4)
        #TODO: Move Monday companies to Player / Minor to be able to see in Entities
        # @companies_for_monday.each do |company|
        #   company.owner = Bank
        #   Bank.companies << company
        # end

        Round::Draft.new(self, [Step::G18ZOO::SimpleDraft], reverse_order: true)
      end

      # TODO: Move all the remaining companies from isr to Player / Minor to be able to see in Entities
      def init_round_finished
        # @companies_for_isr.select { |company| !company.owner }.each do |company|
        #   company.owner = Bank
        #   Bank.companies << company
        # end
      end

      # Only buy and sell par shares is possible action during SR
      def stock_round
        Round::Stock.new(self, [
            Step::G18ZOO::BuySellParShares,
        ])
      end

      def new_operating_round(round_num)
        @operating_rounds = 3 if @turn == 3 # Last round has 3 ORs
        update_zootickets_value(@turn, round_num)

        #TODO: Move Tuesday companies to Player / Minor to be able to see in Entities
        # @companies_for_tuesday.select { |company| !company.owner }.each do |company|
        #   company.owner = Bank
        #   Bank.companies << company
        # end if @turn == 1

        #TODO: Move Wednesday companies to Player / Minor to be able to see in Entities
        # @companies_for_wednesday.select { |company| !company.owner }.each do |company|
        #   company.owner = Bank
        #   Bank.companies << company
        # end if @turn == 2

        super
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
            Step::G18ZOO::Track,
        # Step::Token, TODO: add and test
        # Step::Route, TODO: add and test
        # Step::Dividend, TODO: add and test
        # Step::BuyTrain TODO: add and test
        ], round_num: round_num)
      end

      def or_set_finished
        update_zootickets_value(@turn, 0)
      end

      # Game will end at the end of the ORs in the third turn
      def custom_end_game_reached?
        @turn == 3
      end

      def purchasable_companies(entity = nil)
        @companies.select do |company|
          company.owner&.player? && company.owner.name == 'Market' && !company.abilities(:no_buy)
        end
      end

      def event_green_par!
        @log << "-- Event: #{EVENTS_TEXT['green_par'][1]} --"
        stock_market.enable_par_price(9)
      end

      def event_brown_par!
        @log << "-- Event: #{EVENTS_TEXT['brown_par'][1]} --"
        stock_market.enable_par_price(12)
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

      def end_game!
        return if @finished

        update_zootickets_value(4, 0)

        super
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
