# frozen_string_literal: true

require_relative 'meta'
require_relative 'step/convert_to_national'
require_relative '../base'

module Engine
  module Game
    module G18OE
      class Game < Game::Base
        include_meta(G18OE::Meta)
        attr_accessor :minor_regional_order, :minor_available_regions, :minor_floated_regions, :regional_corps_floated,
                      :nationals_can_form, :nationals_formation_queue

        MARKET = [
          ['', '110', '120C', '135', '150', '165', '180', '200', '225', '250', '280', '310', '350', '390', '440', '490', '550'],
          %w[90p 100 110C 120 135 150 165 180 200 225 250 280 310 350 390 440 490],
          %w[80p 90 100C 110 120 135 150 165 180 200 225 250 280 310],
          %w[75p 80 90C 100 110 120 135 150 165 180 200],
          %w[70p 75 80C 90 100 110 120 135 150],
          %w[65p 70 75C 80 90 100 110],
          %w[60p 65 70 75 80],
          %w[50 60 65 70],
        ].freeze
        CERT_LIMIT = { 3 => 48, 4 => 36, 5 => 29, 6 => 24, 7 => 20 }.freeze
        STARTING_CASH = { 3 => 1735, 4 => 1300, 5 => 1040, 6 => 870, 7 => 745 }.freeze
        BANK_CASH = 54_000
        CAPITALIZATION = :incremental
        SELL_BUY_ORDER = :sell_buy
        MUST_SELL_IN_BLOCKS = false
        HOME_TOKEN_TIMING = :float
        TILE_UPGRADES_MUST_USE_MAX_EXITS = [:cities].freeze

        STOCKMARKET_COLORS = {
          par: :blue,
          convert_range: :red,
        }.freeze

        MARKET_TEXT = {
          par: 'Regional par values',
          convert_range: 'Major par values',
        }.freeze

        PHASES = [
          {
            name: '2',
            train_limit: { minor: 2, regional: 2, major: 4 },
            tiles: [:yellow],
            operating_rounds: 2,
          },
          {
            name: '3',
            on: '3',
            train_limit: { minor: 2, regional: 2, major: 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: { minor: 1, regional: 1, major: 3, national: 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: { minor: 1, regional: 1, major: 3, national: 4 },
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '6',
            train_limit: { major: 2, national: 3 },
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '7',
            on: '7+7',
            train_limit: { major: 2, national: 3 },
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
          },
          {
            name: '8',
            on: '8+8',
            train_limit: { major: 2, national: 3 },
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: '2+2',
            distance: [{ 'nodes' => ['town'], 'pay' => 2, 'visit' => 99 },
                       { 'nodes' => %w[city offboard town], 'pay' => 2, 'visit' => 2 }],
            price: 100,
            num: 5,
          },
          {
            name: '3',
            distance: [{ 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 },
                       { 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 }],
            price: 200,
            variants: [{
              name: '3+3',
              distance: [{ 'nodes' => ['town'], 'pay' => 3, 'visit' => 99 },
                         { 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 }],
              price: 225,
            }],
            num: 4,
          },
        ].freeze

        CORPORATIONS_TRACK_RIGHTS = {
          'LNWR' => 'UK',
          'GWR' => 'UK',
          'GSWR' => 'UK',
          'PLM' => 'FR',
          'MIDI' => 'FR',
          'OU' => 'FR',
          'BEL' => 'FR',
        }.freeze

        NATIONAL_REGION_HEXES = {
          'UK' => %w[D25 E24 E26 E28 F23 F25 F27 F29 G16 G18 G20 G24 G26 G28 H15 H17 H19 H21 H25 H27 H29 I14 I16 I18 I20 I26 I28
                     J13 J15 J17 J19 J23 J25 J27 J29 K22 K24 K26 K28 K30 L23 L25 L27 L29 L31 M22 M24 M26 M28 M30],
          'FR' => %w[N31 N33 N35 N37 O24 O28 O30 O32 O34 O36 O38 P19 P21 P23 P25 P27 P29 P31 P33 P35 P37 Q20 Q22 Q24 Q26 Q28 Q30
                     Q32 Q34 Q36 Q38 R23 R25 R27 R29 R31 R33 R35 R37 R39 S24 S26 S28 S30 S32 S34 S36 S38 T23 T25 T27 T29 T31 T33
                     T35 T37 U22 U24 U26 U28 U30 U32 U34 U36 U38 V21 V23 V25 V27 V29 V31 V33 V35 V37 W22 W24 W26 W28 W30 W32 W34
                     W36 W38 X25 X27 X29 X33 X35 X37 Y28 Z41], # plus Alger
        }.freeze

        TRACK_RIGHTS_COST = {
          'UK' => 40,
          'FR' => 20,
        }.freeze

        MAX_FLOATED_REGIONALS = 18

        # still need green+ OE specific track tiles
        TILES = {
          '3' => 14,
          '4' => 25,
          '5' => 25,
          '6' => 15,
          '7' => 14,
          '8' => 99,
          '9' => 99,
          '12' => 10,
          '13' => 8,
          '57' => 19,
          '58' => 25,
          '80' => 5,
          '81' => 5,
          '82' => 20,
          '83' => 20,
          '141' => 15,
          '142' => 15,
          '143' => 5,
          '144' => 5,
          '145' => 13,
          '146' => 21,
          '147' => 13,
          '201' => 9,
          '202' => 18,
          '205' => 17,
          '206' => 17,
          '207' => 12,
          '208' => 9,
          '544' => 8,
          '545' => 8,
          '546' => 7,
          '621' => 12,
          '622' => 9,
          'OE1' =>
            {
              'count' => 4,
              'color' => 'yellow',
              'code' => 'town=revenue:10;town=revenue:10;path=a:0,b:_0;path=a:_0,b:_1;path=a:_1,b:3',
            },
          'OE2' =>
            {
              'count' => 6,
              'color' => 'yellow',
              'code' => 'town=revenue:10;town=revenue:10;path=a:0,b:_0;path=a:_0,b:_1;path=a:_1,b:2',
            },
          'OE3' =>
            {
              'count' => 2,
              'color' => 'yellow',
              'code' => 'town=revenue:10;town=revenue:10;path=a:0,b:_0;path=a:_0,b:_1;path=a:_1,b:1',
            },
          'OE4' =>
            {
              'count' => 5,
              'color' => 'yellow',
              'code' => 'city=revenue:30;city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_2;label=ABP',
            },
          'OE5' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:_0,b:1;path=a:5,b:_1;path=a:_1,b:3;label=C',
            },
          'OE6' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:5,b:_0;path=a:2,b:_1;path=a:4,b:_1;label=L',
            },
          'OE7' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:4,b:_1;label=N',
            },
          'OE8' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:5,b:_1;label=S',
            },
          # 'OE9' => 3, green, double town
          # 'OE10' => 3, green, double town
          # 'OE11' => 3, green, double town
          'OE12' =>
            {
              'count' => 3,
              'color' => 'green',
              'code' => 'city=revenue:50;city=revenue:50;city=revenue:50;path=a:0,b:_0;path=a:_0,b:3;'\
                        'path=a:2,b:_1;path=a:_1,b:5;path=a:4,b:_2;path=a:_2,b:1;label=A',
            },
          'OE13' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:60;city=revenue:60;city=revenue:60;path=a:0,b:_0;path=a:_0,b:3;'\
                        'path=a:2,b:_1;path=a:_1,b:5;path=a:4,b:_2;path=a:_2,b:1;label=B',
            },
          'OE14' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:50;city=revenue:50,slots:2;path=a:0,b:_0;path=a:_0,b:1;path=a:5,b:_1;path=a:_1,b:3;label=C',
            },
          'OE15' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:60,slots:2;city=revenue:60,slots:2;path=a:1,b:_0;path=a:5,b:_0;'\
                        'path=a:2,b:_1;path=a:3,b:_1;path=a:4,b:_1;label=L',
            },
          'OE16' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:50,slots:2;city=revenue:50;path=a:1,b:_0;path=a:_0,b:3;path=a:4,b:_1;path=a:_1,b:2;label=N',
            },
          'OE17' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:50;city=revenue:50;city=revenue:50;path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_2;label=P',
            },
          'OE18' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:50;city=revenue:50,slots:2;path=a:0,b:_0;path=a:_0,b:2;path=a:5,b:_1;path=a:_1,b:3;label=S',
            },
          # 'OE20' => 3, brown, two towns
          # 'OE21' => 2, brown, two towns
          # 'OE22' => 6, brown, two towns
          'OE23' =>
            {
              'count' => 12,
              'color' => 'brown',
              'code' => 'city=revenue:40;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            },
          'OE24' =>
            {
              'count' => 20,
              'color' => 'brown',
              'code' => 'city=revenue:40;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0',
            },
          'OE25' =>
            {
              'count' => 12,
              'color' => 'brown',
              'code' => 'city=revenue:40;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            },
          'OE26' =>
            {
              'count' => 5,
              'color' => 'brown',
              'code' => 'city=revenue:80,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                        'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=ACS',
            },
          'OE27' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                        'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=B',
            },
          'OE28' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:90,slots:4;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=L',
            },
          'OE29' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:80,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=N',
            },
          'OE30' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:80;city=revenue:80;city=revenue:80;path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_1;'\
                        'path=a:3,b:_2;path=a:4,b:_2;path=a:5,b:_0;label=P',
            },
          'OE31' =>
            {
              'count' => 3,
              'color' => 'brown',
              'code' => 'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;label=Y',
            },
          'OE32' =>
            {
              'count' => 3,
              'color' => 'brown',
              'code' => 'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=Y',
            },
          'OE33' =>
            {
              'count' => 11,
              'color' => 'brown',
              'code' => 'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                        'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Y',
            },
          'OE34' =>
            {
              'count' => 5,
              'color' => 'gray',
              'code' => 'city=revenue:60;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0',
            },
          'OE35' =>
            {
              'count' => 6,
              'color' => 'gray',
              'code' => 'city=revenue:60;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            },
          'OE36' =>
            {
              'count' => 16,
              'color' => 'gray',
              'code' => 'city=revenue:60;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            },
          'OE37' =>
            {
              'count' => 5,
              'color' => 'gray',
              'code' => 'city=revenue:100,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                        'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=APS',
            },
          'OE38' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' => 'city=revenue:120,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                        'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=B',
            },
          'OE39' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' => 'city=revenue:100,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                        'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=B',
            },
          'OE40' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' => 'city=revenue:120,slots:4;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=L',
            },
          'OE41' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' => 'city=revenue:100,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=N',
            },
          'OE42' =>
            {
              'count' => 3,
              'color' => 'gray',
              'code' => 'city=revenue:80,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;label=Y',
            },
          'OE43' =>
            {
              'count' => 3,
              'color' => 'gray',
              'code' => 'city=revenue:80,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=Y',
            },
          'OE44' =>
            {
              'count' => 11,
              'color' => 'gray',
              'code' => 'city=revenue:80,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                        'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Y',
            },
        }.freeze

        def setup
          super
          @minor_regional_order = []
          @minor_available_regions = %w[UK UK FR FR] # this should be set per variant, big game will need extra logic
          @minor_floated_regions = {}
          @regional_corps_floated = 0
          @nationals_can_form = false
          @nationals_formation_queue = []
          @national_graph = Graph.new(self, home_as_token: true, no_blocking: true)
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def operating_order
          majors_and_nationals = @corporations.select { |c| c.floated? && %i[major national].include?(c.type) }
          @minor_regional_order + (majors_and_nationals - @minor_regional_order).sort
        end

        def graph_for_entity(entity)
          return @national_graph if entity.type == :national

          @graph
        end

        def token_graph_for_entity(entity)
          return @national_graph if entity.type == :national

          @graph
        end

        def nationals_forming?
          @nationals_can_form && @nationals_formation_queue.any?
        end

        def event_nationals_can_form!
          @log << '-- Event: Nationals may now form --'
          @nationals_can_form = true
          purchaser_index = @players.index(@round.current_entity&.owner) || 0
          @nationals_formation_queue = @players.rotate(purchaser_index).dup
        end

        def convert_to_national(corporation)
          @log << "#{corporation.name} converts to a national"

          # Treasury cash → bank
          corporation.spend(corporation.cash, @bank) if corporation.cash.positive?

          # Treasury shares → Open Market (may temporarily exceed 50% limit)
          corporation.shares_of(corporation).dup.each { |s| transfer_share(s, @share_pool) }

          # Remove all placed tokens from the map
          corporation.placed_tokens.dup.each(&:remove!)

          # Abandon merged minors (stub — full minor abandonment deferred)
          # Remove track rights, OE markers etc. (stub — not yet tracked in code)

          # Change company type to national
          corporation.type = :national

          # Set coordinates to all hexes in home zone for national graph virtual tokens
          zone = CORPORATIONS_TRACK_RIGHTS[corporation.id]
          corporation.coordinates = NATIONAL_REGION_HEXES[zone].dup

          # Retain all trains including rusted; discard excess vs phase limit (rusted first)
          enforce_national_train_limit(corporation)

          @graph.clear
          @national_graph.clear
        end

        def enforce_national_train_limit(corporation)
          limit = @phase.train_limit(corporation)
          return unless limit&.positive?

          trains = corporation.trains.sort_by { |t| t.rusted? ? 0 : 1 }
          while trains.size > limit
            train = trains.shift
            @depot.reclaim_train(train)
            @log << "#{corporation.name} discards a #{train.name} train"
          end
        end

        def national_revenue(entity)
          zone = CORPORATIONS_TRACK_RIGHTS[entity.id]
          zone_hexes = NATIONAL_REGION_HEXES[zone] || []

          all_cities = []
          all_towns = []
          zone_hexes.each do |hex_id|
            hex = hex_by_id(hex_id)
            next unless hex

            all_cities.concat(hex.tile.cities)
            all_towns.concat(hex.tile.towns)
          end

          connected = @national_graph.connected_nodes(entity) || {}
          linked_cities   = all_cities.select { |c| connected[c] }
          linked_towns    = all_towns.select  { |t| connected[t] }
          unlinked_cities = all_cities - linked_cities
          unlinked_towns  = all_towns  - linked_towns

          city_cap, town_cap = national_capacity(entity)
          revenue = 0

          # Linked cities at face value (best revenue first)
          linked_cities.sort_by { |c| -(c.revenue[@phase.name] || 0) }.first(city_cap).each do |c|
            revenue += c.revenue[@phase.name] || 0
          end
          city_cap -= [linked_cities.size, city_cap].min
          city_cap -= [unlinked_cities.size, city_cap].min # unlinked consume capacity at £0
          revenue += city_cap * 60                         # remaining capacity at £60/city

          # Same logic for towns
          linked_towns.sort_by { |t| -(t.revenue || 0) }.first(town_cap).each do |t|
            revenue += t.revenue || 0
          end
          town_cap -= [linked_towns.size, town_cap].min
          town_cap -= [unlinked_towns.size, town_cap].min
          revenue += town_cap * 10 # remaining capacity at £10/town

          # Inherent Pullman: +£10 × level of highest non-rusted train
          best = entity.trains.reject(&:rusted?).max_by { |t| t.name.match(/\d+/).to_s.to_i }
          revenue += best.name.match(/\d+/).to_s.to_i * 10 if best

          revenue
        end

        def national_capacity(entity)
          city_cap = 0
          town_cap = 0
          entity.trains.reject(&:rusted?).each do |t|
            t.distance.each do |d|
              nodes = d['nodes'] || []
              if nodes.include?('city') || nodes.include?('offboard')
                city_cap += d['pay'].to_i
              elsif nodes == ['town']
                town_cap += d['pay'].to_i
              end
            end
          end
          [city_cap, town_cap]
        end

        def routes_revenue(routes)
          entity = routes.first&.train&.owner
          return national_revenue(entity) if entity&.type == :national

          super
        end

        def tile_cost(tile, entity, hex)
          # Nationals are exempt from all terrain tile placement costs
          return 0 if entity&.type == :national

          super
        end

        def rust?(train, purchased_train)
          # Nationals retain all trains — never rust trains owned by a national
          return false if train.owner&.type == :national

          super
        end

        def hex_within_national_region?(entity, hex)
          NATIONAL_REGION_HEXES[CORPORATIONS_TRACK_RIGHTS[entity.id] || @minor_floated_regions[entity.id]].include?(hex.name)
        end

        def home_token_locations(corporation)
          # if minor, choose non-metropolis hex
          # if regional, starts on reserved hex

          available_regions = NATIONAL_REGION_HEXES.select { |key, _value| @minor_available_regions.include?(key) }
          region_hexes = available_regions.values.flatten

          @hexes
            .select { |hex| region_hexes.include?(hex.name.to_s) }
            .select { |hex| hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) } }
            .reject { |hex| metropolis_hex?(hex) }
        end

        def metropolis_hex?(hex)
          %w[A56 B41 C74 F87 K26 M28 M50 Q30 R55 Y14 AA82 BB51].include?(hex.name.to_s)
        end

        def metropolis_tile?(tile)
          %w[OE4 OE5 OE6 OE7 OE8 OE12 OE13 OE14 OE15 OE16 OE17
             OE18 OE26 OE27 OE28 OE29 OE30 OE37 OE38 OE39 OE40 OE41].include?(tile.name.to_s)
        end

        def must_buy_train?(entity)
          # must buy the reserved 2+2, otherwise only majors must buy trains
          # return unless entity.type == 'major'
          return false if depot.depot_trains.first&.name != '2+2' && entity.type != :major

          super
        end

        def upgrades_to_correct_label?(from, to)
          return true if from.label == to.label
          return false if from.label && !to.label

          case from.hex.name
          when 'K26', 'Y14', 'R55'
            to.label.to_s.include?('A')
          when 'M50'
            to.label.to_s.include?('B')
          when 'AA82'
            to.label.to_s.include?('C')
          when 'Q30'
            to.label.to_s.include?('P')
          when 'C74'
            to.label.to_s.include?('S')
          end
        end

        def company_becomes_minor?(company)
          corp = @corporations.find { |c| c.name == company.sym }
          return false unless corp

          corp.type == :minor
        end

        def form_button_text(_entity)
          'Float'
        end

        def after_par(corporation)
          super
          # Spend the cost of the regionals track rights zone
          region = NATIONAL_REGION_HEXES.select { |_key, value| value.include?(corporation.coordinates) }.keys.first
          corporation.spend(TRACK_RIGHTS_COST[region], @bank)
        end

        def issuable_shares(entity)
          return [] if !entity.corporation? || entity.type != :major

          bundles_for_corporation(entity, entity)
            .select { |bundle| @share_pool.fit_in_bank?(bundle) }
        end

        def value_for_dumpable(player, corporation)
          return 0 if corporation.type == :regional

          super
        end

        def stock_round
          Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G18OE::Step::HomeToken,
            G18OE::Step::BuySellParShares,
          ])
        end

        def new_auction_round
          Round::Auction.new(self, [
            G18OE::Step::WaterfallAuction,
          ])
        end

        def operating_round(round_num)
          Round::G18OE::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::DiscardTrain,
            Engine::Step::HomeToken,
            G18OE::Step::Track,
            G18OE::Step::Token,
            Engine::Step::Route,
            G18OE::Step::Dividend,
            G18OE::Step::BuyTrain,
            G18OE::Step::ConvertToNational,
            Engine::Step::IssueShares,
          ], round_num: round_num)
        end
      end
    end
  end
end
