# frozen_string_literal: true

require_relative '../config/game/g_18_mag'
require_relative 'base'

module Engine
  module Game
    class G18Mag < Base
      attr_reader :tile_groups, :unused_tiles, :sik, :skev, :ldsteg, :mavag, :raba, :snw, :gc, :terrain_tokens

      load_from_json(Config::Game::G18Mag::JSON)

      GAME_LOCATION = 'Hungary'
      GAME_RULES_URL = 'https://www.lonny.at/games/18magyarorsz%C3%A1g/'
      GAME_DESIGNER = 'Leonhard "Lonny" Orgler'
      GAME_PUBLISHER = :lonny_games
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18Mag'

      DEV_STAGE = :alpha

      EBUY_PRES_SWAP = false # allow presidential swaps of other corps when ebuying
      EBUY_OTHER_VALUE = false # allow ebuying other corp trains for up to face
      HOME_TOKEN_TIMING = :float
      SELL_AFTER = :any_time
      SELL_BUY_ORDER = :sell_buy
      MARKET_SHARE_LIMIT = 100

      TRACK_RESTRICTION = :permissive

      SELL_MOVEMENT = :left_block

      TILE_LAYS = [{ lay: true, upgrade: true }, { lay: true, upgrade: :not_if_upgraded, cost: 10 }].freeze

      START_PRICES = [60, 60, 65, 65, 70, 70, 75, 75, 80, 80].freeze
      MINOR_STARTING_CASH = 50

      TRAIN_PRICE_MIN = 1

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
        'first_three' => ['First 3', 'Advance phase'],
        'first_four' => ['First 4', 'Advance phase'],
        'first_six' => ['First 6', 'Advance phase'],
      ).freeze

      GAME_END_CHECK = { final_phase: :one_more_full_or_set }.freeze

      STATUS_TEXT = Base::STATUS_TEXT.merge(
        'end_game_triggered' => ['End Game', 'After next SR, final three ORs are played'],
      ).freeze

      RABA_BONUS = [20, 20, 30, 30].freeze
      SNW_BONUS = [30, 30, 50, 50].freeze

      CORP_TOKEN_REVENUE = 10

      MAX_ORS_NO_TRAIN = 3

      FIXED_ROTATION_TILES = {
        'L33' => 2,
      }.freeze

      TERRAIN_TOKENS = {
        '5' => 3,
        '6' => 1,
        '7' => 1,
        '12' => 2,
        '13' => 1,
      }.freeze

      CORPORATE_POWERS = {
        'SIK' => 'Earns for each terrain symbol',
        'SKEV' => 'Earns for tokens and 2nd tile lay',
        'LdStEG' => 'Sells 2, 4 trains',
        'MAVAG' => 'Sells 3, 6 trains',
        'RABA' => 'Sells off board bonus',
        'SNW' => 'Sells mine access',
        'G&C' => 'Sells plus-train conversion',
      }.freeze

      def setup
        @sik = @corporations.find { |c| c.name == 'SIK' }
        @skev = @corporations.find { |c| c.name == 'SKEV' }
        @ldsteg = @corporations.find { |c| c.name == 'LdStEG' }
        @mavag = @corporations.find { |c| c.name == 'MAVAG' }
        @raba = @corporations.find { |c| c.name == 'RABA' }
        @snw = @corporations.find { |c| c.name == 'SNW' }
        @gc = @corporations.find { |c| c.name == 'G&C' }

        @terrain_tokens = TERRAIN_TOKENS.dup

        @tile_groups = init_tile_groups
        update_opposites
        @unused_tiles = []

        # start with first minor tokens placed (as opposed to just reserved)
        @mine = @minors.find { |m| m.name == 'mine' }
        @minors.delete(@mine)

        # Place all mine tokens and mark them as non-blocking
        # route restrictions will be handled elsewhere
        @mine.coordinates.each do |coord|
          hex = hex_by_id(coord)
          hex.tile.cities[0].place_token(@mine, @mine.next_token)
        end
        @mine.tokens.each { |t| t.type = :neutral }

        # IPO and float all corporations with semi-randomly chosen prices
        # They will start off in receivership with all shares in market
        rand_prices = START_PRICES.sort_by { rand }
        @corporations.each do |corp|
          share_price = @stock_market.par_prices.find { |p| p.price == rand_prices[0] }
          rand_prices.shift
          @stock_market.set_par(corp, share_price)
          corp.ipoed = true

          corp.ipo_shares.each do |share|
            @share_pool.transfer_shares(
              share.to_bundle,
              share_pool,
              spender: share_pool,
              receiver: @bank,
              price: 0
            )
          end
          corp.owner = @share_pool
        end

        @trains_left = %w[3 4 6]
        @phase_change = false
        @train_bought = false
        @ors_no_train = 0
      end

      def partition_companies
        init_minors.select { |m| m.name == 'mine' }
      end

      def reservation_corporations
        minors.reject { |m| m.name == 'mine' }
      end

      def init_tile_groups
        [
          %w[7],
          %w[8 9],
          %w[3],
          %w[58 4],
          %w[5 57],
          %w[6],
          %w[L32],
          %w[L33],
          %w[16 19],
          %w[20],
          %w[23 24],
          %w[25],
          %w[26 27],
          %w[28 29],
          %w[30 31],
          %w[204],
          %w[88 87],
          %w[619],
          %w[14 15],
          %w[209],
          %w[236],
          %w[237 238],
          %w[8858],
          %w[8859],
          %w[8860],
          %w[8863],
          %w[8864],
          %w[8865],
          %w[39 40],
          %w[41 42],
          %w[43 70],
          %w[44 47],
          %w[45 46],
          %w[G17],
          %w[611],
          %w[L17],
          %w[L34],
          %w[L35],
          %w[L38],
          %w[455],
          %w[X9],
          %w[L36],
          %w[L37],
        ]
      end

      # set opposite correctly for two-sided tiles
      def update_opposites
        by_name = @tiles.group_by(&:name)
        @tile_groups.each do |grp|
          next unless grp.size == 2

          name_a, name_b = grp
          num = by_name[name_a].size
          raise GameError, 'Sides of double-sided tiles need to have same number' if num != by_name[name_b].size

          num.times.each do |idx|
            tile_a = tile_by_id("#{name_a}-#{idx}")
            tile_b = tile_by_id("#{name_b}-#{idx}")

            tile_a.opposite = tile_b
            tile_b.opposite = tile_a
          end
        end
      end

      def float_minor(minor)
        minor.float!
        train = @depot.upcoming[0]
        buy_train(minor, train, :free)
        @bank.spend(MINOR_STARTING_CASH, minor)
        hex = hex_by_id(minor.coordinates)
        hex.tile.cities[minor.city || 0].place_token(minor, minor.next_token)
      end

      def init_starting_cash(players, bank)
        cash = self.class::STARTING_CASH
        cash = cash[players.size] if cash.is_a?(Hash)

        players.each do |player|
          bank.spend(cash, player, check_positive: false)
        end
      end

      def new_auction_round
        Round::Draft.new(self, [Step::G18Mag::SimpleDraft], rotating_order: true)
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Exchange,
          Step::HomeToken,
          Step::G18Mag::Track,
          Step::G18Mag::Token,
          Step::G18Mag::DiscardTrain,
          Step::G18Mag::Route,
          Step::G18Mag::Dividend,
          Step::G18Mag::BuyTrain,
        ], round_num: round_num)
      end

      def new_operating_round(round_num = 1)
        @train_bought = false
        @log << "-- #{round_description('Operating', round_num)} --"
        operating_round(round_num)
      end

      def next_round!
        @round =
          case @round
          when Round::Stock
            @operating_rounds = @phase.operating_rounds
            reorder_players
            new_operating_round
          when Round::Operating
            no_train_advance!
            if @round.round_num < @operating_rounds && !@phase_change
              or_round_finished
              new_operating_round(@round.round_num + 1)
            else
              @phase_change = false
              @turn += 1
              or_round_finished
              or_set_finished
              new_stock_round
            end
          when init_round.class
            @operating_rounds = @phase.operating_rounds
            init_round_finished
            reorder_players
            new_operating_round
          end
      end

      def total_rounds(name)
        # Return the total number of rounds for those with more than one.
        if !@phase_change
          @operating_rounds if name == 'Operating'
        elsif name == 'Operating'
          @round.round_num
        end
      end

      def upgrades_to?(from, to, special = false)
        # correct color progression?
        return false unless Engine::Tile::COLORS.index(to.color) == (Engine::Tile::COLORS.index(from.color) + 1)

        # honors pre-existing track?
        return false unless from.paths_are_subset_of?(to.paths)

        # If special ability then remaining checks is not applicable
        return true if special

        # correct label?
        return false if from.label != to.label && !(from.label.to_s == 'K' && to.color == :yellow)

        # honors existing town/city counts?
        # - allow labelled cities to upgrade regardless of count; they're probably
        #   fine (e.g., 18Chesapeake's OO cities merge to one city in brown)
        # - TODO: account for games that allow double dits to upgrade to one town
        return false if from.towns.size != to.towns.size
        return false if (!from.label || from.label.to_s == 'K') && from.cities.size != to.cities.size

        # handle case where we are laying a yellow OO tile and want to exclude single-city tiles
        return false if (from.color == :white) && from.label.to_s == 'OO' && from.cities.size != to.cities.size

        true
      end

      def must_buy_train?(_entity)
        false
      end

      # price is nil, :free, or a positive int
      def buy_train(operator, train, price = nil)
        @train_bought = true if train.owner == @depot # No idea if this is what Lonny wants
        cost = price || train.price
        if price != :free && train.owner == @depot
          corp = %w[2 4].include?(train.name) ? @ldsteg : @mavag
          operator.spend(cost / 2, @bank)
          operator.spend(cost / 2, corp)
          @log << "#{corp.name} earns #{format_currency(cost / 2)}"
        elsif price != :free
          operator.spend(cost, train.owner)
        end
        remove_train(train)
        train.owner = operator
        operator.trains << train
        operator.rusted_self = false
        @crowded_corps = nil
      end

      def place_home_token(_corp); end

      def init_phase
        Phase.new(self.class::PHASES.dup.map(&:dup), self)
      end

      def no_train_advance!
        if @train_bought
          @ors_no_train = 0
          return
        end

        @ors_no_train += 1
        return unless @phase.upcoming && @ors_no_train >= MAX_ORS_NO_TRAIN

        @log << "-- No trains purchased in #{MAX_ORS_NO_TRAIN} Operating Rounds --"
        @ors_no_train = 0
        @phase.next!
        @phase.current[:on] = nil
        @phase_change = true
        if @phase.upcoming
          @phase.upcoming[:on] = @trains_left
          @phase.next_on = @trains_left
        else
          @depot.trains.each { |t| t.events.clear }
        end
      end

      def event_first_three!
        @phase_change = true
        @trains_left.delete('3')
        @phase.current[:on] = nil
        if @phase.upcoming
          @phase.upcoming[:on] = @trains_left
          @phase.next_on = @trains_left
        else
          @depot.trains.each { |t| t.events.clear }
        end
      end

      def event_first_four!
        @phase_change = true
        @trains_left.delete('4')
        @phase.current[:on] = nil
        if @phase.upcoming
          @phase.upcoming[:on] = @trains_left
          @phase.next_on = @trains_left
        else
          @depot.trains.each { |t| t.events.clear }
        end
      end

      def event_first_six!
        @phase_change = true
        @trains_left.delete('6')
        @phase.current[:on] = nil
        if @phase.upcoming
          @phase.upcoming[:on] = @trains_left
          @phase.next_on = @trains_left
        else
          @depot.trains.each { |t| t.events.clear }
        end
      end

      def info_on_trains(phase)
        Array(phase[:on]).join(', ')
      end

      def legal_tile_rotation?(_entity, hex, tile)
        if FIXED_ROTATION_TILES.include?(tile.name)
          tile.rotation == FIXED_ROTATION_TILES[tile.name]
        else
          (tile.exits & hex.tile.borders.select { |b| b.type == :water }.map(&:edge)).empty? &&
            hex.tile.partitions.all? do |partition|
              tile.paths.all? do |path|
                (path.exits - partition.inner).empty? || (path.exits - partition.outer).empty?
              end
            end
        end
      end

      def gc_train?(route)
        @round.rail_cars.include?('G&C') && route.visited_stops.sum(&:visit_cost) > route.train.distance
      end

      def other_gc_train?(route)
        route.routes.each do |r|
          return false if r == route
          return true if gc_train?(r)
        end
        false
      end

      def snw_train?(route)
        @round.rail_cars.include?('SNW') &&
          route.visited_stops.any? { |n| n.city? && n.tokens.any? { |t| t&.type == :neutral } }
      end

      def other_snw_train?(route)
        route.routes.each do |r|
          return false if r == route
          return true if snw_train?(r)
        end
        false
      end

      def raba_train?(route)
        @round.rail_cars.include?('RABA') && route.visited_stops.any?(&:offboard?)
      end

      def other_raba_train?(route)
        route.routes.each do |r|
          return false if r == route
          return true if raba_train?(r)
        end
        false
      end

      def check_distance(route, visits)
        distance = if gc_train?(route) && !other_gc_train?(route)
                     [
                       {
                         nodes: %w[city offboard],
                         pay: route.train.distance,
                         visit: route.train.distance,
                       },
                       {
                         nodes: %w[town],
                         pay: route.train.distance,
                         visit: route.train.distance,
                       },
                     ]
                   else
                     route.train.distance
                   end

        if distance.is_a?(Numeric)
          route_distance = visits.sum(&:visit_cost)
          raise GameError, "#{route_distance} is too many stops for #{distance} train" if distance < route_distance
          raise GameError, 'Must visit minimum of two non-mine stops' if route_distance < 2

          return
        end

        type_info = Hash.new { |h, k| h[k] = [] }

        distance.each do |h|
          pay = h['pay']
          visit = h['visit'] || pay
          info = { pay: pay, visit: visit }
          h['nodes'].each { |type| type_info[type] << info }
        end

        grouped = visits.group_by(&:type)

        grouped.each do |type, group|
          num = group.sum(&:visit_cost)

          type_info[type].sort_by(&:size).each do |info|
            next unless info[:visit].positive?

            info[:visit] -= num
            num = info[:visit] * -1
            break unless num.positive?
          end

          raise GameError, 'Route has too many stops' if num.positive?
        end
        raise GameError, 'Must visit minimum of two non-mine stops' if visits.sum(&:visit_cost) < 2
      end

      # Change "Stop" displayed if G&C power is used
      def route_distance(route)
        return super unless gc_train?(route) && !other_gc_train?(route)

        n_cities = route.stops.select { |s| s.visit_cost.positive? }.count { |n| n.city? || n.offboard? }
        n_towns = route.stops.count(&:town?)
        "#{n_cities}+#{n_towns}"
      end

      # Check to see if it's OK to visit a mine (SNW power)
      def check_other(route)
        mines = route.visited_stops.select { |n| n.city? && n.tokens.any? { |t| t&.type == :neutral } }
        if !mines.empty? && (!@round.rail_cars.include?('SNW') || other_snw_train?(route))
          raise GameError, 'Cannot visit mine'
        end
        raise GameError, 'Cannot visit multiple mines' if mines.size > 1
      end

      # Modify revenue of offboard if RABA is used
      def revenue_for(route, stops)
        raba_add = if raba_train?(route) && !other_raba_train?(route)
                     raba_delta(@phase)
                   else
                     0
                   end

        corp_tokens = stops.select(&:city?).sum { |c| c.tokens.count { |t| t&.corporation&.corporation? } }

        stops.select { |s| s.visit_cost.positive? }.sum { |stop| stop.route_revenue(route.phase, route.train) } +
          raba_add + corp_tokens * CORP_TOKEN_REVENUE
      end

      def raba_delta(phase)
        RABA_BONUS[phase.current[:tiles].size - 1]
      end

      # Modify revenue string if RABA is used
      def revenue_str(route)
        raba_add = if raba_train?(route) && !other_raba_train?(route)
                     ' (RABA)'
                   else
                     ''
                   end
        route.hexes.map(&:name).join('-') + raba_add
      end

      def subsidy_for(route, _stops)
        snw_train?(route) ? snw_delta : 0
      end

      def snw_delta
        SNW_BONUS[phase.current[:tiles].size - 1]
      end

      def routes_subsidy(routes)
        routes.sum(&:subsidy)
      end

      def status_str(entity)
        if entity.minor? && @terrain_tokens[entity.name]&.positive?
          "Terrain Tokens: #{@terrain_tokens[entity.name]}"
        elsif entity.corporation?
          CORPORATE_POWERS[entity.name]
        end
      end

      def player_card_minors(player)
        minors.select { |m| m.owner == player }
      end

      def player_sort(entities)
        minors, majors = entities.partition(&:minor?)
        (minors.sort_by { |m| m.name.to_i } + majors.sort_by(&:name)).group_by(&:owner)
      end
    end
  end
end
