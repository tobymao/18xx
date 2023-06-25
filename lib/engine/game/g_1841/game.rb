# frozen_string_literal: true

require_relative '../base'
require_relative 'meta'
require_relative 'entities'
require_relative 'map'
require_relative 'stock_market'

module Engine
  module Game
    module G1841
      class Game < Game::Base
        include_meta(G1841::Meta)
        include Entities
        include Map

        attr_reader :corporation_info

        register_colors(black: '#16190e',
                        blue: '#0189d1',
                        brown: '#7b352a',
                        gray: '#7c7b8c',
                        green: '#3c7b5c',
                        olive: '#808000',
                        lightGreen: '#009a54ff',
                        lightBlue: '#4cb5d2',
                        lightishBlue: '#0097df',
                        teal: '#009595',
                        orange: '#d75500',
                        magenta: '#d30869',
                        purple: '#772282',
                        red: '#ef4223',
                        rose: '#b7274c',
                        coral: '#f3716d',
                        white: '#fff36b',
                        navy: '#000080',
                        cream: '#fffdd0',
                        yellow: '#ffdea8')

        CURRENCY_FORMAT_STR = 'L.%s'
        BANK_CASH = 14_400
        CERT_LIMIT = { 3 => 21, 4 => 16, 5 => 13, 6 => 11, 7 => 10, 8 => 9 }.freeze
        STARTING_CASH = { 3 => 1120, 4 => 840, 5 => 672, 7 => 480, 8 => 420 }.freeze
        CAPITALIZATION = :incremental
        MUST_SELL_IN_BLOCKS = false
        SELL_MOVEMENT = :down_share
        SOLD_OUT_INCREASE = true
        POOL_SHARE_DROP = :one
        TRACK_RESTRICTION = :semi_restrictive

        MARKET = [
          %w[72 83 95 107 120 133 147 164 182 202 224m 248 276 306 340x 377n 419 465 516],
          %w[63 72 82 93 104 116 128 142 158 175 195m 216x 240 266 295 328n 365 404 449],
          %w[57 66 75 84 95 105 117 129 144p 159 177m 196 218 242 269 298n 331 367 408],
          %w[54 62 71 80 90 100p 111 123 137 152 169m 187 208 230 256 284n],
          %w[52 59 68p 77 86 95 106 117 130 145 160m 178 198 219],
          %w[47 54 62 70 78 87 96 107 118 131 146m 162 180],
          %w[41 47 54 61 68 75 84 93 103 114 127m 141],
          %w[34 39 45 50 57 63 70 77 86 95 106m],
          %w[27 31 36 40 45 50 56 62 69 76],
          %w[21 24 27 31 35 39 43 48 53],
          %w[16 18 20 23 26 29 32 35],
          %w[11 13 15 16 18 20 23],
          %w[8 9 10 11 13 14],
        ].freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(par_1: 'Major Corporation Par',
                                              par: 'Major/Minor Corporation Par',
                                              max_price: 'Maximum price for a minor',
                                              max_price_1: 'Maximum price before phase 8').freeze

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(par_1: :green,
                                                            max_price: :orange,
                                                            max_price_1: :blue).freeze

        PHASES = [
          {
            name: '2',
            train_limit: { minor: 2, major: 4 },
            tiles: %i[yellow],
            operating_rounds: 1,
            status: %w[no_border_crossing one_tile_per_base],
          },
          {
            name: '3',
            on: '3',
            train_limit: { minor: 2, major: 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[one_tile_per_base_max_2 start_non_hist],
          },
          {
            name: '4',
            on: '4',
            train_limit: { minor: 2, major: 3 },
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[one_tile_per_base_max_2 start_non_hist concessions_removed],
            events: [{ 'type' => 'phase4_regions' }],
          },
          {
            name: '5',
            on: '5',
            train_limit: { minor: 2, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: %w[one_tile_per_or start_non_hist],
            events: [{ 'type' => 'phase5_regions' }],
          },
          {
            name: '6',
            on: '6',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: %w[one_tile_per_or start_non_hist],
          },
          {
            name: '7',
            on: '7',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: %w[one_tile_per_or start_non_hist],
          },
          {
            name: '8',
            on: '8',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: %w[one_tile_per_or start_non_hist],
          },
        ].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'phase4_regions' => ['Phase4 Regions',
                               'Conservative Zone border is eliminated; The Austrian possesions are limited to Veneto'],
          'phase5_regions' => ['Phase5 Regions',
                               'Austrian possessions are eliminated; 1859-1866 Austrian border is deleted'],
        )

        TRAINS = [
          {
            name: '2',
            distance: [{ 'nodes' => %w[city offboard pass], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 100,
            rusts_on: '4',
            num: 8,
          },
          {
            name: '3',
            distance: [{ 'nodes' => %w[city offboard pass], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 200,
            rusts_on: '5',
            num: 6,
          },
          {
            name: '4',
            distance: [{ 'nodes' => %w[city offboard pass], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 350,
            rusts_on: '7',
            num: 4,
          },
          {
            name: '5',
            distance: [{ 'nodes' => %w[city offboard pass], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 550,
            num: 2,
          },
          {
            name: '6',
            distance: [{ 'nodes' => %w[city offboard pass], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 800,
            num: 2,
          },
          {
            name: '7',
            distance: [{ 'nodes' => %w[city offboard pass], 'pay' => 7, 'visit' => 7 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 110,
            num: 2,
          },
          {
            name: '8',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 8, 'visit' => 8 },
                       { 'nodes' => %w[town pass], 'pay' => 99, 'visit' => 99 }],
            price: 1450,
            num: 7,
          },
        ].freeze

        HOME_TOKEN_TIMING = nil
        SELL_BUY_ORDER = :sell_buy
        BANKRUPTCY_ENDS_GAME_AFTER = :all_but_one

        GAME_END_CHECK = { bankrupt: :immediate, stock_market: :immediate, bank: :current_or }.freeze

        # Per railhead/base (needs special code in track step)
        TILE_LAYS = [
          { lay: true, upgrade: true, cost: 0 },
          { lay: true, upgrade: true, cost: 0, cannot_reuse_same_hex: true  },
          { lay: true, upgrade: true, cost: 0, cannot_reuse_same_hex: true  },
          { lay: true, upgrade: true, cost: 0, cannot_reuse_same_hex: true  },
          { lay: true, upgrade: true, cost: 0, cannot_reuse_same_hex: true  },
        ].freeze

        REAL_PHASE_TO_REV_PHASE = {
          '2' => :white,
          '3' => :white,
          '4' => :gray,
          '5' => :gray,
          '6' => :black,
          '7' => :black,
          '8' => :black,
        }.freeze

        CERT_LIMIT_INCLUDES_PRIVATES = false
        MAX_CORPORATE_CERTS = 5

        def init_graph
          Graph.new(self, check_tokens: true)
        end

        # only allow president shares in market on EMR/Frozen
        def init_share_pool
          SharePool.new(self, allow_president_sale: true)
        end

        # load non-standard corporation info
        def load_corporation_extended
          game_corporations.to_h do |cm|
            corp = @corporations.find { |m| m.name == cm[:sym] }
            [corp, { historical: cm[:historical], startable: cm[:startable] }]
          end
        end

        def init_stock_market
          G1841::StockMarket.new(game_market, self.class::CERT_LIMIT_TYPES,
                                 multiple_buy_types: self.class::MULTIPLE_BUY_TYPES, game: self)
        end

        def setup
          # used for tokens and for track in phase 2
          @region_graph = Graph.new(self, check_tokens: true, check_regions: true)
          @selected_graph = @region_graph

          @corporation_info = load_corporation_extended
          modify_regions(2, true)
          @border_paths = nil
          update_frozen!
          corporations.each { |corp| @corporation_info[corp][:operated] = false }
        end

        def select_track_graph
          @selected_graph = if @phase.name == '2'
                              @region_graph
                            else
                              @graph
                            end
        end

        def select_token_graph
          @selected_graph = @region_graph
        end

        def graph_for_entity(_entity)
          @selected_graph
        end

        def token_graph_for_entity(_entity)
          @region_graph
        end

        def clear_graph_for_entity(entity)
          super
          @border_paths = nil
        end

        def clear_token_graph_for_entity(entity)
          super
          @border_paths = nil
        end

        def event_phase4_regions!
          modify_regions(2, false)
          modify_regions(4, true)
          @border_paths = nil
          @log << 'Border change: Conservative Zone border is eliminated; The Austrian possesions are limited to Veneto'
        end

        def event_phase5_regions!
          modify_regions(4, false)
          modify_regions(5, true)
          @border_paths = nil
          @log << 'Border change: Austrian possessions are eliminated; 1859-1866 Austrian border is deleted'
        end

        def modify_regions(phase, add)
          REGIONS_BY_PHASE[phase].each do |coord, edges|
            hex = hex_by_id(coord)
            edges.each do |edge|
              if add
                add_region(hex, edge)
                add_region(hex.neighbors[edge], Hex.invert(edge))
              else
                remove_region(hex, edge)
                remover_region(hex.neighbors[edge], Hex.invert(edge))
              end
            end
          end
        end

        def add_region(hex, edge)
          remove_region(hex, edge)
          hex.tile.borders << Part::Border.new(edge, 'province', nil, 'red')
        end

        def remove_region(hex, edge)
          old = hex.tile.borders.find { |b| b.edge == edge }
          hex.tile.borders.delete(old) if old
        end

        def calc_border_paths
          border_paths = {}
          @hexes.each do |hex|
            hex_border_edges = hex.tile.borders.select { |b| b.type == :province }.map(&:edge)
            next if hex_border_edges.empty?

            hex.tile.paths.each do |path|
              border_paths[path] = true unless (path.edges & hex_border_edges).empty?
            end
          end
          border_paths
        end

        def border_paths
          @border_paths ||= calc_border_paths
        end

        def graph_border_paths(_entity)
          border_paths
        end

        def region_border?(hex, edge)
          hex.tile.borders.any? { |b| (b.type == :province) && (b.edge == edge) }
        end

        def major?(entity)
          entity&.corporation? && (entity.type == :major)
        end

        def historical?(entity)
          entity&.corporation? && @corporation_info[entity][:historical]
        end

        # returns a list of tokens on cities for this corporation
        def railheads(entity)
          return [] unless entity&.corporation?

          entity.tokens.select { |t| t.used && t.city && !t.city.pass? }
        end

        def skip_token?(_graph, _corporation, city)
          city.pass?
        end

        def all_token_cities
          ZONES.flatten
        end

        def austrian_cities
          if @phase.name.to_i < 4
            (ZONES[3] | ZONES[4])
          else
            []
          end
        end

        def reserved_cities
          if @phase.name.to_i < 4
            HISTORICAL_CITIES
          else
            []
          end
        end

        def home_token_locations(corporation)
          if corporation.name == 'SFMA'
            [hex_by_id(corporation.coordinates)]
          elsif major?(corporation)
            # major non-historical
            if corporation.tokens.first&.used
              home_hex = corporation.tokens.first.city.hex.name
              zone = ZONES.index { |z| z.include?(home_hex) }
              # need to account for regions merging on and after phase 4
              major_pool = if @phase.name.to_i < 4
                             ZONES[zone].dup
                           elsif @phase.name.to_i == 4
                             zone < 4 ? (all_token_cities - ZONE[4]) : ZONE[4].dup
                           else
                             all_token_cities
                           end
              major_pool -= [home_hex]
            else
              major_pool = all_token_cities
            end
            (major_pool - reserved_cities - austrian_cities).map { |h| hex_by_id(h) }
          else
            # minor non-historical
            minor_pool = (all_token_cities - reserved_cities - austrian_cities - MAJOR_CITIES).map { |h| hex_by_id(h) }
            minor_pool.reject { |h| h.tile.cities.any?(&:tokened?) }
          end
        end

        # SFMA and non-historical corps are dealt with elsewhere
        def place_home_token(corporation)
          Array(corporation.coordinates).each do |coord|
            hex = hex_by_id(coord)
            tile = hex&.tile
            cities = tile.cities
            city = cities.find { |c| c.reserved_by?(corporation) } || cities.first
            token = corporation.find_token_by_type

            @log << "#{corporation.name} places a token on #{hex.name}"
            city.place_token(corporation, token)
          end
          @graph.clear
        end

        # from https://www.redblobgames.com/grids/hexagons
        def doubleheight_coordinates(hex)
          [hex.id[1..-1].to_i, hex.id[0].ord - 'A'.ord] # works because AZ isn't close to a home city
        end

        def hex_distance(hex_a, hex_b)
          x_a, y_a = doubleheight_coordinates(hex_a)
          x_b, y_b = doubleheight_coordinates(hex_b)

          # from https://www.redblobgames.com/grids/hexagons#distances
          # this game essentially uses double-height coordinates
          dx = (x_a - x_b).abs
          dy = (y_a - y_b).abs
          distance = hex_a == hex_b ? -1 : [0, dx + [0, (dy - dx) / 2].max - 1].max
          distance + 1
        end

        def tile_laid_at_exit?(hex)
          hex.tile.exits.any? do |e|
            next if hex.tile.borders.any? { |b| b.edge == e && ((b.type == :impassable) || (b.type == :province)) }

            neighbor = hex_neighbor(hex, e)
            neighbor && !neighbor.tile.preprinted
          end
        end

        def hex_connected?(hex)
          !hex.tile.preprinted ||                                  # any tile has been laid here
            (!hex.tile.paths.empty? && !hex.tile.cities.empty?) || # pre-printed with track and a city
            (!hex.tile.paths.empty? && tile_laid_at_exit?(hex)) # pre-printed with track and tile connecting to it
        end

        def search_hexes(current_hex, hex_list, start_hex)
          hex_list << current_hex
          distance = hex_distance(current_hex, start_hex)
          @min_connected_distance = distance if hex_connected?(current_hex) && (distance < @min_connected_distance)
          return if distance >= 2

          6.times do |edge|
            neighbor = hex_neighbor(current_hex, edge)
            next unless neighbor
            next if hex_list.include?(neighbor)
            next if hex_distance(neighbor, start_hex) > 2
            next if current_hex.tile.borders.any? { |b| b.edge == edge && ((b.type == :impassable) || (b.type == :province)) }

            search_hexes(neighbor, hex_list, start_hex)
          end
        end

        def hex_price(token_hex)
          hex_list = []
          @min_connected_distance = 3
          search_hexes(token_hex, hex_list, token_hex)
          case @min_connected_distance
          when 3
            25
          when 2
            50
          when 1
            100
          else
            200
          end
        end

        def token_price(corporation)
          if historical?(corporation)
            50
          else
            price = hex_price(corporation.tokens.first.city.hex)
            price = [price, hex_price(corporation.tokens[1].city.hex)].max if corporation.tokens[1]&.used
            price
          end
        end

        def purchase_tokens!(corporation, count, price)
          min = major?(corporation) ? 2 : 1
          (count - min).times { corporation.tokens << Token.new(corporation, price: 0) }
          corporation.spend((cost = price * count), @bank)
          @log << "#{corporation.name} buys #{count} tokens for #{format_currency(cost)}"
        end

        def legal_tile_rotation?(_entity, _hex, tile)
          return true unless NO_ROTATION_TILES.include?(tile.name)

          tile.rotation.zero?
        end

        def transfer_share(share, new_owner)
          corp = share.corporation
          corp.share_holders[share.owner] -= share.percent
          corp.share_holders[new_owner] += share.percent
          share.owner.shares_by_corporation[corp].delete(share)
          new_owner.shares_by_corporation[corp] << share
          share.owner = new_owner
        end

        def ipo_name(_corp)
          'IPO'
        end

        # FIXME
        def corporation_available?(corp)
          super
        end

        # FIXME
        def can_par?(corporation, entity)
          return false unless corporation_available?(corporation)

          super
        end

        def stock_round
          G1841::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G1841::Step::HomeToken,
            G1841::Step::BuyTokens,
            G1841::Step::BuySellParShares,
          ])
        end

        # FIXME
        def operating_round(round_num)
          G1841::Round::Operating.new(self, [
            G1841::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G1841::Step::Dividend,
            # G1841::Step::BuyToken,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            G1841::Step::HomeToken,
            G1841::Step::BuyTokens,
            G1841::Step::CorporateBuySellParShares,
            # G1841::Step::Merge,
            # G1841::Step::Transform,
          ], round_num: round_num)
        end

        # implement non-standard offboard colors
        def game_route_revenue(stop, phase, train)
          return 0 unless stop

          if stop.offboard?
            stop.revenue[REAL_PHASE_TO_REV_PHASE[phase.name]]
          else
            stop.route_revenue(phase, train)
          end
        end

        def revenue_for(route, stops)
          stops.sum { |stop| game_route_revenue(stop, route.phase, route.train) }
        end

        # route must have at least two cities, non-port towns or offboards
        # - passes and ports don't count
        def check_other(route)
          required_stops = route.visited_stops.count do |stop|
            !stop.pass? && !(stop.town? && stop.tile.icons.any? { |i| i.name == 'port' })
          end
          raise GameError, 'Route must have at least 2 cities, non-port towns or offboards' unless required_stops > 1
        end

        # return a list of owners from the current corporation to a human (or the share pool)
        # return nil if circular chain of ownership
        def chain_of_control(entity)
          return [entity] unless entity&.corporation?

          owner = entity&.owner
          chain = [owner]
          while owner&.corporation?
            owner = owner&.owner
            if chain.include?(owner)
              chain << share_pool
              return chain
            end

            chain << owner
          end
          chain
        end

        # find the human in control if there is one, or the share pool if not
        def controller(entity)
          return entity unless entity.corporation?

          chain_of_control(entity)&.last
        end

        # return list of corporations controlled by a given player
        def controlled_corporations(entity)
          return [] unless entity&.player?

          controlled = []
          corporations.each do |corp|
            next if controlled.include?(corp)

            controlled << corp if controller(corp) == entity
          end
          controlled
        end

        def in_chain?(entity1, entity2)
          chain_of_control(entity1).include?(entity2)
        end

        def player_controlled_percentage(buyer, corporation)
          human = controller(buyer)
          total_percent = human.common_percent_of(corporation)
          controlled_corporations(human).each do |c|
            next if c == corporation

            total_percent += c.common_percent_of(corporation)
          end
          total_percent
        end

        def acting_for_entity(entity)
          return entity if entity&.player?
          return controller(entity) if entity&.corporation?

          super
        end

        def frozen?(entity)
          entity.corporation? && @corporation_info[entity][:frozen]
        end

        def frozen_corporations
          corporations.select { |corp| frozen?(corp) }
        end

        def update_frozen!
          corporations.each do |corp|
            frozen = corp.ipoed && !controller(corp)&.player?
            @log << "#{corp.name} is no longer frozen" if frozen?(corp) && !frozen
            @log << "#{corp.name} is now frozen" if !frozen?(corp) && frozen
            @corporation_info[corp][:frozen] = frozen
          end
        end

        # A corp is not considered to have operated until the end of it's first OR
        def done_operating!(entity)
          return unless entity&.corporation?

          @log << "#{entity.name} has finished operating for the first time" unless operated?(entity)

          @corporation_info[entity][:operated] = true
        end

        def operated?(entity)
          return nil unless entity&.corporation?

          @corporation_info[entity][:operated]
        end

        def check_sale_timing(_entity, bundle)
          operated?(bundle.corporation)
        end

        def num_certs(entity)
          return super unless entity&.corporation?

          entity.shares.sum do |s|
            (s.corporation != entity) && s.corporation.counts_for_limit && s.counts_for_limit ? s.cert_size : 0
          end
        end

        def cert_limit(entity)
          return super unless entity&.corporation?

          MAX_CORPORATE_CERTS
        end

        def corporations_can_ipo?
          true
        end

        def separate_treasury?
          true
        end

        def player_sort(entities)
          entities.sort_by { |entity| [operating_order.index(entity) || Float::INFINITY, entity.name] }
            .group_by { |e| acting_for_entity(e) }
        end

        def possible_presidents
          players.reject(&:bankrupt) + corporations.select(&:floated?).reject(&:closed?).sort
        end

        # for 1841, this means frozen
        def receivership_corporations
          frozen_corporations
        end

        def status_str(corp)
          return unless frozen?(corp)

          'FROZEN'
        end
      end
    end
  end
end
