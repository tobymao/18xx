# frozen_string_literal: true

require_relative 'meta'
require_relative 'map'
require_relative 'entities'
require_relative '../base'
require_relative '../company_price_up_to_face'

module Engine
  module Game
    module G1840
      class Game < Game::Base
        include_meta(G1840::Meta)
        include Map
        include Entities
        include CompanyPriceUpToFace

        register_colors(red: '#d1232a',
                        orange: '#f58121',
                        black: '#110a0c',
                        blue: '#025aaa',
                        purple: '#A79ECD',
                        lightBlue: '#8dd7f6',
                        yellow: '#ffe600',
                        green: '#32763f',
                        brightGreen: '#6ec037')

        TRACK_RESTRICTION = :permissive
        SELL_BUY_ORDER = :sell_buy
        CURRENCY_FORMAT_STR = '%s'

        BANK_CASH = 99_999

        CERT_LIMIT = { 2 => 18, 3 => 16, 4 => 14, 5 => 13, 6 => 12 }.freeze

        STARTING_CASH = { 2 => 350, 3 => 300, 4 => 260, 5 => 230, 6 => 200 }.freeze

        ADDITIONAL_CASH = 350

        OPERATING_ROUND_NAME = 'Line'
        OPERATION_ROUND_SHORT_NAME = 'LRs'

        AVAILABLE_CORP_COLOR = '#c6e9af'
        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false
        EBUY_CAN_SELL_SHARES = false
        ALLOW_TRAIN_BUY_FROM_OTHERS = false

        EBUY_CAN_TAKE_PLAYER_LOAN = true
        PLAYER_LOAN_INTEREST_RATE = -100
        PLAYER_LOAN_ENDGAME_PENALTY = 200

        TILE_LAYS = [{ lay: true, upgrade: true, cost: 0 }, { lay: true, upgrade: true, cost: 0 }].freeze

        GAME_END_CHECK = { fixed_round: :current_round }.freeze

        NEXT_SR_PLAYER_ORDER = :most_cash

        MARKET_TEXT = {
          par: 'City Corporation Par',
          par_2: 'Major Corporation Par',
        }.freeze

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
          par: :red,
          par_2: :green,
        ).freeze

        PAR_RANGE = {
          city: [65, 75, 85, 95],
          major: [70, 80, 90, 100],
        }.freeze

        INITIAL_CITY_PAR = {
          'W' => 95,
          'V' => 85,
          'G' => 75,
          'D' => 65,
        }.freeze

        INITIAL_CITY_TOKENS = {
          'W' => [
            { coordinate: 'I1', ignore_two_player: true },
            { coordinate: 'I9', ignore_two_player: true },
            { coordinate: 'I11', city_index: 1, only_two_player: true },
            { coordinate: 'I15' },
            { coordinate: 'F24' },
          ],
          'V' => [
            { city_index: 1, coordinate: 'A17' },
            { coordinate: 'A13' },
            { coordinate: 'B10' },
            { coordinate: 'C7' },
            { coordinate: 'F6' },
            { coordinate: 'G3' },
          ],
          'G' => [
            { coordinate: 'A17' },
            { coordinate: 'D12' },
            { coordinate: 'I11' },
          ],
          'D' => [
            { city_index: 2, coordinate: 'A17' },
            { coordinate: 'D22' },
            { coordinate: 'E23' },
            { city_index: 1, coordinate: 'F24' },
          ],
        }.freeze

        PROGRESS_INFORMATION = [
          { type: :PRE },
          { type: :SR, name: '1' },
          { type: :CR, name: '1', value: '1x' },
          { type: :LR, name: '1a' },
          { type: :LR, name: '1b' },
          { type: :CR, name: '2', value: '1x' },
          { type: :SR, name: '2' },
          { type: :LR, name: '2a' },
          { type: :LR, name: '2b' },
          { type: :CR, name: '3', value: '1x' },
          { type: :SR, name: '3' },
          { type: :LR, name: '3a' },
          { type: :LR, name: '3b' },
          { type: :CR, name: '4', value: '2x' },
          { type: :SR, name: '4' },
          { type: :LR, name: '4a' },
          { type: :LR, name: '4b' },
          { type: :CR, name: '5', value: '3x' },
          { type: :SR, name: '5' },
          { type: :LR, name: '5a' },
          { type: :LR, name: '5b' },
          { type: :LR, name: '5c' },
          { type: :CR, name: '6', value: '10x' },
          { type: :End },
        ].freeze

        CITY_TRACK_EXITS = {
          # G
          'B16' => [1, 3],
          'B14' => [0, 4],
          'C13' => [0, 3],
          'D12' => [5, 3],
          'E13' => [0, 2],
          'F12' => [0, 3],
          'G11' => [5, 3], # only 2 player
          'H12' => [0, 2],
          # V
          'B10' => [0, 3],
          'C9' => [1, 3],
          'D6' => [5, 3],
          'E7' => [0, 2],
          'F6' => [0, 3],
          'G5' => [1, 3],
          # D
          'B20' => [2, 5],
          'C21' => [2, 5],
          'D22' => [2, 5],
          'E23' => [2, 5],
          # W
          'G23' => [1, 3],
          'G21' => [1, 4],
          'G19' => [1, 4],
          'G17' => [0, 4],
          'H16' => [0, 3],
          'I15' => [1, 3],
          'I13' => [1, 4],
          'I9' => [1, 4],
          'I7' => [1, 4],
          'I5' => [1, 4],
          'I3' => [1, 4],
        }.freeze

        RED_TILES = %w[D20 E19 E21].freeze

        NO_TOKEN_REMOVE_HEX = %w[I1 A17 I11 F24].freeze

        TILES_FIXED_ROTATION = %w[L30a L30b L31a L31b].freeze
        PURPLE_SPECIAL_TILES = {
          'G11' => %w[L30a L31a],
          'F24' => %w[L30b L31b],
        }.freeze

        TRAIN_ORDER = [
          %w[Y1 O1],
          %w[Y2 O2 R1],
          %w[O3 R2 Pi1],
          %w[R3 Pi2 Pu1],
          %w[Pi3 Pu2],
          [],
        ].freeze

        DEPOT_CLEARING = [
          '',
          '',
          'Y1',
          'O1',
          'R1',
        ].freeze

        MAINTENANCE_COST = {
          'Y1' => {},
          'O1' => {},
          'R1' => { 'Y1' => -50 },
          'Pi1' => { 'Y1' => -200, 'O1' => -100, 'R1' => -50 },
          'Pu1' => { 'Y1' => -400, 'O1' => -300, 'R1' => -100, 'Pu1' => 200 },
        }.freeze

        PRICE_MOVEMENT_CHART = [
          ['Dividend', 'Share Price Change'],
          ['0', '1 ←'],
          ['10 - 90', 'none'],
          ['100 - 190', '1 →'],
          ['200 - 390', '2 →'],
          ['400 - 590', '3 →'],
          ['600 - 990', '4 →'],
          ['1000 - 1490', '5 →'],
          ['1500 - 2490', '6 →'],
          ['2500+', '7 →'],
        ].freeze

        TRAIN_FOR_PLAYER_COUNT = {
          2 => { Y1: 2, O1: 3, R1: 3, Pi1: 3, Pu1: 3 },
          3 => { Y1: 4, O1: 4, R1: 4, Pi1: 4, Pu1: 4 },
          4 => { Y1: 6, O1: 5, R1: 5, Pi1: 5, Pu1: 5 },
          5 => { Y1: 8, O1: 6, R1: 6, Pi1: 6, Pu1: 6 },
          6 => { Y1: 10, O1: 7, R1: 7, Pi1: 7, Pu1: 7 },
        }.freeze

        CR_MULTIPLIER = [1, 1, 1, 2, 3, 10].freeze

        THREE_PLAYER_SMALL_REMOVE =  %w[A1 A3 A5 A7 A9 A11 A15 A25 A27 A29 B2 B4 B6 B8 B10 B26 B28 C1 C3 C5 C7 C9 C27
                                        C29 D2 D4 D6 D8 D26 D28 E1 E3 E5 E7 F2 F4 F6 F8 G1 G3 G5].freeze

        TWO_PLAYER_REMOVE = %w[A13 B12 C11 D10 E9 E11 F10 G7 G9 G11 H4 H6 H8 H10 H12 I1 I3 I5 I7 I9 I11 J4 J6 J8 J10 K7].freeze

        THREE_PLAYER_SMALL_ADD = {
          gray: { ['B10'] => 'town=revenue:10;path=a:4,b:_0;path=a:5,b:_0' },
        }.freeze

        TWO_PLAYER_ADD = {
          gray: { ['I11'] => 'city=revenue:30;city=revenue:30;path=a:3,b:_0,track:narrow;path=a:4,b:_1,track:narrow;' },
          white: {
            ['G11'] => 'upgrade=cost:20;frame=color:#ffa500;icon=image:1840/yellow_hex',
            ['H12'] => 'upgrade=cost:20;frame=color:#ffa500;icon=image:1840/red_hex',
          },
        }.freeze

        THREE_PLAYER_LINES_REMOVE = %w[9 10 13 14 16 17].freeze
        TWO_PLAYER_LINES_REMOVE = %w[8 9 10 11 12 13 14 16 17].freeze

        THREE_PLAYER_COMPANY_REMOVE = 'Prater'
        THREE_PLAYER_CORP_REMOVE = 'V'

        TWO_PLAYER_COMPANY_REMOVE = ['Schloss Schönbrunn', 'Prater'].freeze

        attr_reader :tram_corporations, :major_corporations, :tram_owned_by_corporation, :city_graph, :city_tracks

        def setup
          @intern_cr_phase_counter = 0
          @cr_counter = 0
          @first_stock_round = true
          @or = 0
          @active_maintenance_cost = {}
          @last_revenue = Hash.new { |h, k| h[k] = 0 }
          @player_order_first_sr = Hash.new { |h, k| h[k] = 0 }
          @all_tram_corporations = @corporations.select { |item| item.type == :minor }
          @tram_corporations = @all_tram_corporations.reject { |item| item.id == '2' }.sort_by do
            rand
          end.first(@players.size + 1)
          @tram_corporations.each { |corp| corp.reservation_color = self.class::AVAILABLE_CORP_COLOR }
          @unavailable_tram_corporations = @all_tram_corporations - @tram_corporations
          @city_corporations = @corporations.select { |item| item.type == :city }
          @major_corporations = @corporations.select { |item| item.type == :major }
                                .sort_by { rand }.first(@players.size)

          @tram_owned_by_corporation = {}
          @major_corporations.each do |item|
            @tram_owned_by_corporation[item] = []
          end
          @city_corporations.each do |corporation|
            par_value = INITIAL_CITY_PAR[corporation.id]
            price = @stock_market.par_prices.find { |p| p.price == par_value }
            @stock_market.set_par(corporation, price)
            corporation.ipoed = true

            initial_coordinates_info = INITIAL_CITY_TOKENS[corporation.id]

            initial_coordinates_info.each do |info|
              next if info[:ignore_two_player] && two_player?
              next if info[:only_two_player] && !two_player?

              token = corporation.find_token_by_type
              city_index = info[:city_index] || 0
              hex_by_id(info[:coordinate]).tile.cities[city_index].place_token(corporation, token,
                                                                               check_tokenable: false)
            end
            corporation.owner = @share_pool
            train = @depot.upcoming.find { |item| item.name == 'City' }
            @depot.remove_train(train)
            train.owner = corporation
            corporation.trains << train
          end

          @corporations.clear
          @corporations.concat(@major_corporations)
          @corporations.concat(@city_corporations)
          @corporations.concat(@tram_corporations)

          @city_graph = Graph.new(self, skip_track: :broad)

          @city_tracks = {
            'D' => %w[B20 C21 D22 E23],
            'V' => %w[B10 C9 D6 E7 F6 G5],
          }

          @city_tracks['G'] = if two_player?
                                %w[B16 B14 C13 D12 E13 F12 G11 H12]
                              else
                                %w[B16 B14 C13 D12 E13 F12 H12]
                              end

          @city_tracks['W'] = if two_player?
                                %w[G23 G21 G19 G17 H16 I15 I13]
                              else
                                %w[G23 G21 G19 G17 H16 I15 I13 I9 I7 I5 I3]
                              end

          setup_company_price_up_to_face
        end

        def two_player?
          @players.size == 2
        end

        def three_player_small?
          @players.size == 3 && @optional_rules&.include?(:three_player_small)
        end

        def optional_hexes
          return self.class::HEXES if !three_player_small? && !two_player?

          new_hexes = {}
          HEXES.keys.each do |color|
            new_map = self.class::HEXES[color].transform_keys do |coords|
              coords -= THREE_PLAYER_SMALL_REMOVE
              coords -= TWO_PLAYER_REMOVE if two_player?

              coords
            end
            THREE_PLAYER_SMALL_ADD[color]&.each { |coords, tile_str| new_map[coords] = tile_str } if three_player_small?
            TWO_PLAYER_ADD[color]&.each { |coords, tile_str| new_map[coords] = tile_str } if two_player?
            new_hexes[color] = new_map
          end

          new_hexes
        end

        def init_companies(players)
          companies = super
          if two_player? || three_player_small?
            companies = companies.reject do |item|
              item.name == THREE_PLAYER_COMPANY_REMOVE
            end
          end
          companies = companies.reject { |item| TWO_PLAYER_COMPANY_REMOVE.include?(item.name) } if two_player?
          companies
        end

        def init_corporations(stock_market)
          corporations = super
          return corporations if !three_player_small? && !two_player?

          lines_to_remove = if three_player_small?
                              THREE_PLAYER_LINES_REMOVE
                            else
                              TWO_PLAYER_LINES_REMOVE
                            end
          corporations.reject do |item|
            item.id == THREE_PLAYER_CORP_REMOVE ||
            lines_to_remove.include?(item.id)
          end
        end

        def init_graph
          Graph.new(self, skip_track: :narrow)
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G1840::Step::SelectionAuction,
          ])
        end

        def player_order_round
          G1840::Round::Choices.new(self, [
            G1840::Step::ChoosePlayerOrder,
          ])
        end

        def stock_round
          if @first_stock_round
            @log << "Every Player receives #{format_currency(ADDITIONAL_CASH)} to par a corporation"
            @players.each { |item| @bank.spend(ADDITIONAL_CASH, item) }
            @first_stock_round = false
          end
          G1840::Round::Stock.new(self, [
            G1840::Step::BuySellParShares,
          ])
        end

        def init_company_round
          @round_counter += 1
          @intern_cr_phase_counter = 1
          @cr_counter += 1
          @sorted_corporations_for_company_round = operating_order
          remove_obsolete_trains
          @log << "-- #{round_description('Company', nil)} --"
          new_company_operating_route_round
        end

        def new_operating_round(round_num = 1)
          if [2, 6, 8].include?(@or)
            @phase.next!
            @operating_rounds = @phase.operating_rounds
          end
          @log << "-- #{round_description(self.class::OPERATING_ROUND_NAME, round_num)} --"
          @or += 1
          @round_counter += 1
          operating_round(round_num)
        end

        def new_company_operating_route_round
          G1840::Round::Company.new(self, [
            G1840::Step::SellCompany,
            G1840::Step::Route,
            G1840::Step::Dividend,
          ], no_city: false)
        end

        def new_company_operating_buy_train_round
          G1840::Round::Company.new(self, [
            G1840::Step::SellCompany,
            G1840::Step::BuyTrain,
            G1840::Step::ReassignTrains,
          ], no_city: true)
        end

        def new_company_operating_auction_round
          G1840::Round::Acquisition.new(self, [
            G1840::Step::SellCompany,
            G1840::Step::InterruptingReassignTrains,
            G1840::Step::InterruptingBuyTrain,
            G1840::Step::AcquisitionAuction,
          ])
        end

        def operating_round(round_num)
          G1840::Round::Line.new(self, [
            G1840::Step::SellCompany,
            G1840::Step::SpecialTrack,
            G1840::Step::SpecialToken,
            G1840::Step::BuyCompany,
            Engine::Step::HomeToken,
            G1840::Step::TrackAndToken,
            G1840::Step::Route,
            G1840::Step::Dividend,
            [G1840::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Stock
              reorder_players(log_player_order: true)
              if @cr_counter.zero?
                init_company_round
              else
                new_operating_round(@round.round_num)
              end
            when G1840::Round::Company
              @intern_cr_phase_counter += 1
              if @intern_cr_phase_counter < 3
                new_company_operating_buy_train_round
              else
                new_company_operating_auction_round
              end
            when new_company_operating_auction_round.class
              if @cr_counter == 1
                new_operating_round(@round.round_num)
              else
                new_stock_round
              end
            when Engine::Round::Operating
              if @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                init_company_round
              end
            when init_round.class
              player_order_round
            when player_order_round.class
              init_round_finished
              order_for_first_sr
              new_stock_round
            end
        end

        def par_prices(corp)
          par_nodes = stock_market.par_prices
          available_par_prices = PAR_RANGE[corp.type]
          par_nodes.select { |par_node| available_par_prices.include?(par_node.price) }
        end

        def all_major_corporations_ipoed?
          @major_corporations.all?(&:ipoed)
        end

        def can_par?(corporation, parrer)
          super && corporation.type == :major
        end

        def show_progress_bar?
          true
        end

        def progress_information
          self.class::PROGRESS_INFORMATION
        end

        def corporate_card_minors(corporation)
          @tram_owned_by_corporation[corporation] || []
        end

        def owning_major_corporation(corporation)
          @tram_owned_by_corporation.find { |_k, v| v.find { |item| item == corporation } }&.first
        end

        def buy_tram_corporation(buying_corporation, tram_corporation)
          tram_corporation.ipoed = true
          tram_corporation.ipo_shares.each do |share|
            @share_pool.transfer_shares(
              share.to_bundle,
              share_pool,
              spender: share_pool,
              receiver: buying_corporation,
              price: 0,
              allow_president_change: false
            )
          end
          tram_corporation.owner = buying_corporation.owner
          @tram_owned_by_corporation[buying_corporation] << tram_corporation
          @tram_corporations.delete(tram_corporation)
        end

        def restock_tram_corporations
          count_new_tram_corporations = @players.size + 1
          return if count_new_tram_corporations.zero?

          new_tram_corporations = @unavailable_tram_corporations.sort_by { rand }.first(count_new_tram_corporations)
          new_tram_corporations.each { |corp| corp.reservation_color = self.class::AVAILABLE_CORP_COLOR }
          @tram_corporations.concat(new_tram_corporations)
          @corporations.concat(new_tram_corporations)
          @unavailable_tram_corporations -= new_tram_corporations

          @log << '-- New Tram Lines available for next round: ' \
                  "#{new_tram_corporations.sort_by { |item| item.id.to_i }.map(&:id).join(', ')} --"
        end

        def payout_companies
          if (@intern_cr_phase_counter == 1 && @round.is_a?(G1840::Round::Company)) ||
             @round.is_a?(Engine::Round::Auction)
            super
          end
        end

        def place_home_token(corporation)
          super
          @graph.clear
        end

        def buying_power(entity, **)
          return 0 if entity.type == :city
          return entity.cash if entity.type == :major

          owning_major_corporation(entity).cash
        end

        def orange_framed?(tile)
          tile.frame&.color == '#ffa500'
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          if from.towns.empty? && from.cities.empty? && !to.towns.empty? && to.cities.empty? &&
            from.color == :white && to.color == :yellow
            return true
          end
          if orange_framed?(from) && from.towns.size == 1 &&
             to.towns.size == 2 && from.color == :yellow && to.color == :green
            return true
          end

          return true if from.color == :red && to.color == :red && RED_TILES.include?(from.hex.coordinates)
          return true if from.color == :purple && to.color == :purple

          super
        end

        def needed_exits_for_hex(hex)
          CITY_TRACK_EXITS[hex.id]
        end

        def info_train_name(train)
          names = train.names_to_prices.keys.sort
          active_variant = active_variant(train)
          return names.join(', ') unless active_variant

          names -= [active_variant]
          "#{active_variant}, (#{names.join(', ')})"
        end

        def info_available_train(_first_train, train)
          !active_variant(train).nil?
        end

        def info_train_price(train)
          name_and_prices = train.names_to_prices.sort_by { |k, _v| k }.to_h

          active_variant = active_variant(train)
          return name_and_prices.values.map { |p| format_currency(p) }.join(', ') unless active_variant

          active_price = name_and_prices[active_variant]
          name_and_prices.delete(active_variant)

          "#{active_price}, (#{name_and_prices.values.map { |p| format_currency(p) }.join(', ')})"
        end

        def active_variant(train)
          (available_trains & train.variants.keys).first
        end

        def available_trains
          index = [@cr_counter - 1, 0].max
          TRAIN_ORDER[index]
        end

        def remove_obsolete_trains
          train_to_remove = DEPOT_CLEARING[@cr_counter - 1]
          return unless train_to_remove

          @depot.export_all!(train_to_remove)
        end

        def buy_train(operator, train, price = nil)
          super

          new_cost = MAINTENANCE_COST[train.sym]
          @active_maintenance_cost = new_cost if new_cost['Y1'] &&
                                      (@active_maintenance_cost['Y1'].nil? ||
                                         new_cost['Y1'] < @active_maintenance_cost['Y1'])
        end

        def status_str(corporation)
          return "Maintenance: #{format_currency(maintenance_costs(corporation))}" if corporation.type == :minor

          return 'Revenue' if corporation.type == :major
        end

        def status_array(corporation)
          return if corporation.type != :major

          ["Last: #{format_currency(@last_revenue[corporation])}",
           "Next: #{format_currency(major_revenue(corporation))}"]
        end

        def maintenance_costs(corporation)
          corporation.trains.sum { |train| train_maintenance(train.sym) }
        end

        def train_maintenance(train_sym)
          @active_maintenance_cost[train_sym] || 0
        end

        def routes_revenue(routes)
          return super if routes.empty?

          corporation = routes.first.train.owner
          sum = routes.sum(&:revenue)
          return sum + maintenance_costs(corporation) if corporation.type == :minor

          sum * current_cr_multipler
        end

        def revenue_str(route)
          str = super

          return str if route.corporation.type == :city

          valid_stops = route.stops.reject do |s|
            s.hex.tile.cities.empty? && s.hex.tile.towns.empty?
          end
          hex_ids = valid_stops.map { |s| s.hex.id }.uniq

          bonus = []
          major_corp = owning_major_corporation(route.corporation)
          major_corp.companies.each do |company|
            abilities(company, :hex_bonus) do |ability|
              bonus << company.name unless (ability.hexes & hex_ids).empty?
            end
          end

          return str if bonus.empty?

          "#{str} (#{bonus.join(',')})"
        end

        def scrap_train(train, entity)
          @log << "#{entity.name} scraps #{train.name}"
          remove_train(train)
          train.owner = nil
        end

        def check_other(route)
          check_track_type(route)
          check_red_tiles(route)
        end

        def check_track_type(route)
          corporation = route.corporation
          track_types = route.chains.flat_map { |item| item[:paths] }.flat_map(&:track).uniq

          if corporation.type == :city && !(track_types - [:narrow]).empty?
            raise GameError,
                  'Route may only contain narrow tracks'
          end

          return if corporation.type != :minor || (track_types - ['broad']).empty?

          raise GameError, 'Route may only contain broad tracks'
        end

        def check_red_tiles(route)
          visited_hexes = route.stops.map { |s| s.hex.id }.uniq
          RED_TILES.each do |item|
            if visited_hexes.include?(item)
              hex = hex_by_id(item)
              raise GameError, "Route may not connect to #{hex.location_name} yet" if hex.original_tile == hex.tile
            end
          end
        end

        def graph_for_entity(entity)
          return @city_graph if entity.type == :city

          @graph
        end

        def major_revenue(corporation)
          corporate_card_minors(corporation).sum(&:cash)
        end

        def price_movement_chart
          PRICE_MOVEMENT_CHART
        end

        def update_last_revenue(entity)
          @last_revenue[entity] = major_revenue(entity)
        end

        def revenue_for(route, stops)
          # without city or with tokened city
          base_revenue = stops.sum do |stop|
            next 0 if stop.is_a?(Engine::Part::City) && stop.tokens.none? do |token|
              token&.corporation == route.corporation
            end

            stop.route_revenue(route.phase, route.train)
          end

          return base_revenue if route.corporation.type == :city

          valid_stops = stops.reject do |s|
            s.hex.tile.cities.empty? && s.hex.tile.towns.empty?
          end
          hex_ids = valid_stops.map { |s| s.hex.id }.uniq

          major_corp = owning_major_corporation(route.corporation)
          major_corp.companies.each do |company|
            abilities(company, :hex_bonus) do |ability|
              base_revenue += hex_ids&.sum { |id| ability.hexes.include?(id) ? ability.amount : 0 }
            end
          end
          base_revenue
        end

        def check_connected(route, corporation)
          return if corporation.type == :city

          super
        end

        def scrappable_trains(entity)
          corporate_card_minors(entity).flat_map(&:trains) + entity.trains
        end

        def scrap_info(train)
          "Maintenance: #{format_currency(train_maintenance(train.sym))}"
        end

        def scrap_button_text
          'Scrap'
        end

        def num_trains(train)
          num_players = [@players.size, 2].max
          TRAIN_FOR_PLAYER_COUNT[num_players][train[:name].to_sym]
        end

        def set_order_for_first_sr(player, index)
          @player_order_first_sr[player] = index
        end

        def order_for_first_sr
          @players.sort_by! { |p| @player_order_first_sr[p] }
          @log << "Priority order: #{@players.map(&:name).join(', ')}"
        end

        def entity_can_use_company?(entity, company)
          return true if entity.player? && entity == company.owner
          return true if entity.corporation? && company.owner == owning_major_corporation(entity)
          return true if entity.corporation? && company.owner == entity.corporation.owner

          false
        end

        def sell_company_choice(company)
          { { type: :sell } => "Sell for #{format_currency(company.value)} to the bank" }
        end

        def sell_company(company)
          price = company.value
          owner = company.owner

          @log << "#{owner.name} sells #{company.name} for #{format_currency(price)} to the bank"

          @bank.spend(price, owner)

          company.close!
        end

        def current_cr_multipler
          index = [@cr_counter - 1, 0].max
          CR_MULTIPLIER[index]
        end

        def game_end_check_fixed_round?
          @cr_counter == 6
        end

        def game_ending_description
          _, after = game_end_check
          return unless after

          'Game Ends at conclusion of this Company Round'
        end

        def starting_nodes(corporation)
          case corporation.id
          when 'V'
            [hex_by_id('A17').tile.cities[1], hex_by_id('G3').tile.cities.first]
          when 'D'
            [hex_by_id('A17').tile.cities[2], hex_by_id('F24').tile.cities[1]]
          when 'G'
            [hex_by_id('A17').tile.cities.first, hex_by_id('I11').tile.cities.first]
          when 'W'
            nodes = [hex_by_id('F24').tile.cities.first]
            nodes << hex_by_id('I1').tile.cities.first unless two_player?
            nodes << hex_by_id('I11').tile.cities[1] if two_player?
            nodes
          end
        end

        def take_player_loan(player, amount)
          loan_count = (amount / 100.to_f).ceil
          loan_amount = loan_count * 100

          super(player, loan_amount)
        end

        def remove_open_tram_corporations
          @log << '-- All major corporations owns 3 line corporations --'
          @all_tram_corporations.each do |corp|
            close_corporation(corp) unless owning_major_corporation(corp)
          end
        end

        def timeline
          @timeline = ['Green tiles available in LR2, brown tiles in LR4 and grey tiles in LR5.',
                       'Maintenance cost increase when first train bought:',
                       'Red → Yellow: -50 ',
                       'Pink → Yellow: -200 | Orange: -100 | Red: -50  ',
                       'Purple → Yellow: -400 | Orange: -300 | Red: -100 | Purple +200  '].freeze
        end

        def train_actions_always_use_operating_round_view?
          true
        end

        def sorted_corporations
          @sorted_corporations_for_company_round || operating_order
        end
      end
    end
  end
end
