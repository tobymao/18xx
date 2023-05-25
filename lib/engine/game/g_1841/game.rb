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

        HOME_TOKEN_TIMING = :par
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

        def init_graph
          Graph.new(self, check_tokens: true)
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
          entity.corporation? && (entity.type == :major)
        end

        # returns a list of cities with tokens for this corporation
        def railheads(entity)
          return [] unless entity.corporation?

          entity.tokens.select { |t| t.used && t.city && !t.city.pass? }.map(&:city)
        end

        def skip_token?(_graph, _corporation, city)
          city.pass?
        end

        # FIXME: need to deal with SFMA and non-historical corps
        def place_home_token(corporation)
          return if corporation.tokens.first&.used # FIXME: will this work if this token is sold to another corp?

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

        # FIXME
        def ipo_name(_corp)
          'Treasury'
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

        # FIXME
        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            # G1841::Step::BuyTOkens,
            Engine::Step::BuySellParShares,
          ])
        end

        # FIXME
        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            G1841::Step::Track,
            Engine::Step::Token, # FIXME
            Engine::Step::Route,
            Engine::Step::Dividend,
            # G1841::Step::BuyToken,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            # G1841::Step::SellCorpShares,
            # G1841::Step::BuyCorpShares,
            # G1841::Step::Merge,
            # G1841::Step::Transform,
          ], round_num: round_num)
        end
      end
    end
  end
end
