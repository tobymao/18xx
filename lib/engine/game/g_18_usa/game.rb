# frozen_string_literal: true

require_relative '../g_1817/game'
require_relative 'meta'
require_relative 'map'
require_relative 'entities'

module Engine
  module Game
    module G18USA
      class Game < G1817::Game
        include_meta(G18USA::Meta)
        include G18USA::Entities
        include G18USA::Map

        attr_reader :jump_graph, :subsidies_by_hex, :recently_floated, :plain_yellow_city_tiles, :plain_green_city_tiles,
                    :mexico_hexes

        CURRENCY_FORMAT_STR = '$%d'

        BANK_CASH = 99_999

        CERT_LIMIT = { 2 => 32, 3 => 21, 4 => 16, 5 => 16, 6 => 13, 7 => 11 }.freeze

        STARTING_CASH = { 2 => 630, 3 => 420, 4 => 315, 5 => 300, 6 => 250, 7 => 225 }.freeze

        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = false

        MARKET = [
          %w[0l 0a 0a 0a 42 44 46 48 50p 53s 56p 59p 62p 66p 70p 74s 78p 82p 86p 90p 95p 100p 105p 110p 115p 120s 127p 135p 142p
             150p 157p 165p 172p 180p 190p 200p 210 220 230 240 250 260 270 285 300 315 330 345 360 375 390 405 420 440 460 480
             500 520 540 560 580 600 625 650 675 700 725 750 775 800],
           ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
            corporation_sizes: [2],
          },
          {
            name: '2+',
            on: '2+',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
            corporation_sizes: [2],
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            corporation_sizes: [2, 5],
          },
          {
            name: '3+',
            on: '3+',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            corporation_sizes: [2, 5],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            corporation_sizes: [5],
          },
          {
            name: '4+',
            on: '4+',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            corporation_sizes: [5],
          },
          {
            name: '5',
            on: '5',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
            corporation_sizes: [5, 10],
            events: [{ 'type' => 'increased_oil' }],
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
            corporation_sizes: [10],
          },
          {
            name: '7',
            on: '7',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
            corporation_sizes: [10],
          },
          {
            name: '8',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            status: %w[no_new_shorts],
            operating_rounds: 2,
            corporation_sizes: [10],
          },
        ].freeze

        # Trying to do {static literal}.merge(super.static_literal) so that the capitalization shows up first.
        EVENTS_TEXT = {
          'upgrade_oil' => [
            'Oil Upgraded',
            'Oil worth $20 for the remainder of the game',
          ],
        }.merge(Base::EVENTS_TEXT)

        TRAINS = [{ name: '2', distance: 2, price: 100, rusts_on: '4', num: 40 },
                  { name: '2+', distance: 2, price: 100, obsolete_on: '4', num: 5 },
                  { name: '3', distance: 3, price: 250, rusts_on: '6', num: 12 },
                  { name: '3+', distance: 3, price: 250, obsolete_on: '6', num: 2 },
                  { name: '4', distance: 4, price: 400, rusts_on: '8', num: 8 },
                  { name: '4+', distance: 4, price: 400, obsolete_on: '8', num: 1 },
                  { name: '5', distance: 5, price: 600, num: 6 },
                  { name: '6', distance: 6, price: 750, num: 5 },
                  { name: '7', distance: 7, price: 900, num: 3 },
                  {
                    name: '8',
                    distance: 8,
                    price: 1100,
                    num: 40,
                    events: [{ 'type' => 'signal_end_game' }],
                  },
                  { name: 'P', distance: 0, price: 200, available_on: '5', num: 20 }].freeze

        # Does not include guaranteed metropolis New York City
        POTENTIAL_METROPOLIS_HEX_IDS = %w[D20 E11 G3 H14 H22 I19].freeze

        def potential_metropolitan_hexes
          @potential_metropolitan_hexes ||= POTENTIAL_METROPOLIS_HEX_IDS.map { |hex_id| @hexes.find { |h| h.id == hex_id } }
        end

        EXTENDED_MAX_LOAN = 60
        EXTENDED_LOANS_PER_INCREMENT = 6

        def bridge_city_hex?(hex_id)
          BRIDGE_CITY_HEXES.include?(hex_id)
        end

        ASSIGNMENT_TOKENS = {
          'bridge' => '/icons/1817/bridge_token.svg',
        }.freeze

        SEED_MONEY = 200

        def event_upgrade_oil!
          @log << "-- Event: #{EVENTS_TEXT['upgrade_oil'][1]} --"
          @oil_value = 20
        end

        def active_metropolitan_hexes
          @active_metropolitan_hexes ||= [@hexes.find { |h| h.id == 'D28' }]
        end

        def metro_new_orleans
          @metro_new_orleans ||= false
        end

        def metro_denver
          @metro_denver ||= false
        end

        def loans_per_increment(increment)
          return 4 if @players.size >= 5 && increment == min_loan
          return 6 if @players.size >= 5

          super
        end

        def max_loan
          return 60 if @players.size >= 5

          super
        end

        def tile_by_name(name)
          @all_tiles.find { |t| t.name == name }
        end

        def setup
          @rhq_tile = tile_by_name('X23')
          @company_town_tiles ||= COMPANY_TOWN_TILES.map { |id| tile_by_name(id) }
          @yellow_plain_tiles ||= @all_tiles.select { |t| YELLOW_PLAIN_TRACK_TILES.include?(t.name) }
          @green_plain_tiles ||= @all_tiles.select { |t| GREEN_PLAIN_TRACK_TILES.include?(t.name) }
          @brown_plain_tiles ||= @all_tiles.select { |t| BROWN_PLAIN_TRACK_TILES.include?(t.name) }
          @gray_plain_tiles ||= @all_tiles.select { |t| GRAY_PLAIN_TRACK_TILES.include?(t.name) }
          @plain_yellow_city_tiles ||= @all_tiles.select { |t| PLAIN_YELLOW_CITY_TILES.include?(t.name) }
          @plain_green_city_tiles ||= @all_tiles.select { |t| PLAIN_GREEN_CITY_TILES.include?(t.name) }
          @plain_brown_city_tiles ||= @all_tiles.select { |t| PLAIN_BROWN_CITY_TILES.include?(t.name) }

          @brown_ny_tile ||= tile_by_name('X16')
          @brown_dfw_tile ||= tile_by_name('X14')
          @brown_la_tile ||= tile_by_name('X15')
          @brown_cl_tile ||= tile_by_name('X13')
          @brown_b_tile ||= tile_by_name('593')

          @mexico_hexes = MEXICO_HEXES.map { |h| hex_by_id(h) }
          @jump_graph = Graph.new(self, no_blocking: true)

          @oil_value = 10

          # Place neutral tokens in the off board cities
          neutral = Corporation.new(
            sym: 'N',
            name: 'Neutral',
            logo: 'minus_ten',
            simple_logo: 'minus_ten',
            tokens: [0, 0, 0],
          )
          neutral.owner = @bank
          @recently_floated = []

          metro_hexes = METROPOLITAN_HEXES.sort_by { rand }.take(3)
          metro_hexes.each { |metro_hex| convert_potential_metro(hex_by_id(metro_hex)) }

          setup_train_roster
          randomize_subsidies
        end

        def setup_train_roster
          return if @players.size >= 5

          to_remove = %w[2+ 4 5 6]
          @depot.trains.dup.reverse_each do |train|
            next unless train.name == to_remove.last

            @depot.forget_train(train)
            to_remove.pop
          end
        end

        # Convert a potential metro hex to a metro hex
        def convert_potential_metro(hex)
          active_metropolitan_hexes << hex
          case hex.id
          when 'H14'
            hex.lay(@tiles.find { |t| t.name == 'X03' })
          when 'E11'
            hex.lay(@tiles.find { |t| t.name == 'X04' })
            @metro_denver = true
          when 'G3'
            hex.lay(@tiles.find { |t| t.name == 'X05' }.rotate!(3))
          when 'D20'
            hex.lay(@tiles.find { |t| t.name == 'X02' }.rotate!(1))
          when 'I19'
            hex.lay(@tiles.find { |t| t.name == 'X06' })
            @metro_new_orleans = true
          when 'H22'
            hex.lay(@tiles.find { |t| t.name == 'X01' })
          end
        end

        def randomize_subsidies
          randomized_subsidies = SUBSIDIES.sort_by { rand }.take(SUBSIDIZED_HEXES.size)
          @subsidies_by_hex = {}
          SUBSIDIZED_HEXES.zip(randomized_subsidies).each do |hex_id, subsidy|
            hex = hex_by_id(hex_id)
            @subsidies_by_hex[hex_id] = subsidy
            hex.tile.icons.reject! { |icon| icon.name == 'coins' }
            hex.tile.icons << Engine::Part::Icon.new("18_usa/#{subsidy['icon']}")
          end
        end

        def home_hex_for(corporation)
          corporation.tokens.first.hex
        end

        #
        # In 18USA you need to use the maximum number of exits for a given tile, but unlike 1817 there are more types of tiles
        # that this applies to:
        # Gray plain track
        # Brown cities
        # Gray plain track with labels
        # and at a given time it's possible to have multiple legal color choices to lay
        # so we need to be able to filter within each group
        def filter_by_max_edges(tiles)
          tiles.group_by { |t| [t.color, t.cities&.size, t.label&.to_s] }.flat_map do |grouped_tiles|
            # flat_map on the hash flattens the hash into [[key, value], [key value], [key, value], ...]
            grouped_tiles = grouped_tiles.last
            max_edges = grouped_tiles.map { |t| t.edges.size }.max
            grouped_tiles.select { |t| t.edges.size == max_edges }
          end
        end

        TRACK_ENGINEER_TILE_LAYS = [ # Three lays with one being an upgrade, second tile costs 20, third tile free
          { lay: true, upgrade: true },
          { lay: true, upgrade: :not_if_upgraded, cost: 20, cannot_reuse_same_hex: true },
          { lay: true, upgrade: :not_if_upgraded, cost: 0, cannot_reuse_same_hex: true },
        ].freeze

        def tile_lays(entity)
          return TRACK_ENGINEER_TILE_LAYS if entity.companies.include?(company_by_id('P7'))

          super
        end

        def resource_tile?(tile)
          %w[coal ore oil].any? { |resource| tile.name.include?(resource) }
        end

        def company_can_lay_resource?(company, from, to)
          return false unless company
          return false unless (ability = abilities(company, 'tile_lay'))
          if company.id == 'P17'
            return company.owner.companies.reject { |c| c == company }.any? { |c| company_can_lay_resource?(c, from, to) }
          end

          ability.hexes.include?(from.hex.id) && ability.tiles.include?(to.name)
        end

        #
        # Aggressively allows upgrading to brown tiles; the rules depend on who is laying and the current phase
        # so the track step will need to clamp down on this
        #
        # Get the currently possible upgrades for a tile
        # from: Tile - Tile to upgrade from
        # to: Tile - Tile to upgrade to
        # special - ???
        def upgrades_to?(from, to, _special = false, selected_company: nil)
          # Resource tiles
          return @phase.tiles.include?(:green) && ore_upgrade?(from, to) if from.name.include?('ore')
          if to.color == :yellow && resource_tile?(to)
            return from.color == :white && company_can_lay_resource?(selected_company, from, to)
          end

          # Brown home city upgrade only on first operation
          laying_entity = @round.current_entity
          if !laying_entity.operated? &&
             @phase.tiles.include?(:brown) &&
             from.hex == home_hex_for(laying_entity) &&
             to.color == :brown &&
             Engine::Tile::COLORS.index(to.color) > Engine::Tile::COLORS.index(from.color)
            if active_metroplitan_hexes.include?(from.hex)
              return to.name == 'X14' if from.hex.id == 'H14'
              return to.name == 'X15' if from.hex.id == 'G3'
              return to.name == 'X16' if from.hex.id == 'D28'

              return to.name == '593'
            end

            return to.name == 'X13' if from.hex.id == 'D24'

            return %w[63 448 611].include?(to.name)
          end

          if @phase.tiles.include?(:brown) && from.color == :white && !from.cities.empty? && !from.label
            # Unplaced cities must go to green
            return PLAIN_GREEN_CITY_TILES.include?(to.name)
          end

          super
        end

        def ore_upgrade?(from, to)
          [%w[7ore10 7ore20], %w[8ore10 8ore20], %w[9ore10 9ore20]].any? { |upg| upg == [from.name, to.name] }
        end

        def upgrades_to_correct_color?(from, to)
          if @phase.tiles.include?(:brown) && from.cities.empty?
            return Engine::Tile::COLORS.index(to.color) > Engine::Tile::COLORS.index(from.color)
          end

          super
        end

        def tile_color_valid_for_phase?(tile, phase_color_cache: nil)
          colors = phase_color_cache || @phase.tiles
          colors.include?(tile.color) ||
            (tile.color == :brown && colors.include?(:green)) || (tile.color == :gray && colors.include?(:brown))
        end

        # Get all possible upgrades for a tile
        # tile: The tile to be upgraded
        # tile_manifest: true/false Is this being called from the tile manifest screen
        #
        def all_potential_upgrades(tile, tile_manifest: false, selected_company: nil)
          # This method does not factor in illegal tile lays. Do not show those as a 'Later Phase' tile.
          return [] if %w[P9 S8].include?(selected_company&.id)

          upgrades = super
          return filter_by_max_edges(upgrades) unless tile_manifest

          upgrades << @brown_cl_tile if tile.name == '15' # only K green city that fits clevelands hex
          upgrades << @rhq_tile if %w[14 15 619 63 611 448].include?(tile.name)
          upgrades |= @company_town_tiles if tile.color == :white && !tile.label

          # Don't include the tile skips; those follow normal tile lay rules, they upgrade multiple times in a row
          upgrades
        end

        def owns_p15?(entity)
          entity.companies.find { |c| c.id == 'P15' }
        end

        def p6_offboard_revenue
          @p6_offboard_revenue ||= 'yellow_30|green_40|brown_50|gray_80'
        end

        def maximum_loans(entity)
          super + (owns_p15?(entity) ? 1 : 0)
        end

        def take_loan(entity, loan)
          raise GameError, "Cannot take more than #{maximum_loans(entity)} loans" unless can_take_loan?(entity)

          price = entity.share_price.price
          name = entity.name
          name += " (#{entity.owner.name})" if @round.is_a?(Round::Stock)
          @log << "#{name} takes a loan and receives #{format_currency(loan.amount)}"
          @bank.spend(loan.amount, entity)
          @stock_market.move_left(entity)
          @stock_market.move_left(entity)
          log_share_price(entity, price)
          entity.loans << loan
          @loans.delete(loan)
        end

        def interest_owed(entity)
          owed = super
          owed += (5 - interest_rate) if owed.positive? && owns_p15?(entity)
          owed
        end

        OFFBOARD_VALUES = [[20, 30, 40, 50], [20, 30, 40, 60], [20, 30, 50, 60], [20, 30, 50, 60], [20, 30, 60, 90],
                           [20, 40, 50, 80], [30, 40, 40, 50], [30, 40, 50, 60], [30, 50, 60, 80], [30, 50, 60, 80],
                           [40, 50, 40, 40]].freeze

        def optional_hexes
          offboard = OFFBOARD_VALUES.sort_by { rand }
          game_hexes.merge(
          {
            red: {
              ['A15'] => "town=revenue:yellow_#{offboard[3][0]}|green_#{offboard[3][1]}|brown_#{offboard[3][2]}"\
                         "|gray_#{offboard[3][3]};path=a:0,b:_0;path=a:5,b:_0",
              ['A27'] => "offboard=revenue:yellow_#{offboard[0][0]}|green_#{offboard[0][1]}"\
                         "|brown_#{offboard[0][2]}|gray_#{offboard[0][3]};"\
                         'path=a:5,b:_0;path=a:0,b:_0',
              ['B2'] => "town=revenue:yellow_#{offboard[4][0]}|green_#{offboard[4][1]}|brown_#{offboard[4][2]}"\
                        "|gray_#{offboard[4][3]};path=a:4,b:_0;path=a:5,b:_0",
              ['E1'] => "town=revenue:yellow_#{offboard[6][0]}|green_#{offboard[6][1]}|brown_#{offboard[6][2]}"\
                        "|gray_#{offboard[6][3]};path=a:4,b:_0;path=a:5,b:_0;path=a:3,b:_0",
              ['I5'] => "offboard=revenue:yellow_#{offboard[2][0]}|green_#{offboard[2][1]}|brown_#{offboard[2][2]}"\
                        "|gray_#{offboard[2][3]},groups:Mexico,hide:1;path=a:2,b:_0;path=a:3,b:_0;border=edge:4",
              %w[I7
                 I9] => "offboard=revenue:yellow_#{offboard[2][0]}|green_#{offboard[2][1]}|brown_#{offboard[2][2]}"\
                        "|gray_#{offboard[2][3]},groups:Mexico,hide:1;path=a:2,b:_0;path=a:3,b:_0;border=edge:4;border=edge:1",
              ['I11'] => "offboard=revenue:yellow_#{offboard[2][0]}|green_#{offboard[2][1]}|brown_#{offboard[2][2]}"\
                         "|gray_#{offboard[2][3]},groups:Mexico;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;border=edge:1;"\
                         'border=edge:5',
              ['J12'] => "offboard=revenue:yellow_#{offboard[2][0]}|green_#{offboard[2][1]}|brown_#{offboard[2][2]}"\
                         "|gray_#{offboard[2][3]},groups:Mexico,hide:1;path=a:3,b:_0;path=a:4,b:_0;border=edge:2;border=edge:5",
              ['J20'] => "offboard=revenue:yellow_#{offboard[1][0]}|green_#{offboard[1][1]}|brown_#{offboard[1][2]}"\
                         "|gray_#{offboard[1][3]};path=a:2,b:_0",
              ['J24'] => "town=revenue:yellow_#{offboard[5][0]}|green_#{offboard[5][1]}|brown_#{offboard[5][2]}"\
                         "|gray_#{offboard[5][3]};path=a:2,b:_0;path=a:3,b:_0",
              ['K13'] => "offboard=revenue:yellow_#{offboard[2][0]}|green_#{offboard[2][1]}|brown_#{offboard[2][2]}"\
                         "|gray_#{offboard[2][3]},groups:Mexico,hide:1;path=a:3,b:_0;border=edge:2",
            },
          }
        )
        end

        def timeline
          @timeline = [
            'After SR 1 all unused subsidies are removed from the map',
            'After OR 1.1 all unsold 2 trains are exported.',
            'After OR 1.2 all unsold 2+ trains are exported.',
            'After OR 2.1 no trains are exported',
            'After OR 2.2 all unsold 3 trains are exported',
            'After OR 3.1 and further ORs the next available train will be exported '\
            '(removed, triggering phase change as if purchased)',
          ].freeze
        end

        def new_operating_round
          remove_subsidies if @round.stock? && @turn == 1 && @round.round_num == 1
          super
        end

        def remove_subsidies
          @log << 'All unused subsidies are removed from the game'
          @subsidies_by_hex = {}
          SUBSIDIZED_HEXES.each do |hex_id|
            hex = hex_by_id(hex_id)
            hex.tile.icons.reject! { |icon| icon.name.include?('subsidy') }
          end
        end

        def or_round_finished
          @recently_floated = []
          turn = "#{@turn}.#{@round.round_num}"
          case turn
          when '1.1' then @depot.export_all!('2')
          when '1.2' then @depot.export_all!('2+')
          when '2.2' then @depot.export_all!('3')
          else
            @depot.export! unless turn == '2.1'
          end
        end

        def stock_round
          close_bank_shorts
          @interest_fixed = nil

          G18USA::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G18USA::Step::DenverTrack,
            G18USA::Step::HomeToken,
            G18USA::Step::BuySellParShares,
          ])
        end

        def new_auction_round
          log << "Seed Money for initial auction is #{format_currency(self.class::SEED_MONEY)}" unless @round
          Engine::Round::Auction.new(self, [
            G18USA::Step::SelectionAuction,
          ])
        end

        def operating_round(round_num)
          @interest_fixed = nil
          @interest_fixed = interest_rate
          # Revaluate if private companies are owned by corps with trains
          @companies.each do |company|
            next unless company.owner

            abilities(company, :revenue_change, time: 'has_train') do |ability|
              company.revenue = company.owner.trains.any? ? ability.revenue : 0
            end
          end

          G18USA::Round::Operating.new(self, [
            G1817::Step::Bankrupt,
            G1817::Step::CashCrisis,
            G18USA::Step::Loan,
            G18USA::Step::SpecialTrack,
            G18USA::Step::SpecialToken,
            G18USA::Step::SpecialBuyTrain,
            G18USA::Step::Assign,
            G18USA::Step::Track,
            G18USA::Step::DenverTrack,
            G18USA::Step::Token,
            G18USA::Step::Route,
            G18USA::Step::Dividend,
            Engine::Step::DiscardTrain,
            G18USA::Step::BuyTrain,
          ], round_num: round_num)
        end

        def next_round!
          clear_interest_paid
          @round =
            case @round
            when Engine::Round::Stock
              @operating_rounds = @final_operating_rounds || @phase.operating_rounds
              reorder_players
              new_operating_round
            when Engine::Round::Operating
              or_round_finished
              # Store the share price of each corp to determine if they can be acted upon in the AR
              @stock_prices_start_merger = @corporations.map { |corp| [corp, corp.share_price] }.to_h
              @log << "-- #{round_description('Merger and Conversion', @round.round_num)} --"
              G1817::Round::Merger.new(self, [
                G18USA::Step::ReduceTokens,
                Engine::Step::DiscardTrain,
                G1817::Step::PostConversion,
                G1817::Step::PostConversionLoans,
                G1817::Step::Conversion,
              ], round_num: @round.round_num)
            when G1817::Round::Merger
              @log << "-- #{round_description('Acquisition', @round.round_num)} --"
              G1817::Round::Acquisition.new(self, [
                Engine::Step::ReduceTokens,
                G1817::Step::Bankrupt,
                G1817::Step::CashCrisis,
                Engine::Step::DiscardTrain,
                G1817::Step::Acquire,
              ], round_num: @round.round_num)
            when G1817::Round::Acquisition
              if @round.round_num < @operating_rounds
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_set_finished
                new_stock_round
              end
            when init_round.class
              reorder_players
              new_stock_round
            end
        end

        GNR_FULL_BONUS = 60
        GNR_FULL_BONUS_HEXES = %w[B2 B8 B14 D20].freeze
        GNR_HALF_BONUS = 30
        GNR_HALF_BONUS_HEXES = %w[B8 B14].freeze

        def revenue_for(route, stops)
          stop_hexes = stops.map { |stop| stop.hex.id }
          revenue = super

          corporation = route.train.owner

          # TODO: Is it only the junctions and resource non-city track that can't be revisited or all?
          raise GameError, 'Route visits same hex twice' if route.hexes.size != route.hexes.uniq.size

          company_tile = route.all_hexes.find { |hex| COMPANY_TOWN_TILES.include?(hex.tile.name) }&.tile

          revenue -= 10 if company_tile && !company_tile.cities.first.tokened_by?(corporation)

          revenue += 10 * route.all_hexes.count { |hex| hex.tile.id.include?('coal') }
          revenue += 10 * route.all_hexes.count { |hex| hex.tile.id.include?('ore10') }
          revenue += 20 * route.all_hexes.count { |hex| hex.tile.id.include?('ore20') }
          revenue += @oil_value * route.all_hexes.count { |hex| hex.tile.id.include?('oil') }

          pullman_assigned = @round.train_upgrade_assignments[route.train]&.any? { |upgrade| upgrade['id'] == 'P' }
          revenue += 20 * stops.count { |s| !RURAL_TILES.include?(s.tile.name) } if pullman_assigned

          revenue += 10 if route.all_hexes.any? { |hex| hex.tile.icons.any? { |icon| icon.name == 'plus_ten' } }
          revenue += @phase.tiles.include?(:brown) ? 20 : 10 if route.all_hexes.any? do |hex|
                                                                  hex.tile.icons.any? do |icon|
                                                                    icon.name == 'plus_ten_twenty'
                                                                  end
                                                                end

          if GNR_FULL_BONUS_HEXES.difference(stop_hexes).empty?
            revenue += GNR_FULL_BONUS
          elsif GNR_HALF_BONUS_HEXES.difference(stop_hexes).empty?
            revenue += GNR_HALF_BONUS
          end

          if @round.train_upgrade_assignments[route.train]&.any? { |upgrade| upgrade['id'] == '/' }
            stop_skipped = skipped_stop(route, stops)
            if stop_skipped
              revenue -= stop_skipped.route_revenue(@phase, route.train)
              # remove the pullman bonus if a pullman is used on this train
              revenue -= 20 if pullman_assigned
            end
          end
          revenue
        end

        def skipped_stop(route, stops)
          # Blocked stop is highest priority as it may stop route from being legal
          t = tokened_out_stop(route)
          return t if t

          counted_stops = stops.select { |stop| stop&.visit_cost&.positive? }

          # Skipping is optional - if we are using STRICTLY fewer stops than distance (jumping adds 1) we don't need to skip
          return nil if counted_stops.size < route.train.distance

          # Count how many of our tokens are on the route; if only one we cannot skip that one.
          our_tokened_stops = counted_stops.select { |stop| stop&.tokened_by?(route.train.owner) }

          # Skip the worst stop if enough tokened stops
          return counted_stops.min_by { |stop| stop.route_revenue(@game.phase, route.train) } if our_tokened_stops.size > 1

          # Otherwise skip the worst untokened stop
          untokened_stops = counted_stops.reject { |stop| stop&.tokened_by(route.train.owner) }
          untokened_stops.min_by { |stop| stop.route_revenue(@game.phase, route.train) }
        end

        def check_distance(route, visits)
          super
          raise GameError, 'Train cannot start or end on a rural junction' unless
              (RURAL_TILES & [visits.first.tile.name, visits.last.tile.name]).empty?
        end

        def check_connected(route, token)
          return super unless @round.train_upgrade_assignments[route.train]&.any? { |upgrade| upgrade['id'] == '/' }

          visits = route.visited_stops
          blocked = nil

          if visits.size > 2
            corporation = route.corporation
            visits[1..-2].each do |node|
              next if !node.city? || !node.blocks?(corporation)
              raise GameError, 'Route can only bypass one tokened-out city' if blocked

              blocked = node
            end
          end

          paths_ = route.paths.uniq
          token = blocked if blocked

          return if token.select(paths_, corporation: route.corporation).size == paths_.size

          raise GameError, 'Route is not connected'
        end

        def tokened_out_stop(route)
          visits = route.visited_stops
          return false unless visits.size > 2

          corporation = route.corporation
          visits[1..-2].find { |node| node.city? && node.blocks?(corporation) }
        end

        def route_trains(entity)
          entity.runnable_trains.reject { |t| pullman_train?(t) }
        end

        def pullman_train?(train)
          train.name == 'P'
        end

        def float_corporation(corporation)
          @recently_floated << corporation

          super
        end

        def upgrade_cost(old_tile, hex, entity, spender)
          new_tile = hex.tile
          super_charge_cost = 0
          upgrade_level = (Engine::Tile::COLORS.index(new_tile.color) - Engine::Tile::COLORS.index(old_tile.color))
          super_charge_cost = 10 * (upgrade_level - 1) if old_tile.cities.size.zero? && upgrade_level > 1
          if super_charge_cost.positive?
            @log << "#{entity.name} owes #{format_currency(super_charge_cost)} "\
                    'for fast track upgrade charge'
          end
          super_charge_cost + super
        end

        def create_company_from_subsidy(subsidy)
          company = Engine::Company.new(
            {
              sym: subsidy['id'],
              name: subsidy['name'],
              desc: subsidy['desc'],
              value: subsidy['value'] || 0,
              abilities: subsidy['abilities'] || [],
            }
          )
          @companies << company
          update_cache(:companies)
          company
        end
      end
    end
  end
end
