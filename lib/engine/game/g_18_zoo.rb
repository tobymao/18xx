# frozen_string_literal: true

require_relative '../config/game/g_18_zoo'
require_relative 'base'

module Engine
  module Game
    class G18ZOO < Base
      load_from_json(Config::Game::G18ZOO::JSON_MAP_A, Config::Game::G18ZOO::JSON_CERT_LIMIT_MAP_SMALL,
                     Config::Game::G18ZOO::JSON_STARTING_CASH_MAP_SMALL, Config::Game::G18ZOO::JSON)

      GAME_DESIGNER = 'Paolo Russo'

      # Game end after the ORs in the third turn, of if any company reach 24
      GAME_END_CHECK = { stock_market: :current_or, custom: :full_or }.freeze

      OPTIONAL_RULES = [
        # {sym: :map_b, short_name: 'Map B', desc: '5 families'}, # TODO: unblock after the map creation
        # {sym: :map_c, short_name: 'Map C', desc: '5 families'}, # TODO: unblock after the map creation
        # {sym: :map_d, short_name: 'Map D', desc: '7 families'}, # TODO: unblock after the map creation
        # {sym: :map_e, short_name: 'Map E', desc: '5 families'}, # TODO: unblock after the map creation
        # {sym: :map_f, short_name: 'Map F', desc: '5 families'}, # TODO: unblock after the map creation
        { sym: :power_visible, short_name: 'Powers visible', desc: 'Next powers are visible since the beginning.' },
      ].freeze

      BANKRUPTCY_ALLOWED = false

      HOME_TOKEN_TIMING = :float

      SELL_BUY_ORDER = :sell_buy
      SELL_AFTER = :any_time

      MARKET_SHARE_LIMIT = 80 # percent

      MARKET_TEXT = Base::MARKET_TEXT.merge(par_2: 'Can only enter during phase green',
                                            par_3: 'Can only enter during phase brown').freeze
      STOCKMARKET_COLORS = {
        par_1: :yellow,
        par_2: :green,
        par_3: :brown,
        endgame: :gray,
      }.freeze

      MUST_BUY_TRAIN = :always

      # Two lays or one upgrade
      TILE_LAYS = [{ lay: true, upgrade: true }, { lay: true, upgrade: :not_if_upgraded }].freeze

      CORPORATIONS_ORDER = %w[CR GI PB PE LI TI BB EL] * 2

      TILE_M7 = Tile.from_code('7 (mountain)', 'yellow', 'path=a:0,b:1;upgrade=cost:1,terrain:mountain')
      TILE_MM7 = Tile.from_code('7 (mountain)', 'yellow', 'path=a:0,b:1;upgrade=cost:2,terrain:mountain')
      TILE_W7 = Tile.from_code('7 (water)', 'yellow',
                               'town=revenue:10;path=a:0,b:_0;path=a:_0,b:1;upgrade=cost:0,terrain:water')

      TILE_M8 = Tile.from_code('8 (mountain)', 'yellow', 'path=a:0,b:2;upgrade=cost:1,terrain:mountain')
      TILE_MM8 = Tile.from_code('8 (mountain)', 'yellow', 'path=a:0,b:2;upgrade=cost:2,terrain:mountain')
      TILE_W8 = Tile.from_code('8 (water)', 'yellow',
                               'town=revenue:10;path=a:0,b:_0;path=a:_0,b:2;upgrade=cost:0,terrain:water')

      TILE_M9 = Tile.from_code('9 (mountain)', 'yellow', 'path=a:0,b:3;upgrade=cost:1,terrain:mountain')
      TILE_MM9 = Tile.from_code('9 (mountain)', 'yellow', 'path=a:0,b:3;upgrade=cost:2,terrain:mountain')
      TILE_W9 = Tile.from_code('9 (water)', 'yellow',
                               'town=revenue:10;path=a:0,b:_0;path=a:_0,b:3;upgrade=cost:0,terrain:water')

      attr_accessor :floated_corporation, :additional_tracks, :new_train_brought, :skip_free_actions
      attr_reader :companies_for_isr, :companies_for_monday, :market_infos, :available_companies, :future_companies

      def title
        '18ZOO - Map A (5 families)'
      end

      def init_optional_rules(optional_rules)
        optional_rules = super(optional_rules)

        maps = optional_rules.select { |rule| rule.start_with?('map_') }
        raise GameError, 'Please select a single map.' unless maps.size <= 1

        @map = maps.empty? ? self : maps.first
        raise GameError, 'Please select map D, E or F to play with five players.' if @players.size == 5 &&
          %i[map_b map_c].include?(@map)

        @real_map = case @map
                    when :map_b
                      Engine::Game::G18ZOOMaps::MapB.new(@names)
                    when :map_c
                      Engine::Game::G18ZOOMaps::MapC.new(@names)
                    when :map_d
                      Engine::Game::G18ZOOMaps::MapD.new(@names)
                    when :map_e
                      Engine::Game::G18ZOOMaps::MapD.new(@names)
                    when :map_f
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

        # Assign ZOOTickets to each player
        num_ticket_zoo = players.size == 5 ? 2 : 3
        players.each do |player|
          (1..num_ticket_zoo).each do |i|
            ticket = Company.new(sym: "ZOOTicket #{i} - #{player.id}",
                                 name: "ZOOTicket #{i}",
                                 value: 4,
                                 desc: 'Can be sold to gain money.')
            ticket.owner = player
            player.companies << ticket
            companies << ticket
          end

          @log << "#{player.name} got #{num_ticket_zoo} ZOOTickets"
        end

        companies.each do |company|
          company.min_price = 0
          company.max_price = company.value
        end

        companies
      end

      def init_corporations(stock_market)
        result = @real_map == self ? super : @real_map.init_corporations(stock_market)
        @near_families_purchasable = result.map { |c| { id: c.id } }
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

      def upgrades_to?(from, to, special)
        return true if to.name.end_with?('(water)') && from.upgrades.any? do |upgrade|
                         upgrade.terrains.any? do |terrain|
                           terrain == 'water'
                         end
                       end
        return false if from.name.end_with?('(mountain)')

        current_step = ability_blocking_step
        return upgrades_floated?(from, to,
                                 special) if @floated_corporation && @floated_corporation.par_price.price >= 9 &&
          current_step&.is_a?(Engine::Step::G18ZOO::HomeTrackAfterPar)

        super
      end

      def upgrades_floated?(from, to, special)
        # correct color progression?
        if @floated_corporation.par_price.price == 9
          return false unless Engine::Tile::COLORS.index(to.color) <= (Engine::Tile::COLORS.index(:green))
        elsif @floated_corporation.par_price.price == 12
          return false unless Engine::Tile::COLORS.index(to.color) <= (Engine::Tile::COLORS.index(:brown))
        end

        # honors pre-existing track?
        return false unless from.paths_are_subset_of?(to.paths)

        # If special ability then remaining checks is not applicable
        return true if special

        # correct label?
        return false if from.label != to.label

        # honors existing town/city counts?
        # - allow labelled cities to upgrade regardless of count; they're probably
        #   fine (e.g., 18Chesapeake's OO cities merge to one city in brown)
        # - TODO: account for games that allow double dits to upgrade to one town
        return false if from.towns.size != to.towns.size
        return false if !from.label && from.cities.size != to.cities.size

        # handle case where we are laying a yellow OO tile and want to exclude single-city tiles
        return false if (from.color == :white) && from.label.to_s == 'OO' && from.cities.size != to.cities.size

        true
      end

      def format_currency(val)
        current_step = active_step
        is_route_step = current_step&.is_a?(Engine::Step::Route) || current_step&.is_a?(Engine::Step::G18ZOO::Route)

        is_route_step ? val.to_s : "#{val}$N"
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
        @market_infos = self.class::MARKET.map do |row|
          row.map do |code|
            { value: code[0], threshold: code[1], share_value: code[2] }
          end
        end

        StockMarket.new(market, self.class::CERT_LIMIT_TYPES, multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
      end

      def stock_market_green_can_par?
        @phase.tiles.include?('green') && @stock_market.market[1][3].can_par?
      end

      def stock_market_brown_can_par?
        @phase.tiles.include?('brown') && @stock_market.market[1][6].can_par?
      end

      def setup
        @operating_rounds = 2 # 2 ORs on first and second round

        @available_companies = []
        @future_companies = []

        draw_size = players.size == 5 ? 6 : 4
        @companies_for_isr = @companies.drop(draw_size + 4).first(4)
        @companies_for_monday = @companies.first(draw_size)
        @companies_for_tuesday = @companies.drop(draw_size + 8).first(4)
        @companies_for_wednesday = @companies.drop(draw_size + 12).first(4)

        @available_companies.concat(@companies_for_isr)

        if @all_private_visible
          @log << 'All powers visible in the future deck'
          @future_companies.concat(@companies_for_monday + @companies_for_tuesday + @companies_for_wednesday)
        else
          @future_companies.concat(@companies_for_monday)
        end

        reserve_shares(false)
      end

      def bank_corporation
        @corporations.select { |c| c.name == 'FUTURE' }.first
      end

      def num_certs(entity)
        entity.shares.count { |s| s.corporation.counts_for_limit && s.counts_for_limit }
      end

      def player_value(player)
        player.cash + player.shares.select { |s| s.corporation.ipoed }.sum(&:price) + player.companies.select do |c|
                                                                                        c.name.start_with?('ZOOTicket')
                                                                                      end.sum(&:value)
      end

      def apply_custom_ability(company)
        if company.sym == :TOO_MUCH_RESPONSIBILITY
          bank.spend(3, company.owner, check_positive: false)
          @log << "#{company.owner.name} earn #{format_currency(3)} using \"#{company.name}\""
          company.close!
        elsif company.sym == :LEPRECHAUN_POT_OF_GOLD
          bank.spend(2, company.owner, check_positive: false)
          @log << "#{company.owner.name} receives #{format_currency(2)} using \"#{company.name}\""
        elsif %i[RABBITS MOLES ANCIENT_MAPS HOLE ON_DIET SPARKLING_GOLD THAT_S_MINE WORK_IN_PROGRESS CORN TWO_BARRELS
                 A_SQUEEZE BANDAGE WINGS A_SPOONFUL_OF_SUGAR].include?(company.sym)
          raise GameError, 'Power logic not yet implemented' # TODO: remove from this list when implementing a power
        end
      end

      def update_zootickets_value(turn, round_num = 1)
        new_value = case "#{turn}-#{round_num}"
                    when '1-0'
                      4 # "Monday Stock"
                    when '1-1'
                      5 # "Monday OR 1"
                    when '1-2'
                      6 # "Monday OR 2"
                    when '2-0'
                      7 # "Tuesday Stock"
                    when '2-1'
                      8 # "Tuesday OR 1"
                    when '2-2'
                      9 # "Tuesday OR 2"
                    when '3-0'
                      10 # "Wednesday Stock"
                    when '3-1'
                      12 # "Wednesday OR 1"
                    when '3-2'
                      15 # "Wednesday OR 2"
                    when '3-3'
                      18 # "Wednesday OR 3"
                    when '4-0'
                      20 # "End of game"
                    end
        @companies.select { |c| c.name.start_with?('ZOOTicket') }.each do |company|
          company.value = new_value
          company.min_price = 0
          company.max_price = company.value
        end
      end

      def log_share_price(entity, from, additional_info = '')
        to = entity.share_price.price
        return unless from != to

        @log << "#{entity.name}'s share price changes from #{format_currency(from)} "\
          "to #{format_currency(to)} #{additional_info}"
      end

      def after_par(corporation)
        super

        @floated_corporation = corporation

        if corporation.par_price.price == 9
          bank.spend(5, corporation)
          @log << "#{corporation.name} earns #{format_currency(5)} as treasury bonus"
          @additional_tracks = 2
        elsif corporation.par_price.price == 12
          bank.spend(10, corporation)
          @log << "#{corporation.name} earns #{format_currency(10)} as treasury bonus"
          @additional_tracks = 4
        end

        return unless @near_families

        if @corporations.count(&:ipoed) == 1
          corporations_not_ipoed = @corporations.reject(&:ipoed).map(&:id)
          next_corporation = CORPORATIONS_ORDER.drop_while { |id| id != corporation.id }
                                               .find { |id| corporations_not_ipoed.include?(id) }
          previous_corporation = CORPORATIONS_ORDER.reverse
                                                   .drop_while { |id| id != corporation.id }
                                                   .find { |id| corporations_not_ipoed.include?(id) }
          @near_families_purchasable = [{ direction: 'next', id: next_corporation },
                                        { direction: 'reverse', id: previous_corporation }]
          @log << "Near family rule: only #{@corporations.find { |c| c.id == previous_corporation }.full_name}"\
            "and #{@corporations.find { |c| c.id == next_corporation }.full_name} are now available."
        else
          if @corporations.count(&:ipoed) == 2
            @near_families_direction = @near_families_purchasable.find { |c| c[:id] == corporation.id }[:direction]
          end
          corporations_not_ipoed = @corporations.reject(&:ipoed).map(&:id)
          corporations = @near_families_direction == 'reverse' ? CORPORATIONS_ORDER.reverse : CORPORATIONS_ORDER
          following_corporation = corporations.drop_while { |id| id != corporation.id }
                                              .find { |id| corporations_not_ipoed.include?(id) }
          @near_families_purchasable = [{ id: following_corporation }]
          unless following_corporation.nil?
            @log << "Near family rule: only #{@corporations.find do |c|
                                                c.id == following_corporation
                                              end.full_name} is now available."
          end
        end
      end

      def create_zooticket(ticket, value)
        owner = ticket.owner
        new_ticket = Company.new(sym: ticket.sym, name: ticket.name, value: value, desc: ticket.desc)
        new_ticket.owner = owner
        new_ticket.min_price = 0
        new_ticket.max_price = new_ticket.value

        owner.companies << new_ticket
        owner.companies.delete(ticket)

        @companies.delete(ticket)
        @companies << new_ticket

        new_ticket
      end

      def reserve_shares(buyable)
        @corporations.each { |c| c.shares.last.buyable = buyable }
      end

      def add_cousins
        @log << 'Cousins join families.'

        reserve_shares(true)
      end

      def new_stock_round
        result = super

        add_cousins if @turn == 3

        update_current_and_future(@companies_for_monday, @companies_for_tuesday, 1)
        update_current_and_future(@companies_for_tuesday, @companies_for_wednesday, 2)
        update_current_and_future(@companies_for_wednesday, nil, 3)

        @available_companies.select { |c| c.owner.nil? }.each { |c| c.owner = @bank }

        result
      end

      def update_current_and_future(to_current, to_future, turn)
        @available_companies.concat(to_current) if @turn == turn
        return unless !@all_private_visible && to_future && @turn == turn

        @log << "Powers #{to_future.map { |c| "\"#{c.name}\"" }.join(', ')} added to the future deck"
        @future_companies.concat(to_future)
      end

      def corporation_available?(entity)
        return false if entity == bank_corporation
        return entity.corporation? unless @near_families

        entity.ipoed || @near_families_purchasable.any? { |f| f[:id] == entity.id }
      end

      def purchasable_companies(entity = nil)
        entity ||= @round.current_operator
        return [] unless entity && (entity.corporation? || entity.player?)

        if entity.player?
          # player can buy no more than 3 companies
          return [] if entity.companies.count { |c| !c.name.start_with?('ZOOTicket') } >= 3

          # player can buy only companies not already owned
          return @companies.select { |company| company.owner == @bank && !abilities(company, :no_buy) }
        end

        # corporation can buy only companies from owner
        companies_for_corporation = @companies.select do |company|
          company.owner&.player? &&
                  entity.owner == company.owner && !abilities(company, :no_buy)
        end
        # corporations can buy no more than 3 companies
        if entity.companies.count { |c| !c.name.start_with?('ZOOTicket') } >= 3
          return companies_for_corporation.select { |c| c.name.start_with?('ZOOTicket') }
        end

        companies_for_corporation
      end

      def entity_can_use_company?(entity, company)
        return entity == company.owner if entity.player?

        return entity == company.owner ||
          (entity.owned_by_player? && entity.player == company.owner) if entity.corporation?

        false
      end

      # Only buy and sell par shares is possible action during SR
      def stock_round
        Round::Stock.new(self, [
          Step::G18ZOO::BuySellParShares,
          Step::G18ZOO::HomeTrackAfterPar,
          Step::G18ZOO::AdditionalTracksAfterPar,
          [Step::G18ZOO::FreeActionsOnSr, blocks: true],
        ])
      end

      def new_operating_round(round_num)
        @operating_rounds = 3 if @turn == 3 # Last round has 3 ORs
        update_zootickets_value(@turn, round_num)

        super
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::G18ZOO::SpecialTrack,
          Step::G18ZOO::BuyCompany,
          Step::G18ZOO::Track,
          Step::Token,
          Step::G18ZOO::Route,
          Step::G18ZOO::Dividend,
          Step::G18ZOO::BuyCompany,
          Step::G18ZOO::BuyTrain,
          [Step::G18ZOO::BuyCompany, block: true],
        ], round_num: round_num)
      end

      def or_set_finished
        update_zootickets_value(@turn, 0)
      end

      def unowned_purchasable_companies(_company)
        @available_companies
      end

      # Game will end at the end of the ORs in the third turn
      def custom_end_game_reached?
        @turn == 3
      end

      def check_distance(route, visits)
        super

        distance = route.train.distance

        return if distance.is_a?(Numeric)

        cities_visited = visits.count { |v| v.city? || (v.offboard? && v.revenue[:yellow].positive?) }

        return unless cities_visited < 2

        raise GameError, 'Water and external gray doesn\'t count against city limit.'
      end

      def tile_lays(entity)
        return super unless @floated_corporation

        current_step = ability_blocking_step

        repetition = if current_step&.is_a?(Engine::Step::G18ZOO::HomeTrackAfterPar)
                       1
                     else
                       case @floated_corporation.par_price.price
                       when 9
                         2
                       when 12
                         4
                       else
                         1
                       end
                     end
        repetition.times.map { |_| { lay: true, upgrade: true } }
      end

      def event_new_train!
        @new_train_brought = true
      end

      def round_description(name, round_number = nil)
        round_number ||= @round.round_num
        day = case @turn
              when 1
                'Monday'
              when 2
                'Tuesday'
              when 3
                'Wednesday'
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
        # load_from_json(Config::Game::G18ZOO::JSON_MAP_B, Config::Game::G18ZOO::JSON_CERT_LIMIT_MAP_SMALL,
        # Config::Game::G18ZOO::JSON_STARTING_CASH_MAP_SMALL, Config::Game::G18ZOO::JSON)
      end

      class MapC < GenericMap
        # load_from_json(Config::Game::G18ZOO::JSON_MAP_C, Config::Game::G18ZOO::JSON_CERT_LIMIT_MAP_SMALL,
        # Config::Game::G18ZOO::JSON_STARTING_CASH_MAP_SMALL, Config::Game::G18ZOO::JSON)
      end

      class MapD < GenericMap
        # load_from_json(Config::Game::G18ZOO::JSON_MAP_D, Config::Game::G18ZOO::JSON_CERT_LIMIT_MAP_LARGE,
        # Config::Game::G18ZOO::JSON_STARTING_CASH_MAP_LARGE, Config::Game::G18ZOO::JSON)
      end

      class MapE < GenericMap
        # load_from_json(Config::Game::G18ZOO::JSON_MAP_E, Config::Game::G18ZOO::JSON_CERT_LIMIT_MAP_LARGE,
        # Config::Game::G18ZOO::JSON_STARTING_CASH_MAP_LARGE, Config::Game::G18ZOO::JSON)
      end

      class MapF < GenericMap
        # load_from_json(Config::Game::G18ZOO::JSON_MAP_F, Config::Game::G18ZOO::JSON_CERT_LIMIT_MAP_LARGE,
        # Config::Game::G18ZOO::JSON_STARTING_CASH_MAP_LARGE, Config::Game::G18ZOO::JSON)
      end
    end
  end
end
