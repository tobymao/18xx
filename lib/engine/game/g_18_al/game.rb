# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative '../company_price_50_to_150_percent'
require_relative '../cities_plus_towns_route_distance_str'

module Engine
  module Game
    module G18AL
      class Game < Game::Base
        include CitiesPlusTownsRouteDistanceStr
        include_meta(G18AL::Meta)

        CURRENCY_FORMAT_STR = '$%d'

        BANK_CASH = 8000

        CERT_LIMIT = { 3 => 15, 4 => 12, 5 => 10 }.freeze

        STARTING_CASH = { 3 => 600, 4 => 500, 5 => 400 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        TILES = {
          '3' => 3,
          '4' => 3,
          '5' => 3,
          '6' => 3,
          '7' => 5,
          '8' => 11,
          '9' => 10,
          '14' => 4,
          '15' => 4,
          '16' => 1,
          '17' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 4,
          '24' => 4,
          '25' => 1,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 3,
          '42' => 3,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 2,
          '57' => 4,
          '58' => 3,
          '63' => 7,
          '70' => 1,
          '142' => 2,
          '143' => 2,
          '144' => 2,
          '445' => 1,
          '446' => 1,
          '441a' => 1,
          '442a' => 1,
          '443a' => 1,
          '444b' => 1,
          '444m' => 1,
        }.freeze

        LOCATION_NAMES = {
          'A4' => 'Nashville',
          'B1' => 'Corinth',
          'B7' => 'Chattanooga',
          'C2' => 'Florence',
          'C4' => 'Decatur',
          'C6' => 'Stevenson',
          'D7' => 'Rome',
          'E6' => 'Gadsden',
          'F1' => 'Tupelo',
          'G4' => 'Birmingham',
          'G6' => 'Anniston',
          'G8' => 'Atlanta',
          'H3' => 'Tuscaloosa',
          'H5' => 'Oxmoor',
          'J7' => 'West Point',
          'K2' => 'York',
          'K4' => 'Selma',
          'L1' => 'Meridian',
          'L5' => 'Montgomery',
          'M8' => 'Phenix City',
          'O6' => 'Dothan',
          'P7' => 'Gulf of Mexico',
          'Q2' => 'Mobile',
        }.freeze

        MARKET = [
          %w[60
             65
             70
             75
             80
             90p
             105p
             120
             135
             150
             170
             190
             215
             240
             270
             300e],
          %w[55
             60
             65
             70p
             75p
             80
             90
             105
             120
             135
             150
             170
             190
             215
             240],
          %w[50y
             55
             60p
             65
             70
             75
             80
             90
             105
             120
             135
             150
             170],
          %w[45y 50y 55 60 65 70 75 80 90 105 120],
          %w[40y 45y 50y 55 60 65 70 75],
          %w[35y 40y 45y 50y 55y],
          %w[30y 35y 40y 45y 50y],
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 1,
            status: %w[can_buy_companies_from_other_players limited_train_buy],
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            status: %w[can_buy_companies
                       can_buy_companies_from_other_players
                       limited_train_buy],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            status: %w[can_buy_companies can_buy_companies_from_other_players],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '7',
            on: '7',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '4D',
            on: '4D',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 100,
            rusts_on: '4',
            num: 5,
          },
          {
            name: '3',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 180,
            rusts_on: '6',
            num: 4,
          },
          {
            name: '4',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 300,
            obsolete_on: '7',
            num: 3,
          },
          {
            name: '5',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            events: [{ 'type' => 'close_companies' }],
            price: 450,
            num: 2,
          },
          {
            name: '6',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 630,
            num: 1,
            events: [{ 'type' => 'remove_tokens' }],
          },
          {
            name: '7',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 7, 'visit' => 7 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 700,
            num: 1,
          },
          {
            name: '4D',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4, 'multiplier' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 800,
          },
        ].freeze

        COMPANIES = [
          {
            sym: 'TR',
            name: 'Tuscumbia Railway',
            value: 20,
            revenue: 5,
            desc: 'No special abilities.',
          },
          {
            sym: 'SNAR',
            name: 'South & North Alabama Railroad',
            value: 40,
            revenue: 10,
            desc: 'Owning corporation may place the Warrior Coal Field token in one of the city '\
                  'hexes with a mining symbol (Gadsden, Anniston, Oxmoor, Birmingham, or Tuscaloosa) '\
                  'provided that the corporation can reach the city with a route that is in the range '\
                  'of a train owned by the corporation (i.e. not an infinite route). Placing the '\
                  'token does not close the company. The owning corporation adds 10 to revenue for '\
                  'all trains whose route includes the city with the token. The token is removed from '\
                  'the game at the beginning of phase 6.',
            abilities: [
              {
                type: 'assign_hexes',
                hexes: %w[H3 G4 H5 G6 E6],
                count: 1,
                owner_type: 'corporation',
              },
            ],
          },
          {
            sym: 'BLC',
            name: 'Brown & Sons Lumber Co.',
            value: 70,
            revenue: 15,
            desc: 'Owning corporation may during the track laying step lay the Lumber Terminal '\
                  'track tile (# 445) in an empty swamp hex, which need not be connected to the '\
                  'corporation\'s station(s). The tile is free and does not count as the '\
                  'corporation\'s one tile lay per turn. Laying the tile does not close the '\
                  'company. The tile is permanent and cannot be upgraded.',
            abilities: [
              {
                type: 'tile_lay',
                free: true,
                owner_type: 'corporation',
                tiles: ['445'],
                hexes: %w[G2 M2 O4 N5 P5],
                count: 1,
                when: 'track',
              },
            ],
          },
          {
            sym: 'M&C',
            name: 'Memphis & Charleston Railroad',
            value: 100,
            revenue: 20,
            desc: 'Owning corporation receives the Robert E. Lee marker which adds +20 to revenue '\
                  'if a route includes Atlanta and Birmingham and the Pan American marker which adds '\
                  '+40 to revenue if a route includes Nashville and Mobile. Each marker may be assigned '\
                  'to one train each operating round and both markers may be assigned to a single '\
                  'train. The bonuses are permanent unless a new player becomes president of the '\
                  'corporation, in which case they are removed from the game.',
          },
          {
            sym: 'NDY',
            name: 'New Decatur Yards',
            value: 120,
            revenue: 20,
            desc: 'Owning corporation may purchase one new train from the bank with a discount of 50%, '\
                  'which closes the company.',
            abilities: [
              {
                type: 'train_discount',
                discount: 0.5,
                owner_type: 'corporation',
                trains: %w[3 4 5],
                count: 1,
                closed_when_used_up: true,
                when: 'buying_train',
              },
            ],
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'L&N',
            name: 'Louisville & Nashville Railroad',
            logo: '18_al/LN',
            simple_logo: '18_al/LN.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'A4',
            color: 'blue',
            abilities: [{ type: 'assign_hexes', hexes: ['G4'], count: 1 }],
          },
          {
            sym: 'M&O',
            name: 'Mobile & Ohio Railroad',
            logo: '18_al/MO',
            simple_logo: '18_al/MO.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'Q2',
            color: 'orange',
            abilities: [{ type: 'assign_hexes', hexes: ['K2'], count: 1 }],
          },
          {
            sym: 'WRA',
            name: 'Western Railway of Alabama',
            logo: '18_al/WRA',
            simple_logo: '18_al/WRA.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'L5',
            color: 'red',
            abilities: [{ type: 'assign_hexes', hexes: ['J7'], count: 1 }],
          },
          {
            sym: 'ATN',
            name: 'Alabama, Tennessee & Northern Railroad',
            logo: '18_al/ATN',
            simple_logo: '18_al/ATN.alt',
            tokens: [0, 40, 100],
            coordinates: 'F1',
            color: 'black',
            abilities: [{ type: 'assign_hexes', hexes: ['L1'], count: 1 }],
          },
          {
            sym: 'ABC',
            name: 'Atlanta, Birmingham & Coast Railroad',
            logo: '18_al/ABC',
            simple_logo: '18_al/ABC.alt',
            tokens: [0, 40],
            coordinates: 'G6',
            color: 'green',
            abilities: [{ type: 'assign_hexes', hexes: ['G4'], count: 1 }],
          },
          {
            sym: 'TAG',
            name: 'Tennessee, Alabama & Georgia Railway',
            logo: '18_al/TAG',
            simple_logo: '18_al/TAG.alt',
            tokens: [0, 40],
            coordinates: 'E6',
            color: 'yellow',
            text_color: 'black',
            abilities: [{ type: 'assign_hexes', hexes: ['G4'], count: 1 }],
          },
        ].freeze

        HEXES = {
          white: {
            %w[A2
               B5
               D1
               E2
               E4
               F3
               F5
               H1
               H7
               I2
               I4
               I6
               I8
               J1
               J3
               J5
               K6
               K8
               L7
               M4
               M6
               N1
               N7
               P1
               P3] => '',
            ['B3'] => 'border=edge:0,type:impassable',
            ['D3'] => 'upgrade=cost:20,terrain:water;border=edge:3,type:impassable',
            %w[C2 C6] => 'town=revenue:0;upgrade=cost:20,terrain:water',
            ['C4'] => 'city=revenue:0;upgrade=cost:20,terrain:water',
            %w[L3 N3 O2] => 'upgrade=cost:20,terrain:water',
            %w[G2 M2 N5 O4 P5] => 'upgrade=cost:20,terrain:swamp',
            ['D5'] => 'upgrade=cost:60,terrain:mountain|water',
            ['F7'] => 'upgrade=cost:60,terrain:mountain',
            ['G4'] =>
                   'city=revenue:0;upgrade=cost:60,terrain:mountain;label=B;icon=image:18_al/coal,sticky:1',
            %w[J7 K2 L5] => 'city=revenue:0',
            %w[G6 H3] => 'city=revenue:0;icon=image:18_al/coal,sticky:1',
            ['O6'] => 'town=revenue:0',
          },
          red: {
            ['A4'] =>
                     'city=revenue:yellow_40|brown_50;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1',
            ['B1'] => 'offboard=revenue:yellow_40|brown_30;path=a:5,b:_0',
            ['B7'] => 'offboard=revenue:yellow_30|brown_50;path=a:1,b:_0',
            ['G8'] => 'offboard=revenue:yellow_40|brown_70;path=a:0,b:_0;path=a:1,b:_0',
            ['P7'] => 'offboard=revenue:yellow_30|brown_40;path=a:2,b:_0;path=a:3,b:_0',
            ['Q2'] => 'city=revenue:yellow_40|brown_50;path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1;'\
                      'path=a:4,b:_0,terminal:1',
          },
          gray: {
            ['D7'] => 'town=revenue:10;path=a:0,b:_0;path=a:_0,b:1',
            ['F1'] => 'city=revenue:30;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['H5'] =>
            'city=revenue:30;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;icon=image:18_al/coal,sticky:1',
            ['L1'] =>
            'city=revenue:yellow_30|brown_40,slots:2;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            ['M8'] => 'town=revenue:10;path=a:1,b:_0;path=a:_0,b:2',
          },
          yellow: {
            ['E6'] =>
                     'city=revenue:20;path=a:3,b:_0;path=a:4,b:_0;icon=image:18_al/coal,sticky:1',
            ['K4'] => 'city=revenue:20;path=a:1,b:_0;path=a:_0,b:5',
          },
        }.freeze

        LAYOUT = :flat

        AXES = { x: :number, y: :letter }.freeze

        GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_or, bank: :current_or }.freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'remove_tokens' => ['Remove Tokens', 'Warrior Coal Field token removed']
        ).freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'can_buy_companies_from_other_players' => ['Interplayer Company Buy',
                                                     'Companies can be bought between players']
        ).merge(
          Engine::Step::SingleDepotTrainBuy::STATUS_TEXT
        ).freeze

        ROUTE_BONUSES = {
          atlanta_birmingham: 'ATL>BRM',
          mobile_nashville: 'MOB>NSH',
        }.freeze

        STANDARD_YELLOW_CITY_TILES = %w[5 6 57].freeze

        ASSIGNMENT_TOKENS = {
          'SNAR' => '/icons/18_al/snar_token.svg',
        }.freeze
        include CompanyPrice50To150Percent

        def route_bonuses
          ROUTE_BONUSES
        end

        def setup
          @recently_floated = []

          setup_company_price_50_to_150_percent

          move_ln_corporation if @optional_rules&.include?(:LN_home_city_moved)
          change_4t_to_hardrust if @optional_rules&.include?(:hard_rust_t4)

          @corporations.each do |corporation|
            abilities(corporation, :assign_hexes) do |ability|
              hex_name = ability.hexes.first
              location = get_location_name(hex_name)
              ability.description = "Historical objective: #{location}"
              ability.desc_detail = "If #{corporation.name} puts a token into #{location} (#{hex_name}) "\
                                    "#{format_currency(100)} is added to its treasury."
            end
          end

          @green_m_tile ||= @tiles.find { |t| t.name == '443a' }
        end

        def num_trains(train)
          return train[:num] unless train[:name] == '4D'

          @optional_rules&.include?(:unlimited_4d) ? 8 : 5
        end

        def south_and_north_alabama_railroad
          @south_and_north_alabama_railroad ||= company_by_id('SNAR')
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            G18AL::Step::Assign,
            G18AL::Step::BuyCompany,
            Engine::Step::HomeToken,
            Engine::Step::SpecialTrack,
            Engine::Step::Track,
            G18AL::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::SpecialBuyTrain,
            Engine::Step::SingleDepotTrainBuy,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def or_round_finished
          @recently_floated = []
        end

        def stock_round
          Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G18AL::Step::BuySellParShares,
          ])
        end

        def revenue_for(route, stops)
          revenue = super

          abilities(route.corporation, :hexes_bonus) do |ability|
            revenue += bonuses_for_hex_on_route(ability, stops).sum { |b| b[:revenue] }
          end

          revenue += bonuses_for_routes(route.routes).sum { |b| b[:route] == route ? b[:revenue] : 0 }

          revenue
        end

        def revenue_str(route)
          str = super

          r_bonuses = bonuses_for_routes(route.routes).select { |b| b[:route] == route }
          abilities(route.corporation, :hexes_bonus) do |ability|
            r_bonuses += bonuses_for_hex_on_route(ability, route.stops)
          end
          str += " + #{r_bonuses.map { |b| b[:description] }.join(' + ')}" if r_bonuses.any?

          str
        end

        def event_remove_tokens!
          @corporations.each do |corporation|
            abilities(corporation, :hexes_bonus) do |a|
              assigned_hex = @hexes.find { |h| a.hexes.include?(h.name) }
              hex_name = assigned_hex.name
              assigned_hex.remove_assignment!(south_and_north_alabama_railroad.id)
              corporation.remove_ability(a)

              @log << "Warrior Coal Field token is removed from #{get_location_name(hex_name)} (#{hex_name})"
            end
          end
        end

        def event_close_companies!
          super

          # Remove mining icons if Warrior Coal Field has not been assigned
          @corporations.each do |corporation|
            next unless abilities(corporation, :hexes_bonus)

            @companies.each do |company|
              abilities(company, :assign_hexes) do |ability|
                remove_mining_icons(ability.hexes)
              end
            end
          end
        end

        def get_location_name(hex_name)
          @hexes.find { |h| h.name == hex_name }.location_name
        end

        def remove_mining_icons(hexes_to_clear)
          @hexes
            .select { |hex| hexes_to_clear.include?(hex.name) }
            .each { |hex| hex.tile.icons = [] }
        end

        def upgrades_to?(from, to, _special = false, selected_company: nil)
          # Lumber terminal cannot be upgraded
          return false if from.name == '445'

          # If upgrading Montgomery (L5) to green, only M tile #443a is allowed
          return to.name == '443a' if from.color == :yellow && from.hex.name == 'L5'

          super
        end

        def float_corporation(corporation)
          @recently_floated << corporation

          super
        end

        def all_potential_upgrades(tile, tile_manifest: false, selected_company: nil)
          # Lumber terminal cannot be upgraded
          return [] if tile.name == '445'

          upgrades = super

          return upgrades unless tile_manifest

          # Tile manifest for yellow cities should show M tile as an option
          upgrades |= [@green_m_tile] if @green_m_tile && STANDARD_YELLOW_CITY_TILES.include?(tile.name)

          upgrades
        end

        def tile_lays(entity)
          return super if !@optional_rules&.include?(:double_yellow_first_or) ||
            !@recently_floated&.include?(entity)

          [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }]
        end

        private

        def bonuses_for_hex_on_route(ability, stops)
          stops.map do |stop|
            next unless ability.hexes.include?(stop.hex.id)

            { revenue: ability.amount, description: "Coal(#{stop.hex.name})" }
          end.compact
        end

        def bonuses_for_routes(routes)
          return [] if routes.empty?

          route_bonuses.map do |type, _description|
            next unless abilities(routes.first.corporation, type)

            possible_bonuses = routes.map { |r| bonus_for_route(r, type) }.compact
            best_bonus = possible_bonuses.max { |b| b[:revenue] }
            next unless best_bonus

            best_bonus
          end.compact
        end

        def bonus_for_route(route, type)
          revenue = Array(abilities(route.corporation, type)).sum do |ability|
            ability.hexes == (ability.hexes & route.hexes.map(&:name)) ? ability.amount : 0
          end

          return unless revenue.positive?

          { route: route, revenue: revenue, description: route_bonuses[type] }
        end

        def move_ln_corporation
          ln = corporation_by_id('L&N')
          previous_hex = hex_by_id('A4')
          old_tile = previous_hex.tile
          tile_string = 'offboard=revenue:yellow_40|brown_50;path=a:0,b:_0;path=a:1,b:_0'
          previous_hex.tile = Tile.from_code(old_tile.name, old_tile.color, tile_string)
          previous_hex.tile.location_name = 'Nashville'

          new_hex = hex_by_id('C4')
          new_hex.tile.add_reservation!(ln, 0, 0)

          ln.coordinates = 'C4'
        end

        def change_4t_to_hardrust
          @depot.trains
            .select { |t| t.name == '4' }
            .each { |t| change_to_hardrust(t) }
        end

        def change_to_hardrust(t)
          t.rusts_on = t.obsolete_on
          t.obsolete_on = nil
          t.variants.each { |_, v| v.merge!(rusts_on: t.rusts_on, obsolete_on: t.obsolete_on) }
        end
      end
    end
  end
end
