# frozen_string_literal: true

require_relative '../config/game/g_18_zoo'
require_relative 'base'

module Engine
  module Game
    class G18ZOO < Base
      load_from_json(Config::Game::G18ZOO::JSON_MAP_A, Config::Game::G18ZOO::JSON_CERT_LIMIT_MAP_SMALL, Config::Game::G18ZOO::JSON_STARTING_CASH_MAP_SMALL, Config::Game::G18ZOO::JSON)

      GAME_DESIGNER = 'Paolo Russo'

      #Game end after the ORs in the third turn, of if any company reach 24
      GAME_END_CHECK = {stock_market: :current_or, custom: :full_or}.freeze

      OPTIONAL_RULES = [
          # {sym: :map_b, short_name: 'Map B', desc: '5 families'}, #TODO: unblock after the map creation
          # {sym: :map_c, short_name: 'Map C', desc: '5 families'}, #TODO: unblock after the map creation
          # {sym: :map_d, short_name: 'Map D', desc: '7 families'}, #TODO: unblock after the map creation
          # {sym: :map_e, short_name: 'Map E', desc: '5 families'}, #TODO: unblock after the map creation
          # {sym: :map_f, short_name: 'Map F', desc: '5 families'}, #TODO: unblock after the map creation
          {sym: :power_visible, short_name: 'Poteri scoperti', desc: 'Poteri scoperti'},
      ].freeze

      BANKRUPTCY_ALLOWED = false

      HOME_TOKEN_TIMING = :float

      SELL_BUY_ORDER = :sell_buy
      SELL_AFTER = :any_time

      MUST_BUY_TRAIN = :always

      # Two lays or one upgrade
      TILE_LAYS = [{lay: true, upgrade: true}, {lay: true, upgrade: false}].freeze

      attr_accessor :just_ipoed, :new_train_brought
      attr_reader :companies_for_isr, :market_infos

      def title
        "18ZOO - Map A (5 families)"
      end

      def init_optional_rules(optional_rules)
        optional_rules = super

        maps = optional_rules.select { |rule| rule.start_with?('map_') }
        raise GameError, 'Please select a single map.' unless maps.size <= 1

        @map = maps.empty? ? self : maps.first
        raise GameError, 'Please select map D, E or F to play with five players.' if @players.size == 5 and [:map_b, :map_c].include?(@map)

        @real_map = case (@map)
                    when :map_b then
                      Engine::Game::G18ZOOMaps::MapB.new(@names)
                    when :map_c then
                      Engine::Game::G18ZOOMaps::MapC.new(@names)
                    when :map_d then
                      Engine::Game::G18ZOOMaps::MapD.new(@names)
                    when :map_e then
                      Engine::Game::G18ZOOMaps::MapD.new(@names)
                    when :map_f then
                      Engine::Game::G18ZOOMaps::MapD.new(@names)
                    else
                      self
                    end

        @near_families = @players.size < 5
        @all_private_visible = optional_rules.include?(:power_visible)

        optional_rules
      end

      def init_companies(players)
        companies = super.sort_by { rand }

        #Assign ZOOTickets to each player
        numTicketZoo = players.size == 5 ? 2 : 3
        players.each_with_index do |player, index|
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

        companies
      end

      def init_corporations(stock_market)
        result = @real_map == self ? super : @real_map.init_corporations(stock_market)

        bank_corporation = Corporation.new(sym: 'BANK', name: 'BANK', float_percent: 100, logo: '18_zoo/bank',
                                           shares: [100], max_ownership_percent: 0, min_price: 99999, tokens: [], coordinates: 'A0', color: '#fff', text_color: 'black',
                                           abilities: [type: "no_buy"])
        #ADD BANK_CORPORATION to the Corporations
        result << bank_corporation

        draw_size = players.size == 5 ? 6 : 4
        @companies_for_isr = companies.first(draw_size)
        @companies_for_isr.each do |company|
          dup = company.dup
          dup.owner = bank_corporation
          bank_corporation.companies << dup
        end

        @companies_for_monday = companies.drop(draw_size + 4).first(4)
        @companies_for_tuesday = companies.drop(draw_size + 8).first(4)
        @companies_for_wednesday = companies.drop(draw_size + 12).first(4)

        #Move Monday companies to Corporation Bank to be able to see them in Entities or all of them if @all_private_visible
        if @all_private_visible
          @log << "All powers visible in the future deck"
          (@companies_for_monday + @companies_for_tuesday + @companies_for_wednesday).each do |company|
            company.owner = bank_corporation
            bank_corporation.companies << company
          end
        else
          add_powers_to_bank_corporation(bank_corporation, @companies_for_monday)
        end

        result
      end

      def init_cert_limit
        @real_map == self ? super : @real_map.init_cert_limit
      end

      def num_trains(train)
        num_players = @players.size

        case train[:name]
        when '2S'
          num_players
        else
          super
        end
      end

      def upgrades_to?(from, to, _special)
        return true if to.name.end_with?("(water)") && from.upgrades.any? { |upgrade| upgrade.terrains.any? { |terrain| terrain == 'water' } }

        super
      end

      def format_currency(val)
        "#{val}$N"
      end

      def init_starting_cash(players, bank)
        @real_map == self ? super : @real_map.init_starting_cash(players, bank)
      end

      def init_hexes(companies, corporations)
        @real_map == self ? super : @real_map.init_hexes(companies, corporations)
      end

      def init_round
        Round::Draft.new(self, [Step::G18ZOO::SimpleDraft], reverse_order: true)
      end

      def init_stock_market
        market = self.class::MARKET.map { |row| row.map { |code| code[0] } }
        @market_infos = self.class::MARKET.map.with_index do |row, r_index|
          row.map do |code|
            {value: code[0], threshold: code[1], share_value: code[2]}
          end
        end

        StockMarket.new(market, self.class::CERT_LIMIT_TYPES,
                        multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
      end

      def setup
        @operating_rounds = 2 #2 ORs on first and second round
        @bank_player = Player.new('BANK')
      end

      def bank_corporation
        @corporations.select { |c| c.name == 'BANK' }.first
      end

      def num_certs(entity)
        entity.companies.count { |c| !c.name.start_with?('ZOOTicket') } + entity.shares.count { |s| s.corporation.counts_for_limit && s.counts_for_limit }
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

      def after_par(corporation)
        super

        @just_ipoed = corporation
        corporation.owner.spend(-5, bank) if corporation.par_price == 9
        corporation.owner.spend(-10, bank) if corporation.par_price == 12
      end

      def create_zooticket(ticket, value)
        new_ticket = Company.new(sym: ticket.sym, name: ticket.name, value: value, desc: ticket.desc)
        new_ticket.owner = ticket.owner
        new_ticket.owner.companies << new_ticket
        ticket.close!
        new_ticket
      end


      def init_round_finished
        # Move all the remaining companies from Draft to Bank Player (to be able to buy them) / Bank Minor (to be able to see in Entities)
        @companies_for_isr.select { |company| !company.owner }.each do |company|
          # company.owner = @bank_player
          # @bank_player.companies << company
          company.owner = bank
          # bank.companies << company
        end
      end

      def new_stock_round
        result = super

        add_powers_to_bank_player(@companies_for_monday) if @turn == 1
        add_powers_to_bank_corporation(bank_corporation, @companies_for_tuesday) if @turn == 1
        add_powers_to_bank_player(@companies_for_tuesday) if @turn == 2
        add_powers_to_bank_corporation(bank_corporation, @companies_for_wednesday) if @turn == 2
        add_powers_to_bank_player(@companies_for_wednesday) if @turn == 3

        result
      end

      def add_powers_to_bank_player(companies)
        companies.each do |company|
          # company.owner = @bank_player
          # @bank_player.companies << company
          company.owner = bank
          # bank.companies << company
        end
      end

      def add_powers_to_bank_corporation(bank_corporation, companies)
        if !@all_private_visible && companies
          @log << "Powers #{companies.map { |c| c.name.to_s }} added to the future deck"
          companies.each do |company|
            company.owner = bank_corporation
            bank_corporation.companies << company
          end
        end
      end

      def corporation_available?(entity)
        entity.corporation? && entity != bank_corporation
      end

      # Only buy and sell par shares is possible action during SR
      def stock_round
        Round::Stock.new(self, [
            Step::G18ZOO::BuySellParShares,
            Step::G18ZOO::TrackAfterHome
        ])
      end

      def new_operating_round(round_num)
        @operating_rounds = 3 if @turn == 3 # Last round has 3 ORs
        update_zootickets_value(@turn, round_num)

        super
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
            Step::G18ZOO::Track,
            Step::Token,
            Step::Route,
            Step::G18ZOO::Dividend,
            Step::G18ZOO::BuyTrain
        ], round_num: round_num)
      end

      def or_set_finished
        update_zootickets_value(@turn, 0)
      end

      # Game will end at the end of the ORs in the third turn
      def custom_end_game_reached?
        @turn == 3
      end

      def tile_lays(entity)
        return super unless @just_ipoed

        case @just_ipoed.par_price
        when 9
          2.times.map { |_| {lay: true, upgrade: false} }
        when 12
          4.times.map { |_| {lay: true, upgrade: false} }
        else
          1.times.map { |_| {lay: true, upgrade: false} }
        end
      end

      def action_processed(action)
        # if action.is_a?(Engine::Action::LayTile) && @just_ipoed
        #   # @just_ipoed = nil
        # end
        # @log << "#{action}"
      end

      def event_new_train!
        @new_train_brought = true
      end

      def event_green_par!
        @log << "event_green_par!"
        # @stock_market.enable_par_price(9)
      end

      def event_brown_par!
        @log << "event_brown_par!"
        # @stock_market.enable_par_price(12)
      end

      def round_description(name, round_number = nil)
        round_number ||= @round.round_num
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
          "#{day} Operating Round (#{round_number} of #{@operating_rounds})"
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
    end

    module G18ZOOMaps
      class GenericMap < Base
      end

      class MapB < GenericMap
        # load_from_json(Config::Game::G18ZOO::JSON_MAP_B, Config::Game::G18ZOO::JSON_CERT_LIMIT_MAP_SMALL, Config::Game::G18ZOO::JSON_STARTING_CASH_MAP_SMALL, Config::Game::G18ZOO::JSON)
      end

      class MapC < GenericMap
        # load_from_json(Config::Game::G18ZOO::JSON_MAP_C, Config::Game::G18ZOO::JSON_CERT_LIMIT_MAP_SMALL, Config::Game::G18ZOO::JSON_STARTING_CASH_MAP_SMALL, Config::Game::G18ZOO::JSON)
      end

      class MapD < GenericMap
        # load_from_json(Config::Game::G18ZOO::JSON_MAP_D, Config::Game::G18ZOO::JSON_CERT_LIMIT_MAP_LARGE, Config::Game::G18ZOO::JSON_STARTING_CASH_MAP_LARGE, Config::Game::G18ZOO::JSON)
      end

      class MapE < GenericMap
        # load_from_json(Config::Game::G18ZOO::JSON_MAP_E, Config::Game::G18ZOO::JSON_CERT_LIMIT_MAP_LARGE, Config::Game::G18ZOO::JSON_STARTING_CASH_MAP_LARGE, Config::Game::G18ZOO::JSON)
      end

      class MapF < GenericMap
        # load_from_json(Config::Game::G18ZOO::JSON_MAP_F, Config::Game::G18ZOO::JSON_CERT_LIMIT_MAP_LARGE, Config::Game::G18ZOO::JSON_STARTING_CASH_MAP_LARGE, Config::Game::G18ZOO::JSON)
      end
    end
  end
end
