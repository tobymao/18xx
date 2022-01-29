# frozen_string_literal: true

require_relative '../base'
require_relative 'meta'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G21Moon
      class Game < Game::Base
        include_meta(G21Moon::Meta)
        include Entities
        include Map

        attr_reader :bc_graph, :sp_graph, :train_base

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

        CURRENCY_FORMAT_STR = '₡%d'
        BANK_CASH = 12_000
        CERT_LIMIT = { 3 => 15, 4 => 12, 5 => 10 }.freeze
        STARTING_CASH = { 3 => 540, 4 => 410, 5 => 340 }.freeze
        CAPITALIZATION = :incremental
        MUST_SELL_IN_BLOCKS = false
        SELL_MOVEMENT = :down_block
        SOLD_OUT_INCREASE = true
        POOL_SHARE_DROP = :one
        IMPASSABLE_HEX_COLORS = %i[purple orange].freeze

        MARKET = [
          ['', '', '', '', '', '', '', '', '', '', '', '', '', '', '330', '360', '395', '430'],
          ['', '', '100', '110', '120', '130', '140', '150', '160', '175', '195', '215', '240', '265', '295', '325', '360',
           '395'],
          %w[70 80 90p 100 110 120 130 140 150 160 175 190 215 235 260 285 315 345],
          %w[60 70 80p 90 100 110 120 130 140 150 160 175 190 200 220 250 275 300],
          %w[50 60 70p 80 90 100 110 120 130 140 150 160 175 190],
          %w[40 50 60p 70 80 90 100 110 120 130 140 150],
          %w[0c 40 50 60 70 80 90 100 110 120],
        ].freeze

        MARKET_TEXT = {
          par: 'Par value',
          no_cert_limit: 'Corporation shares do not count towards cert limit',
          unlimited: 'Corporation shares can be held above 60%',
          multiple_buy: 'Can buy more than one share in the corporation per turn',
          close: 'Corporation closes',
          endgame: 'End game trigger',
          liquidation: 'Liquidation',
          repar: 'Minor company value',
          ignore_one_sale: 'Ignore first share sold when moving price',
        }.freeze

        PHASES = [
          {
            name: '2',
            train_limit: { BC: 2, SP: 2 },
            tiles: %i[yellow],
            operating_rounds: 2,
          },
          {
            name: '3',
            on: '3',
            train_limit: { BC: 2, SP: 2 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: { BC: 2, SP: 2 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: { BC: 2, SP: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '6',
            train_limit: { BC: 2, SP: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '10',
            on: '10',
            train_limit: { BC: 2, SP: 2 },
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 120,
            rusts_on: '5',
            num: 5,
          },
          {
            name: '3',
            distance: 3,
            price: 150,
            rusts_on: '6',
            num: 4,
          },
          {
            name: '4',
            distance: 4,
            price: 240,
            rusts_on: '10',
            num: 3,
          },
          {
            name: '5',
            distance: 5,
            price: 500,
            num: 2,
          },
          {
            name: '6',
            distance: 6,
            price: 540,
            num: 2,
          },
          {
            name: '10',
            distance: 10,
            price: 730,
            num: 14,
          },
        ].freeze

        HOME_TOKEN_TIMING = :start
        MUST_BUY_TRAIN = :always
        SELL_BUY_ORDER = :sell_buy
        BANKRUPTCY_ENDS_GAME_AFTER = :all_but_one

        # Game will end after 5 sets of ORs - checked in end_now? below
        GAME_END_CHECK = { bankrupt: :immediate, custom: :current_or }.freeze

        GAME_END_REASONS_TEXT = Base::GAME_END_REASONS_TEXT.merge(
          custom: 'Fixed number of ORs'
        )

        # Two lays or upgrades, but only one from each base
        TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: true, upgrade: true },
        ].freeze

        LAST_OR = 11
        SP_HEX = 'E9'
        T_HEX = 'F8'
        T_BONUS = 30
        RIFT_BONUS = 60
        EW_BONUS = 100
        NE_HEXES = %w[K1 L2 L4].freeze
        SE_HEXES = %w[L14 M11 M13].freeze
        NW_HEXES = %w[A3 A5 B2].freeze
        SW_HEXES = %w[B14 C15].freeze
        END_BONUS_VALUE = 50

        ICON_PREFIX = '21Moon/'

        ICON_REVENUES = {
          'RL' => { yellow: 20, green: 20, brown: 20, gray: 20 },
          'BC' => { yellow: 30, green: 30, brown: 30, gray: 30 },
          'X' => { yellow: 20, green: 40, brown: 60, gray: 80 },
          'H' => { yellow: 30, green: 40, brown: 50, gray: 60 },
          'R' => { yellow: 20, green: 20, brown: 40, gray: 50 },
          'A' => { yellow: 40, green: 30, brown: 30, gray: 20 },
          'M' => { yellow: 10, green: 10, brown: 10, gray: 10 },
        }.freeze

        MINERAL_HEXES = %w[A7 A9 B4 B12 D10 E15 F2 H10 I7 J2 J10 K5 K13 L10 H2 E5 G13].freeze

        def reservation_corporations
          corporations + minors
        end

        def init_graph
          Graph.new(self, check_tokens: true)
        end

        def setup
          # We need a total of three graphs:
          # One from just BC (@bc_graph)
          # One from just SP (@sp_graph)
          # One from both (@graph)
          #
          # We always ignore non-BC non-SP tokens however
          #
          @bc_graph = Graph.new(self, check_tokens: true)
          @sp_graph = Graph.new(self, check_tokens: true)
          select_combined_graph

          # randomize minerals
          #
          load_icons
          MINERAL_HEXES.sort_by { rand }.map { |h| hex_by_id(h) }.each_with_index do |hex, idx|
            hex.tile.icons << case idx
                              when 0, 1, 2
                                @icons['X'][:yellow]
                              when 3, 4, 5, 6
                                @icons['H'][:yellow]
                              when 7, 8, 9, 10
                                @icons['R'][:yellow]
                              when 11, 12, 13, 14
                                @icons['A'][:yellow]
                              else
                                @icons['M'][:yellow]
                              end
          end

          # pick one corp to wait until SR3

          # adjust parameters for majors to allow both IPO and treasury stock
          # place BC and SP tokens
          # place BC icon
          #
          @corporations.each do |corp|
            corp.ipo_owner = @bank
            corp.share_holders.keys.each do |sh|
              next if sh == @bank

              sh.shares_by_corporation[corp].dup.each { |share| transfer_share(share, @bank) }
            end
            place_home_token(corp)
            place_sp_token(corp)
            hex_by_id(corp.coordinates).tile.icons << @bc_icon
          end

          # pick one corp to wait until SR3
          #

          @train_base = {}
          @or = 0
          @three_or_round = false
          @end_bonuses = Hash.new { |h, k| h[k] = [] }
        end

        def transfer_share(share, new_owner)
          corp = share.corporation
          corp.share_holders[share.owner] -= share.percent
          corp.share_holders[new_owner] += share.percent
          share.owner.shares_by_corporation[corp].delete(share)
          new_owner.shares_by_corporation[corp] << share
          share.owner = new_owner
        end

        def place_sp_token(corporation)
          sp_token = corporation.tokens.first.dup

          sp_tile = hex_by_id(self.class::SP_HEX).tile
          sp_tile.cities.first.place_token(corporation, sp_token)
          @log << "#{corporation.name} places a token on #{self.class::SP_HEX}"
        end

        def load_icons
          @icons = Hash.new { |h, k| h[k] = {} }
          ICON_REVENUES.keys.each do |root|
            case root
            when 'BC'
              @bc_icon = Part::Icon.new(ICON_PREFIX + 'BC', 'BC', false, false, false)
              %i[yellow green brown gray].each { |color| @icons[root][color] = @bc_icon }
            when 'RL'
              @rl_icon = Part::Icon.new(ICON_PREFIX + 'RL', 'RL', false, false, false)
              %i[yellow green brown gray].each { |color| @icons[root][color] = @rl_icon }
            else
              %i[yellow green brown gray].each do |color|
                full = root + '_' + color.to_s
                @icons[root][color] = Part::Icon.new(ICON_PREFIX + full, full, false, false, false)
              end
            end
          end
        end

        def skip_token?(graph, corporation, city)
          if graph == @bc_graph
            city.hex.id != corporation.coordinates
          elsif graph == @sp_graph
            city.hex.id != self.class::SP_HEX
          else
            city.hex.id != corporation.coordinates &&
              city.hex.id != self.class::SP_HEX
          end
        end

        def select_combined_graph
          @selected_graph = @graph
        end

        def select_bc_graph
          @selected_graph = @bc_graph
        end

        def select_sp_graph
          @selected_graph = @sp_graph
        end

        def graph_for_entity(_entity)
          @selected_graph
        end

        def token_graph_for_entity(_entity)
          @bc_graph
        end

        def upgrades_to_correct_color?(from, to)
          case from.color
          when :red, :gray
            to.color == :yellow
          else
            super
          end
        end

        def new_corporate_round
          @log << "-- #{round_description('Corporate')} --"
          @round_counter += 1
          corporate_round
        end

        def corporate_round
          G21Moon::Round::Corporate.new(self, [
            G21Moon::Step::CorporateBuySellShares,
          ])
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            G21Moon::Step::TradeStock,
            G21Moon::Step::BuySellParShares,
          ])
        end

        def new_operating_round(round_num = 1)
          @or += 1

          if @or == 9
            @operating_rounds = 3
            @three_or_round = true
          end

          super
        end

        def or_round_finished
          # In case we get phase change during the last OR set we ensure we have 3 ORs
          @operating_rounds = 3 if @three_or_round
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            G21Moon::Step::Track,
            G21Moon::Step::Token,
            G21Moon::Step::Route,
            G21Moon::Step::Dividend,
            G21Moon::Step::BuyTrain,
          ], round_num: round_num)
        end

        def next_round!
          @round =
            case @round
            when Round::Corporate
              @operating_rounds = @phase.operating_rounds
              new_operating_round
            when Engine::Round::Stock
              reorder_players
              new_corporate_round
            when Engine::Round::Operating
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
              reorder_players
              new_stock_round
            end
        end

        # Game will end directly after the end of OR 11
        def end_now?(_after)
          @or == LAST_OR
        end

        # ignore minors
        def operating_order
          @corporations.select(&:floated?).sort
        end

        def operated_operators
          @corporations.select(&:operated?)
        end

        def route_bonus(stops)
          bonus = { revenue: 0 }

          east = stops.find { |stop| stop.groups.include?('E') }
          west = stops.find { |stop| stop.groups.include?('W') }
          terminal = stops.find { |stop| stop.hex.id == T_HEX }

          if east && west
            bonus[:revenue] += EW_BONUS
            bonus[:description] = 'E/W'
          end

          if east && terminal
            bonus[:revenue] += T_BONUS
            if bonus[:description]
              bonus[:description] += '+Term'
            else
              bonus[:description] = 'Term'
            end
          end

          bonus
        end

        def update_icon(old_icon, new_tile)
          @icons[icon_base(old_icon)][new_tile.color]
        end

        def icon_base(icon)
          name = icon.name
          name[0...name.index('_')]
        end

        def icon_revenue(stop)
          tile = stop.tile
          return 0 if tile.icons.empty?

          tile.icons.sum { |i| ICON_REVENUES[icon_base(i)][tile.color] }
        end

        def revenue_for(route, stops)
          stops.sum do |stop|
            stop.route_revenue(route.phase, route.train) + icon_revenue(stop)
          end + route_bonus(stops)[:revenue]
        end

        def revenue_str(route)
          str = super
          bonus = route_bonus(route.stops)[:description]
          str += " + #{bonus}" if bonus
          str
        end

        def bank_sort(corporations)
          corporations.reject(&:minor?).sort_by(&:name)
        end

        def bc_trains(corporation)
          corporation.trains.select { |t| @train_base[t] == :bc }
        end

        def sp_trains(corporation)
          corporation.trains.select { |t| @train_base[t] == :sp }
        end

        def route_trains(entity)
          bc_trains(entity) + sp_trains(entity)
        end

        def visited_base?(entity, base, route)
          (base == :sp && route.visited_stops.any? { |s| s.hex.id == SP_HEX }) ||
            (base == :bc && route.visited_stops.any? { |s| s.hex.id != SP_HEX && s.city? && s.tokened_by?(entity) })
        end

        def intersects?(route_a, route_b)
          visits_a = route_a.visited_stops
          visits_b = route_b.visited_stops
          visits_a.any? { |s| visits_b.include?(s) }
        end

        def check_other(route)
          # this route must visit corresponding base, OR it must
          # intersect with a route that does
          this_train = route.train
          base = @train_base[this_train]
          return if visited_base?(this_train.owner, base, route)

          other_route = route.routes.find { |r| r.train != this_train && @train_base[r.train] == base }
          return if other_route && visited_base?(this_train.owner, base, other_route) && intersects?(route, other_route)

          raise GameError, "Must visit #{base.to_s.upcase}" unless other_route

          raise GameError, "Must visit #{base.to_s.upcase} or intersect with a route that does"
        end

        def sp_revenue(routes)
          routes_revenue(routes.select { |r| @train_base[r.train] == :sp })
        end

        def bc_revenue(routes)
          routes_revenue(routes.select { |r| @train_base[r.train] == :bc })
        end

        def submit_revenue_str(routes, _render_halts)
          "#{format_revenue_currency(sp_revenue(routes))} (+#{format_revenue_currency(bc_revenue(routes))} Withhold)"
        end

        def assign_base(train, base)
          @train_base[train] = base
        end

        def trains_str(corporation)
          if corporation.trains.empty?
            'None'
          else
            bc = bc_trains(corporation)
            sp = sp_trains(corporation)
            str = ''
            str += 'BC:' + bc.map(&:name).join(' ') unless bc.empty?
            str += ' ' if !bc.empty? && !sp.empty?
            str += 'SP:' + sp.map(&:name).join(' ') unless sp.empty?
            str
          end
        end

        def train_name(train)
          "#{train.name} (#{@train_base[train].to_s.upcase})"
        end

        def update_end_bonuses(corp, routes)
          offboards = {}
          routes.each do |r|
            r.hexes.each do |h|
              hid = h.id
              offboards['NE'] = true if NE_HEXES.include?(hid)
              offboards['SE'] = true if SE_HEXES.include?(hid)
              offboards['NW'] = true if NW_HEXES.include?(hid)
              offboards['SW'] = true if SW_HEXES.include?(hid)
            end
          end

          offboards.keys.each do |k|
            unless @end_bonuses[corp].include?(k)
              @end_bonuses[corp] << k
              @log << "#{corp.name} receives '#{k}' end game bonus token"
            end
          end
        end

        def timeline
          @timeline ||= [
            'SR 3: 7th corporation becomes available',
            'OR 3.2: Space Port upgraded to 30c',
            'OR 4.1: Remaining private companies close',
            'OR 5.1: Space Port upgraded to 40c',
            'Game ends after OR 5.3',
          ].freeze
          @timeline
        end

        def show_progress_bar?
          true
        end

        def progress_information
          [
            { type: :PRE },
            { type: :SR, name: '1' },
            { type: :CR, name: '1', color: :yellow },
            { type: :OR, name: '1.1' },
            { type: :OR, name: '1.2' },
            { type: :SR, name: '2' },
            { type: :CR, name: '2', color: :yellow },
            { type: :OR, name: '2.1' },
            { type: :OR, name: '2.2' },
            { type: :SR, name: '3' },
            { type: :CR, name: '3', color: :yellow },
            { type: :OR, name: '3.1' },
            { type: :OR, name: '3.2' },
            { type: :SR, name: '4' },
            { type: :CR, name: '4', color: :yellow },
            { type: :OR, name: '4.1' },
            { type: :OR, name: '4.2' },
            { type: :SR, name: '5' },
            { type: :CR, name: '5', color: :yellow },
            { type: :OR, name: '5.1' },
            { type: :OR, name: '5.2' },
            { type: :OR, name: '5.3' },
            { type: :End },
          ]
        end

        def separate_treasury?
          true
        end

        def ipo_name(_corp)
          'IPO'
        end

        def status_str(corp)
          return if @end_bonuses[corp].empty?

          "End game bonus#{@end_bonuses[corp].one? ? '' : 'es'}: #{@end_bonuses[corp].join(',')}"
        end

        def player_value(player)
          value = super
          value += shares.sum { |s| @end_bonuses[s.corporation].size * END_BONUS_VALUE } if @finished
          value
        end
      end
    end
  end
end
