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
        CURRENCY_FORMAT_STR = '%d'

        BANK_CASH = 99_999

        CERT_LIMIT = { 3 => 16, 4 => 14, 5 => 13, 6 => 12 }.freeze

        STARTING_CASH = { 3 => 300, 4 => 260, 5 => 230, 6 => 200 }.freeze

        ADDITIONAL_CASH = 350

        OPERATING_ROUND_NAME = 'Line'

        AVAILABLE_CORP_COLOR = '#c6e9af'
        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false
        EBUY_CAN_SELL_SHARES = false
        ALLOW_TRAIN_BUY_FROM_OTHERS = false

        TILE_LAYS = [{ lay: true, upgrade: true, cost: 0 }, { lay: true, upgrade: true, cost: 0 }].freeze

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

        TILE_COST = 0

        INITIAL_CITY_PAR = {
          'W' => 95,
          'V' => 85,
          'G' => 75,
          'D' => 65,
        }.freeze

        INITIAL_CITY_TOKENS = {
          'W' => [
            { coordinate: 'I1' },
            { coordinate: 'I9' },
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
          { type: :SR, name: '3', value: '1x' },
          { type: :LR, name: '3a' },
          { type: :LR, name: '3b' },
          { type: :CR, name: '4', value: '2x' },
          { type: :SR, name: '4', value: '1x' },
          { type: :LR, name: '4a' },
          { type: :LR, name: '4b' },
          { type: :CR, name: '5', value: '3x' },
          { type: :SR, name: '5', value: '1x' },
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
        ].freeze

        DEPOT_CLEARING = [
          '',
          '',
          'Y1',
          'O1',
          'R1',
        ].freeze

        MAINTAINANCE_COST = {
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

        attr_reader :tram_corporations, :major_corporations, :tram_owned_by_corporation, :city_graph

        def setup
          @intern_cr_phase_counter = 0
          @cr_counter = 0
          @first_stock_round = true
          @or = 0
          @active_maintainance_cost = {}
          @player_debts = Hash.new { |h, k| h[k] = 0 }
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

          setup_company_price_up_to_face
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
          remove_obsolete_trains
          @log << "-- #{round_description('Company', nil)} --"
          new_company_operating_route_round
        end

        def new_operating_round(round_num = 1)
          @log << "-- #{round_description(self.class::OPERATING_ROUND_NAME, round_num)} --"
          @phase.next! if @or == 2 || @or == 6 || @or == 8
          @or += 1
          @round_counter += 1
          operating_round(round_num)
        end

        def new_company_operating_route_round(round_num)
          G1840::Round::CompanyOperating.new(self, [
            G1840::Step::SellCompany,
            G1840::Step::Route,
            G1840::Step::Dividend,
          ], round_num: round_num, no_city: false)
        end

        def new_company_operating_buy_train_round(round_num)
          G1840::Round::CompanyOperating.new(self, [
            G1840::Step::SellCompany,
            G1840::Step::BuyTrain,
          ], round_num: round_num, no_city: true)
        end

        def new_company_operating_auction_round
          G1840::Round::Acquisition.new(self, [
            G1840::Step::SellCompany,
            G1840::Step::InterruptingBuyTrain,
            G1840::Step::AcquisitionAuction,
          ])
        end

        def new_company_operating_switch_trains(round_num)
          G1840::Round::CompanyOperating.new(self, [
            G1840::Step::SellCompany,
            G1840::Step::ReassignTrains,
          ], round_num: round_num, no_city: true)
        end

        def operating_round(round_num)
          G1840::Round::LineOperating.new(self, [
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
              if @cr_counter.zero?
                init_company_round
              else
                new_operating_round(@round.round_num)
              end
            when G1840::Round::CompanyOperating
              @intern_cr_phase_counter += 1
              if @intern_cr_phase_counter < 3
                new_company_operating_buy_train_round
              elsif @intern_cr_phase_counter < 4
                new_company_operating_auction_round
              elsif @cr_counter == 1
                new_operating_round(@round.round_num)
              else
                new_stock_round
              end
            when new_company_operating_auction_round.class
              new_company_operating_switch_trains
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
          @tram_owned_by_corporation.find { |_k, v| v.find { |item| item == corporation } }.first
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
          count_new_tram_corporations = @players.size + 1 - @tram_corporations.size
          return if count_new_tram_corporations.zero?

          new_tram_corporations = @unavailable_tram_corporations.sort_by { rand }.first(count_new_tram_corporations)
          new_tram_corporations.each { |corp| corp.reservation_color = self.class::AVAILABLE_CORP_COLOR }
          @tram_corporations.concat(new_tram_corporations)
          @corporations.concat(new_tram_corporations)
          @unavailable_tram_corporations -= new_tram_corporations
        end

        def payout_companies
          return unless @intern_cr_phase_counter.zero?

          super
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

          return true if from.color == 'red' && to.color == 'red' && RED_TILES.include?(from.hex.coordinates)
          return true if from.color == 'purple' && to.color == 'purple'

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

          new_cost = MAINTAINANCE_COST[train.sym]
          @active_maintainance_cost = new_cost if new_cost['Y1'] &&
                                      (@active_maintainance_cost['Y1'].nil? ||
                                         new_cost['Y1'] < @active_maintainance_cost['Y1'])
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
          @active_maintainance_cost[train_sym] || 0
        end

        def routes_revenue(routes)
          return super if routes.empty?

          corporation = routes.first.train.owner
          routes.sum(&:revenue) + maintenance_costs(corporation)
        end

        def scrap_train(train, entity)
          @log << "#{entity.name} scraps #{train.name}"
          remove_train(train)
          train.owner = nil
        end

        def increase_debt(player, amount)
          @player_debts[player] += amount * 2
        end

        def player_debt(player)
          @player_debts[player]
        end

        def player_value(player)
          super - player_debt(player)
        end

        def check_other(route)
          check_track_type(route)
        end

        def check_track_type(route)
          corporation = route.train.owner
          track_types = route.chains.flat_map { |item| item[:paths] }.flat_map(&:track).uniq

          if corporation.type == :city && !(track_types - [:narrow]).empty?
            raise GameError,
                  'Route may only contain narrow tracks'
          end

          return if corporation.type != :minor || (track_types - ['broad']).empty?

          raise GameError, 'Route may only contain broad tracks'
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
          if route.corporation.type == :city

            # without city or with tokened city
            return stops.sum do |stop|
                     next 0 if !stop.tile.cities.empty? && stop.tile.cities.none? do |city|
                       city.tokens.any? { |token| token&.corporation == route.corporation }
                     end

                     stop.route_revenue(route.phase, route.train)
                   end
          end

          revenue = super

          major_corp = owning_major_corporation(route.corporation)
          major_corp.companies.each do |company|
            abilities(company, :hex_bonus) do |ability|
              revenue += stops.map { |s| s.hex.id }.uniq&.sum { |id| ability.hexes.include?(id) ? ability.amount : 0 }
            end
          end
          revenue
        end

        def check_connected(route, token)
          return if route.corporation.type == :city

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
          num_players = @players.size
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

          false
        end

        def sell_company_choice(company)
          { { type: :sell } => "Sell for #{format_currency(company.value)}" }
        end

        def sell_company(company)
          price = company.value
          player = company.player

          @log << "#{player.name} sells #{company.name} for #{format_currency(price)}"

          @bank.spend(price, player)

          company.close!
        end
      end
    end
  end
end
