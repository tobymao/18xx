# frozen_string_literal: true

require_relative 'meta'
require_relative 'entities'
require_relative 'map'
require_relative '../base'

module Engine
  module Game
    module G18ZOO
      class Game < Game::Base
        include_meta(G18ZOO::Meta)
        include G18ZOO::Entities
        include G18ZOO::Map

        CURRENCY_FORMAT_STR = '%d$N'

        BANK_CASH = 99_999

        CERT_LIMIT = {
          2 => { '5' => 10, '7' => 12 },
          3 => { '5' => 7, '7' => 9 },
          4 => { '5' => 5, '7' => 7 },
          5 => { '5' => 0, '7' => 6 },
        }.freeze

        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = true

        MARKET = [
          %w[7 8 9 10 11 12 13 14 15 16 20 24e],
          %w[6 7x 8 9z 10 11 12w 13 14],
          %w[5 6x 7 8 9 10 11],
          %w[4 5x 6 7 8],
          %w[3 4 5],
          %w[2 3],
        ].freeze

        PHASES = [
          {
            name: '2S',
            train_limit: 4,
            tiles: [:yellow],
            status: ['can_buy_companies'],
            operating_rounds: 2,
          },
          {
            name: '3S',
            on: '3S',
            train_limit: 4,
            tiles: %i[yellow green],
            status: ['can_buy_companies'],
            operating_rounds: 2,
          },
          {
            name: '4S',
            on: '4S',
            train_limit: 3,
            tiles: %i[yellow green],
            status: ['can_buy_companies'],
            operating_rounds: 2,
          },
          {
            name: '5S',
            on: '5S',
            train_limit: 2,
            tiles: %i[yellow green brown],
            status: ['can_buy_companies'],
            operating_rounds: 2,
          },
          {
            name: '4J/2J',
            on: '4J',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            status: ['can_buy_companies'],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [
          {
            name: '2S',
            distance: 2,
            price: 7,
            rusts_on: '4S',
          },
          {
            name: '3S',
            distance: 3,
            price: 12,
            rusts_on: '5S',
            num: 3,
            events: [{ 'type' => 'new_train' }],
          },
          {
            name: '3S Long',
            distance: 3,
            price: 12,
            obsolete_on: '4J',
            num: 1,
          },
          {
            name: '4S',
            distance: 4,
            price: 20,
            obsolete_on: '4J',
            num: 3,
            events: [{ 'type' => 'new_train' }],
          },
          {
            name: '5S',
            distance: 5,
            price: 30,
            num: 2,
            events: [{ 'type' => 'new_train' }],
          },
          {
            name: '4J',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 4, 'multiplier' => 2 }],
            price: 47,
            num: 99,
            events: [{ 'type' => 'new_train' }, { 'type' => 'rust_own_3s_4s' }],
            variants: [
              {
                name: '2J',
                distance: [{ 'nodes' => %w[city offboard town], 'pay' => 2, 'multiplier' => 2 }],
                price: 37,
                num: 99,
              },
            ],
          },
        ].freeze

        LAYOUT = :flat

        # Game end after the ORs in the third turn, of if any company reach 24
        GAME_END_CHECK = { stock_market: :current_or, custom: :full_or }.freeze

        GAME_END_REASONS_TEXT = Base::GAME_END_REASONS_TEXT.merge(
          custom: 'End of Turn 3'
        )

        BANKRUPTCY_ALLOWED = false

        STARTING_CASH_SMALL_MAP = { 2 => 40, 3 => 28, 4 => 23, 5 => 22 }.freeze

        STARTING_CASH_BIG_MAP = { 2 => 48, 3 => 32, 4 => 27, 5 => 22 }.freeze

        SMALL_MAP = %i[map_a map_b map_c].freeze

        CERT_LIMIT_INCLUDES_PRIVATES = false

        STOCKMARKET_COLORS = {
          par_1: :yellow,
          par_2: :green,
          par_3: :brown,
          endgame: :gray,
        }.freeze

        STOCKMARKET_THRESHOLD = [
          [100, 150, 150, 200, 200, 250, 250, 300, 350, 400, 450, 0],
          [100, 100, 150, 150, 200, 200, 250, 250, 300],
          [80, 100, 100, 150, 150, 200, 200],
          [50, 80, 100, 100, 150],
          [40, 50, 80],
          [30, 40],
        ].freeze

        STOCKMARKET_GAIN = [
          [1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 5, 6],
          [1, 1, 2, 2, 2, 2, 3, 3, 3],
          [1, 1, 2, 2, 2, 2, 2],
          [1, 1, 1, 2, 2],
          [0, 1, 1],
          [0, 0],
        ].freeze

        STOCKMARKET_OWNER_GAIN = [0, 0, 0, 1, 2, 2, 2, 2, 3].freeze

        SELL_AFTER = :any_time

        SELL_BUY_ORDER = :sell_buy

        NEXT_SR_PLAYER_ORDER = :most_cash # TODO: check if a bug

        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false

        HOME_TOKEN_TIMING = :float

        MUST_BUY_TRAIN = :always

        # A yellow/upgrade and a yellow
        TILE_LAYS = [
          { lay: true, upgrade: true, cannot_reuse_same_hex: true },
          { lay: true, upgrade: :not_if_upgraded, cannot_reuse_same_hex: true },
        ].freeze

        ASSIGNMENT_TOKENS = {
          'CORN' => '/icons/18_zoo/corn.svg',
          'BARREL' => '/icons/18_zoo/barrel.svg',
          'HOLE' => '/icons/18_zoo/hole.svg',
          'WINGS' => '/icons/18_zoo/wings.svg',
        }.freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(par_2: 'Can only enter during green phase',
                                              par_3: 'Can only enter during brown phase').freeze

        MARKET_SHARE_LIMIT = 80 # percent

        ZOO_TICKET_VALUE = {
          1 => { 0 => 4, 1 => 5, 2 => 6 },
          2 => { 0 => 7, 1 => 8, 2 => 9 },
          3 => { 0 => 10, 1 => 12, 2 => 15, 3 => 18 },
          4 => { 0 => 20 },
        }.freeze

        attr_accessor :first_train_of_new_phase
        attr_reader :available_companies, :future_companies

        def setup
          @operating_rounds = 2 # 2 ORs on first and second round

          @holes = []

          @available_companies = []
          @future_companies = []

          draw_size = @players.size == 5 ? 6 : 4
          @companies_for_isr = @companies.first(draw_size)
          @companies_for_monday = @companies[draw_size..draw_size + 3]
          @companies_for_tuesday = @companies[draw_size + 4..draw_size + 7]
          @companies_for_wednesday = @companies[draw_size + 8..draw_size + 11]

          @available_companies.concat(@companies_for_isr)
          @available_companies.each { |c| c.owner = @bank unless c.owner }

          if @all_private_visible
            @log << 'All powers visible in the future deck'
            @future_companies.concat(@companies_for_monday + @companies_for_tuesday + @companies_for_wednesday)
          else
            @future_companies.concat(@companies_for_monday)
          end

          @corporations.each { |c| c.shares.last.buyable = false }

          @tile_groups = [
            %w[7 X7],
            %w[8 X8],
            %w[9 X9],
            %w[5],
            %w[6],
            %w[57],
            %w[201],
            %w[202],
            %w[621],
            %w[19],
            %w[23],
            %w[24],
            %w[25],
            %w[26],
            %w[27],
            %w[28],
            %w[29],
            %w[30],
            %w[31],
            %w[14],
            %w[15],
            %w[619],
            %w[576],
            %w[577],
            %w[579],
            %w[792],
            %w[793],
            %w[40],
            %w[41],
            %w[42],
            %w[43],
            %w[45],
            %w[46],
            %w[611],
            %w[582],
            %w[455],
          ]
        end

        def init_optional_rules(optional_rules)
          rules = super

          maps = rules.select { |rule| rule.start_with?('map_') }
          raise GameError, 'Please select a single map.' unless maps.size <= 1

          @map = maps.empty? ? :map_a : maps.first

          @near_families = @players.size < 5
          @all_private_visible = rules.include?(:power_visible)

          rules
        end

        # use to modify hexes based on optional rules
        def optional_hexes
          self.class::HEXES_BY_MAP[@map]
        end

        # use to modify location names based on optional rules
        def location_name(coord)
          self.class::LOCATION_NAMES_BY_MAP[@map][coord]
        end

        def purchasable_companies(entity = nil)
          entity ||= @round.current_operator
          return [] if !entity || !(entity.corporation? || entity.player?)

          if entity.player?
            # player can buy no more than 3 companies
            return [] if entity.companies.count { |c| !c.name.start_with?('ZOOTicket') } >= 3

            # player can buy only companies not already owned
            return @companies.select { |company| company.owner == @bank && !abilities(company, :no_buy) }
          end

          # entity can buy ZOOTicket only from owner, and other companies from any player
          companies_for_corporation = @companies.select do |company|
            company.owner&.player? && !abilities(company, :no_buy) &&
              (entity.owner == company.owner || !company.name.start_with?('ZOOTicket'))
          end
          # corporations can buy no more than 3 companies
          return companies_for_corporation.select { |c| c.name.start_with?('ZOOTicket') } if entity.companies.count >= 3

          companies_for_corporation
        end

        def player_value(player)
          player.cash + player.shares.select { |s| s.corporation.ipoed }.sum(&:price) +
            player.companies.select { |company| company.name.start_with?('ZOOTicket') }.sum(&:value)
        end

        def end_game!
          return if @finished

          update_zoo_tickets_value(4, 0)

          super
        end

        def tile_lays(entity)
          # Operating - Track
          return super if @round.is_a?(Engine::Round::Operating)

          # Stock - Home Track
          return [{ lay: true, upgrade: true }] unless @round.available_tracks.empty?

          # Stock - Bonus Track
          Array.new(@round.bonus_tracks) { |_| { lay: true } } if @round.bonus_tracks.positive?
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          # Stock - Home Track
          if @round.is_a?(Engine::Round::Stock) && @round.available_tracks.any?
            return @round.available_tracks.include?(to.name) &&
              Engine::Tile::COLORS.index(to.color) > Engine::Tile::COLORS.index(from.color) &&
              from.paths_are_subset_of?(to.paths)
          end

          # Operating - Rabbits
          if @round.is_a?(Engine::Round::Operating) && selected_company == rabbits
            return super && (upgrades_to_correct_label?(from, to) ||
              (%w[M MM].include?(from.hex.location_name) && from.color == :yellow))
          end

          # Operating - Moles
          if @round.is_a?(Engine::Round::Operating) && selected_company == moles
            return super(from, to, true, selected_company: selected_company)
          end

          # Operating - Ancient Maps
          if @round.is_a?(Engine::Round::Operating) && selected_company == ancient_maps && from.color != :white
            return false
          end

          super
        end

        def unowned_purchasable_companies(_entity)
          @available_companies + @future_companies
        end

        def after_par(corporation)
          @round.floated_corporation = corporation
          @round.available_tracks = %w[5 6 57]

          bonus_after_par(corporation, 5, 2, %w[14 15]) if corporation.par_price.price == 9
          bonus_after_par(corporation, 10, 4, %w[14 15 611]) if corporation.par_price.price == 12

          return unless @near_families

          corporations_order = @corporations.sort_by(&:full_name).cycle(2).to_a
          if @corporations.count(&:ipoed) == 1
            # Take the first entity not ipoed after the one just parred
            next_corporation = corporations_order.drop_while { |c| c.id != corporation.id }
                                                 .find { |c| !c.ipoed }
            # Take the first entity not ipoed before the one just parred
            previous_corporation = corporations_order.reverse
                                                     .drop_while { |c| c.id != corporation.id }
                                                     .find { |c| !c.ipoed }
            @near_families_purchasable = [{ direction: 'next', id: next_corporation.id },
                                          { direction: 'reverse', id: previous_corporation.id }]
            @log << "Near family rule: #{previous_corporation.full_name} and #{next_corporation.full_name}"\
            ' are available.'
          else
            if @corporations.count(&:ipoed) == 2
              @near_families_direction = @near_families_purchasable.find { |c| c[:id] == corporation.id }[:direction]
            end
            corporations = @near_families_direction == 'reverse' ? corporations_order.reverse : corporations_order
            following_corporation = corporations.drop_while { |c| c.id != corporation.id }
                                                .find { |c| !c.ipoed }
            if following_corporation
              @near_families_purchasable = [{ id: following_corporation.id }]

              @log << "Near family rule: #{following_corporation.full_name} is now available."
            end
          end
        end

        def entity_can_use_company?(entity, company)
          return true if entity.player? && entity == company.owner
          return true if entity.corporation? && entity == company.owner
          return true if entity.corporation? && zoo_ticket?(company) && entity.owner == company.owner

          false
        end

        def holiday
          @holiday ||= company_by_id('HOLIDAY')
        end

        def midas
          @midas ||= company_by_id('MIDAS')
        end

        def midas_active?
          midas.all_abilities.any? { |ability| ability.is_a?(Engine::Ability::Close) }
          # Maybe !abilities(midas, :close).nil? is better?
        end

        def too_much_responsibility
          @too_much_responsibility ||= company_by_id('TOO_MUCH_RESPONSIBILITY')
        end

        def leprechaun_pot_of_gold
          @leprechaun_pot_of_gold ||= company_by_id('LEPRECHAUN_POT_OF_GOLD')
        end

        def it_is_all_greek_to_me
          @it_is_all_greek_to_me ||= company_by_id('IT_IS_ALL_GREEK_TO_ME')
        end

        def greek_to_me_active?
          !abilities(it_is_all_greek_to_me, :close).nil?
        end

        def whatsup
          @whatsup ||= company_by_id('WHATSUP')
        end

        def rabbits
          @rabbits ||= company_by_id('RABBITS')
        end

        def moles
          @moles ||= company_by_id('MOLES')
        end

        def ancient_maps
          @ancient_maps ||= company_by_id('ANCIENT_MAPS')
        end

        def hole
          @hole ||= company_by_id('HOLE')
        end

        def on_diet
          @on_diet ||= company_by_id('ON_DIET')
        end

        def sparkling_gold
          @sparkling_gold ||= company_by_id('SPARKLING_GOLD')
        end

        def that_is_mine
          @that_is_mine ||= company_by_id('THAT_IS_MINE')
        end

        def can_choose_is_mine?(entity, company)
          company == that_is_mine && entity&.corporation? && that_is_mine.owner == entity &&
            !@round.tokened &&
            !entity.unplaced_tokens.empty? &&
            entity.unplaced_tokens.first.price <= buying_power(entity) &&
            that_is_mine.all_abilities[0].is_a?(Ability::Reservation) &&
            graph.reachable_hexes(entity)[that_is_mine.all_abilities[0].hex]
        end

        def work_in_progress
          @work_in_progress ||= company_by_id('WORK_IN_PROGRESS')
        end

        def corn
          @corn ||= company_by_id('CORN')
        end

        def two_barrels
          @two_barrels ||= company_by_id('TWO_BARRELS')
        end

        def can_choose_two_barrels?(entity, company)
          company == two_barrels && entity&.corporation? && two_barrels.owner == entity &&
            !two_barrels_used_this_or?(entity)
        end

        def two_barrels_used_this_or?(entity)
          entity&.assigned?('BARREL')
        end

        def a_squeeze
          @a_squeeze ||= company_by_id('A_SQUEEZE')
        end

        def bandage
          @bandage ||= company_by_id('BANDAGE')
        end

        def wings
          @wings ||= company_by_id('WINGS')
        end

        def a_spoonful_of_sugar
          @a_spoonful_of_sugar ||= company_by_id('A_SPOONFUL_OF_SUGAR')
        end

        def can_choose_sugar?(entity, company)
          company == a_spoonful_of_sugar && entity&.corporation? && a_spoonful_of_sugar.owner == entity &&
            entity.trains.any? { |train| !%w[2J 4J].include?(train.name) } &&
            entity.all_abilities.none? { |a| a.type == :increase_distance_for_train }
        end

        def apply_custom_ability(company)
          case company.sym
          when 'TOO_MUCH_RESPONSIBILITY'
            bank.spend(3, company.owner, check_positive: false)
            @log << "#{company.owner.name} earns #{format_currency(3)} using \"#{company.name}\""
            company.close!
          when 'LEPRECHAUN_POT_OF_GOLD'
            bank.spend(2, company.owner, check_positive: false)
            @log << "#{company.owner.name} earns #{format_currency(2)} using \"#{company.name}\""
          end
        end

        def corporation_available?(entity)
          return true unless @near_families

          entity.ipoed || @near_families_purchasable.any? { |f| f[:id] == entity.id }
        end

        def log_share_price(entity, from, additional_info = '')
          to = entity.share_price.price
          return unless from != to

          @log << "#{entity.name}'s share price changes from #{format_currency(from)} "\
              "to #{format_currency(to)} #{additional_info}"
        end

        def revenue_for(route, stops)
          revenue = super

          # Add 30$N if route contains 'Corn' and Corporation owns 'Corn'
          revenue += 30 if route.corporation.assigned?(corn.id) && stops.any? { |stop| stop.hex.assigned?(corn.id) }

          # Towns revenues are doubled if 'Two barrels' is in use
          revenue += 10 * stops.count { |stop| !stop.tile.towns.empty? } if two_barrels_used_this_or?(route.corporation)

          # Add Hole off-board revenue when passing through
          if !@holes.empty? && (@holes & route.all_hexes).size == 2
            revenue += @holes[0].tile.offboards[0].route_revenue(route.phase, route.train)
          end

          # City skipped by Wings worth 0
          visits = route.visited_stops
          if visits.size > 2
            corporation = route.corporation
            visits[1..-2].each do |node|
              next if !node.city? || !node.blocks?(corporation)

              revenue -= node.hex.tile.cities.first.route_revenue(route.phase, route.train)
            end
          end

          revenue
        end

        def zoo_ticket?(company)
          company.name.start_with?('ZOOTicket')
        end

        def zoo_tickets?(entity)
          entity.player? && entity.companies.any? { |c| zoo_ticket?(c) }
        end

        def check_distance(route, visits)
          distance = route.train.distance
          cities_visited = visits.count { |v| v.city? || (v.offboard? && v.revenue[:yellow].positive?) }

          # Passing through Hole count as a stop
          cities_visited += 1 if !@holes.empty? && (@holes & route.all_hexes).size == 2

          # Passing through City with Wings doesn't count
          visits = route.visited_stops
          if visits.size > 2
            corporation = route.corporation
            visits[1..-2].each do |node|
              cities_visited -= 1 if node.city? && node.blocks?(corporation)
            end
          end

          raise GameError, 'Water and external gray don\'t count as city/offboard.' if cities_visited < 2

          # 2S, 3S, 4S, 5S
          if distance.is_a?(Numeric)
            # Ability 'IncreaseDistanceForTrain' can change the max distance for a specific train
            distance += abilities(route.train.owner, :increase_distance_for_train)&.distance || 0
            raise GameError, "#{cities_visited} is too many stops for #{distance} train" if distance < cities_visited
          else
            super
          end
        end

        def check_other(route)
          super

          return if @holes.empty?

          # Route cannot use Hole as off-board and as pass-through, or used twice
          holes_in_route = route.paths.map(&:tile).count { |tile| @holes.include?(tile.hex) }
          raise GameError, 'Hole cannot be a terminal or used multiple times if used as tunnel.' if holes_in_route > 2
        end

        def check_connected(route, _token)
          blocked = nil
          blocked_by = nil

          route.routes.each_with_index do |current_route, index|
            visits = current_route.visited_stops

            next unless visits.size > 2

            corporation = route.corporation
            visits[1..-2].each do |node|
              next if !node.city? || !node.blocks?(corporation)
              raise GameError, "City with only '#{work_in_progress.name}' slot cannot be bypassed" if node.city? &&
                node.slots(all: true) == 1 && node.tokens.first.type == :blocking
              raise GameError, 'Only one train can bypass a tokened-out city' if blocked && blocked_by != index
              raise GameError, 'Route can only bypass one tokened-out city' if blocked

              blocked = node
              blocked_by = index
            end
          end
        end

        def company_header(company)
          type_text = @future_companies.include?(company) ? 'FUTURE POWER' : 'POWER'
          sr_or_text = case company.sym
                       when 'HOLIDAY', 'MIDAS', 'TOO_MUCH_RESPONSIBILITY', 'LEPRECHAUN_POT_OF_GOLD',
                         'IT_IS_ALL_GREEK_TO_ME', 'WHATSUP'
                         '(SR)'
                       else
                         '(OR)'
                       end
          "#{type_text} #{sr_or_text}"
        end

        def train_help(entity, runnable_trains, _routes)
          return [] if runnable_trains.empty?

          # Barrel assignment
          barrel_assignment = entity.assigned?('BARREL')

          # Corn assignment
          corn_assignment = entity.assigned?('CORN')

          # Holes assignment
          holes_assignment = !@holes.empty?

          help = []
          # TODO: add logic for Bandage - trains

          help << 'Routes get no subsidy at all, but every town increase route value by 10.' if barrel_assignment
          if holes_assignment
            help << "Off-boards (#{@holes.map(&:coordinates)}) are special: they can used as terminal (as usual); "\
                    'Any route passing through them must go to the other side, and a single route cannot use it twice.'
          end
          help << 'Any train running in a city which has a Corn token increase route value by 30.' if corn_assignment
          help
        end

        def subsidy_for(_route, stops)
          subsidy = 0
          # Get 1 for each town
          subsidy += stops.count { |s| !s.tile.towns.empty? }

          subsidy
        end

        def routes_subsidy(routes)
          return 0 if routes.empty?

          entity = routes.first.train.owner
          # No subsidy if it is using 'Two Barrels'
          return 0 if two_barrels_used_this_or?(entity)

          subsidy = routes.sum(&:subsidy)
          # 3$N additional if any subsidy and own 'A squeeze'
          subsidy += 3 if a_squeeze.owner == entity && subsidy.positive?

          subsidy
        end

        def format_currency(val)
          # object with :revenue should not be formatted
          val.is_a?(Integer) ? super : val[:revenue].to_s
        end

        def bonus_payout_for_share(share_price)
          STOCKMARKET_GAIN[share_price.coordinates[0]][share_price.coordinates[1]]
        end

        def bonus_payout_for_president(share_price)
          return 0 if share_price.coordinates[0].positive?

          STOCKMARKET_OWNER_GAIN[share_price.coordinates[1]] || 0
        end

        def threshold(entity)
          STOCKMARKET_THRESHOLD[entity.share_price.coordinates[0]][entity.share_price.coordinates[1]]
        end

        def share_price_updated(entity, revenue)
          return stock_market.find_share_price(entity, :right) if revenue >= threshold(entity)

          stock_market.find_share_price(entity, :stay)
        end

        def route_distance(route)
          distance = route.visited_stops.sum(&:visit_cost)

          visits = route.visited_stops
          if visits.size > 2
            corporation = route.corporation
            visits[1..-2].each do |node|
              distance -= 1 if node.city? && node.blocks?(corporation)
            end
          end

          return distance if @holes.empty?

          distance + ((@holes & route.all_hexes).size == 2 ? 1 : 0)
        end

        def assign_hole(entity, target)
          @holes << target

          return unless entity.all_abilities.empty?

          items = @holes.map(&:coordinates).sort.join('-')
          hole_to_convert = self.class::HOLE_BY_MAP[@map]
          hole_to_convert[items].each do |coordinates_list, new_tile_code|
            coordinates_list.each do |coordinates|
              hex_by_id(coordinates).lay(Engine::Tile.from_code(coordinates, :red, new_tile_code))
            end
          end

          coordinates_to_convert = hole_to_convert["#{items}-tiles"]

          hole_to_convert['tiles'].each do |coordinates_list, new_tile_code|
            coordinates_list&.each do |coordinates|
              next unless coordinates_to_convert.include?(coordinates)

              hex_by_id(coordinates).lay(Engine::Tile.from_code(coordinates, :red, new_tile_code))
            end
          end

          graph.clear_graph_for(entity.owner)
          connect_hexes
        end

        private

        def init_round
          Engine::Round::Draft.new(self, [G18ZOO::Step::SimpleDraft], reverse_order: true)
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
              ticket.add_ability(Ability::NoBuy.new(type: 'no_buy'))
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

        def num_trains(train)
          num_players = @players.size

          case train[:name]
          when '2S'
            num_players
          else
            super
          end
        end

        def init_corporations(stock_market)
          corporations = self.class::CORPORATIONS.select { |c| CORPORATIONS_BY_MAP[@map].include?(c[:sym]) }
                                                 .map do |corporation|
            Corporation.new(
              min_price: stock_market.par_prices.map(&:price).min,
              capitalization: self.class::CAPITALIZATION,
              coordinates: CORPORATION_COORDINATES_BY_MAP[@map][corporation[:sym]],
              **corporation.merge(corporation_opts),
            )
          end
          @near_families_purchasable = corporations.map { |c| { id: c.id } }
          corporations
        end

        def init_starting_cash(players, bank)
          hash = SMALL_MAP.include?(@map) ? self.class::STARTING_CASH_SMALL_MAP : self.class::STARTING_CASH_BIG_MAP
          cash = hash[players.size]

          players.each do |player|
            bank.spend(cash, player)
          end
        end

        def custom_end_game_reached?
          @turn == 3
        end

        def reorder_players(_order = nil)
          return if @round.is_a?(Engine::Round::Draft)

          current_order = @players.dup
          @players.sort_by! { |p| [midas_active? && p == midas.owner ? -1 : 0, -p.cash, current_order.index(p)] }
          @log << "Priority order: #{@players.map(&:name).join(', ')}"
        end

        def new_stock_round
          result = super

          update_zoo_tickets_value(@turn, 0)

          add_cousins if @turn == 3

          update_current_and_future(@companies_for_monday, @companies_for_tuesday, 1)
          update_current_and_future(@companies_for_tuesday, @companies_for_wednesday, 2)
          update_current_and_future(@companies_for_wednesday, nil, 3)

          if leprechaun_pot_of_gold.owner&.player?
            bank.spend(2, leprechaun_pot_of_gold.owner, check_positive: false)
            @log << "#{leprechaun_pot_of_gold.owner.name} earns #{format_currency(2)} using
            '#{leprechaun_pot_of_gold.name}'"
          end

          result
        end

        def stock_round
          Engine::Game::G18ZOO::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G18ZOO::Step::HomeTrack,
            G18ZOO::Step::BonusTracks,
            G18ZOO::Step::BuySellParShares,
          ])
        end

        def new_operating_round(round_num = 1)
          @operating_rounds = 3 if @turn == 3 # Last round has 3 ORs
          update_zoo_tickets_value(@turn, round_num)

          midas.close! if midas_active?

          super
        end

        def operating_round(round_num)
          Engine::Game::G18ZOO::Round::Operating.new(self, [
            G18ZOO::Step::Assign,
            G18ZOO::Step::SpecialTrack,
            G18ZOO::Step::SpecialToken,
            G18ZOO::Step::BuyOrUsePowerOnOr,
            G18ZOO::Step::BuyCompany,
            G18ZOO::Step::Track,
            G18ZOO::Step::Token,
            G18ZOO::Step::Route,
            G18ZOO::Step::Dividend,
            Engine::Step::DiscardTrain,
            G18ZOO::Step::BuyTrain,
            [G18ZOO::Step::BuyOrUsePowerOnOr, { blocks: true }],
          ], round_num: round_num)
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

        def add_cousins
          @log << 'Cousins join families.'

          @corporations.each { |c| c.shares.last.buyable = true }
        end

        def update_current_and_future(to_current, to_future, turn)
          if @turn == turn
            @available_companies.concat(to_current)
            @future_companies -= to_current
            to_current.each { |c| c.owner = @bank unless c.owner }
          end
          return if @all_private_visible || !to_future || @turn != turn

          @log << "Powers #{to_future.map { |c| "\"#{c.name}\"" }.join(', ')} added to the future deck"
          @future_companies.concat(to_future)
        end

        def update_zoo_tickets_value(turn, round_num = 1)
          new_value = ZOO_TICKET_VALUE[turn][round_num]
          @companies.select { |c| c.name.start_with?('ZOOTicket') }.each do |company|
            company.value = new_value
            company.min_price = 0
            company.max_price = company.value - 1
          end
        end

        def bonus_after_par(corporation, money, additional_tracks, available_tracks)
          bank.spend(money, corporation)
          @log << "#{corporation.name} earns #{format_currency(money)} as treasury bonus"

          @round.available_tracks.concat(available_tracks)

          @round.bonus_tracks = additional_tracks
        end

        def event_new_train!
          @first_train_of_new_phase = true if @round.is_a?(Engine::Round::Operating)
        end

        def event_rust_own_3s_4s!
          @log << '-- Event: "3S long" and "4S" owned by current player are rusted! --' # TODO: only if any owned
          # TODO: remove the 3S long and 4S owned by current player
        end

        def all_potential_upgrades(tile, tile_manifest: nil, selected_company: nil)
          if selected_company == rabbits
            return all_potential_upgrades_for_rabbits(tile, tile_manifest,
                                                      selected_company)
          end
          return all_potential_upgrades_for_moles(tile, tile_manifest, selected_company) if selected_company == moles

          super
            .reject { |t| %w[80 X80 81 X81 82 X82 83 X83].include?(t.name) }
        end

        RABBITS_UPGRADES = {
          'X7' => %w[X26 X27 X28 X29 X30 X31],
          'X8' => %w[X19 X23 X24 X25 X28 X29 X30 X31],
          'X9' => %w[X23 X24 X26 X27],
        }.freeze

        def all_potential_upgrades_for_rabbits(tile, _tile_manifest, company)
          @all_tiles
            .uniq(&:name)
            .select { |t| (RABBITS_UPGRADES[tile.name] || []).include?(t.name) }
            .select { |t| upgrades_to?(tile, t, true, selected_company: company) }
        end

        MOLES_UPGRADES = {
          '7' => %w[80 82 83],
          'X7' => %w[X80 X82 X83],
          '8' => %w[80 81 82 83],
          'X8' => %w[X80 X81 X82 X83],
          '9' => %w[82 83],
          'X9' => %w[X82 X83],
        }.freeze

        def all_potential_upgrades_for_moles(tile, _tile_manifest, company)
          @all_tiles
            .uniq(&:name)
            .select { |t| (MOLES_UPGRADES[tile.name] || []).include?(t.name) }
            .select { |t| upgrades_to?(tile, t, selected_company: company) }
        end
      end
    end
  end
end
