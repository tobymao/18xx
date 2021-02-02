# frozen_string_literal: true

require_relative 'base'

module Engine
  module Game
    class G18Mag < Base
      attr_reader :tile_groups, :unused_tiles, :sik, :skev, :ldsteg, :mavag, :raba, :snw, :gc, :terrain_tokens

      CURRENCY_FORMAT_STR = '%d Ft'
      BANK_CASH = 100_000
      CERT_LIMIT = {
        2 => 10,
        3 => 18,
        4 => 14,
        5 => 11,
        6 => 9,
      }.freeze
      STARTING_CASH = {
        2 => 0,
        3 => 0,
        4 => 0,
        5 => 0,
        6 => 0,
      }.freeze
      CAPITALIZATION = :full
      MUST_SELL_IN_BLOCKS = false
      LAYOUT = :pointy
      COMPANIES = [].freeze

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

      CORPORATE_POWERS_2P = {
        'SIK' => 'Earns for each terrain symbol',
        'SKEV' => 'Earns for tokens and 2nd tile lay',
        'LdStEG' => 'Sells all trains',
        'RABA' => 'Sells offboard bonus / +train conversion',
      }.freeze

      MINORS_2P = %w[
        1
        2
        3
        4
        6
        7
        11
        mine
      ].freeze

      CORPORATIONS_2P = %w[
        SIK
        SKEV
        LdStEG
        RABA
      ].freeze

      def multiplayer?
        @multiplayer ||= @players.size >= 3
      end

      def location_name(coord)
        @location_names ||= game_location_names

        @location_names[coord]
      end

      def setup
        @sik = @corporations.find { |c| c.name == 'SIK' }
        @skev = @corporations.find { |c| c.name == 'SKEV' }
        @ldsteg = @corporations.find { |c| c.name == 'LdStEG' }
        @raba = @corporations.find { |c| c.name == 'RABA' }
        if multiplayer?
          @mavag = @corporations.find { |c| c.name == 'MAVAG' }
          @snw = @corporations.find { |c| c.name == 'SNW' }
          @gc = @corporations.find { |c| c.name == 'G&C' }
        end

        @terrain_tokens = TERRAIN_TOKENS.dup

        @tile_groups = init_tile_groups
        update_opposites
        @unused_tiles = []

        # start with first minor tokens placed (as opposed to just reserved)
        @mine = @minors.find { |m| m.name == 'mine' }
        @minors.delete(@mine)

        # Place all mine tokens and mark them as non-blocking
        # route restrictions will be handled elsewhere
        if multiplayer?
          @mine.coordinates.each do |coord|
            hex = hex_by_id(coord)
            hex.tile.cities[0].place_token(@mine, @mine.next_token)
          end
          @mine.tokens.each { |t| t.type = :neutral }
        end

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

        @trains_left = multiplayer? ? %w[3 4 6] : %w[3 4]
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
        groups = [
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
        ]
        # do it this way to avoid reordering
        unless multiplayer?
          groups.delete(%w[236])
          groups.delete(%w[237 238])
          groups.delete(%w[L34])
        end
        groups_3p = [
          %w[L38],
          %w[455],
          %w[X9],
          %w[L36],
          %w[L37],
        ]
        groups.concat(groups_3p) if multiplayer?
        groups
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

      def all_corporations
        minors + corporations
      end

      def new_auction_round
        Round::Draft.new(self, [Step::G18Mag::SimpleDraft], rotating_order: multiplayer?,
                                                            snake_order: !multiplayer?)
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
          if multiplayer?
            corp = %w[2 4].include?(train.name) ? @ldsteg : @mavag
            operator.spend(cost / 2, @bank)
            operator.spend(cost / 2, corp)
            @log << "#{corp.name} earns #{format_currency(cost / 2)}"
          else
            operator.spend(3 * cost / 4, @bank)
            operator.spend(cost / 4, @ldsteg)
            @log << "#{@ldsteg.name} earns #{format_currency(cost / 4)}"
          end
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
        if multiplayer?
          @round.rail_cars.include?('G&C') && route.visited_stops.sum(&:visit_cost) > route.train.distance
        else
          @round.rail_cars.include?('RABA') && route.visited_stops.sum(&:visit_cost) > route.train.distance
        end
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
        if multiplayer?
          @round.rail_cars.include?('RABA') && route.visited_stops.any?(&:offboard?)
        else
          @round.rail_cars.include?('RABA') && route.visited_stops.any?(&:offboard?) &&
            route.routes.none? { |r| gc_train?(r) }
        end
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
                         nodes: %w[city offboard town],
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

        grouped.sort_by { |t, _| type_info[t].size }.each do |type, group|
          num = group.sum(&:visit_cost)

          type_info[type].each do |info|
            next unless info[:visit].positive?

            if num <= info[:visit]
              info[:visit] -= num
              num = 0
            else
              num -= info[:visit]
              info[:visit] = 0
            end
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
        elsif entity.corporation? && multiplayer?
          CORPORATE_POWERS[entity.name]
        elsif entity.corporation?
          CORPORATE_POWERS_2P[entity.name]
        end
      end

      def player_card_minors(player)
        minors.select { |m| m.owner == player }
      end

      def player_sort(entities)
        minors, majors = entities.partition(&:minor?)
        (minors.sort_by { |m| m.name.to_i } + majors.sort_by(&:name)).group_by(&:owner)
      end

      def game_location_names
        if multiplayer?
          {
            'B17' => 'Kassa',
            'B23' => 'Moszkva',
            'C6' => 'Bécs',
            'C8' => 'Pozsony',
            'C12' => 'Selmecbánya',
            'C16' => 'Miskolc',
            'D7' => 'Sopron',
            'D9' => 'Györ',
            'D19' => 'Szatmárnémeti & Nyíregyháza',
            'E10' => 'Székesfehérvár',
            'E12' => 'Buda & Pest',
            'E14' => 'Szolnok',
            'E18' => 'Debrecen',
            'F13' => 'Kecskemét',
            'F19' => 'Nagyvárad',
            'F23' => 'Kolozsvár',
            'G10' => 'Pécs & Mohács',
            'G14' => 'Szeged & Szabadka',
            'G16' => 'Arad',
            'H1' => 'Trieszt',
            'H5' => 'Zágráb',
            'H17' => 'Temesvár',
            'H23' => 'Nagyzeben',
            'H27' => 'Brassó',
            'I2' => 'Fiume',
            'I14' => 'Újvidék & Pétrovárad',
            'I26' => 'Isztambul',
            'J15' => 'Belgrád',
          }
        else
          {
            'A2' => 'Bécs',
            'A12' => 'Miskolc',
            'A18' => 'Galicia',
            'B3' => 'Sopron',
            'B5' => 'Györ',
            'B15' => 'Nyíregyháza',
            'C6' => 'Székesfehérvár',
            'C8' => 'Buda & Pest',
            'C10' => 'Szolnok',
            'C14' => 'Debrecen',
            'D9' => 'Kecskemét',
            'E6' => 'Pécs & Mohács',
            'E10' => 'Szeged',
            'F3' => 'Trieszt',
            'F11' => 'Belgrád',
          }
        end
      end

      def game_tiles
        tiles = {
          '6' => 7,
          '7' => 4,
          '8' => 21,
          '9' => 21,
          '3' => 5,
          '58' => 13,
          '4' => 13,
          '5' => 10,
          '57' => 10,
          'L32' => {
            'count' => 4,
            'color' => 'yellow',
            'code' => 'city=revenue:30,loc:2;city=revenue:0,loc:0;path=a:2,b:_0;label=OO;'\
              'upgrade=cost:20,terrain:water',
          },
          'L33' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_1;path=a:0,b:_1;'\
              'label=B;upgrade=cost:20,terrain:water',
          },
          '16' => 2,
          '19' => 2,
          '20' => 1,
          '23' => 6,
          '24' => 6,
          '25' => 2,
          '26' => 4,
          '27' => 4,
          '28' => 2,
          '29' => 2,
          '30' => 2,
          '31' => 2,
          '209' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
              'path=a:5,b:_0;label=B',
          },
          '204' => 3,
          '88' => 6,
          '87' => 6,
          '619' => 5,
          '14' => 8,
          '15' => 8,
          '8860' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_1;path=a:5,b:_1;'\
              'label=OO',
          },
          '8859' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:4,b:_0;path=a:0,b:_1;path=a:3,b:_1;'\
              'label=OO',
          },
          '8858' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:2,b:_0;path=a:1,b:_1;path=a:3,b:_1;'\
              'label=OO',
          },
          '8863' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,loc:1.5;city=revenue:40;path=a:1,b:_0;path=a:2,b:_0;path=a:0,b:_1;'\
              'path=a:3,b:_1;label=OO',
          },
          '8864' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40,loc:3.5;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_1;'\
              'path=a:4,b:_1;label=OO',
          },
          '8865' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40,loc:4.5;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_1;'\
              'path=a:5,b:_1;label=OO',
          },
          '39' => 2,
          '40' => 2,
          '41' => 2,
          '42' => 2,
          '43' => 2,
          '70' => 2,
          '44' => 2,
          '47' => 2,
          '45' => 2,
          '46' => 2,
          'G17' => {
            'count' => 4,
            'color' => 'brown',
            'code' => 'town=revenue:20;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          '611' => 8,
          'L17' => {
            'count' => multiplayer? ? 3 : 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
              'path=a:5,b:_0;label=OO',
          },
          'L35' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
              'path=a:4,b:_0;path=a:5,b:_0;label=B',
          },
        }
        tiles_3p = {
          '236' => 1,
          '237' => 2,
          '238' => 2,
          'L34' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=K',
          },
          'L38' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'town=revenue:30;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
            'path=a:5,b:_0',
          },
          '455' => 2,
          'X9' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;'\
            'path=a:5,b:_0;label=OO',
          },
          'L36' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:2;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=K',
          },
          'L37' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
            'path=a:4,b:_0;path=a:5,b:_0;label=B',
          },
        }
        tiles.merge!(tiles_3p) if multiplayer?
        tiles
      end

      def game_market
        if multiplayer?
          [
            %w[
            55
            60p
            65p
            70p
            75p
            80p
            85
            90
            95
            100
            110
            120
            130
            140
            152
            164
            178
            192
            208
            224
            242
            260
            280
            300
            320
            340
            360
            380
            400
            ],
          ]
        else
          [
            %w[
            55
            60p
            65p
            70p
            75p
            80p
            85
            90
            95
            100
            110
            120
            130
            140
            152
            164
            178
            192
            208
            224
            242
            260
            280
            300
            ],
          ]
        end
      end

      def game_minors
        minor_list = [
          {
            sym: '1',
            name: 'Magyar Északi Vasút',
            logo: '18_mag/1',
            tokens: [
              0,
              40,
              80,
            ],
            coordinates: multiplayer? ? 'E12' : 'C8',
            city: 1,
            color: 'black',
          },
          {
            sym: '2',
            name: 'Magyar Keleti Vasút',
            logo: '18_mag/2',
            tokens: [
              0,
              40,
              80,
            ],
            coordinates: multiplayer? ? 'D19' : 'B15',
            city: 0,
            color: 'black',
          },
          {
            sym: '3',
            name: 'Magyar Nyugoti Vasút',
            logo: '18_mag/3',
            tokens: [
              0,
              40,
              80,
            ],
            coordinates: multiplayer? ? 'E10' : 'C6',
            color: 'black',
          },
          {
            sym: '4',
            name: 'TiszaVidéki Vasút',
            logo: '18_mag/4',
            tokens: [
              0,
              40,
              80,
            ],
            coordinates: multiplayer? ? 'G14' : 'E10',
            city: multiplayer? ? 1 : 0,
            color: 'black',
          },
          {
            sym: '5',
            name: 'Első Erdélyi Vasút',
            logo: '18_mag/5',
            tokens: [
              0,
              40,
              80,
            ],
            coordinates: 'H27',
            color: 'black',
          },
          {
            sym: '6',
            name: 'Kassa-Oderbergi Vasút',
            logo: '18_mag/6',
            tokens: [
              0,
              40,
              80,
            ],
            coordinates: multiplayer? ? 'B17' : 'A12',
            color: 'black',
          },
          {
            sym: '7',
            name: 'Mohács-Pécsi Vasút',
            logo: '18_mag/7',
            tokens: [
              0,
              40,
              80,
            ],
            coordinates: multiplayer? ? 'G10' : 'E6',
            city: 1,
            color: 'black',
          },
          {
            sym: '8',
            name: 'Hrvatske Željeznice',
            logo: '18_mag/8',
            tokens: [
              0,
              40,
              80,
            ],
            coordinates: 'H5',
            color: 'black',
          },
          {
            sym: '9',
            name: 'Szabadka-Újvidék Vasút',
            logo: '18_mag/9',
            tokens: [
              0,
              40,
              80,
            ],
            coordinates: 'I14',
            city: 1,
            color: 'black',
          },
          {
            sym: '10',
            name: 'Arad-Temesvári Vasúttársaság',
            logo: '18_mag/10',
            tokens: [
              0,
              40,
              80,
            ],
            coordinates: 'H17',
            city: 0,
            color: 'black',
          },
          {
            sym: '11',
            name: 'Győr-Sopron-Ebenfurti Vasút',
            logo: '18_mag/11',
            tokens: [
              0,
              40,
              80,
            ],
            coordinates: multiplayer? ? 'D7' : 'B3',
            color: 'black',
          },
          {
            sym: '12',
            name: 'Segesvár–Szentágotai Vasút',
            logo: '18_mag/12',
            tokens: [
              0,
              40,
              80,
            ],
            coordinates: 'H23',
            color: 'black',
          },
          {
            sym: '13',
            name: 'Déli Vasút',
            logo: '18_mag/13',
            tokens: [
              0,
              40,
              80,
            ],
            coordinates: 'I2',
            color: 'black',
          },
          {
            sym: 'mine',
            name: 'mine',
            logo: '18_mag/mine',
            tokens: [
              0,
              0,
              0,
              0,
            ],
            coordinates: %w[
              A10
              A18
              E26
              I20
            ],
            color: 'white',
            abilities: [
              {
                type: 'blocks_partition',
                partition_type: 'water',
              },
            ],
          },
        ]
        minor_list.select! { |m| MINORS_2P.include?(m[:sym]) } unless multiplayer?
        minor_list
      end

      def game_corporations
        corps = [
          {
            sym: 'RABA',
            name: 'Magyar Waggon-és Gépgyár Rt.',
            logo: '18_mag/RABA',
            float_percent: 0,
            max_ownership_percent: 60,
            tokens: [
              40,
              80,
            ],
            color: 'red',
          },
          {
            sym: 'G&C',
            name: 'Ganz & Cie',
            logo: '18_mag/GC',
            float_percent: 0,
            max_ownership_percent: 60,
            tokens: [
              40,
              80,
            ],
            color: 'lightblue',
            text_color: 'black',
          },
          {
            sym: 'SNW',
            name: 'Schlick-Nicholson Gép-, Waggon és Hajógyár Rt.',
            logo: '18_mag/SNW',
            float_percent: 0,
            max_ownership_percent: 60,
            tokens: [
              40,
              80,
            ],
            color: 'dimgray',
          },
          {
            sym: 'SIK',
            name: 'Gróf Széchenyi István Konsorcium',
            logo: '18_mag/SIK',
            float_percent: 0,
            max_ownership_percent: 60,
            tokens: [
              40,
              80,
            ],
            color: 'green',
          },
          {
            sym: 'SKEV',
            name: 'Széchy Károly Építőipari Vállalat',
            logo: '18_mag/SKEV',
            float_percent: 0,
            max_ownership_percent: 60,
            tokens: [
              40,
              80,
            ],
            color: 'yellow',
            text_color: 'black',
          },
          {
            sym: 'LdStEG',
            name: 'Lokomotivfabrik der Staatseisenbahn-Gesellschaft',
            logo: '18_mag/LdStEG',
            float_percent: 0,
            max_ownership_percent: 60,
            tokens: [
              40,
              80,
            ],
            color: 'orange',
          },
          {
            sym: 'MAVAG',
            name: 'Magyar Királyi Államvasutak Gépgyára',
            logo: '18_mag/MAVAG',
            float_percent: 0,
            max_ownership_percent: 60,
            tokens: [
              40,
              80,
            ],
            color: 'purple',
          },
        ]
        corps.select! { |c| CORPORATIONS_2P.include?(c[:sym]) } unless multiplayer?
        corps
      end

      def game_trains
        train_list = [
          {
            name: '2',
            distance: 2,
            price: 80,
            num: 25,
          },
          {
            name: '3',
            distance: 3,
            price: 120,
            num: 25,
            events: [
              { 'type' => 'first_three' },
            ],
          },
          {
            name: '4',
            distance: 4,
            price: 200,
            num: 25,
            events: [
              { 'type' => 'first_four' },
            ],
          },
          {
            name: '6',
            distance: 6,
            price: 320,
            num: 25,
            events: [
              { 'type' => 'first_six' },
            ],
          },
        ]
        train_list.reject! { |t| t[:name] == '6' } unless multiplayer?
        train_list
      end

      def game_hexes
        hexes_multiplayer = {
          white: {
            [
              'E12',
            ] => 'city=revenue:20,loc:0.5;city=revenue:20,loc:3.5;path=a:0,b:_0;path=a:3,b:_1;label=B',
            %w[
              D19
              G10
              G14
              I14
            ] => 'city=revenue:0;city=revenue:0;label=OO',
            %w[
              C12
              C16
              E10
              E14
              E18
              F13
              F19
              G16
              H5
              H17
            ] => 'city=revenue:0',
            [
              'I2',
            ] => 'city=revenue:0;label=K',
            %w[
              B17
              F23
            ] => 'city=revenue:0;upgrade=cost:10,terrain:mountain',
            [
              'D9',
            ] => 'city=revenue:0;upgrade=cost:20,terrain:water',
            [
              'C8',
            ] => 'city=revenue:0;border=edge:0,type:impassable',
            [
              'D7',
            ] => 'city=revenue:0;border=edge:3,type:impassable',
            %w[
              H23
              H27
            ] => 'city=revenue:0;upgrade=cost:10,terrain:mountain;label=K',
            %w[
              B15
              D13
              E6
              F17
              G18
              G22
              H7
              H13
            ] => 'town=revenue:0',
            %w[
              D17
              G6
              J19
            ] => 'town=revenue:0;upgrade=cost:10,terrain:water',
            %w[
              B9
              G24
            ] => 'town=revenue:0;upgrade=cost:10,terrain:mountain',
            [
              'C20',
            ] => 'town=revenue:0;upgrade=cost:20,terrain:water|mountain',
            %w[
              E22
              E24
              F25
              G26
            ] => 'town=revenue:0;upgrade=cost:20,terrain:mountain',
            [
              'H11',
            ] => 'town=revenue:0;upgrade=cost:30,terrain:water',
            %w[
              B11
              I4
              I18
              J3
            ] => 'upgrade=cost:10,terrain:mountain',
            %w[
              C18
              F15
              G8
              H9
              H15
            ] => 'upgrade=cost:10,terrain:water',
            %w[
              D11
              F11
              G12
              I12
            ] => 'upgrade=cost:20,terrain:water',
            [
              'D21',
            ] => 'upgrade=cost:20,terrain:water|mountain',
            %w[
              B13
              C14
              C22
              F21
              G20
              H3
              H19
              H21
              H25
            ] => 'upgrade=cost:20,terrain:mountain',
            [
              'D23',
            ] => 'upgrade=cost:30,terrain:water|mountain',
            %w[
              A12
              A14
              A16
              B19
              B21
              C24
              D25
              F27
              G28
            ] => 'upgrade=cost:30,terrain:mountain',
            [
              'I6',
            ] => 'border=edge:0,type:impassable;upgrade=cost:10,terrain:mountain',
            [
              'J5',
            ] => 'border=edge:3,type:impassable;upgrade=cost:10,terrain:mountain',
            [
              'F5',
            ] => 'border=edge:0,type:impassable',
            [
              'G4',
            ] => 'border=edge:3,type:impassable',
            [
              'F9',
            ] => 'partition=a:1,b:4,type:water',
            %w[
              C10
              D15
              E8
              E16
              E20
              F7
              I8
              I10
              I16
            ] => '',
          },
          red: {
            [
              'B23',
            ] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_60;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0',
            [
              'C6',
            ] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_70;path=a:4,b:_0;path=a:5,b:_0',
            [
              'H1',
            ] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_50;path=a:4,b:_0;path=a:5,b:_0',
            [
              'I26',
            ] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_50;path=a:2,b:_0;path=a:3,b:_0',
            [
              'J15',
            ] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_40;path=a:2,b:_0;path=a:3,b:_0',
          },
          gray: {
            [
              'A10',
            ] => 'city=revenue:yellow_30|brown_50,visit_cost:0;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            [
              'A18',
            ] => 'city=revenue:yellow_30|brown_50,visit_cost:0;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0',
            [
              'E26',
            ] => 'city=revenue:yellow_30|brown_50,visit_cost:0;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0',
            [
              'I20',
            ] => 'city=revenue:yellow_30|brown_50,visit_cost:0;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          },
        }
        hexes_2player = {
          white: {
            %w[
              C8
            ] => 'city=revenue:20,loc:0.5;city=revenue:20,loc:3.5;path=a:0,b:_0;path=a:3,b:_1;label=B',
            %w[
              E6
            ] => 'city=revenue:0;city=revenue:0;label=OO',
            %w[
              A12
              B3
              B15
              C6
              C14
              D9
              E10
            ] => 'city=revenue:0',
            %w[
              C10
            ] => 'city=revenue:0;upgrade=cost:10,terrain:water',
            %w[
              B5
            ] => 'city=revenue:0;upgrade=cost:20,terrain:water',
            %w[
              B9
              C2
              D13
              F9
            ] => 'town=revenue:0',
            %w[
              B13
              E2
            ] => 'town=revenue:0;upgrade=cost:10,terrain:water',
            %w[
              A16
            ] => 'town=revenue:0;upgrade=cost:20,terrain:water|mountain',
            %w[
              A14
              D11
              E4
              F5
            ] => 'upgrade=cost:10,terrain:water',
            %w[
              B7
              D7
              E8
            ] => 'upgrade=cost:20,terrain:water',
            %w[
              B17
            ] => 'upgrade=cost:20,terrain:water|mountain',
            %w[
              A10
            ] => 'upgrade=cost:20,terrain:mountain',
            %w[
              F7
            ] => 'upgrade=cost:30,terrain:water',
            %w[
              D5
            ] => 'partition=a:1,b:4,type:water',
            %w[
              B11
              C4
              C12
              D1
              D3
              E12
            ] => '',
          },
          red: {
            %w[
              A2
            ] => 'offboard=revenue:yellow_30|green_40|brown_50;path=a:4,b:_0;path=a:5,b:_0',
            %w[
              A18
            ] => 'offboard=revenue:yellow_30|green_40|brown_50;path=a:0,b:_0;path=a:1,b:_0',
            %w[
              F3
            ] => 'offboard=revenue:yellow_20|green_30|brown_40;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            %w[
              F11
            ] => 'offboard=revenue:yellow_10|green_20|brown_30;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          },
          gray: {
            %w[
              A4
            ] => 'town=revenue:10;path=a:1,b:_0;path=a:5,b:_0',
            %w[
              a11
            ] => 'town=revenue:10;path=a:0,b:_0;path=a:5,b:_0',
          },
        }
        multiplayer? ? hexes_multiplayer : hexes_2player
      end

      def game_phases
        if multiplayer?
          [
            {
              name: 'Yellow',
              train_limit: 2,
              tiles: [
                'yellow',
              ],
              operating_rounds: 1,
            },
            {
              name: 'Green',
              on: %w[3 4 6],
              train_limit: 2,
              tiles: %i[
                yellow
                green
              ],
              operating_rounds: 2,
            },
            {
              name: 'Brown',
              train_limit: 2,
              tiles: %i[
                yellow
                green
                brown
              ],
              operating_rounds: 2,
            },
            {
              name: 'Gray',
              train_limit: 2,
              tiles: %i[
                yellow
                green
                brown
                gray
              ],
              operating_rounds: 3,
              status: [
                'end_game_triggered',
              ],
            },
          ]
        else
          [
            {
              name: 'Yellow',
              train_limit: 2,
              tiles: [
                'yellow',
              ],
              operating_rounds: 1,
            },
            {
              name: 'Green',
              on: %w[3 4],
              train_limit: 2,
              tiles: %i[
                yellow
                green
              ],
              operating_rounds: 2,
            },
            {
              name: 'Brown',
              train_limit: 2,
              tiles: %i[
                yellow
                green
                brown
              ],
              operating_rounds: 3,
              status: [
                'end_game_triggered',
              ],
            },
          ]
        end
      end
    end
  end
end
