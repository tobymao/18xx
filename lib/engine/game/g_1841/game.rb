# frozen_string_literal: true

require_relative '../base'
require_relative 'meta'
require_relative 'entities'
require_relative 'map'
require_relative 'stock_market'
require_relative '../cities_plus_towns_route_distance_str'

module Engine
  module Game
    module G1841
      class Game < Game::Base
        include_meta(G1841::Meta)
        include CitiesPlusTownsRouteDistanceStr
        include Entities
        include Map

        attr_reader :corporation_info, :done_this_round, :transform_state

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

        BANK_CASH_NORMAL = 14_400
        BANK_CASH_LITE = 10_900

        def bank_starting_cash
          lite? ? self.class::BANK_CASH_LITE : self.class::BANK_CASH_NORMAL
        end

        STARTING_CASH_NORMAL = { 3 => 1120, 4 => 840, 5 => 672, 6 => 560, 7 => 480, 8 => 420 }.freeze
        STARTING_CASH_LITE = { 3 => 840, 4 => 630, 5 => 504, 6 => 420 }.freeze
        def init_starting_cash(players, bank)
          cash = (lite? ? STARTING_CASH_LITE : STARTING_CASH_NORMAL)[players.size]
          players.each { |player| bank.spend(cash, player) }
        end

        CERT_LIMIT = { 3 => 21, 4 => 16, 5 => 13, 6 => 11, 7 => 10, 8 => 9 }.freeze
        CAPITALIZATION = :incremental
        MUST_SELL_IN_BLOCKS = false
        SELL_MOVEMENT = :down_share
        SELL_AFTER = :operate
        SOLD_OUT_INCREASE = true
        POOL_SHARE_DROP = :down_block
        TRACK_RESTRICTION = :semi_restrictive
        MIN_BID_INCREMENT = 5

        MARKET = [
          %w[72 83 95 107 120 133 147 164 182 202 224m 248 276 306 340x 377n 419 465 516e],
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
          },
          {
            name: '5',
            on: '5',
            train_limit: { minor: 2, major: 3 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: %w[one_tile_per_or start_non_hist],
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

        EVENTS_TEXT = {
          'close_companies' => ['Concessions Close',
                                'All concessions are discarded from the game'],
          'phase4_regions' => ['Phase4 Regions',
                               'Conservative Zone border is eliminated; The Austrian possesions are limited to Veneto'],
          'ferd_secession' => ['Ferdinandea Secession',
                               'The IRSFF is broken into two corporations'],
          'tuscan_merge' => ['Tuscan Merge',
                             'Corporations in Tuscany are merged together'],
          'phase5_regions' => ['Phase5 Regions',
                               'Austrian possessions are eliminated; 1859-1866 Austrian border is deleted'],
        }.freeze

        def game_trains
          trains = [
            {
              name: '2',
              distance: [{ 'nodes' => %w[city offboard pass], 'pay' => 2, 'visit' => 2 },
                         { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
              price: 100,
              rusts_on: '4',
              num: lite? ? 6 : 8,
            },
            {
              name: '3',
              distance: [{ 'nodes' => %w[city offboard pass], 'pay' => 3, 'visit' => 3 },
                         { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
              price: 200,
              rusts_on: '5',
              num: lite? ? 5 : 6,
            },
          ]

          trains << if lite?
                      {
                        name: '4',
                        distance: [{ 'nodes' => %w[city offboard pass], 'pay' => 4, 'visit' => 4 },
                                   { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                        price: 350,
                        rusts_on: '7',
                        num: 3,
                        events: [{ 'type' => 'close_companies' },
                                 { 'type' => 'phase4_regions' },
                                 { 'type' => 'ferd_secession' }],
                      }
                    else
                      {
                        name: '4',
                        distance: [{ 'nodes' => %w[city offboard pass], 'pay' => 4, 'visit' => 4 },
                                   { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                        price: 350,
                        rusts_on: '7',
                        num: 4,
                        events: [{ 'type' => 'close_companies' },
                                 { 'type' => 'phase4_regions' },
                                 { 'type' => 'ferd_secession' },
                                 { 'type' => 'tuscan_merge' }],
                      }
                    end

          trains.concat([
            {
              name: '5',
              distance: [{ 'nodes' => %w[city offboard pass], 'pay' => 5, 'visit' => 5 },
                         { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
              price: 550,
              rusts_on: '8',
              num: lite? ? 2 : 3,
              events: [{ 'type' => 'phase5_regions' }],
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
              price: 1100,
              num: 2,
            },
            {
              name: '8',
              distance: [{ 'nodes' => %w[city offboard], 'pay' => 8, 'visit' => 8 },
                         { 'nodes' => %w[town pass], 'pay' => 99, 'visit' => 99 }],
              price: 1450,
              num: 7,
            },
          ])

          trains
        end

        HOME_TOKEN_TIMING = nil
        SELL_BUY_ORDER = :sell_buy
        BANKRUPTCY_ENDS_GAME_AFTER = :all_but_one
        MUST_EMERGENCY_ISSUE_BEFORE_EBUY = true

        GAME_END_CHECK = { bankrupt: :immediate, bank: :current_or, stock_market: :current_turn, offboards: :current_turn }.freeze

        GAME_END_TIMING_PRIORITY = %i[immediate current_turn current_or].freeze

        GAME_END_REASONS_TEXT = {
          bankrupt: 'player is bankrupt', # this is prefixed in the UI
          bank: 'The bank runs out of money',
          stock_market: 'Corporation enters end game trigger on stock market',
          offboards: 'All offboards are connected to a city',
        }.freeze

        GAME_END_DESCRIPTION_REASON_MAP_TEXT = {
          bank: 'Bank Broken',
          bankrupt: 'Bankruptcy',
          stock_market: 'Company hit max stock value',
          offboards: 'All offboards are connected to a city',
        }.freeze
        GAME_END_REASONS_TIMING_TEXT = {
          immediate: 'Immediately',
          current_or: 'Next end of an OR',
          current_turn: 'End of an OR turn or end of a SR',
        }.freeze

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

        BUY_SHARE_FROM_OTHER_PLAYER = true
        CERT_LIMIT_INCLUDES_PRIVATES = false
        MAX_CORPORATE_CERTS = 5
        BANKRUPTCY_LOAN = 500
        XFORM_REQ_TOKEN_COST = 50
        XFORM_OPT_TOKEN_COST = 100
        SECESSION_OPT_TOKEN_COST = 50
        RIGHTMOST_MINOR_COLUMN = 10

        def init_graph
          Graph.new(self, check_tokens: true)
        end

        # only allow president shares in market on EMR/Frozen
        def init_share_pool
          SharePool.new(self, allow_president_sale: true, no_rebundle_president_buy: true)
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

          @merger_state = nil
          @merger_share_price = nil
          @done_this_round = {}

          @transform_state = nil
          @secession_state = nil
          @tuscan_merge_state = nil

          @loans = Hash.new { |h, k| h[k] = 0 }
          init_offboard_list
        end

        def version
          @version ||= @optional_rules&.include?(:version_1) ? 1 : 2
        end

        def select_track_graph
          @selected_graph = if @phase.name.to_i == 2
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

        def clear_graph_for_entity(_entity)
          @graph.clear
          @region_graph.clear
          @border_paths = nil
        end

        def event_phase4_regions!
          modify_regions(2, false)
          modify_regions(4, true)
          @border_paths = nil
          @log << 'Border change: Conservative Zone border is eliminated; The Austrian possesions are limited to Veneto'
        end

        def event_ferd_secession!
          irsff = corporation_by_id('IRSFF')
          sb = corporation_by_id(version == 2 ? 'SB' : 'SFV')
          sfl = corporation_by_id('SFL')

          unless irsff.floated?
            @log << '-- Event: The Ferdinandea Secession will not occur - IRSFF is not active --'
            sb.close!
            sfl.close!
            return
          end

          # see if Milano and Venezia are connected by any legal route (i.e. for any corporation)
          milano = irsff.tokens.find { |t| t.city&.hex&.id == 'F8' }&.city
          venezia = irsff.tokens.find { |t| t.city&.hex&.id == 'F16' }&.city

          # any? vs. find ???
          connected = corporations.find do |corp|
            railheads(corp).map(&:city).find do |city|
              nodes = @graph.connected_nodes_by_token(corp, city)
              nodes.include?(milano) && nodes.include?(venezia)
            end
          end
          if connected
            @log << '-- Event: The Ferdinandea Secession will not occur - Milano and Venezia are connected --'
            sb.close!
            sfl.close!
            return
          end
          @log << '-- Event: The Ferdinandea Secession begins - Milano and Venezia are not connected --'
          secession_start(irsff, sb, sfl)
        end

        def find_holding_corp
          @corporations.find { |c| major?(c) && !historical?(c) && !c.closed? && !c.floated? } ||
            corporation_by_id('Holding')
        end

        def event_tuscan_merge!
          if @secession_state
            @tuscan_merge_state = :deferred
            return
          end

          sflp = corporation_by_id('SFLP')
          ssfl = corporation_by_id('SSFL')
          sfli = corporation_by_id('SFLi')
          holding = find_holding_corp

          count = 0
          count += 1 if sflp.floated?
          count += 1 if sfma.floated?
          count += 1 if ssfl.floated?

          if count < 2
            @log << '-- Event: The Tuscan Merge will not occur - 2 or more Tuscan corporations are not active --'
            sfli.close!
            return
          end

          sflp_idx = @round.entities.find_index(sflp)
          sfma_idx = @round.entities.find_index(sfma)
          ssfl_idx = @round.entities.find_index(ssfl)

          will_run = (version == 2) || sfli_run_variant?
          will_run = false if sflp_idx && sflp_idx <= @round.entity_index
          will_run = false if sfma_idx && sfma_idx <= @round.entity_index
          will_run = false if ssfl_idx && ssfl_idx <= @round.entity_index

          @log << '-- Event: The Tuscan Merge begins --'
          tuscan_merge_start(sflp, sfma, ssfl, sfli, holding, will_run)
        end

        def event_phase5_regions!
          modify_regions(4, false)
          modify_regions(5, true)
          @border_paths = nil
          @log << 'Border change: Austrian possessions are eliminated; 1859-1866 Austrian border is deleted'
        end

        def modify_regions(phase, add)
          regions_by_phase[phase].each do |coord, edges|
            hex = hex_by_id(coord)
            edges.each do |edge|
              if add
                add_region(hex, edge)
                add_region(hex.neighbors[edge], Hex.invert(edge))
              else
                remove_region(hex, edge)
                remove_region(hex.neighbors[edge], Hex.invert(edge))
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
          b_paths = {}
          @hexes.each do |hex|
            hex_border_edges = hex.tile.borders.select { |b| b.type == :province }.map(&:edge)
            next if hex_border_edges.empty?

            hex.tile.paths.each do |path|
              b_paths[path] = true unless (path.edges.map(&:num) & hex_border_edges).empty?
            end
          end
          b_paths
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

        def startable?(entity)
          entity&.corporation? && @corporation_info[entity][:startable]
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
            HISTORICAL_CITIES + [LUGANO]
          else
            [LUGANO]
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
                             zone < 4 ? (all_token_cities - ZONES[4]) : ZONES[4].dup
                           else
                             all_token_cities
                           end
              major_pool -= [home_hex]
            else
              major_pool = all_token_cities
            end
            (major_pool - reserved_cities - austrian_cities).map { |h| hex_by_id(h) }.compact
          else
            # minor non-historical
            minor_pool = (all_token_cities - reserved_cities - austrian_cities - MAJOR_CITIES).map { |h| hex_by_id(h) }.compact
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
            np_edge = hex.invert(e)
            neighbor && !neighbor.tile.preprinted && neighbor.tile.exits.include?(np_edge)
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

        def purchase_tokens!(corporation, count, total_cost)
          min = major?(corporation) ? 2 : 1
          (count - min).times { corporation.tokens << Token.new(corporation, price: 0) }
          auto_emr(corporation, total_cost) if corporation.cash < total_cost
          corporation.spend(total_cost, @bank)
          @log << "#{corporation.name} buys #{count} tokens for #{format_currency(total_cost)}"
        end

        def purchase_additional_tokens!(corp, count, total_cost)
          if count.zero?
            @log << "#{corp.name} skips buying additional tokens"
            return
          end

          count.times { corp.tokens << Token.new(corp, price: 0) }
          corp.spend(total_cost, @bank)
          @log << "#{corp.name} buys #{count} additional tokens for #{format_currency(total_cost)}"
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

        def corporation_available?(corp)
          (historical?(corp) && startable?(corp)) ||
            (!historical?(corp) && (@phase.name.to_i >= 3))
        end

        def concession_ok?(player, corp)
          return true if @phase.name.to_i >= 4
          return true unless historical?(corp)
          return false unless player.player?

          player.companies.any? { |c| c.sym == corp.name }
        end

        def can_par?(corporation, entity)
          return false unless corporation_available?(corporation)
          return false unless concession_ok?(entity, corporation)

          super
        end

        def new_auction_round
          if version == 1
            Engine::Round::Auction.new(self, [
              G1841::Step::BlindAuction,
            ])
          else
            Engine::Round::Auction.new(self, [
              G1841::Step::ConcessionAuction,
            ])
          end
        end

        def initial_auction_companies
          companies
        end

        # reorder players by least cash.
        # - if tied, lowest numbered concession
        # - if tied, original order
        def init_reorder_players
          return if version == 1 # already done

          current_order = @players.dup
          lowest_concession = {}
          @players.each do |p|
            lowest = p.companies.min_by { |c| @companies.index(c) }
            lowest_concession[p] = lowest ? @companies.index(lowest) : -1
          end
          @players.sort_by! { |p| [p.cash, lowest_concession[p], current_order.index(p)] }
          @log << '-- New player order: --'
          @players.each.with_index do |p, idx|
            pd = idx.zero? ? ' - Priority Deal -' : ''
            @log << "#{p.name}#{pd} (#{format_currency(p.cash)})"
          end
        end

        def init_round_finished
          companies.reject { |c| c&.owner&.player? }.each do |c|
            c.owner = bank
            @log << "#{c.name} (#{c.sym}) has not been bought and is moved to the bank"
          end
        end

        def stock_round
          G1841::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G1841::Step::HomeToken,
            G1841::Step::BuyNewTokens,
            G1841::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          G1841::Round::Operating.new(self, [
            G1841::Step::Bankrupt,
            G1841::Step::Track,
            G1841::Step::Destinate,
            G1841::Step::Token,
            Engine::Step::Route,
            G1841::Step::Dividend,
            G1841::Step::BuyToken,
            Engine::Step::DiscardTrain,
            G1841::Step::RemoveTokens,
            G1841::Step::ChooseOption,
            G1841::Step::BuyNewTokens,
            G1841::Step::BuyTrain,
            G1841::Step::HomeToken,
            G1841::Step::TokenEmergencyMoney,
            G1841::Step::CorporateBuySellParShares,
            G1841::Step::Merge,
            G1841::Step::Transform,
          ], round_num: round_num)
        end

        def next_round!
          @round =
            case @round
            when Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when Round::Operating
              if @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                new_stock_round
              end
            when init_round.class
              init_round_finished
              init_reorder_players
              new_stock_round
            end
        end

        def bayard
          @bayard ||= company_by_id('Bayard')
        end

        def sfma
          @sfma ||= corporation_by_id('SFMA')
        end

        def return_concessions!
          companies.each do |c|
            next if c == bayard
            next unless c&.owner&.player?
            next if corporation_by_id(c.sym).ipoed

            player = c.owner
            player.companies.delete(c)
            c.owner = bank
            bank.companies << c
            @log << "#{c.name} (#{c.sym}) has not been used by #{player.name} and is returned to the bank"
          end
        end

        def finish_stock_round
          payout_companies
          return_concessions!
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
              chain << nil
              return chain
            end

            chain << owner
          end
          chain
        end

        def chain_of_corps(entity)
          return [entity] unless entity&.corporation?

          ([entity] + chain_of_control(entity)[0...-1])
        end

        # find the human in control if there is one, or the share pool if not
        def controller(entity)
          return entity unless entity.corporation?

          chain_of_control(entity)&.last || @share_pool
        end

        def corporation_owner(entity)
          controller(entity)
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
          return false unless entity1&.corporation?

          chain_of_control(entity1).include?(entity2)
        end

        def in_full_chain?(entity1, entity2)
          return false unless entity1&.corporation?

          ([entity1] + chain_of_control(entity1)).include?(entity2)
        end

        # entity2 was in chain of control of entity1 when it became frozen, or
        # entity2 is currently in chain of control of entity1
        def in_circular_chain?(entity1, entity2)
          return false unless entity1&.corporation?

          @corporation_info[entity1][:circular_chain]&.include?(entity2) || in_chain?(entity1, entity2)
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

        def circular?(entity)
          entity.corporation? && @corporation_info[entity][:circular]
        end

        def circular_corporations
          corporations.select { |corp| circular?(corp) }
        end

        def update_frozen!
          corporations.each do |corp|
            frozen = corp.ipoed && !controller(corp)&.player?
            circular = corp.ipoed && !controller(corp)
            @log << "#{corp.name} is no longer frozen" if frozen?(corp) && !frozen
            @log << "#{corp.name} is now frozen" if !frozen?(corp) && frozen
            @corporation_info[corp][:frozen] = frozen
            if frozen
              @corporation_info[corp][:circular] = circular || circular?(corp) # sticky until unfrozen
              @corporation_info[corp][:circular_chain] = chain_of_control(corp) if circular
            else
              @corporation_info[corp][:circular] = false
              @corporation_info[corp][:circular_chain] = []
            end
          end
        end

        # A corp is not considered to have operated until the end of it's first OR
        def done_operating!(entity)
          game_end_reason, end_timing = game_end_check
          end_game!(game_end_reason) if end_timing == :current_turn

          return unless entity&.corporation?
          return if @done_this_round[entity]

          @log << "#{entity.name} has finished operating for the first time" if !operated?(entity) && !@finished

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
          false
        end

        def player_sort(entities)
          entities.sort_by { |entity| [operating_order.index(entity) || Float::INFINITY, entity.name] }
            .group_by { |e| acting_for_entity(e) }
        end

        def player_distance_for_president(previous, entity)
          return 0 if !previous || !entity

          possible_players = if previous.player?
                               @players.rotate(@players.index(previous)).reject(&:bankrupt)
                             else
                               @players.reject(&:bankrupt)
                             end
          possible_corps = corporations.reject(&:closed?).sort

          possible = possible_players + possible_corps
          possible.reject! { |p| p == previous }
          possible = [previous] + possible

          a = possible.find_index(previous)
          b = possible.find_index(entity)
          a < b ? b - a : b - (a - possible.size)
        end

        # for 1841, this means frozen
        def receivership_corporations
          @corporations.select { |c| c.owner && !c.player }
        end

        def status_str(corp)
          str = ''
          str = 'Minor ' unless major?(corp)
          if historical?(corp)
            company = @companies.find { |c| !c.closed? && c.sym == corp.name }
            str += if company&.owner&.player?
                     "Concession: #{company.owner.name} "
                   else
                     'Historical '
                   end
          end

          str += 'FROZEN' if frozen?(corp)
          str.strip
        end

        def company_header(_company)
          'CONCESSION'
        end

        def allow_player2player_sales?
          @player2player ||= @optional_rules&.include?(:p2p_purchases)
        end

        def lite?
          @lite ||= @optional_rules&.include?(:lite)
        end

        def sfli_run_variant?
          @sfli_run_variant ||= @optional_rules&.include?(:sfli_run_variant)
        end

        def event_close_companies!
          @log << '-- Event: Concessions close --'
          @companies.each do |company|
            if (ability = abilities(company, :close, on_phase: 'any')) && (ability.on_phase == 'never' ||
                @phase.phases.any? { |phase| ability.on_phase == phase[:name] })
              next
            end

            corp = corporation_by_id(company.sym)

            if corp&.ipoed
              deferred_president_change(corp)
            else
              # remove reservations and close
              if corp
                @hexes.each do |hex|
                  tile = hex.tile
                  tile.reservations.delete(corp) if tile.reserved_by?(corp)
                  tile.cities.each do |city|
                    city.reservations.delete(corp) if city.reserved_by?(corp)
                  end
                end
              end
              @log << "Inactive corporation #{corp.name} closes" if corp
              corp&.close!
            end

            company.close!
          end
        end

        def pres_change_ok?(corporation)
          (@phase.name.to_i >= 4) || !historical?(corporation)
        end

        # change president if needed
        def deferred_president_change(corporation)
          previous_president = corporation.owner
          max_shares = corporation.player_share_holders.values.max
          majority_share_holders = corporation.player_share_holders.select { |_, p| p == max_shares }.keys
          return if majority_share_holders.any? { |entity| entity == previous_president }

          president = majority_share_holders
            .select { |p| p.percent_of(corporation) >= corporation.presidents_percent }
            .min_by { |p| player_distance_for_president(previous_president, p) }
          return unless president

          corporation.owner = president
          @log << "#{president.name} becomes the president of #{corporation.name}"

          presidents_share = previous_president.shares_of(corporation).find(&:president)

          # swap shares so new president has president share
          @share_pool.change_president(presidents_share, previous_president, president)
        end

        def buyable_bank_owned_companies
          return [] unless @turn > 1

          super
        end

        # passes and only passes upgrade only to passes
        def upgrades_to?(from, to, special = false, selected_company: nil)
          from_pass_size = from.cities.any?(&:pass?) ? from.cities[0].size : 0
          to_pass_size = to.cities.any?(&:pass?) ? to.cities[0].size : 0
          return false if from_pass_size != to_pass_size

          super
        end

        # no payment or president change
        #
        def simple_transfer_share(share, new_owner)
          @share_pool.transfer_shares(share.to_bundle, new_owner, allow_president_change: false)
        end

        def mergeable?(corp)
          (!historical?(corp) || (@phase.name.to_i >= 4)) && operated?(corp) && !frozen?(corp) && !corp.closed?
        end

        # also for transformations
        def merge_target?(corp)
          !historical?(corp) && !corp.ipoed && corp.type == :major && !corp.closed?
        end

        def find_rightmost_share_price(value)
          market_best_col = -1
          market_best = nil
          @stock_market.market.each do |row|
            row_col = 0
            row_best = row.first
            row.each_with_index do |sp, col|
              if sp.price > row_best.price && sp.price < value
                row_col = col
                row_best = sp
              end
            end
            next unless row_col > market_best_col

            market_best_col = row_col
            market_best = row_best
          end
          market_best
        end

        def merger_values(corpa, corpb)
          raise GameError, 'Both corporations must be the same type' unless corpa.type == corpb.type

          if corpa.type == :major && corpa.share_price.price > 250 && corpb.share_price.price > 250
            #  both majors are above 250
            return [corpa.share_price, corpb.share_price].sort_by(&:price) if corpa.share_price.price != corpb.share_price.price

            return [corpa.share_price]
          end

          # choose the major above 250
          return [corpa.share_price] if corpa.type == :major && corpa.share_price.price > 250
          return [corpb.share_price] if corpa.type == :major && corpb.share_price.price > 250

          if corpa.type == :major
            # neither major is above 250
            sum = [corpa.share_price.price + corpb.share_price.price, 250].min
            return [find_rightmost_share_price(sum)]
          end

          # minor
          [find_rightmost_share_price((corpa.share_price.price + corpb.share_price.price) / 2.0)]
        end

        def merger_start(corpa, corpb, target, tuscan_merge: false)
          @merger_state = :start
          @merger_corpa = corpa
          @merger_corpb = corpb
          @merger_target = target
          @merger_tuscan = tuscan_merge
          @merger_decider = tuscan_merge ? @tuscan_merge_decider : corpa.player
          @merger_title = tuscan_merge ? 'Tuscan Merge - ' : ''
          @merger_title += "Merging #{corpa.name} with #{corpb.name} to form #{target.name}: "

          @log << if tuscan_merge
                    "-- Tuscan Merge: #{corpa.name} and #{corpb.name} will merge and form #{target.name} --"
                  else
                    "#{corpa.name} and #{corpb.name} will merge and form #{target.name}"
                  end
          share_prices = merger_values(corpa, corpb)
          if share_prices.one?
            merger_exchange_start(share_prices.first)
            return
          end
          # player must choose share price
          @round.pending_options << {
            title: @merger_title,
            entity: @merger_tuscan ? @tuscan_merge_decider : corpa,
            type: :price,
            share_prices: share_prices,
          }
          @round.clear_cache!
        end

        # move all assets over to target except for:
        # - ipo stock (will be ignored - essentially becomes ipo stock of target)
        # - cross purchased stock (will be discarded -> moved to ipo of old corporation)
        # - tokens (handled later)
        #
        def move_assets(from, other, target)
          if other
            other_shares = from.shares_of(other).dup
            @log << "Removing #{other_shares.size} share(s) of #{other.name} in #{from.name} treasury" unless other_shares.empty?
            other_shares.each do |cross_share|
              simple_transfer_share(cross_share, other)
            end
          end

          shares = from.shares_by_corporation
          shares.keys.each do |corp|
            next if corp == from
            next if shares[corp].empty?

            bundle = ShareBundle.new(Array(shares[corp]))
            is_pres = bundle.presidents_share
            @log << "Moving #{bundle.percent}% of shares of #{corp.name} from #{from.name} to #{target.name} treasury"

            # special case: if from is already president of share being moved, don't allow president change
            # because: 1: transfer_shares doesn't handle the president transfer correctly if more than 1 share is moved
            # and 2: the presidency should stay with the target anyway
            @share_pool.transfer_shares(bundle, target, allow_president_change: !is_pres)
            next unless is_pres

            # handle president transfer manually
            corp.owner = target
            @log << "#{target.name} retains presidency of #{corp.name}"
          end

          # cash
          if from.cash.positive?
            @log << "Moving #{format_currency(from.cash)} from #{from.name} to #{target.name} treasury"
            from.spend(from.cash, target)
          end

          # trains
          @log << "Moving #{from.trains.size} train(s) from #{from.name} to #{target.name}"
          from.trains.each { |t| t.owner = target }
          target.trains.concat(from.trains)
          from.trains.clear
          @crowded_corps = nil
        end

        def total_percent(entity, corpa, corpb)
          entity.percent_of(corpa) + entity.percent_of(corpb)
        end

        # build a list of stockholders that own percent shares of the old companies, starting with controller
        # of merging corp then to any controlled corps for that person, then to the next person, and so on
        def merger_share_holder_list(corpa, corpb, percent)
          sh_list = []
          priority = @merger_decider
          @players.rotate(@players.index(priority)).each do |p|
            sh_list << p if total_percent(p, corpa, corpb) >= percent
            controlled_corporations(p).each do |c|
              next if c == corpa || c == corpb

              sh_list << c if total_percent(c, corpa, corpb) >= percent
            end
          end

          # pool and frozen corps are next
          sh_list << @share_pool if total_percent(@share_pool, corpa, corpb) >= percent

          frozen_corporations.each do |c|
            next if c == corpa || c == corpb

            sh_list << c if total_percent(c, corpa, corpb) >= percent
          end
          sh_list
        end

        def merger_exchange_start(share_price)
          @merger_share_price = share_price
          stock_market.set_par(@merger_target, share_price)
          @log << "#{@merger_target.name} share price will be #{format_currency(share_price.price)}"

          # start the target
          @merger_target.ipoed = true
          @merger_target.floated = true
          @merger_target.share_price = share_price

          @merger_share_holders = merger_share_holder_list(@merger_corpa, @merger_corpb, 10)

          @merger_sh_list = @merger_share_holders.select { |sh| total_percent(sh, @merger_corpa, @merger_corpb) >= 20 }

          # move assets (except for tokens) to the target
          move_assets(@merger_corpa, @merger_corpb, @merger_target)
          move_assets(@merger_corpb, @merger_corpa, @merger_target)

          if @merger_corpa.type == :major
            @merger_state = :exchange_pass1
            merger_next_exchange
          else
            @merger_state = :exchange_minor
            merger_minor_exchange
          end
        end

        def pres_upgrade_cost(percent, target)
          (target.share_price.price * (40 - percent) / 20.0).to_i
        end

        def full_upgrade_cost(target)
          (target.share_price.price / 2.0).to_i
        end

        def afford_upgrade_to_pres?(player, percent, target)
          player.cash >= pres_upgrade_cost(percent, target)
        end

        def afford_upgrade_to_full?(player, target)
          player.cash >= full_upgrade_cost(target)
        end

        def merger_next_exchange
          entity = @merger_sh_list.first
          tp = total_percent(entity, @merger_corpa, @merger_corpb)
          pres_share = @merger_target.shares_of(@merger_target).find(&:president)
          if @merger_state == :exchange_pass1
            if tp >= 40 || !pres_share || !entity.player? || !afford_upgrade_to_pres?(entity, tp, @merger_target)
              merger_do_exchange(:no)
            else
              # ask to see if the player wants to upgrade to president's share
              @round.pending_options << {
                title: @merger_title,
                entity: entity,
                type: :upgrade,
                percent: tp,
                old_shares: (entity.shares_of(@merger_corpa) + entity.shares_of(@merger_corpb)).sort_by(&:percent).reverse,
                target: @merger_target,
                choices: %i[pres no],
              }
              @round.clear_cache!
            end
          else # pass2
            normal_share = @merger_target.shares_of(@merger_target).reject(&:president).first
            current_shares = entity.shares_of(@merger_target)

            options = [:cash]
            options << :pres if entity.player? && pres_share && afford_upgrade_to_pres?(entity, tp, @merger_target)
            options << :full if entity.player && normal_share && afford_upgrade_to_full?(entity, @merger_target)
            if entity.player && !normal_share && pres_share && !current_shares.empty? &&
                afford_upgrade_to_full?(entity, @merger_target)
              # special case: entity already has a share, no target normal shares left but
              # president share is still available
              options << :full
            end
            options.uniq!

            if options.one?
              merger_do_exchange(options.first)
            else
              # ask to see if they want to buy into a pres share or full share
              @round.pending_options << {
                title: @merger_title,
                entity: entity,
                type: :upgrade,
                percent: tp,
                old_shares: (entity.shares_of(@merger_corpa) + entity.shares_of(@merger_corpb)).sort_by(&:percent).reverse,
                target: @merger_target,
                choices: options,
              }
              @round.clear_cache!
            end
          end
        end

        def merger_do_exchange(answer)
          entity = @merger_sh_list.shift
          share_list = (entity.shares_of(@merger_corpa) + entity.shares_of(@merger_corpb)).sort_by(&:percent).reverse
          tp = total_percent(entity, @merger_corpa, @merger_corpb)
          if tp > 10
            # player/corp has at least one pair of shares. Answer indicates whether the player
            # wants to upgrade to a president's share (always no for corps)

            if answer == :pres
              # upgrade to president's share
              share_list.each { |s| simple_transfer_share(s, s.corporation) }
              pres_share = @merger_target.shares_of(@merger_target).find(&:president)
              cost = pres_upgrade_cost(tp, @merger_target)
              share_list.each { |s| simple_transfer_share(s, s.corporation) }
              @log << "#{entity.name} upgrades to a president share for #{format_currency(cost)}"
              entity.spend(cost, @merger_target)
              @share_pool.transfer_shares(pres_share.to_bundle, entity, allow_president_change: true)
            else
              # exchange pairs until only a single share left
              #
              while total_percent(entity, @merger_corpa, @merger_corpb) > 10
                # move old shares out (20%)
                share0 = share_list.shift
                share1 = nil
                share1 = share_list.shift if share0.percent < 20
                simple_transfer_share(share0, share0.corporation)
                simple_transfer_share(share1, share1.corporation) if share0.percent < 20

                # move new share in (10%), if available
                new_share = @merger_target.shares_of(@merger_target).reject(&:president).first
                if new_share
                  @log << "#{entity.name} exchanges 20% of old shares for a share of #{@merger_target.name}"
                  @share_pool.transfer_shares(new_share.to_bundle, entity, allow_president_change: true)
                else
                  # out of 10% shares, but can get president's share if we have 10% of target
                  pres_share = @merger_target.shares_of(@merger_target).find(&:president)
                  ten_share = entity.shares_of(@merger_target).first
                  if pres_share && ten_share
                    @log << "#{entity.name} exchanges 20% of old shares for president share of #{@merger_target.name}"
                    @share_pool.transfer_shares(ten_share.to_bundle, @merger_target, allow_president_change: true)
                    @share_pool.transfer_shares(pres_share.to_bundle, entity, allow_president_change: true)
                  else
                    @log << "Out of 10% shares for #{entity.name} to exchange pairs of old shares for. "\
                            "Will sell 2 old shares for #{format_currency(@merger_target.share_price.price)}"
                    @bank.spend(@merger_target.share_price.price, entity)
                  end
                end
              end
            end
          else
            # only one share. Answer indicates whether the player/corp wants to buy
            # a full share or a pres share
            #
            raise GameError, 'Inconsistant share count' unless share_list.one?

            last_share = share_list.first
            simple_transfer_share(last_share, last_share.corporation)
            cost = full_upgrade_cost(@merger_target)

            pres_share = @merger_target.shares_of(@merger_target).find(&:president)
            new_share = @merger_target.shares_of(@merger_target).reject(&:president).first

            if answer == :pres
              raise GameError, 'Missing president share' unless pres_share

              cost = pres_upgrade_cost(tp, @merger_target)
              @log << "#{entity.name} upgrades to a president share for #{format_currency(cost)}"
              entity.spend(cost, @merger_target)
              @share_pool.transfer_shares(pres_share.to_bundle, entity, allow_president_change: true)
            elsif answer == :full
              # upgrade to a full share

              @log << "#{entity.name} upgrades to full share for #{format_currency(cost)}"
              if new_share
                entity.spend(cost, @merger_target)
                @share_pool.transfer_shares(new_share.to_bundle, entity, allow_president_change: true)
              else
                raise GameError, 'No shares to transfer' unless pres_share

                ten_share = entity.shares_of(@merger_target).first
                entity.spend(cost, @merger_target)
                @share_pool.transfer_shares(ten_share.to_bundle, @merger_target, allow_president_change: true)
                @share_pool.transfer_shares(pres_share.to_bundle, entity, allow_president_change: true)
              end
            elsif entity != @share_pool
              # cash out
              cost = full_upgrade_cost(@merger_target)
              @log << "#{entity.name} sells share of #{last_share.corporation.name} for #{format_currency(cost)}"
              @bank.spend(cost, entity)
            else
              @log << "#{entity.name} discards share of #{last_share.corporation.name}"
            end
          end

          if !@merger_sh_list.empty?
            merger_next_exchange
          elsif @merger_state == :exchange_pass1
            # start 2nd pass of exchanges
            #
            @merger_state = :exchange_pass2
            @merger_sh_list = @merger_share_holders.select { |sh| total_percent(sh, @merger_corpa, @merger_corpb) >= 10 }
            if !@merger_sh_list.empty?
              merger_next_exchange
            else
              merger_tokens_start
            end
          else
            # move on
            merger_tokens_start
          end
        end

        def merger_minor_exchange
          @merger_sh_list.each do |entity|
            share_list = (entity.shares_of(@merger_corpa) + entity.shares_of(@merger_corpb)).sort_by(&:percent).reverse
            share_list.each do |old_share|
              pres_share = @merger_target.shares_of(@merger_target).find(&:president)
              new_share = @merger_target.shares_of(@merger_target).reject(&:president).first
              next_share = @merger_target.shares_of(@merger_target).reject(&:president)[1]
              simple_transfer_share(old_share, old_share.corporation)
              old_corp = old_share.corporation

              if pres_share && old_share.percent > 20
                @log << "#{entity.name} exchanges 40% share of #{old_corp.name} for president share of #{@merger_target.name}"
                @share_pool.transfer_shares(pres_share.to_bundle, entity, allow_president_change: true)
              elsif old_share.percent > 20
                raise GameError, 'Not enough shares' if !new_share && !next_share

                @log << "#{entity.name} exchanges 40% share of #{old_corp.name} for 2 shares of #{@merger_target.name}"
                @share_pool.transfer_shares(new_share.to_bundle, entity, allow_president_change: true)
                @share_pool.transfer_shares(next_share.to_bundle, entity, allow_president_change: true)
              else
                raise GameError, 'Not enough shares' unless new_share

                @log << "#{entity.name} exchanges 20% share of #{old_corp.name} for a share of #{@merger_target.name}"
                @share_pool.transfer_shares(new_share.to_bundle, entity, allow_president_change: true)
              end
            end
          end

          merger_tokens_start
        end

        def merger_tokens_start
          # first check to see if president share was exchanged
          pres_share = @merger_target.shares_of(@merger_target).find(&:president)
          if pres_share
            raise GameError, 'Cannot complete this merger without a president. Undo required.' unless @merger_tuscan

            # tuscan merge
            @log << "No one has become president of #{@merger_target.name}"
            # put president share in pool in exchange for 0, 1, or 2 shares there
            pool_shares = @share_pool.shares_of(@merger_target).take(2)
            @log << "Moving #{pool_shares.size} #{@merger_target.name} shares from Market to IPO"
            pool_shares.each do |s|
              @share_pool.transfer_shares(s.to_bundle, @merger_target, allow_president_change: false)
            end
            @log << "Moving #{@merger_target.name} president's share from IPO to Market"
            @share_pool.transfer_shares(pres_share.to_bundle, @share_pool, allow_president_change: true)
            update_frozen!
          end

          old_circular = circular_corporations
          update_frozen!
          if !@merger_tuscan && circular_corporations.any? { |c| !old_circular.include?(c) }
            raise GameError, 'Illegal circular ownership chain is created by this merger and exchange. Undo required.'
          end

          if !@merger_tuscan && frozen?(@merger_target)
            raise GameError, 'Cannot complete this merger without a president. Undo required.'
          end

          @merger_state = :select_tokens
          # delete duplicate tokens between corporations
          @merger_dup_tokens = 0
          @merger_corpb.tokens.select(&:used).each do |t|
            next unless t.city.tokened_by?(@merger_corpa)

            @log << "Removing duplicate token in hex #{t.city.hex.id}"
            @merger_dup_tokens += 1
            t.remove!
          end

          # Need to deal with the yellow Firenze tile - the only OO tile in the game
          # Ask which to remove
          oo_hex = nil
          @merger_corpb.tokens.select(&:used).each do |t|
            if t.city.tile.cities.any? { |city| city.tokened_by?(@merger_corpa) }
              oo_hex = t.city.hex
              break
            end
          end
          return merger_tokens_finish unless oo_hex

          @log << "#{@merger_corpa.name} and #{@merger_corpb.name} both have tokens in #{oo_hex.id}. Must remove one."
          unless @merger_target.player
            @log << "-- The rules do not say how to handle this. #{@merger_decider.name} will decide. --"
          end
          @merger_dup_tokens += 1
          @round.pending_removals << {
            entity: @merger_target.player ? @merger_target : @merger_decider,
            hexes: [oo_hex],
            corporations: [@merger_corpa, @merger_corpb],
            min: 1,
            max: 1,
            count: 0,
            oo: true,
          }
          @round.clear_cache!
        end

        def merger_tokens_finish
          if @merger_tuscan && @tuscan_merge_ssfl
            # Tuscan Merge: first merge (of minors)
            # - just replace tokens and bring total to four
            @merger_token_cnt = 4
            return merger_finish
          end

          hexes = (@merger_corpa.tokens.select(&:used) + @merger_corpb.tokens.select(&:used)).map { |t| t.city.hex }
          map_token_cnt = @merger_corpa.tokens.count(&:used) + @merger_corpb.tokens.count(&:used)

          # Tuscan Merge: second or only merge - don't allow removal of Pisa or Firenze
          #                                    - always get 5 tokens
          #                                    - different rules for keeping tokens than for normal mergers
          if @merger_tuscan
            keep_hexes = hexes.select { |hex| TUSCAN_TOKEN_HEXES.include?(hex.id) }
            hexes -= keep_hexes
            kept = keep_hexes.size
            @merger_token_cnt = 5

            map_token_cnt -= kept
            max_to_remove = map_token_cnt
            min_to_remove = [map_token_cnt - (5 - kept), 0].max

            unless @merger_target.player
              # SFLi is frozen - rules stipulate how this is handled
              hexes_to_remove = hexes
              @log << "#{@merger_target.name} tokens are removed/replaced automatically:"
              if keep_hexes.empty?
                # Neither Pisa or Firenze have a token - keep the first city alphabetically
                keep = hexes.reject { |hex| hex.tile.cities[0].pass? }.min_by(&:location_name)
                hexes_to_remove -= [keep]
              end
              hexes_to_remove.each do |hex|
                token = (@merger_corpa.tokens + @merger_corpb.tokens).select(&:used).find { |t| t.city.hex == hex }
                @log << "Removing #{token.corporation.name} token in #{hex.id} (#{hex.location_name})"
                token.destroy!
              end
              return merger_finish
            end
          else
            total_token_cnt = @merger_corpa.tokens.size + @merger_corpb.tokens.size - @merger_dup_tokens
            @merger_token_cnt = [total_token_cnt, 5].min
            unplaced_token_cnt = total_token_cnt - map_token_cnt

            max_unplaced = [unplaced_token_cnt, @merger_token_cnt - 1].min
            min_unplaced = [@merger_token_cnt - map_token_cnt, 0].max

            max_placed = @merger_token_cnt - min_unplaced
            min_placed = @merger_token_cnt - max_unplaced

            min_to_remove = map_token_cnt - max_placed
            max_to_remove = map_token_cnt - min_placed

            @log << "#{@merger_target.name} will have #{total_token_cnt} tokens."\
                    " Up to #{max_unplaced} tokens can be on the charter."
            @log << "Any token of #{@merger_corpa.name} or #{@merger_corpb.name} left on the map will be"\
                    " automatically replaced by a token of #{@merger_target.name}"
          end

          if max_to_remove.positive?
            @log << if min_to_remove == max_to_remove
                      "Must remove #{min_to_remove} token(s) of #{@merger_corpa.name}"\
                        " and/or #{@merger_corpb.name} from map"
                    else
                      "Must remove #{min_to_remove} to #{max_to_remove} tokens of "\
                        "#{@merger_corpa.name} and/or #{@merger_corpb.name} from map"
                    end
            @round.pending_removals << {
              entity: @merger_target.player ? @merger_target : @merger_decider,
              hexes: hexes,
              corporations: [@merger_corpa, @merger_corpb],
              min: min_to_remove,
              max: max_to_remove,
              count: 0,
            }
            @round.clear_cache!
          else
            merger_finish
          end
        end

        def swap_token(target, old_corp, old_token)
          new_token = target.next_token
          city = old_token.city
          @log << "Replaced #{old_corp.name} token in #{city.hex.id} (#{city.hex.location_name}) with #{target.name} token"
          new_token.place(city)
          city.tokens[city.tokens.find_index(old_token)] = new_token
          old_corp.tokens.delete(old_token)
        end

        def merger_finish
          # create new tokens if needed
          (@merger_token_cnt - 2).times { @merger_target.tokens << Token.new(@merger_target, price: 0) } if @merger_token_cnt > 2

          # copy tokens on map to target
          @merger_corpa.tokens.select(&:used).each { |t| swap_token(@merger_target, @merger_corpa, t) }
          @merger_corpb.tokens.select(&:used).each { |t| swap_token(@merger_target, @merger_corpb, t) }
          @graph.clear
          @region_graph.clear

          # reset the corps
          restart_corporation!(@merger_corpa)
          restart_corporation!(@merger_corpb)

          @done_this_round[@merger_corpa] = true
          @done_this_round[@merger_corpb] = true
          @done_this_round[@merger_target] = true
          @round.clear_cache!
          @merger_state = nil

          return tuscan_merge_post_merge if @merger_tuscan
        end

        def restart_corporation!(corporation)
          if historical?(corporation)
            @log << "#{corporation.name} closes"
            corporation.close!
            return
          end

          @log << "#{corporation.name} is available to start"

          # un-IPO the corporation
          corporation.share_price&.corporations&.delete(corporation)
          corporation.share_price = nil
          corporation.par_price = nil
          corporation.ipoed = false
          corporation.unfloat!
          corporation.owner = nil
          @corporation_info[corporation][:operated] = false

          # get back to 1 or 2 tokens
          corporation.tokens.clear
          num_tokens = corporation.type == :major ? 2 : 1
          num_tokens.times { |_t| corporation.tokens << Token.new(corporation, price: 0) }

          # remove trains
          corporation.trains.clear

          # re-sort shares
          corporation.shares_by_corporation[corporation].sort_by!(&:id)

          # forget about routes
          @graph.clear_graph_for(corporation)
        end

        def transformable?(corp)
          corp.type == :minor && (!historical?(corp) || (@phase.name.to_i >= 4))
        end

        def transform_shares(corp, target)
          possible_shareholders = @players.rotate(@players.index(corp.player)) + @corporations + [@share_pool]

          pres = corp.owner
          old_pres = pres.shares_of(corp).find(&:president)
          raise GameError, 'Cannot find old president share' unless old_pres

          pres_share = target.shares_of(target).find(&:president)
          @log << "#{pres.name} swaps president share of #{corp.name} for #{target.name}"
          simple_transfer_share(old_pres, corp)
          @share_pool.transfer_shares(pres_share.to_bundle, pres, allow_president_change: true)

          possible_shareholders.each do |sh|
            next if sh == corp

            shares = sh.shares_of(corp).sort_by(&:percent).reverse
            shares.each do |s|
              simple_transfer_share(s, corp)

              new_share = target.shares_of(target).first

              @log << "#{sh.name} swaps share of #{corp.name} for #{target.name}"
              @share_pool.transfer_shares(new_share.to_bundle, sh, allow_president_change: true)
            end
          end
        end

        def active_share_holder_list(priority, corp, include_corporations: nil)
          sh_list = []
          @players.rotate(@players.index(priority)).each do |p|
            sh_list << p unless p.shares_of(corp).empty?
            next unless include_corporations

            controlled_corporations(p).each do |c|
              next if c == corp

              sh_list << c unless c.shares_of(corp).empty?
            end
          end
          sh_list
        end

        def transform_start(corp, target, tuscan_merge: false)
          @transform_corp = corp
          @transform_target = target
          @transform_tuscan = tuscan_merge

          @log << if tuscan_merge
                    "-- Tuscan Merger: #{corp.name} will transform to a major and form #{target.name} --"
                  else
                    "#{corp.name} will transform to a major and form #{target.name}"
                  end

          # move everything over
          move_assets(corp, nil, target)

          # substitute tokens
          target.tokens.clear
          corp.tokens.size.times { |_t| target.tokens << Token.new(target, price: 0) }
          corp.tokens.select(&:used).each { |t| swap_token(target, corp, t) }

          # open and set share price of target
          @stock_market.set_par(target, corp.share_price)
          target.ipoed = true
          target.floated = true

          # convert shares
          transform_shares(corp, target)

          # swap in operating order
          @round.entities[@round.entities.find_index(corp)] = target

          # offer a share to all current shareholders
          @transform_state = :offer1
          @share_offer_list = active_share_holder_list(target.player, target, include_corporations: true)
          @share_offer_corp = target
          @log << 'First round of share purchase (players and corporations)'
          share_offer_next
        end

        # can a share be offered to sale from IPO to entity?
        def can_buy_share?(entity, corp)
          return false if corp.shares_of(corp).empty?
          return false if entity.cash < corp.share_price.price
          return false if in_full_chain?(entity, corp)

          # can't exceed cert limit
          (!corp.counts_for_limit || num_certs(entity) < cert_limit(entity)) &&
            # can't allow player to control too much
            ((player_controlled_percentage(entity, corp) + 10) <= corp.max_ownership_percent)
        end

        # @share_offer_list contains list of who to offer shares to
        # @share_offer_corp is the corp to buy
        def share_offer_next
          return transform_2nd_offer if @share_offer_list.empty? && @transform_state == :offer1
          return transform_tokens if @share_offer_list.empty? && @transform_state == :offer2
          return secession_post_offer if @share_offer_list.empty? && @secession_state == :offer

          entity = @share_offer_list.first
          unless can_buy_share?(entity, @share_offer_corp)
            @log << "#{entity.name} cannot buy a share of #{@share_offer_corp.name} and is skipped"
            @share_offer_list.shift
            return share_offer_next
          end

          title = if @secession_state
                    'Ferdinandea Secession: '
                  else
                    "#{@transform_tuscan ? 'Tuscan Merge - ' : ''}Transforming #{@transform_corp.name}: "
                  end

          @round.pending_options << {
            title: title,
            entity: entity,
            type: :share_offer,
            target: @share_offer_corp,
          }
          @round.clear_cache!
        end

        def share_offer_option(opt)
          entity = @share_offer_list.first
          if opt == :no
            @log << "#{entity.name} declines to buy a share of #{@share_offer_corp.name}"
            @share_offer_list.shift
            return share_offer_next
          end

          share = @share_offer_corp.shares_of(@share_offer_corp).first
          @log << "#{entity.name} buys a share of #{@share_offer_corp.name}"
          @share_pool.buy_shares(entity, share, allow_president_change: true)
          @share_offer_list.shift
          share_offer_next
        end

        def transform_2nd_offer
          # offer a share to all current player shareholders
          @transform_state = :offer2
          @share_offer_list = @players.rotate(@players.index(@share_offer_corp.player)).reject(&:bankrupt)
          @log << 'Second round of share purchase (all players)'
          share_offer_next
        end

        def transform_tokens
          @transform_state = :tokens

          if @transform_tuscan
            # in Tuscan merger, just give target a 2nd token
            @transform_target.tokens << Token.new(@transform_target, price: 0) if @transform_target.tokens.size < 2
            return transform_finish
          end

          current_token_cnt = @transform_target.tokens.size
          min = current_token_cnt == 1 ? 1 : 0

          first_price = min.zero? ? XFORM_OPT_TOKEN_COST : XFORM_REQ_TOKEN_COST
          required_payment = min.zero? ? 0 : XFORM_REQ_TOKEN_COST
          max_opt_tokens = [((@transform_target.cash - required_payment) / XFORM_OPT_TOKEN_COST).to_i, 0].max
          max = [max_opt_tokens + min, 5 - current_token_cnt].min

          if max.zero?
            @log << "#{@transform_target.name} cannot buy additional tokens"
            return transform_finish
          end

          if min == 1 && max == 1 && emergency_cash_before_selling(@transform_target, XFORM_REQ_TOKEN_COST) < XFORM_REQ_TOKEN_COST
            # have to sell something
            @round.token_emr_entity = @transform_target
            @round.token_emr_amount = XFORM_REQ_TOKEN_COST
            @log << "#{@transform_target.name} will need to perform EMR to buy a token"
          end

          @round.buy_tokens << {
            entity: @transform_tuscan && !@transform_target.player ? @tuscan_merge_decider : @transform_target,
            type: :transform,
            first_price: first_price,
            price: XFORM_OPT_TOKEN_COST,
            min: min,
            max: max,
          }
          @round.clear_cache!
        end

        def transform_finish
          restart_corporation!(@transform_corp)
          @done_this_round[@transform_corp] = true
          @done_this_round[@transform_target] = true
          @round.clear_cache!
          @transform_state = nil

          return tuscan_merge_post_transform if @transform_tuscan
        end

        def secession_replace_price_tokens(old, newa, newb)
          share_price = old.share_price

          newa.share_price = share_price
          newa.par_price = share_price
          newa.original_par_price = share_price

          newb.share_price = share_price
          newb.par_price = share_price
          newb.original_par_price = share_price

          corps = share_price.corporations
          index = corps.index(old)
          corps[index] = newa
          corps.insert(index + 1, newb)
          old.share_price = nil
        end

        def secession_replace_other_tokens(old, newa, newb)
          newa.tokens.clear
          newb.tokens.clear

          placed, unplaced = old.tokens.partition(&:used)
          # First replace the tokens on the map
          placed.each do |old_token|
            if VENETO.include?(old_token.city.hex.id)
              next if version == 1 && newa.tokens.size > 1

              # newa goes in Veneto (Austrian possesions in phase 4)
              newa.tokens << Token.new(newa, price: 0)
              swap_token(newa, old, old_token)
            else
              next if version == 1 && newb.tokens.size > 1

              # newb goes in the rest
              newb.tokens << Token.new(newb, price: 0)
              swap_token(newb, old, old_token)
            end
          end

          # Now the rest
          unplaced.size.times do |i|
            newa.tokens << Token.new(newa, price: 0) if i.even? && (version == 2 || newa.tokens.size < 2)
            newb.tokens << Token.new(newb, price: 0) if i.odd? && (version == 2 || newb.tokens.size < 2)
          end

          # make sure they both have at least two tokens
          newa.tokens << Token.new(newa, price: 0) if newa.tokens.size < 2
          newb.tokens << Token.new(newb, price: 0) if newb.tokens.size < 2
        end

        def secession_move_trains(old, newa, newb)
          trains = old.trains.sort_by(&:name).reverse
          trains.each_with_index do |t, i|
            if i.even?
              t.owner = newa
              newa.trains << t
              @log << "#{newa.name} receives a #{t.name} train from #{old.name}"
            else
              t.owner = newb
              newb.trains << t
              @log << "#{newb.name} receives a #{t.name} train from #{old.name}"
            end
          end
          old.trains.clear
        end

        def secession_move_cash(old, newa, newb)
          cashb = (old.cash / 10).to_i
          casha = old.cash - cashb
          if casha.positive?
            old.spend(casha, newa)
            @log << "#{newa.name} receives #{format_currency(casha)} from #{old.name}"
          end
          return unless cashb.positive?

          old.spend(cashb, newb)
          @log << "#{newb.name} receives #{format_currency(cashb)} from #{old.name}"
        end

        def secession_move_treasury_shares(old, newa, newb)
          tshares = old.corporate_shares.sort_by(&:price).reverse
          tshares.each_with_index do |share, i|
            if i.even?
              @log << "Moving #{share.percent}% share of #{share.corporation.name} from #{old.name} to #{newa.name} treasury"
              @share_pool.transfer_shares(share.to_bundle, newa, allow_president_change: true, corporate_transfer: true)
            else
              @log << "Moving #{share.percent}% share of #{share.corporation.name} from #{old.name} to #{newb.name} treasury"
              @share_pool.transfer_shares(share.to_bundle, newb, allow_president_change: true, corporate_transfer: true)
            end
          end
        end

        def major_only_price?(share_price)
          share_price.coordinates[1] > RIGHTMOST_MINOR_COLUMN
        end

        def secession_set_minor_prices(old, newa, newb)
          minor_price = @stock_market.market[old.share_price.coordinates[0]][RIGHTMOST_MINOR_COLUMN]

          newa.share_price = minor_price
          newa.par_price = minor_price
          newa.original_par_price = minor_price

          newb.share_price = minor_price
          newb.par_price = minor_price
          newb.original_par_price = minor_price

          @log << "New price for #{newa.name} and #{newb.name} will be #{format_currency(minor_price.price)}"

          old.share_price.corporations.delete(old)
          minor_price.corporations << newa
          minor_price.corporations << newb
          old.share_price = nil
        end

        # for version 1, old = IRSFF, newa = SFV (minor), newb = SFL (minor)
        # for version 2, old = IRSFF, newa = SB (major), newb = SFL (major)
        def secession_start(old, newa, newb)
          @secession_old = old
          @secession_newa = newa
          @secession_newb = newb
          @secession_state = :exchange_pairs
          @secession_decider = old.player || @round.current_entity.player # in case IRSFF is frozen

          if version == 1 && major_only_price?(old.share_price)
            secession_set_minor_prices(old, newa, newb)
          else
            secession_replace_price_tokens(old, newa, newb)
          end
          newa.ipoed = true
          newa.floated = true
          newb.ipoed = true
          newb.floated = true
          @corporation_info[newa][:startable] = true
          @corporation_info[newb][:startable] = true

          secession_replace_other_tokens(old, newa, newb)
          secession_move_trains(old, newa, newb)
          secession_move_cash(old, newa, newb)
          secession_move_treasury_shares(old, newa, newb)

          old_owner = old.owner
          presa = newa.shares_of(newa).find(&:president)
          presb = newb.shares_of(newb).find(&:president)

          if !@share_pool.shares_of(old).find(&:president) && old_owner
            if old_owner.percent_of(old) >= 40
              # old owner will get both president's certs
              old_pres = old_owner.shares_of(@secession_old).find(&:president)
              shares = old_owner.shares_of(@secession_old).reject(&:president)
              simple_transfer_share(old_pres, old)
              simple_transfer_share(shares[0], old)
              simple_transfer_share(shares[1], old)
              @share_pool.transfer_shares(presa.to_bundle, old_owner, allow_president_change: true)
              @share_pool.transfer_shares(presb.to_bundle, old_owner, allow_president_change: true)
              @log << "Transferred president shares of #{newa.name} and #{newb.name} to #{old_owner.name}"
              secession_exchange_pairs(newb)
            else
              # ask decider which corp current president of IRSFF wants to be president of
              @round.pending_options << {
                title: 'Ferdinandea Secession: ',
                entity: old.player ? old_owner : @secession_decider,
                type: :pick_exchange_pres,
                share_owner: old_owner,
                corpa: newa,
                corpb: newb,
              }
              @round.clear_cache!
            end
            return
          end

          # IRSFF pres cert is in share pool - move both newa and newb pres cert to share pool
          @share_pool.transfer_shares(presa.to_bundle, @share_pool, allow_president_change: true)
          @share_pool.transfer_shares(presa.to_bundle, @share_pool, allow_president_change: true)

          # by definition, no one else has a pair of IRSFF shares, so go to single share exchange
          secession_exchange_singles
        end

        # build a list of stockholders that own percent shares of the old company
        # then to any controlled corps for that person, then to the next person, and so on
        def secession_share_holder_list(owner, old, percent)
          sh_list = []
          @players.rotate(@players.index(owner)).each do |p|
            sh_list << p if p.percent_of(old) >= percent
            controlled_corporations(p).each do |c|
              next if c == old

              sh_list << c if c.percent_of(old) >= percent
            end
          end

          # pool and frozen corps are next
          sh_list << @share_pool if @share_pool.percent_of(old) >= percent

          frozen_corporations.each do |c|
            next if c == old

            sh_list << c if c.percent_of(old) >= percent
          end
          sh_list
        end

        # choice = :a or :b
        def secession_corp(choice)
          new = choice == :a ? @secession_newa : @secession_newb
          other = choice == :a ? @secession_newb : @secession_newa

          # exchange president cert for president cert
          old_owner = @secession_old.owner
          old_pres = old_owner.shares_of(@secession_old).find(&:president)
          new_pres = new.shares_of(new).find(&:president)
          simple_transfer_share(old_pres, @secession_old)
          @share_pool.transfer_shares(new_pres.to_bundle, old_owner, allow_president_change: true)
          @log << "Transferred president share of #{new.name} to #{old_owner.name}"

          secession_exchange_pairs(other)
        end

        # do exchanges of all pairs held by shareholders of IRSFF
        def secession_exchange_pairs(other)
          other_pres = other.shares_of(other).find(&:president)
          secession_share_holder_list(@secession_decider, @secession_old, 20).each do |sh|
            while sh.percent_of(@secession_old) > 10
              shares = sh.shares_of(@secession_old).dup
              simple_transfer_share(shares[0], @secession_old)
              simple_transfer_share(shares[1], @secession_old)
              if other_pres && sh == @share_pool
                simple_transfer_share(other_pres, sh)
                other.owner = sh
                @log << "#{other.name} president share moved to share pool"
                other_pres = nil
              elsif other_pres
                @share_pool.transfer_shares(other_pres.to_bundle, sh, allow_president_change: true)
                @log << "Transferred president share of #{other.name} to #{sh.name}"
                other_pres = nil
              else
                share_a = @secession_newa.shares_of(@secession_newa)[0]
                share_b = @secession_newb.shares_of(@secession_newb)[0]
                @share_pool.transfer_shares(share_a.to_bundle, sh, allow_president_change: true)
                @log << "Transferred share of #{@secession_newa.name} to #{sh.name}"
                @share_pool.transfer_shares(share_b.to_bundle, sh, allow_president_change: true)
                @log << "Transferred share of #{@secession_newb.name} to #{sh.name}"
              end
            end
          end
          if other_pres
            # no one had 20% -> move other pres to share pool
            @share_pool.transfer_shares(other_pres.to_bundle, @share_pool, allow_president_change: true)
            @log << "#{other.name} president share moved to share pool"
          end

          secession_exchange_singles
        end

        def secession_exchange_singles
          @secession_state = :exchange_singles
          @secession_sh_list = secession_share_holder_list(@secession_decider, @secession_old, 10)

          if @secession_sh_list.empty?
            secession_offer_start
          else
            secession_next_exchange
          end
        end

        def secession_next_exchange
          entity = @secession_sh_list.first

          a_avail = !@secession_newa.shares_of(@secession_newa).empty?
          b_avail = !@secession_newb.shares_of(@secession_newb).empty?

          if a_avail && b_avail && entity.player
            @round.pending_options << {
              title: 'Ferdinandea Secession: ',
              entity: entity,
              type: :pick_exchange_corp,
              share_owner: entity,
              corpa: @secession_newa,
              corpb: @secession_newb,
            }
            @round.clear_cache!
          elsif a_avail && b_avail && entity == @share_pool
            @round.pending_options << {
              title: 'Ferdinandea Secession: ',
              entity: @secession_decider,
              type: :pick_exchange_corp,
              share_owner: entity,
              corpa: @secession_newa,
              corpb: @secession_newb,
            }
            @round.clear_cache!
          elsif a_avail
            # frozen or no shares in b left
            secession_do_exchange(:a)
          elsif b_avail
            # no shares in b left
            secession_do_exchange(:b)
          else
            secession_offer_start
          end
        end

        def secession_do_exchange(choice)
          entity = @secession_sh_list.shift

          old_share = entity.shares_of(@secession_old).first
          new = choice == :a ? @secession_newa : @secession_newb
          new_share = new.shares_of(new).first
          simple_transfer_share(old_share, @secession_old)
          @share_pool.transfer_shares(new_share.to_bundle, entity, allow_president_change: true)
          @log << "#{entity.name} exchanges a share of #{@secession_old.name} for a share of #{new.name}"

          if @secession_sh_list.empty?
            secession_offer_start
          else
            secession_next_exchange
          end
        end

        def secession_offer_start
          @secession_state = :offer
          @secession_offer_corp = @secession_newa
          @secession_offer_donea = false
          @secession_offer_doneb = false
          @secession_offer_first = true

          secession_offer(@secession_newa)
        end

        def secession_offer(corp)
          @share_offer_list = active_share_holder_list(corp.player || @secession_decider,
                                                       corp, include_corporations: true)
          @share_offer_corp = corp
          @log << if @share_offer_list.empty?
                    "Skipping round of share purchases of #{corp.name}"
                  else
                    "Starting round of share purchases of #{corp.name}"
                  end
          share_offer_next
        end

        def secession_post_offer
          if @secession_offer_first
            @secession_offer_corp = @secession_newb
            @secession_offer_first = false
            return secession_offer(@secession_newb)
          end

          return secession_tokens_start if @secession_offer_donea && @secession_offer_doneb

          if @secession_offer_corp == @secession_newa
            # just did A, now do B
            @secession_offer_corp = @secession_newb
            return secession_post_offer if @secession_offer_doneb
          else
            # just did B, now do A
            @secession_offer_corp = @secession_newa
            return secession_post_offer if @secession_offer_donea
          end
          secession_offer_again(@secession_offer_corp)
        end

        def secession_can_any_buy?(corp)
          sh_list = active_share_holder_list(corp.player || @secession_decider, corp, include_corporations: true)
          sh_list.any? { |sh| can_buy_share?(sh, corp) }
        end

        def secession_offer_again(corp)
          unless secession_can_any_buy?(corp)
            if corp == @secession_newa
              @secession_offer_donea = true
            else
              @secession_offer_doneb = true
            end
            return secession_post_offer
          end

          @round.pending_options << {
            title: 'Ferdinandea Secession: ',
            entity: corp.player ? corp : @secession_decider,
            type: :offer_again,
            corp: corp,
          }
          @round.clear_cache!
        end

        def secession_offer_response(choice)
          @log << if choice == :y
                    "Another round of purchases for #{@secession_offer_corp.name} was approved"
                  else
                    "Another round of purchases for #{@secession_offer_corp.name} was declined"
                  end
          return secession_offer(@secession_offer_corp) if choice == :y

          if @secession_offer_corp == @secession_newa
            @secession_offer_donea = true
          else
            @secession_offer_doneb = true
          end
          secession_post_offer
        end

        def secession_tokens_start
          return secession_finish if version == 1

          @secession_state = :tokens
          @secession_tokens_corp = @secession_newa
          secession_tokens
        end

        def secession_tokens
          token_cnt = @secession_tokens_corp.tokens.size
          if token_cnt == 5 || @secession_tokens_corp.cash < SECESSION_OPT_TOKEN_COST
            @log << "#{@secession_tokens_corp.name} cannot buy additional tokens"
            return secession_tokens_next
          end

          available = 5 - token_cnt
          max = [(@secession_tokens_corp.cash / SECESSION_OPT_TOKEN_COST).to_i, available].min

          @round.buy_tokens << {
            entity: @secession_tokens_corp.player ? @secession_tokens_corp : @secession_decider,
            corp: @secession_tokens_corp,
            type: :secession,
            first_price: SECESSION_OPT_TOKEN_COST,
            price: SECESSION_OPT_TOKEN_COST,
            min: 0,
            max: max,
          }
          @round.clear_cache!
        end

        def secession_tokens_next
          if @secession_tokens_corp == @secession_newa
            @secession_tokens_corp = @secession_newb
            return secession_tokens
          end

          secession_finish
        end

        def secession_finish
          old_pos = @round.entities.find_index(@secession_old)

          if old_pos <= @round.entity_index
            # IRSFF already ran or triggered the phase change
            @log << "#{@secession_newa.name} and #{@secession_newb.name} will not run this OR"
            @done_this_round[@secession_newa] = true
            @done_this_round[@secession_newb] = true
          else
            # IRSFF hasn't run
            @log << "#{@secession_newa.name} and #{@secession_newb.name} will run this OR"
            @done_this_round[@secession_newa] = false
            @done_this_round[@secession_newb] = false
            @round.entities[old_pos] = @secession_newa
            @round.entities.insert(old_pos + 1, @secession_newb)
          end
          restart_corporation!(@secession_old)
          update_frozen!
          @round.clear_cache!
          @secession_state = nil
          @log << '-- Ferdinandea Secession Complete --'
          return unless @tuscan_merge_state == :deferred

          @tuscan_merge_state = nil
          event_tuscan_merge!
        end

        # Return corp first in operating order:
        # 1. Highest price, then
        # 2. Rightmost price, then
        # 3. Highest in stack within a price
        #
        def best_stock_value(corps)
          corps.compact.select(&:floated?).min
        end

        def tuscan_merge_start(sflp, sfma, ssfl, sfli, holding, will_run)
          @tuscan_merge_sfli = sfli
          @tuscan_merge_holding = holding
          @tuscan_merge_run = will_run

          decider = best_stock_value([sflp, sfma, ssfl])
          @log << "#{decider.name} has best stock value"
          @tuscan_merge_decider = decider.player || @round.current_entity.player
          @log << "#{@tuscan_merge_decider.name} will perform Tuscan Merge operations"
          @tuscan_merge_ssfl = ssfl
          @corporation_info[sfli][:startable] = true

          if sflp.floated? && sfma.floated? && ssfl.floated?
            # all three are open
            merger_start(sflp, sfma, holding, tuscan_merge: true)
          elsif !sflp.floated?
            # sfma and ssfl are open, but not sflp
            transform_start(sfma, holding, tuscan_merge: true)
          elsif !sfma.floated?
            # sflp and ssfl are open, but not sfma
            transform_start(sflp, holding, tuscan_merge: true)
          else
            # sflp and sfma are open, but not ssfl
            @tuscan_merge_ssfl = nil
            merger_start(sflp, sfma, sfli, tuscan_merge: true)
          end
        end

        def tuscan_merge_post_transform
          # always merge after a transform
          ssfl = @tuscan_merge_ssfl
          @tuscan_merge_ssfl = nil
          merger_start(@tuscan_merge_holding, ssfl, @tuscan_merge_sfli, tuscan_merge: true)
        end

        def tuscan_merge_post_merge
          return tuscan_merge_finish unless @tuscan_merge_ssfl

          tuscan_merge_post_transform
        end

        def tuscan_merge_finish
          @done_this_round[@tuscan_merge_sfli] = !@tuscan_merge_run
          @log << "#{@tuscan_merge_sfli.name} will #{@tuscan_merge_run ? '' : 'not '} run this OR"
          if @tuscan_merge_run
            @round.entities << @tuscan_merge_sfli
            @round.recalculate_order
          end

          @log << '-- Tuscan Merge complete --'
        end

        # sell IPO shares to make up shortfall
        def auto_emr(corp, total_cost)
          diff = total_cost - corp.cash
          return unless diff.positive?

          num_shares = ((2.0 * diff) / corp.share_price.price).ceil
          raise GameError, 'Assumption about starting token EMR is wrong' if num_shares > corp.shares_of(corp).size

          bundle = ShareBundle.new(corp.shares_of(corp).take(num_shares))
          bundle.share_price = corp.share_price.price / 2.0
          sell_shares_and_change_price(bundle)
          @log << "#{corp.name} raises #{format_currency(bundle.price)} and completes EMR"
          @round.recalculate_order if @round.respond_to?(:recalculate_order)
        end

        def can_sell_any_amount?(owner, corp, active)
          # can dump IPO stock
          owner == corp ||
            # can dump stock if not president of corp
            owner != corp.owner ||
            # can dump if corp is not not in chain of ownership and not a historical corp (before phase 4)
            (!in_full_chain?(active, corp) && (!historical?(corp) || @phase.name.to_i >= 4))
        end

        # can sell a partial share of a president's share if another entity can become pres OR
        # there is at least one share in the market
        def can_sell_partial?(owner, corp)
          (corp.player_share_holders.reject { |s_h, _| s_h == owner }.values.max || 0) > 10 ||
            !@share_pool.shares_of(corp).empty?
        end

        def corp_minimum_to_retain(owner, corp, active)
          return 0 if can_sell_any_amount?(owner, corp, active)

          corp.player_share_holders.reject { |s_h, _| s_h == owner }.values.max || 0
        end

        def emr_can_sell?(active, bundle)
          owner = bundle.owner
          corp = bundle.corporation

          return false if bundle.partial? && !can_sell_partial?(owner, corp)
          return true if can_sell_any_amount?(owner, corp, active)

          corp_minimum_to_retain(owner, corp, active) <= (owner.percent_of(corp) - bundle.percent) &&
            !bundle.presidents_share
        end

        def emr_valid_bundles(owner, corp, active)
          return [] if owner.shares_of(corp).empty?

          bundles = all_bundles_for_corporation(owner, corp)
          bundles.each { |b| b.share_price = corp.share_price.price / 2.0 }
          max = owner.percent_of(corp) - corp_minimum_to_retain(owner, corp, active)
          bundles.reject!(&:presidents_share) unless can_sell_any_amount?(owner, corp, active)
          bundles.reject { |b| b.percent > max }
        end

        def emr_value(corp, active)
          value = 0
          corporations.each do |c|
            bundles = emr_valid_bundles(corp, c, active)
            value += bundles.max_by(&:num_shares)&.price unless bundles.empty?
          end
          value
        end

        def emr_bundles_all(corp, active)
          all_bundles = []
          corporations.each do |c|
            bundles = emr_valid_bundles(corp, c, active)
            all_bundles.concat(bundles) unless bundles.empty?
          end
          all_bundles
        end

        # prioritize treasury shares before IPO shares
        def emr_shares_next(corporation, active, needed)
          return [] unless needed.positive?

          all_bundles = emr_bundles_all(corporation, active)
          all_bundles.reject! { |b| b.price >= (needed + b.share_price) }
          return [] if all_bundles.empty?

          ipo, treasury = all_bundles.partition { |s| s.corporation == corporation }

          return treasury unless treasury.empty?

          ipo unless ipo.empty?
        end

        # returns bundles for first corp in chain that has any to sell
        def emergency_issuable_bundles(corporation, needed = nil)
          needed ||= @depot.min_depot_price
          chain_of_corps(corporation).each do |corp|
            needed -= corp.cash
            return [] unless needed.positive?

            shares = emr_shares_next(corp, corporation, needed)
            return shares unless shares.empty?
          end
          []
        end

        # returns total emr cash that could be raised by corp and all corps in ownership chain
        # doesn't include cash in current corp or cash in corps prior to selling shares
        def emergency_issuable_cash(corporation)
          total = 0
          chain_of_corps(corporation).each do |corp|
            total += corp.cash
            total += emr_value(corp, corporation)
          end
          total - emergency_cash_before_issuing(corporation)
        end

        # returns total emr cash that could be raised by corp and all corps in ownership chain
        # doesn't include cash or shares held by president
        def emergency_issuable_funds(corporation)
          total = 0
          chain_of_corps(corporation).each do |corp|
            total += corp.cash
            total += emr_value(corp, corporation)
          end
          total
        end

        # Returns cash in any corps in ownership chain, stopping
        # when reaching corp with sellable shares
        # Doesn't include player cash
        def emergency_cash_before_issuing(corporation, needed = nil)
          needed ||= @depot.min_depot_price
          total = 0
          chain_of_corps(corporation).each do |corp|
            total += corp.cash
            needed -= corp.cash
            shares = emr_shares_next(corp, corporation, needed)
            return total unless shares.empty?
          end
          total
        end

        # Returns cash in any corps in ownership chain, stopping
        # when reaching entity with sellable shares
        # Includes player cash
        def emergency_cash_before_selling(corporation, needed = nil)
          needed ||= @depot.min_depot_price
          total = 0
          ([corporation] + chain_of_control(corporation)).each do |entity|
            total += entity.cash
            needed -= entity.cash
            shares = emr_shares_next(entity, corporation, needed)
            return total unless shares.empty?
          end
          total
        end

        def bankruptcy_options(_entity)
          [0, 1]
        end

        def bankruptcy_button_text(option)
          case option
          when 0
            'Declare Bankruptcy and Resign'
          when 1
            "Declare Bankruptcy and take a loan of #{format_currency(BANKRUPTCY_LOAN)}"
          else
            ''
          end
        end

        def declare_bankrupt(player, option = 0)
          raise GameError, "#{player.name} is already bankrupt, cannot declare bankruptcy again." if player.bankrupt

          if option.zero?
            player.bankrupt = true
            @log << "#{player.name} is now bankrupt and out of the game"
            return
          end

          @log << "#{player.name} is bankrupt and receives a #{format_currency(BANKRUPTCY_LOAN)} loan from the bank"
          @bank.spend(BANKRUPTCY_LOAN, player)
          @loans[player] += BANKRUPTCY_LOAN
        end

        def player_value(player)
          player.value - @loans[player]
        end

        # Firenze is off limits for tokens until either SFMA starts or phase 4
        def check_token_hex(entity, hex)
          return true if lite? || version == 1 || @phase.name.to_i >= 4 || sfma.floated? || entity == sfma

          hex.id != FIRENZE
        end

        def init_offboard_list
          @offboard_connected = {}
          @offboard_list = []
          @offboard_groups = Hash.new { |h, k| h[k] = [] }

          @hexes.each do |hex|
            hex.tile.nodes.each do |node|
              next unless node.offboard?

              group = node.groups.empty? ? hex.id : node.groups[0] # expect only one group per offboard
              @offboard_groups[group] << hex
              @offboard_list << hex
            end
          end
        end

        def new_offboard_connections(entity)
          new_hexes = []
          @selected_graph.connected_nodes(entity).keys.map(&:hex).each do |hex|
            new_hexes << hex if @offboard_list.include?(hex) && !@offboard_connected[hex]
          end
          new_hexes.uniq
        end

        def make_offboard_connection(hexes)
          hexes.each do |hex|
            @offboard_connected[hex] = true if @offboard_list.include?(hex)
          end
        end

        def all_offboards_connected?
          @offboard_groups.all? { |_k, v| v.any? { |hex| @offboard_connected[hex] } }
        end

        def end_now?(after)
          return true if after == :current_turn

          super
        end

        def game_end_check_offboards?
          all_offboards_connected?
        end

        def game_ending_description
          reason, after = game_end_check
          return unless after

          after_text = ''

          unless @finished
            after_text = case after
                         when :immediate
                           ' : Game Ends immediately'
                         when :current_round
                           if @round.is_a?(Round::Operating)
                             " : Game Ends at conclusion of this OR (#{turn}.#{@round.round_num})"
                           else
                             " : Game Ends at conclusion of this round (#{turn})"
                           end
                         when :current_or
                           " : Game Ends at conclusion of this OR (#{turn}.#{@round.round_num})"
                         when :full_or
                           if @round.is_a?(Round::Operating)
                             " : Game Ends at conclusion of #{round_end.short_name} #{turn}.#{operating_rounds}"
                           else
                             " : Game Ends at conclusion of #{round_end.short_name} #{turn}.#{@phase.operating_rounds}"
                           end
                         when :one_more_full_or_set
                           " : Game Ends at conclusion of #{round_end.short_name}"\
                           " #{@final_turn}.#{final_operating_rounds}"
                         when :current_turn
                           if @round.is_a?(Round::Operating)
                             ' : Game Ends at conclusion of this turn'
                           else
                             ' : Game Ends at conclusion of this SR' # probably never seen
                           end
                         end

          end
          "#{self.class::GAME_END_DESCRIPTION_REASON_MAP_TEXT[reason]}#{after_text}"
        end

        def milano_hex
          @milano_hex = hex_by_id(MILANO)
        end

        def check_overlap(routes)
          if milano_hex.tile.color.to_s == 'yellow' && routes.size > 1 &&
              routes.count { |route| route.hexes.include?(milano_hex) } > 1
            raise GameError, 'Cannot visit Yellow Milano more than once'
          end

          super
        end

        def can_buy_presidents_share_directly_from_market?(corporation)
          (@phase.name.to_i >= 4) || !historical?(corporation)
        end

        def liquidity(player, emergency: false)
          return player.cash unless sellable_turn?

          sellable_value =
            if emergency && @round
              lambda do |player_, corporation|
                (value_for_sellable(player_, corporation) / 2.0).to_i
              end
            else
              lambda do |player_, corporation|
                value_for_dumpable(player_, corporation)
              end
            end

          player.cash + player.shares_by_corporation.sum do |corporation, shares|
            next 0 if shares.empty? || !operated?(corporation)

            sellable_value.call(player, corporation)
          end
        end

        def priority_deal_player
          return @players.reject(&:bankrupt)[0] if @round.is_a?(Round::Operating)

          super
        end

        def render_revenue_history?(corporation)
          operated?(corporation) && super
        end
      end
    end
  end
end
