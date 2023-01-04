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

        attr_accessor :pending_rusting_event, :p8_hexes
        attr_reader :jump_graph, :subsidies_by_hex, :recently_floated, :plain_yellow_city_tiles, :plain_green_city_tiles,
                    :mexico_hexes

        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = 99_999

        CERT_LIMIT = { 2 => 32, 3 => 21, 4 => 16, 5 => 16, 6 => 13, 7 => 11 }.freeze

        STARTING_CASH = { 2 => 630, 3 => 420, 4 => 315, 5 => 300, 6 => 250, 7 => 225 }.freeze

        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = false

        OBSOLETE_TRAINS_COUNT_FOR_LIMIT = false

        TILE_UPGRADES_MUST_USE_MAX_EXITS = %i[cities track].freeze

        MARKET = [
          %w[0l 0a 0a 0a 42 44 46 48 50p 53s 56p 59p 62p 66p 70p 74s 78p 82p 86p 90p 95p 100p 105p 110p 115p 120s 127p 135p 142p
             150p 157p 165p 172p 180p 190p 200p 210 220 230 240 250 260 270 285 300 315 330 345 360 375 390 405 420 440 460 480
             500 520 540 560 580 600 625 650 675 700 725 750 775 800],
           ].freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(
           safe_par: 'Minimum Price for a 2($53), 5($74) and 10($120) share'\
                     ' corporation taking maximum loans to ensure it avoids acquisition',
           acquisition: 'Acquisition (Dividends needed to move right: $20: ➤, $40: ➤➤, $60: ➤➤➤, $80: ➤➤➤➤)'
         ).freeze

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
            status: %w[increased_oil],
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

        def game_phases
          phases = self.class::PHASES
          return phases unless @optional_rules.include?(:seventeen_trains)

          phases.reject { |p| %w[3+ 4+].include?(p[:name]) }
        end

        # Trying to do {static literal}.merge(super.static_literal) so that the capitalization shows up first.
        STATUS_TEXT = {
          'increased_oil' => [
            'Oil value increased',
            'Oil worth $20 for the remainder of the game',
          ],
        }.merge(G1817::Game::STATUS_TEXT)

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

        def game_trains
          return seventeen_trains if @optional_rules.include?(:seventeen_trains)

          self.class::TRAINS
        end

        def seventeen_trains
          G1817::Game::TRAINS.dup + [{ name: 'P', distance: 0, price: 200, available_on: '5', num: 20 }]
        end

        # Does not include guaranteed metropolis New York City
        POTENTIAL_METROPOLIS_HEX_IDS = %w[D20 E11 G3 H14 H22 I19].freeze

        def potential_metropolitan_hexes
          @potential_metropolitan_hexes ||= POTENTIAL_METROPOLIS_HEX_IDS.map { |hex_id| @hexes.find { |h| h.id == hex_id } }
        end

        EXTENDED_MAX_LOAN = 60
        EXTENDED_LOANS_PER_INCREMENT = 6

        def river_hex?(hex)
          RIVER_HEXES.include?(hex.id)
        end

        ASSIGNMENT_TOKENS = {
          'bridge' => '/icons/1817/bridge_token.svg',
        }.freeze

        SEED_MONEY = nil

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
          @tiles.find { |t| t.name == name }
        end

        def setup_preround
          randomize_privates
        end

        def setup
          @rhq_tile = tile_by_name('X23')
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

          setup_company_tiles

          @jump_graph = Graph.new(self, no_blocking: true)

          @recently_floated = []

          @mexico_hexes = MEXICO_HEXES.map { |h| hex_by_id(h) }
          metro_hexes = METROPOLITAN_HEXES.sort_by { rand }.take(3)
          metro_hexes.each { |metro_hex| convert_potential_metro(hex_by_id(metro_hex)) }
          @p8_hexes = []

          setup_train_roster

          @subsidies = SUBSIDIES.dup
          setup_resource_subsidy
          randomize_subsidies
        end

        def setup_company_tiles
          @neutral = Corporation.new(
            sym: 'N',
            name: 'Neutral',
            logo: 'minus_ten',
            simple_logo: 'minus_ten',
            tokens: [],
          )
          @neutral.owner = @bank

          # Add neutral tokens to both the tile display and the actual tile
          COMPANY_TOWN_TILES.each do |ct_name|
            [@tiles, @all_tiles].each do |tile_set|
              token = Token.new(@neutral, price: 0, type: :neutral)
              @neutral.tokens << token
              tile = tile_set.find { |t| t.name == ct_name }
              tile.cities.first.place_token(@neutral, token, check_tokenable: false)
            end
          end
        end

        def setup_train_roster
          return if @optional_rules.include?(:seventeen_trains)
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
            hex.lay(@tiles.find { |t| t.name == 'X04s' })
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
          @graph.clear
        end

        def randomize_privates
          always_in = %w[P1 P2 P3 P4]
          always_in << 'P10' if @players.size >= 5
          num_kept = { 30 => 1, 40 => 2, 60 => 3, 80 => 2, 90 => 2, 120 => 1 }

          to_remove = @companies.reject { |c| always_in.include?(c.id) }.group_by(&:value).flat_map do |val, companies|
            companies.sort_by { rand }.take(companies.size - num_kept[val])
          end

          @log << "Removing #{to_remove.map(&:name).join(', ')}"
          to_remove.each(&:close!)
        end

        def setup_resource_subsidy
          subsidy = @subsidies.find { |s| s[:id] == 'S16' }
          ability = subsidy[:abilities][0].dup
          subsidy[:abilities][0] = ability

          resources = []
          if company_by_id('P24').closed?
            ability[:hexes] += ORE_HEXES
            ability[:tiles] << RESOURCE_LABELS[:ore]
            ability[:discount] = 15
            resources << 'ore'
          end
          if company_by_id('P12').closed?
            ability[:hexes] += OIL_HEXES
            ability[:tiles] << RESOURCE_LABELS[:oil]
            resources << 'oil'
          end
          if company_by_id('P18').closed? || company_by_id('P28').closed?
            ability[:hexes] += COAL_HEXES
            ability[:tiles] << RESOURCE_LABELS[:coal]
            ability[:discount] = 15
            resources << 'coal'
          end
          resources << 'NO RESOURCES' if resources.empty?

          subsidy[:desc] =
            "The corporation can place its choice of one of the following resources: #{resources.join(', ')}. " \
            'Placing a track and the resource token from the Resource Subsidy is a free extra ' \
            'track lay in addition to the normal track placements.'

          @log << "Resource subsidy includes #{resources.join(', ')}"
        end

        def randomize_subsidies
          randomized_subsidies = @subsidies.sort_by { rand }.take(SUBSIDIZED_HEXES.size)
          @subsidies_by_hex = {}
          SUBSIDIZED_HEXES.zip(randomized_subsidies).each do |hex_id, subsidy|
            hex = hex_by_id(hex_id)
            @subsidies_by_hex[hex_id] = subsidy
            hex.tile.icons.reject! { |icon| icon.name == 'coins' }
            hex.tile.icons << Engine::Part::Icon.new("18_usa/#{subsidy['icon']}")
          end
        end

        def home_hex_for(entity)
          return nil unless entity.corporation?

          entity.tokens.first.hex
        end

        def phase_5_or_later?
          @phase.tiles.include?(:brown)
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

        def tile_resources(tile)
          if tile.color == :white
            icons = tile.icons.map(&:name)
            return RESOURCE_ICONS.select { |_resource, icon| icons.include?(icon) }.keys
          end
          return [] unless (label = tile.label&.to_s)

          RESOURCE_LABELS.select { |_resource, text| label.include?(text) }.keys
        end

        def resource_tile?(tile)
          !tile_resources(tile).empty?
        end

        def resource_abilities_for_hex(hex, resource, selected_companies)
          selected_companies.flat_map { |c| abilities(c, :tile_lay) }.compact.select do |ability|
            ability.hexes.include?(hex.id) && ability.tiles.include?(RESOURCE_LABELS[resource])
          end
        end

        def abilities_to_lay_resource_tile(hex, tile, selected_companies)
          # Prioritize single resource type abilities
          resources = {}
          tile_resources(tile).each do |r|
            resources[r] = resource_abilities_for_hex(hex, r, selected_companies).sort_by { |a| a.tiles.size }
          end
          return resources.transform_values(&:first) if resources.one?

          # Filter out duplicates
          dups = resources.values[0].intersection(resources.values[1])
          resources.transform_values! { |abilities| (abilities - dups)&.first || dups.shift }
          resources
        end

        def consume_abilities_to_lay_resource_tile(hex, tile, selected_companies)
          return if ORE20_TILES.include?(tile.name)

          abilities_to_lay_resource_tile(hex, tile, selected_companies).each do |resource, ability|
            raise GameError, "Must have #{resource} resource to lay tile" unless ability

            @log << "#{ability.owner.name} contributes the #{resource} resource"
            ability.use!
            next if !ability.count&.zero? || !ability.closed_when_used_up

            company = ability.owner
            @log << "#{company.name} closes"
            company.close!
          end
        end

        def can_lay_resource_tile?(from, to, selected_companies)
          return false if selected_companies.empty?

          from_resources = tile_resources(from)
          return false unless tile_resources(to).all? { |r| from_resources.include?(r) }

          abilities_to_lay_resource_tile(from.hex, to, selected_companies).all? { |_k, v| v }
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
          return @phase.tiles.include?(:green) && ore_upgrade?(from, to) if ORE20_TILES.include?(to.name)
          if to.color == :yellow && resource_tile?(to)
            return from.color == :white && can_lay_resource_tile?(from, to, @round.current_entity.companies)
          end

          # Workaround to allow Denver tile orientation to change after placement
          return to.name == 'X04' if from.name == 'X04s'

          super
        end

        def ore_upgrade?(from, to)
          ORE10_TILES.include?(from.name) && ORE20_TILES.include?(to.name) && upgrades_to_correct_label?(from, to)
        end

        def upgrades_to_correct_label?(from, to)
          case from.hex.name
          when 'D24'
            return true if to.name == 'X13'
            return false if to.color == :brown
          end

          return %w[X01 X02 X04 X06].include?(from.name) if to.name == '592'

          super
        end

        def upgrades_to_correct_color?(from, to, selected_company: nil)
          return true if self.class::SPECIAL_TILES.include?(to.name)

          if phase_5_or_later?
            # Non-track upgrades
            return Engine::Tile::COLORS.index(to.color) > Engine::Tile::COLORS.index(from.color) if from.cities.empty?

            # City upgrades
            if from.color == :white
              entity = selected_company&.owner || @round.current_entity
              colors = [:green]
              colors << :brown if !entity.operated? && home_hex_for(entity) == from.hex
              return colors.include?(to.color)
            end
          end

          super
        end

        def upgrade_cost(tile, hex, entity, spender)
          entity = entity.owner if !entity.corporation? && entity.owner&.corporation?

          if hex.tile.color == :yellow && resource_tile?(hex.tile)
            ability =
              abilities_to_lay_resource_tile(hex, hex.tile, entity.companies).values.flatten.compact.find do |a|
                a.discount.positive?
              end
          end

          ability ||= entity.all_abilities.find { |a| a.type == :tile_discount && a.terrain && tile.terrain.include?(a.terrain) }

          upgrade_cost = tile.upgrades.sum(&:cost)
          return upgrade_cost if upgrade_cost.zero? || !ability

          log_cost_discount(spender, ability, ability.discount)
          upgrade_cost - ability.discount
        end

        def owns_p15?(entity)
          entity.companies.find { |c| c.id == 'P15' }
        end

        def owns_gnr?(entity)
          entity.companies.find { |c| c.id == 'P17' }
        end

        def p6_offboard_revenue
          @p6_offboard_revenue ||= 'yellow_30|green_40|brown_50|gray_80'
        end

        def maximum_loans(entity)
          super + (owns_p15?(entity) ? 1 : 0)
        end

        def loan_taken_stock_market_movement(entity)
          @stock_market.move_left(entity)
          @stock_market.move_left(entity)
        end

        def loan_payoff_stock_market_movement(entity)
          @stock_market.move_right(entity)
          @stock_market.move_right(entity)
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
          return super if @optional_rules.include?(:seventeen_trains)

          @timeline = [
            'End of SR 1: All unused subsidies are removed from the map',
            'End of OR 1.1: All unsold 2 trains are exported.',
            'End of OR 1.2: All unsold 2+ trains are exported.',
            'End of OR 2.1: No trains are exported',
            'End of OR 2.2: All unsold 3 trains are exported',
            'End of each subsequent OR: The next available train is exported', \
            '*Exported trains are removed from the game and can trigger phase changes as if purchased',
          ].freeze
        end

        def remove_subsidies
          @log << 'All unused subsidies are removed from the game'
          @subsidies_by_hex = {}
          SUBSIDIZED_HEXES.each do |hex_id|
            hex = hex_by_id(hex_id)
            hex.tile.icons.reject! { |icon| icon.name.include?('subsidy') }
          end
        end

        def export_train
          return or_round_finished if @optional_rules.include?(:seventeen_trains)

          @recently_floated = []
          turn = "#{@turn}.#{@round.round_num}"
          case turn
          when '1.1'
            @depot.export_all!('2')
          when '1.2'
            @depot.export_all!('2+')
            @phase.next! unless @phase.tiles.include?(:green)
          when '2.2'
            @depot.export_all!('3')
          else
            @depot.export! unless turn == '2.1'
          end
        end

        def stock_round
          close_bank_shorts
          @interest_fixed = nil

          G18USA::Round::Stock.new(self, [
            G18USA::Step::DiscardTrain,
            G18USA::Step::DenverTrack,
            G18USA::Step::HomeToken,
            G18USA::Step::BuySellParShares,
          ])
        end

        def new_auction_round
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
            G18USA::Step::ObsoleteTrain,
            G18USA::Step::Loan,
            G18USA::Step::DiscardTrain,
            G18USA::Step::SpecialTrack,
            G18USA::Step::SpecialToken,
            G18USA::Step::SpecialBuyTrain,
            G18USA::Step::Assign,
            G18USA::Step::DenverTrack,
            G18USA::Step::Track,
            G18USA::Step::Token,
            G18USA::Step::BuyPullman,
            G18USA::Step::Route,
            G18USA::Step::Dividend,
            G18USA::Step::BuyTrain,
          ], round_num: round_num)
        end

        def crowded_corps
          @crowded_corps ||= super | corporations.select { |c| c.trains.count { |t| pullman_train?(t) } > 1 }
        end

        def next_round!
          clear_interest_paid
          @round =
            case @round
            when Engine::Round::Stock
              @operating_rounds = @final_operating_rounds || @phase.operating_rounds
              remove_subsidies if @turn == 1 && @round.round_num == 1
              reorder_players
              new_operating_round
            when Engine::Round::Operating
              # Store the share price of each corp to determine if they can be acted upon in the AR
              @stock_prices_start_merger = @corporations.to_h { |corp| [corp, corp.share_price] }
              @log << "-- #{round_description('Merger and Conversion', @round.round_num)} --"
              G1817::Round::Merger.new(self, [
                G18USA::Step::ReduceTokens,
                G18USA::Step::DiscardTrain,
                G1817::Step::PostConversion,
                G18USA::Step::PostConversionLoans,
                G18USA::Step::Conversion,
              ], round_num: @round.round_num)
            when G1817::Round::Merger
              @log << "-- #{round_description('Acquisition', @round.round_num)} --"
              G1817::Round::Acquisition.new(self, [
                G18USA::Step::ReduceTokens,
                G1817::Step::Bankrupt,
                G1817::Step::CashCrisis,
                G18USA::Step::DiscardTrain,
                G18USA::Step::Acquire,
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
          duplicates = route.ordered_hexes.group_by(&:itself).select { |_, nodes| nodes.size > 1 }.keys
          if duplicates.find { |hex| resource_tile?(hex.tile) }
            raise GameError, 'Cannot pass through resource tiles more than once'
          end
          if duplicates.find { |hex| RURAL_TILES.include?(hex.tile.name) }
            raise GameError, 'Cannot pass through Rural Junction tiles more than once'
          end

          mexico_routes = route.routes.count do |r|
            r_stops = r == route ? stops : r.stops
            !(r_stops.map { |s| s.hex.id } & MEXICO_HEXES).empty?
          end
          raise GameError, 'No more than two trains can run to Mexico' if mexico_routes > 2

          stop_hexes = stops.map(&:hex)
          revenue = super

          corporation = route.train.owner
          company_tile = stop_hexes.find { |hex| COMPANY_TOWN_TILES.include?(hex.tile.name) }&.tile
          revenue -= 10 if company_tile && !company_tile.cities.first.tokened_by?(corporation)

          track_hexes = route.all_hexes - stop_hexes
          revenue += track_hexes.sum do |hex|
            resource_revenue = 0
            next resource_revenue if hex.tile.color == :white || (resources = tile_resources(hex.tile)).empty?

            resource_revenue += 10 if resources.include?(:coal)
            resource_revenue += ORE20_TILES.include?(hex.tile.name) ? 20 : 10 if resources.include?(:ore)
            resource_revenue += phase_5_or_later? ? 20 : 10 if resources.include?(:oil)
            resource_revenue
          end

          pullman_assigned = @round.train_upgrade_assignments[route.train]&.any? { |upgrade| upgrade[:id] == 'P' }
          revenue += 20 * stops.count { |s| !RURAL_TILES.include?(s.tile.name) } if pullman_assigned

          revenue += 10 if stop_hexes.find { |hex| hex.tile.icons.find { |icon| icon.name == 'plus_ten' } }
          if stop_hexes.find { |hex| hex.tile.icons.find { |icon| icon.name == 'plus_ten_twenty' } }
            revenue += phase_5_or_later? ? 20 : 10
          end
          revenue += 10 if company_by_id('P8').owner == corporation && !(stop_hexes & @p8_hexes).empty?

          revenue += gnr_revenue(stops) if gnr_route?(route, stops)

          revenue
        end

        def gnr_route?(route, stops)
          return false if !owns_gnr?(route.train.owner) || gnr_revenue(stops).zero?

          route.routes.max_by { |r| gnr_revenue(r == route ? stops : r.stops) } == route
        end

        def gnr_revenue(stops)
          revenue = 0
          stop_hex_ids = stops.map { |stop| stop.hex.id }

          if (GNR_FULL_BONUS_HEXES - stop_hex_ids).empty?
            revenue = GNR_FULL_BONUS
          elsif (GNR_HALF_BONUS_HEXES - stop_hex_ids).empty?
            revenue = GNR_HALF_BONUS
          end

          revenue
        end

        def revenue_str(route)
          stop_hexes = route.stops.map(&:hex)
          str = route.hexes.map { |h| stop_hexes.include?(h) ? h&.name : "(#{h&.name})" }.join('-')
          str += ' + GNR Bonus' if gnr_route?(route, route.stops)

          str
        end

        def compute_stops(route)
          stops = super
          if @round.train_upgrade_assignments[route.train]&.any? { |upgrade| upgrade[:id] == '/' }
            skipped = skipped_stop(route, stops)
            stops.reject! { |stop| stop == skipped } if skipped
          end
          stops
        end

        def skipped_stop(route, stops)
          return nil if stops.size <= 2

          # Blocked stop is highest priority as it may stop route from being legal
          corporation = route.train.owner
          t = tokened_out_stop(corporation, stops)
          return t if t

          counted_stops = stops.select { |stop| stop&.visit_cost&.positive? }

          # Skipping is optional - if we are using STRICTLY fewer stops than distance (jumping adds 1) we don't need to skip
          return nil if counted_stops.size < route.train.distance

          # Count how many of our tokens are on the route; if only one we cannot skip that one.
          tokened_stops = counted_stops.select { |stop| stop.tokened_by?(route.train.owner) }
          counted_stops.delete(tokened_stops.first) if tokened_stops.one?

          # Find the lowest revenue stop that can be skipped
          counted_stops.max_by { |stop| revenue_for(route, stops.reject { |s| s == stop }) }
        end

        def check_distance(route, visits)
          super
          raise GameError, 'Train cannot start or end on a rural junction' unless
              (RURAL_TILES & [visits.first.tile.name, visits.last.tile.name]).empty?
        end

        def check_connected(route, corporation)
          return super unless @round.train_upgrade_assignments[route.train]&.any? { |upgrade| upgrade[:id] == '/' }

          visits = route.visited_stops
          blocked = nil

          if visits.size > 2
            visits[1..-2].each do |node|
              next if !node.city? || !node.blocks?(corporation)
              raise GameError, 'Route can only bypass one tokened-out city' if blocked

              blocked = node
            end
          end

          # no need to check whether tokened out because of the above
          super(route, nil)
        end

        def tokened_out_stop(corporation, stops)
          stops[1..-2].find { |node| node.city? && node.blocks?(corporation) }
        end

        def pullmans_available?
          # Pullmans are available in phase 5, using the availability of brown track as an easy signal of this
          phase_5_or_later?
        end

        def route_trains(entity)
          entity.runnable_trains.reject { |t| pullman_train?(t) }
        end

        def pullman_train?(train)
          train.name == 'P'
        end

        def rust_trains!(train, entity)
          return super unless p13_can_save_rusting_train?(train)

          @pending_rusting_event = { train: train, entity: entity }
        end

        def p13_can_save_rusting_train?(purchased_train)
          !@pending_rusting_event &&
            (owner = company_by_id('P13')&.owner) &&
            owner.corporation? &&
            owner.trains.any? { |t| rust?(t, purchased_train) }
        end

        def float_corporation(corporation)
          @recently_floated << corporation

          super
        end

        def add_subsidy(corporation, hex)
          return unless (subsidy = @subsidies_by_hex.delete(hex.coordinates))

          hex.tile.icons.reject! { |icon| icon.name.include?('subsidy') }
          subsidy_company = create_company_from_subsidy(subsidy)
          assign_boomtown_subsidy(hex, corporation) if subsidy_company.id == 'S8'
          subsidy_company.owner = corporation
          corporation.companies << subsidy_company
        end

        def create_company_from_subsidy(subsidy)
          subsidy_params = {
            sym: subsidy[:id],
            name: subsidy[:name],
            desc: subsidy[:desc],
            value: subsidy[:value] || 0,
            abilities: subsidy[:abilities] || [],
          }
          company = Engine::Company.new(**subsidy_params)
          @companies << company
          update_cache(:companies)
          company
        end

        def assign_boomtown_subsidy(hex, corporation)
          subsidy = company_by_id('S8')
          subsidy.all_abilities.each do |ability|
            ability.hexes << hex.id if ability.type == :tile_lay
            ability.corporation = corporation.id if ability.type == :close
          end
        end

        def apply_subsidy(corporation)
          return unless (subsidy = corporation.companies.first)

          case subsidy.id
          when 'S10'
            subsidy.owner.tokens.first.hex.tile.icons << Engine::Part::Icon.new('18_usa/plus_ten', 'plus_ten', true)
            subsidy.close!
          when 'S11'
            subsidy.owner.tokens.first.hex.tile.icons << Engine::Part::Icon.new('18_usa/plus_ten_twenty', 'plus_ten_twenty', true)
            subsidy.close!
          when *self.class::CASH_SUBSIDIES
            @log << "Subsidy contributes #{format_currency(subsidy.value)}"
            @bank.spend(subsidy.value, corporation.owner)
          when 'S16'
            if subsidy.abilities.first.hexes.empty?
              @log << "#{subsidy.name} has NO RESOURCES and closes"
              subsidy.close!
            end
          end
        end
      end
    end
  end
end
