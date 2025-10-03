# frozen_string_literal: true

require_relative 'meta'
require_relative 'entities'
require_relative 'map'
require_relative '../base'

module Engine
  module Game
    module G18ZOO
      class Game < Game::Base
        CURRENCY_FORMAT_STR = '%s$N'

        BANK_CASH = 99_999

        CERT_LIMIT = {
          2 => { '5' => 10, '7' => 12 },
          3 => { '5' => 7, '7' => 9 },
          4 => { '5' => 5, '7' => 7 },
          5 => { '5' => 6, '7' => 6 },
        }.freeze

        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = true

        MARKET = [
          %w[7 8 9 10s 11s 12s 13s 14s 15s 16 20 24e],
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
            status: %w[can_buy_companies ipo_9],
          },
          {
            name: '4S',
            on: '4S',
            train_limit: 3,
            tiles: %i[yellow green],
            status: ['can_buy_companies'],
          },
          {
            name: '4S Perm',
            on: '4S Perm',
            train_limit: 3,
            tiles: %i[yellow green brown],
            status: %w[can_buy_companies ipo_12],
          },
          {
            name: '5S',
            on: '5S',
            train_limit: 2,
            tiles: %i[yellow green brown],
            status: ['can_buy_companies'],
          },
          {
            name: '4J',
            on: '4J',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            status: %w[can_buy_companies grey_homes],
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
            num: 2,
            events: [{ 'type' => 'new_train' }],
          },
          {
            name: '4S Perm',
            distance: 4,
            price: 20,
            num: 1,
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
            distance: 4,
            multiplier: 2,
            price: 47,
            num: 99,
            events: [{ 'type' => 'new_train' }, { 'type' => 'rust_own_3s_4s' }],
            variants: [
              {
                name: '2J',
                distance: 2,
                multiplier: 2,
                price: 37,
                num: 99,
              },
            ],
          },
          {
            name: '1S',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 1, 'visit' => 1 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 0,
            num: 1,
            reserved: true,
          },
        ].freeze

        LAYOUT = :flat

        # Game end after the ORs in the third turn, of if any company reach 24
        GAME_END_CHECK = { stock_market: :current_or, fixed_round: :full_or }.freeze

        GAME_END_REASONS_TEXT = Base::GAME_END_REASONS_TEXT.merge(
          fixed_round: 'Complete set of 3SR-7OR'
        )

        GAME_END_REASONS_TIMING_TEXT = Base::GAME_END_REASONS_TIMING_TEXT.merge(
          full_or: 'Ends at the end of OR 3.3'
        )

        BANKRUPTCY_ALLOWED = false

        CERT_LIMIT_INCLUDES_PRIVATES = false

        NEXT_SR_PLAYER_ORDER = :most_cash

        STOCKMARKET_COLORS = {
          par_1: :yellow,
          par_2: :green,
          par_3: :brown,
          endgame: :orange,
          safe_par: :blue,
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

        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false

        EBUY_CAN_TAKE_PLAYER_LOAN = :after_sell
        PLAYER_LOAN_INTEREST_RATE = -100
        PLAYER_LOAN_ENDGAME_PENALTY = 200

        HOME_TOKEN_TIMING = :float

        MUST_BUY_TRAIN = :always

        # A yellow/upgrade and a yellow
        TILE_LAYS = [
          { lay: true, upgrade: true, cannot_reuse_same_hex: true },
          { lay: true, upgrade: :not_if_upgraded, cannot_reuse_same_hex: true },
        ].freeze

        ASSIGNMENT_TOKENS = {
          'WHEAT' => '/icons/18_zoo/wheat.svg',
          'BARREL' => '/icons/18_zoo/barrel.svg',
          'HOLE' => '/icons/18_zoo/hole.svg',
          'WINGS' => '/icons/18_zoo/wings.svg',
          'PATCH' => '/icons/18_zoo/patch.svg',
        }.freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'new_train' => ['First train bonus',
                          'Corporation buying the first train of this type moves one to the right'],
          'rust_own_3s_4s' => ['First train buyer rust 3S Long and 4S',
                               'Corporation buying the first 4J/2J immediately rusts its own 3S Long and 4S '\
                               '(3S long and 4S run one last time for the other corporations)'],
        ).freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'ipo_9' => ['IPO 9 (bonus)',
                      'Corporation gets 5$N bonus in the treasury; must place a yellow or a green'\
                      ' track in the Home and up to 2 yellow tracks'],
          'ipo_12' => ['IPO 12 (bonus)',
                       'Corporation gets 10$N bonus in the treasury; must place a yellow or a green'\
                       ' or a brown track in the Home and up to 4 yellow tracks'],
          'grey_homes' => ['Grey Homes',
                           '3 Grey tracks available; upgrade HOME of GIRAFFES, TIGERS and BROWN BEARS'],
        ).freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(safe_par: 'President bonus (+1/3$N to the president)',
                                              par_1: 'Yellow phase par',
                                              par_2: 'Green phase par (bonus 5$N + 2 yellow tracks)',
                                              par_3: 'Brown phase par (bonus 10$N + 4 yellow tracks)').freeze

        MARKET_SHARE_LIMIT = 80 # percent

        ZOO_TICKET_VALUE = {
          1 => { 0 => 4, 1 => 5, 2 => 6 },
          2 => { 0 => 7, 1 => 8, 2 => 9 },
          3 => { 0 => 10, 1 => 12, 2 => 15, 3 => 18 },
          4 => { 0 => 20 },
        }.freeze

        attr_accessor :first_train_of_new_phase
        attr_reader :available_companies, :future_companies, :train_with_bandage

        def setup
          @operating_rounds = 2 # 2 ORs on first and second round

          @holes = []

          @available_companies = []
          @future_companies = []
          @ticket_zoo_current_value = ZOO_TICKET_VALUE[1][0]

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
            %w[16 X16],
            %w[19 X19],
            %w[20 X20],
            %w[23 X23],
            %w[24 X24],
            %w[25 X25],
            %w[26 X26],
            %w[27 X27],
            %w[28 X28],
            %w[29 X29],
            %w[30 X30],
            %w[31 X31],
            %w[14],
            %w[15],
            %w[619],
            %w[576],
            %w[577],
            %w[579],
            %w[792],
            %w[793],
            %w[39],
            %w[40],
            %w[41],
            %w[42],
            %w[43],
            %w[44],
            %w[45],
            %w[46],
            %w[47],
            %w[611],
            %w[582],
            %w[TI_455],
            %w[BB_455],
            %w[GI_455],
          ]
        end

        def init_optional_rules(optional_rules)
          rules = super

          @near_families = @players.size < 5
          @all_private_visible = rules.include?(:power_visible)

          rules
        end

        def game_bases
          return game_base_3 if @optional_rules.include?(:base_3)
          return game_base_2 if @optional_rules.include?(:base_2)

          nil
        end

        def optional_hexes
          base = game_bases
          hexes = game_hexes
          return hexes unless base

          new_hexes = {}
          hexes.keys.each do |color|
            new_map = hexes[color].transform_keys do |coords|
              coords - base.keys
            end
            base.each do |coords, tile_array|
              next unless color == tile_array[1]

              new_map[[coords]] = tile_array[0]
            end

            new_hexes[color] = new_map
          end

          new_hexes
        end

        def location_name(coord)
          result = game_location_names[coord]
          result = game_location_name_base_2[coord] if @optional_rules.include?(:base_2) &&
            !@optional_rules.include?(:base_3) && game_location_name_base_2.key?(coord)
          result = game_location_name_base_3[coord] if @optional_rules.include?(:base_3) &&
            game_location_name_base_3.key?(coord)
          result
        end

        def result
          current_order = @players.dup
          @players
            .sort_by { |p| [-player_value(p), current_order.index(p)] }
            .to_h { |p| [p.id, player_value(p)] }
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
            player.companies.select { |company| company.name.start_with?('ZOOTicket') }.sum(&:value) -
            player.penalty
        end

        def end_game!(game_end_reason)
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
          return false if to.name == 'TI_455' && from.hex.coordinates != game_corporation_coordinates['TI']
          return false if to.name == 'GI_455' && from.hex.coordinates != game_corporation_coordinates['GI']
          return false if to.name == 'BB_455' && from.hex.coordinates != game_corporation_coordinates['BB']

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
          return false if @round.is_a?(Engine::Round::Operating) && selected_company == ancient_maps && from.color != :white

          super
        end

        def unowned_purchasable_companies(_entity)
          @available_companies + @future_companies
        end

        def after_par(corporation)
          @round.floated_corporation = corporation
          @round.available_tracks = %w[5 6 57]

          bonus_after_par(corporation, 5, 2, %w[14 15 619]) if corporation.par_price.price == 9
          bonus_after_par(corporation, 10, 4, %w[14 15 619 611]) if corporation.par_price.price == 12

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
            @log << "Near family rule: next choice is either #{previous_corporation.full_name} or"\
                    " #{next_corporation.full_name} (choosing one excludes the other one)"
          else
            if @corporations.count(&:ipoed) == 2
              @near_families_direction = @near_families_purchasable.find { |c| c[:id] == corporation.id }[:direction]
            end
            corporations = @near_families_direction == 'reverse' ? corporations_order.reverse : corporations_order
            following_corporation = corporations.drop_while { |c| c.id != corporation.id }
                                                .find { |c| !c.ipoed }
            if following_corporation
              @near_families_purchasable = [{ id: following_corporation.id }]

              @log << "Near family rule: #{following_corporation.full_name} is now available"
            end
          end
        end

        def choices_for_bandage?(entity)
          return {} if @round.respond_to?(:entity_with_bandage) && @round.entity_with_bandage

          corporations = entity.player? ? @corporations.filter { |c| c.owner == entity } : [entity]
          corporation = corporations.find { |c| c.assigned?(patch.id) }
          if corporation
            return [[{ type: :remove_bandage, corporation: corporation.id },
                     "Remove \"Patch\" from 1S (#{corporation.name})"]]
          end

          corporations.flat_map do |c|
            c.trains
             .uniq(&:name)
             .map { |train| [{ type: :patch, train_id: train.id }, "#{train.name} (#{train.owner.name})"] }
          end.to_h
        end

        def can_use_bandage?(entity, patch)
          return false if @round.respond_to?(:entity_with_bandage) && @round.entity_with_bandage

          corporations = entity.player? ? @corporations.filter { |c| c.owner == entity } : [entity]
          return true if corporations.any? do |corporation|
            # can remove the patch
            return true if corporation.assigned?(patch.id)
            # cannot apply the patch if already 3 companies
            return false if patch.owner&.player? && corporation.companies.count >= 3
            # can apply the patch
            return true if !corporation.trains.empty? &&
              [corporation, corporation.owner].include?(patch.owner)

            false
          end

          false
        end

        def entity_can_use_company?(entity, company)
          return true if entity.player? && entity == company.owner
          return true if entity.corporation? && entity == company.owner
          return true if entity.corporation? && zoo_ticket?(company) && entity.owner == company.owner
          return true if company == patch && can_use_bandage?(entity, company)

          false
        end

        def days_off
          @days_off ||= company_by_id('DAYS_OFF')
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
          @it_is_all_greek_to_me ||= company_by_id('IT_S_ALL_GREEK_TO_ME')
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

        def on_a_diet
          @on_a_diet ||= company_by_id('ON_A_DIET')
        end

        def shining_gold
          @shining_gold ||= company_by_id('SHINING_GOLD')
        end

        def that_s_mine
          @that_s_mine ||= company_by_id('THAT_S_MINE')
        end

        def can_choose_is_mine?(entity, company)
          company == that_s_mine && entity&.corporation? && that_s_mine.owner == entity &&
            !@round.tokened &&
            !entity.unplaced_tokens.empty? &&
            entity.unplaced_tokens.first.price <= buying_power(entity) &&
            that_s_mine.all_abilities[0].is_a?(Ability::Reservation) &&
            graph.reachable_hexes(entity)[that_s_mine.all_abilities[0].hex]
        end

        def work_in_progress
          @work_in_progress ||= company_by_id('WORK_IN_PROGRESS')
        end

        def wheat
          @wheat ||= company_by_id('WHEAT')
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

        def patch
          @patch ||= company_by_id('PATCH')
        end

        def wings
          @wings ||= company_by_id('WINGS')
        end

        def a_tip_of_sugar
          @a_tip_of_sugar ||= company_by_id('A_TIP_OF_SUGAR')
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
          from_price = from.price
          to_price = entity.share_price.price
          return unless from_price != to_price

          @log << "#{entity.name}'s share price changes from #{format_currency(from_price)} "\
                  "to #{format_currency(to_price)} #{additional_info}"
        end

        def revenue_for(route, stops)
          revenue = super

          # Add 30$N if route contains 'Wheat' and Corporation owns 'Wheat'
          revenue += 30 * (route.train.multiplier || 1) if route.corporation.assigned?(wheat.id) &&
            stops.any? { |stop| stop.hex.assigned?(wheat.id) }

          # Towns revenues are doubled if 'Two barrels' is in use
          revenue += 10 * stops.count { |stop| !stop.tile.towns.empty? } if two_barrels_used_this_or?(route.corporation)

          # Add Hole off-board revenue when passing through
          revenue += @holes[0].tile.offboards[0].route_revenue(route.phase, route.train) if pass_through_hole?(route)

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
          name = route.train.name
          check_town = %w[4J 2J].include?(name)
          cities_visited = cities_visited(route, visits, check_town)

          if name == '1S'
            raise GameError, "Train with \"Patch\" cannot visit #{cities_visited} stops" if cities_visited > 1
          else
            raise GameError, 'Water and external gray don\'t count as city/offboard.' if cities_visited < 2

            max_distance = distance_aux(route, check_town)
            raise GameError, "#{cities_visited} is too many stops for #{name}" if max_distance < cities_visited
          end
        end

        def check_other(route)
          super

          return if @holes.empty?

          holes_in_route = route.paths.map(&:tile).select { |tile| @holes.include?(tile.hex) }

          # Route cannot use Hole as off-board and as pass-through, or used twice
          count_holes = holes_in_route.size
          if count_holes > 2
            raise GameError, 'Hole cannot be used as a terminal and as a tunnel at the same time; neither can be used'\
                             ' multiple times as tunnel with the same squirrel (train)'
          end

          # Route cannot go in and out from the same hex
          hole_used_twice = (count_holes == 2) && (holes_in_route.uniq.size == 1)
          raise GameError, 'Route cannot go in and out from the same hex of one of the two R AREA' if hole_used_twice

          # Route cannot use Hole as starting end ending point
          hole_used_twice = (@holes & route.stops.map { |stop| stop.tile.hex }).size == 2
          raise GameError, 'Route cannot use holes as terminal more than once' if hole_used_twice
        end

        def check_connected(route, corporation)
          blocked = nil
          blocked_by = nil
          train_with_sugar = nil

          route.routes.each_with_index do |current_route, index|
            visits = current_route.visited_stops

            next unless visits.size > 2

            visits[1..-2].each do |node|
              next if !node.city? || !node.blocks?(corporation)
              raise GameError, 'Route is not connected' unless route.train.owner.assigned?(wings.id)
              raise GameError, "City with only '#{work_in_progress.name}' slot cannot be bypassed" if node.city? &&
                node.slots(all: true) == 1 && node.tokens.first.type == :blocking
              raise GameError, 'Only one train can bypass a tokened-out city' if blocked && blocked_by != index
              raise GameError, 'Route can only bypass one tokened-out city' if blocked

              blocked = node
              blocked_by = index
            end

            distance = current_route.train.distance
            next if %w[1S 4J 2J].include?(current_route.train.name) || current_route.train.owner != a_tip_of_sugar.owner

            cities_visited = cities_visited(current_route, visits, false)

            next unless distance < cities_visited
            raise GameError, 'Only one train can use "A tip of sugar"' if train_with_sugar

            train_with_sugar = current_route.train
          end
        end

        def company_header(company)
          type_text = @future_companies.include?(company) ? 'FUTURE POWER' : 'POWER'
          sr_or_text = case company.sym
                       when 'DAYS_OFF', 'MIDAS', 'TOO_MUCH_RESPONSIBILITY', 'LEPRECHAUN_POT_OF_GOLD',
                         'IT_S_ALL_GREEK_TO_ME', 'WHATSUP'
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

          # Wheat assignment
          corn_assignment = entity.assigned?('WHEAT')

          # Holes assignment
          holes_assignment = !@holes.empty?

          help = []

          help << 'Routes get no subsidy at all, but every town increase route value by 10.' if barrel_assignment
          if holes_assignment
            c1 = @holes.first.coordinates
            c2 = @holes.last.coordinates
            help << "Off-boards #{c1}, #{c2} are special: they can be used at the beginning or end of a route, and"\
                    ' may also be passed through. Click on it to use it as a beginning or end of a route. Click on'\
                    " the first stop out of the off-board #{c1} and the first stop out of the off-board #{c2} to run"\
                    ' a route through.'
          end
          if corn_assignment
            help << 'Any train running in a city which has a "Wheat" token increase route value by '\
                    "#{format_revenue_currency(30)}."
          end
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

        def format_revenue_currency(val)
          "#{val} nuts"
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
          direction = if revenue >= threshold(entity)
                        r, c = entity.share_price.coordinates
                        c + 1 < stock_market.market[r].size ? :right : :up
                      else
                        :stay
                      end

          stock_market.find_share_price(entity, direction)
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

          distance + (pass_through_hole?(route) ? 1 : 0)
        end

        def assign_hole(entity, target)
          @holes << target

          return unless entity.all_abilities.empty?

          items = @holes.map(&:coordinates).sort.join('-')
          hole_to_convert = game_hole
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

        def buying_power(entity, use_tickets: false, **)
          return super unless use_tickets

          tickets = if entity.player?
                      entity.companies || []
                    elsif entity.corporation?
                      entity.owner&.companies || []
                    else
                      []
                    end
          super + tickets.select { |company| company.name.start_with?('ZOOTicket') }.sum(&:value)
        end

        def show_progress_bar?
          true
        end

        def progress_information
          [
            { type: :PRE },
            { type: :SR, value: '4', name: '1' },
            { type: :OR, value: '5', name: '1.1' },
            { type: :OR, value: '6', name: '1.2' },
            { type: :SR, value: '7', name: '2' },
            { type: :OR, value: '8', name: '2.1' },
            { type: :OR, value: '9', name: '2.2' },
            { type: :SR, value: '10', name: '3' },
            { type: :OR, value: '12', name: '3.1' },
            { type: :OR, value: '15', name: '3.2' },
            { type: :OR, value: '18', name: '3.3' },
            { type: :END, value: '20' },
          ]
        end

        def timeline
          near_family_text = case @players.size
                             when 5
                               'may open any company - the neighbor rule is not enforced in a 5 players game'
                             else
                               case @near_families_purchasable.size
                               when 1
                                 corporation = corporation_by_id(@near_families_purchasable[0][:id])
                                 ordered = @corporations.sort_by(&:full_name).cycle(2).to_a
                                 corporations = @near_families_direction == 'reverse' ? ordered.reverse : ordered
                                 following_corporations = corporations.drop_while { |c| c.id != corporation.id }
                                                                      .take(@corporations.size)
                                                                      .reject(&:ipoed)
                                                                      .map(&:full_name)
                                                                      .join(', ')
                                 return if following_corporations.empty?

                                 "open company in strict order: #{following_corporations}"
                               when 2
                                 next_family = corporation_by_id(@near_families_purchasable[0][:id])
                                 prev_family = corporation_by_id(@near_families_purchasable[1][:id])
                                 "open only either #{next_family.full_name} or #{prev_family.full_name}"
                               else
                                 'open any company'
                               end
                             end

          @timeline = [
            "ZOOTicket: the current value is #{format_currency(@ticket_zoo_current_value)}."\
            ' Numbers 4,5,6…20 on the timeline are the value of a single ZOOTicket during each round'\
            ' (i.e. a ZOOTicket is worth 9$N in the OR 2.2). At the end of game each non-sold ZOOTicket is worth'\
            ' 20$N.',
          ]
          @timeline << "NEARBY FAMILY: #{near_family_text}" if near_family_text
          @timeline << 'SR 3: at the start of SR 3 the reserved R shares are available to buy.'
          @timeline << 'END: if during a forced train purchase the player doesn\'t have enough money, the bank covers'\
                       ' the expense; the player gets a penalty equal to twice what the bank paid'
        end

        def rust?(train, purchased_train)
          return false if purchased_train && !super
          return true if depot.discarded.include?(train)
          return true if !train.owner || !train.owner.corporation?
          return true if @round.trains_for_bandage&.include?(train)

          corporation = train.owner
          player = corporation.owner

          # Train protection cannot be applied if corporation has already 3 companies
          return true if patch.owner == player && corporation.companies.count >= 3

          @round.entity_with_bandage = player if patch.owner == player
          @round.entity_with_bandage = corporation if patch.owner == corporation && !corporation.assigned?(patch.id)
          return true if !@round.entity_with_bandage || ![train.owner,
                                                          train.owner.owner].include?(@round.entity_with_bandage)

          @round.trains_for_bandage << train

          false
        end

        def rust(train)
          return super if depot.discarded.include?(train)
          return if !train.owner || !train.owner.corporation?
          # Train protection cannot be applied if corporation has already 3 companies
          return super if patch.owner&.player? && train.owner.companies.count >= 3

          corporation = train.owner
          player = corporation.owner

          @round.entity_with_bandage = player if patch.owner == player
          @round.entity_with_bandage = corporation if patch.owner == corporation && !corporation.assigned?(patch.id)

          super
        end

        def assign_bandage(train)
          corporation = train.owner

          corporation.assign!(patch.id)
          @train_with_bandage = train

          patch.desc = "Train #{train.name} now is a 1S"

          new_train = train_by_id('1S-0')
          new_train.owner = train.owner
          new_train.buyable = false
          train.owner.trains.delete(train)
          train.owner.trains << new_train
          train.rusts_on = "block-#{train.rusts_on}" if train.rusts_on
          train.buyable = false

          return unless patch.owner.player?

          patch.owner.companies&.delete(patch)
          patch.owner = corporation
          corporation.companies << patch
        end

        def process_choose_bandage?(action)
          train = train_by_id(action.choice['train_id'])
          assign_bandage(train)

          @log << "#{train.name} gets a patch, becomes a 1S"
        end

        def process_remove_bandage?(action)
          corporation = corporation_by_id(action.choice['corporation'])
          train = @train_with_bandage
          train.buyable = true
          company = patch

          corporation.remove_assignment!(company.id)
          company.close!
          @log << "#{company.name} closes"

          @log << "#{corporation.name} removes the patch from 1S; train is #{train.name} again"

          corporation.trains.delete(train_by_id('1S-0'))
          corporation.trains << @train_with_bandage
          @train_with_bandage = nil

          if train.rusts_on
            train.rusts_on = train.rusts_on.gsub('block-', '')
            rust_trains!(train_by_id("#{train.rusts_on}-0"), train.owner) if phase.available?(train.rusts_on)
          end

          train_by_id('1S-0').owner = nil

          # re-enable buy_train step if owner has no train
          @round.steps.find { |s| s.is_a?(G18ZOO::Step::BuyTrain) }.unpass! if corporation.trains.empty?
        end

        def can_run_route?(entity)
          entity.trains.any? { |t| t.name == '1S' } || super
        end

        def chart_price(share_price)
          bonus_share = bonus_payout_for_share(share_price)
          bonus_president = bonus_payout_for_president(share_price)
          "#{format_currency(bonus_share)}"\
            "#{bonus_president.positive? ? '+' + format_currency(bonus_president) : ''}"
        end

        def threshold_help
          entity = current_entity
          return unless entity

          threshold = threshold(entity)
          bonus_hold_share = bonus_payout_for_share(entity.share_price)
          bonus_hold_president = bonus_payout_for_president(entity.share_price)
          price_updated = share_price_updated(entity, threshold)
          bonus_pay_share = bonus_payout_for_share(price_updated)
          bonus_pay_president = bonus_payout_for_president(price_updated)

          help = "Current dividend #{format_currency(bonus_hold_share)}"
          help += " (+#{format_currency(bonus_hold_president)} bonus president)" if bonus_hold_president.positive?
          help += ". Threshold to move: #{format_revenue_currency(threshold)}. "\
                  "Dividend if moved #{format_currency(bonus_pay_share)}"
          help += " (+#{format_currency(bonus_pay_president)} bonus president)" if bonus_pay_president.positive?

          help
        end

        def local_length
          99
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
              ticket = Company.new(sym: "ZOOTicket #{i} - #{player.name}",
                                   name: "ZOOTicket #{i}",
                                   value: 4,
                                   desc: 'Exchange it for money')
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
          return @players.size if train[:name] == '2S'

          super
        end

        def init_corporations(stock_market)
          corporations = game_corporations.map do |corporation|
            Corporation.new(
              min_price: stock_market.par_prices.map(&:price).min,
              capitalization: self.class::CAPITALIZATION,
              coordinates: game_corporation_coordinates[corporation[:sym]],
              **corporation.merge(corporation_opts),
            )
          end
          @near_families_purchasable = corporations.map { |c| { id: c.id } }
          corporations
        end

        def game_end_check_fixed_round?
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

          @operating_rounds = @turn == 3 ? 3 : 2 # Last round has 3 ORs

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
            G18ZOO::Step::TrainProtection,
            G18ZOO::Step::BuySellParShares,
          ])
        end

        def new_operating_round(round_num = 1)
          @operating_rounds = @turn == 3 ? 3 : 2 # Last round has 3 ORs
          update_zoo_tickets_value(@turn, round_num)

          midas.close! if midas_active?

          super
        end

        def operating_round(round_num)
          Engine::Game::G18ZOO::Round::Operating.new(self, [
            G18ZOO::Step::Assign,
            G18ZOO::Step::SpecialTrack,
            G18ZOO::Step::SpecialToken,
            G18ZOO::Step::TrainProtection,
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
          @ticket_zoo_current_value = ZOO_TICKET_VALUE[turn][round_num]
          @companies.select { |c| c.name.start_with?('ZOOTicket') }.each do |company|
            company.value = @ticket_zoo_current_value
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
          entity = current_entity
          return unless entity.corporation?

          entity.trains.each do |train|
            next unless train.obsolete

            train.rusts_on = '4J'
          end

          rust_trains!(train_by_id('4J-0'), nil)
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
          'X8' => %w[X16 X19 X23 X24 X25 X28 X29 X30 X31],
          'X9' => %w[X19 X20 X23 X24 X26 X27],
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

        def pass_through_hole?(route)
          !@holes.empty? &&
            (@holes & route.all_hexes).size == 2 &&
            (@holes & route.stops.map { |stop| stop.tile.hex }).size.zero?
        end

        def cities_visited(route, visits, check_town)
          cities_visited = visits.count do |v|
            v.city? || (v.offboard? && v.revenue[:yellow].positive?) ||
              (v.town? && check_town)
          end

          # Passing through Hole count as a stop
          cities_visited += 1 if pass_through_hole?(route)

          # Passing through City with Wings doesn't count
          visits = route.visited_stops
          if visits.size > 2
            corporation = route.corporation
            visits[1..-2].each do |node|
              cities_visited -= 1 if node.city? && node.blocks?(corporation)
            end
          end

          cities_visited
        end

        def distance_aux(route, is_j_train)
          distance = route.train.distance
          # A tip of sugar raise the max_distance number
          distance += 1 if !is_j_train && route.train.owner == a_tip_of_sugar.owner

          distance
        end
      end
    end
  end
end
