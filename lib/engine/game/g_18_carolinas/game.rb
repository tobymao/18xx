# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'entities'
require_relative 'map'
require_relative 'step/buy_sell_par_shares_companies'
require_relative 'step/track'
require_relative 'step/route'
require_relative 'step/dividend'

module Engine
  module Game
    module G18Carolinas
      class Game < Game::Base
        include_meta(G18Carolinas::Meta)
        include Entities
        include Map

        attr_reader :tile_groups, :north_hexes, :south_hexes

        register_colors(green: '#237333',
                        red: '#d81e3e',
                        blue: '#0189d1',
                        lightBlue: '#a2dced',
                        yellow: '#FFF500',
                        orange: '#f48221',
                        brown: '#7b352a')

        CERT_LIMIT = {
          2 => 24,
          3 => 20,
          4 => 16,
          5 => 13,
          6 => 11,
        }.freeze

        STARTING_CASH = {
          2 => 1200,
          3 => 800,
          4 => 600,
          5 => 480,
          6 => 400,
        }.freeze

        MARKET = [
          %w[0
             10
             20
             30
             40
             50
             60p
             70p
             80p
             90p
             100
             110
             125
             140
             160
             180
             200
             225
             250
             275
             300
             325
             350],
        ].freeze

        TRAINS = [
          {
            name: 'X',
            distance: 99,
            price: 1,
            num: 64,
          },
          {
            name: 'Convert',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 0,
            num: 1,
          },
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 2,
            tiles: ['yellow'],
            operating_rounds: 1,
          },
          {
            name: '3',
            train_limit: 2,
            tiles: %w[yellow green],
            operating_rounds: 2,
          },
          {
            name: '4',
            train_limit: 2,
            tiles: %w[yellow green],
            operating_rounds: 2,
          },
          {
            name: '5',
            train_limit: 3,
            tiles: %w[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '6',
            train_limit: 4,
            tiles: %w[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '7',
            train_limit: 5,
            tiles: %w[yellow green brown gray],
            operating_rounds: 3,
          },
          {
            name: '8',
            train_limit: 6,
            tiles: %w[yellow green brown gray],
            operating_rounds: 3,
          },
          {
            name: '8a',
            train_limit: 6,
            tiles: %w[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze

        PAR_BY_LAYER = {
          1 => 90,
          2 => 80,
          3 => 70,
          4 => 60,
        }.freeze

        TOKENS_BY_LAYER = {
          1 => 4,
          2 => 3,
          3 => 3,
          4 => 2,
        }.freeze

        NORTH_CORPORATIONS = %w[NCR SEA WNC WW].freeze
        SOUTH_CORPORATIONS = %w[CAR CSC SR WM].freeze

        CURRENCY_FORMAT_STR = '$%d'
        BANK_CASH = 6_000
        CAPITALIZATION = :full
        MUST_SELL_IN_BLOCKS = false
        MARKET_SHARE_LIMIT = 100
        SELL_BUY_ORDER = :sell_buy
        SELL_AFTER = :first
        PRESIDENT_SALES_TO_MARKET = true
        HOME_TOKEN_TIMING = :operate
        SOLD_OUT_INCREASE = false
        SELL_MOVEMENT = :none
        COMPANY_SALE_FEE = 30
        ADDED_TOKEN_PRICE = 100

        TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }].freeze

        MIN_TRAIN = {
          '2' => 2,
          '3' => 2,
          '4' => 2,
          '5' => 3,
          '6' => 4,
          '7' => 5,
          '8' => 6,
        }.freeze

        MAX_TRAIN = 16

        C_TILES = %w[C1 C2 C3 C4 C5 C6 C7 C8 C9].freeze

        def init_tile_groups
          [
            %w[1 1s],
            %w[2 2s],
            %w[3 3s],
            %w[4 4s],
            %w[5 5s],
            %w[6 6s],
            %w[7 7s],
            %w[8 8s],
            %w[9 9s],
            %w[55 55s],
            %w[56 56s],
            %w[57 57s],
            %w[58 58s],
            %w[C1 C2],
            %w[C3 C4],
            %w[12 12s],
            %w[13 13s],
            %w[14 14s],
            %w[15 15s],
            %w[16 16s],
            %w[19 19s],
            %w[20 20s],
            %w[23 23s],
            %w[24 24s],
            %w[25 25s],
            %w[26 26s],
            %w[27 27s],
            %w[28 28s],
            %w[29 29s],
            %w[87 87s],
            %w[88 88s],
            %w[C5 C6],
            %w[38],
            %w[39],
            %w[40],
            %w[41],
            %w[42],
            %w[43],
            %w[44],
            %w[45],
            %w[46],
            %w[47],
            %w[70],
            %w[C7],
            %w[C8],
            %w[C9],
          ]
        end

        def update_opposites
          by_name = @tiles.group_by(&:name)
          @tile_groups.each do |grp|
            next unless grp.size == 2

            name_a, name_b = grp
            num = by_name[name_a].size
            if num != by_name[name_b].size
              raise GameError, "Sides of double-sided tiles need to have same number (#{name_a}, #{name_b})"
            end

            num.times.each do |idx|
              tile_a = tile_by_id("#{name_a}-#{idx}")
              tile_b = tile_by_id("#{name_b}-#{idx}")

              tile_a.opposite = tile_b
              tile_b.opposite = tile_a
            end
          end
        end

        def init_share_pool
          SharePool.new(self, allow_president_sale: true)
        end

        def setup
          @tile_groups = init_tile_groups
          update_opposites
          @unused_tiles = []

          # find north and south hexes
          @north_hexes = []
          @south_hexes = []
          @hexes.each do |hex|
            tile = hex.tile
            @north_hexes << hex if tile.frame&.color == NORTH_COLOR || tile.frame&.color2 == NORTH_COLOR
            @south_hexes << hex if tile.frame&.color == SOUTH_COLOR || tile.frame&.color2 == SOUTH_COLOR
          end

          @highest_layer = 1
          # randomize layers (tranches) with one North and one South in each
          @layer_by_corp = {}
          @north_corps = @corporations.select { |c| NORTH_CORPORATIONS.include?(c.name) }.sort_by { rand }
          @south_corps = @corporations.select { |c| SOUTH_CORPORATIONS.include?(c.name) }.sort_by { rand }
          @north_corps.zip(@south_corps).each_with_index do |corps, idx|
            layer = idx + 1
            corps.each do |corp|
              @layer_by_corp[corp] = layer
              # add additional tokens for earlier layers
              (TOKENS_BY_LAYER[layer] - 2).times do |_t|
                corp.tokens << Token.new(corp, price: ADDED_TOKEN_PRICE)
              end
            end
          end

          # Distribute privates
          # Rules call for randomizing privates, assigning to players then reordering players
          # based on worth of private
          # Instead, just pass out privates from least to most expensive since player order is already
          # random
          sorted_companies = @companies.sort_by(&:value)
          @players.each_with_index do |player, idx|
            if idx < 4
              company = sorted_companies.shift
              @log << "#{player.name} receives #{company.name} and pays #{format_currency(company.value)}"
              player.spend(company.value, @bank)
              player.companies << company
              company.owner = player
            else
              corp = [@north_corps[0], @south_corps[0]][idx - 4]
              price = par_prices(corp)[0]
              @stock_market.set_par(corp, price)
              share = corp.ipo_shares.first
              @share_pool.buy_shares(player,
                                     share.to_bundle,
                                     exchange: nil,
                                     swap: nil,
                                     allow_president_change: true)
              after_par(corp)
            end
          end

          @conversion_train = @depot.trains.find { |t| t.name == 'Convert' }

          # initialize corp trains
          @corporation_trains = {}
          @corporation_power = {}
          @corporations.each do |corp|
            8.times { buy_train(corp, @depot.depot_trains[0], :free) }
            @corporation_trains[corp] = nil
            @corporation_power[corp] = 5 # FIXME: set to 0 after testing
          end
        end

        def can_ipo?(corp)
          @layer_by_corp[corp] <= current_layer
        end

        def par_prices(corp)
          price = PAR_BY_LAYER[@layer_by_corp[corp]]
          stock_market.par_prices.select { |p| p.price == price }
        end

        def check_new_layer
          layer = current_layer
          @log << "-- Tranche #{layer} corporations now available --" if layer > @highest_layer
          @highest_layer = layer
        end

        def current_layer
          layers = @layer_by_corp.select do |corp, _layer|
            corp.num_ipo_shares.zero?
          end.values
          layers.empty? ? 1 : [layers.max + 1, 4].min
        end

        def init_round
          @log << "-- #{round_description('Stock', 1)} --"
          @round_counter += 1
          stock_round
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            G18Carolinas::Step::BuySellParSharesCompanies,
          ])
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::HomeToken,
            G18Carolinas::Step::Track,
            Engine::Step::Token,
            G18Carolinas::Step::Route,
            G18Carolinas::Step::Dividend,
            Engine::Step::BuyTrain,
          ], round_num: round_num)
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          standard = to.paths.any? { |p| p.track == :broad }
          southern = to.paths.any? { |p| p.track != :broad }

          north = @north_hexes.include?(from.hex)
          south = @south_hexes.include?(from.hex)

          # Can only ever lay standard track in the North
          return false if north && !south && southern

          # Can only ever lay southern track in the South before phase 5
          return false if !north && south && standard && !@phase.available?('5')

          # handle C tiles specially
          return false if from.label.to_s == 'C' && to.color == :yellow && from.cities.size != to.cities.size

          super
        end

        def update_tile_lists!(tile, old_tile)
          @tiles.delete(tile)
          if tile.opposite
            @tiles.delete(tile.opposite)
            @unused_tiles << tile.opposite
          end

          return if old_tile.preprinted

          @tiles << old_tile
          return unless old_tile.opposite

          @unused_tiles.delete(old_tile.opposite)
          @tiles << old_tile.opposite
        end

        def flip_tile!(hex)
          old = hex.tile
          return if old.color != :yellow && old.color != :green
          return if C_TILES.include?(old.name)

          new = old.opposite
          @log << "Flipping tile #{old.name} to #{new.name} in hex #{hex.id}"

          new.rotate!(old.rotation)
          update_tile_lists(new, old)
          hex.lay(new)
        end

        def sorted_corporations
          @corporations.sort_by { |c| @layer_by_corp[c] }
        end

        def corporation_available?(entity)
          entity.corporation? && can_ipo?(entity)
        end

        def status_array(corp)
          layer_str = "Tranche #{@layer_by_corp[corp]}"
          layer_str += ' (N/A)' unless can_ipo?(corp)

          prices = par_prices(corp).map(&:price).sort
          par_str = ("Par #{prices[0]}" unless corp.ipoed)

          status = [[layer_str]]
          status << [par_str] if par_str
          status << %w[Receivership bold] if corp.receivership?

          status
        end

        def conversion_trains
          [@conversion_train]
        end

        def check_route_token(route, token)
          return if route.train.name == 'Convert'

          super
        end

        def enough_power?(entity)
          return false unless entity.corporation?

          @corporation_power[entity] >= MIN_TRAIN[@phase.name]
        end

        def load_corporation_trains(entity)
          operating = entity.operating_history
          last_run = operating[operating.keys.max]&.routes
          return [] unless last_run

          last_run.keys
        end

        def route_trains(entity)
          @corporation_trains[entity] ||= load_corporation_trains(entity)

          # adjust trains that don't meet lower limit
          # - this may cause an illegal set of routes, but will preserve previous run
          @corporation_trains[entity].each do |t|
            if t.distance < MIN_TRAIN[@phase.name]
              t.distance = MIN_TRAIN[@phase.name]
              t.name = MIN_TRAIN[@phase.name].to_s
            end
          end

          if @corporation_trains[entity].empty? && @corporation_power[entity] >= MIN_TRAIN[@phase.name]
            train = entity.trains[0]
            train.distance = MIN_TRAIN[@phase.name]
            train.name = MIN_TRAIN[@phase.name].to_s
            @corporation_trains[entity] = [train]
          end
          @corporation_trains[entity]
        end

        # after running routes, update sizes of trains actually used
        def update_route_trains(entity, routes)
          @corporation_trains[entity] = nil
          routes.each do |route|
            next if route.visited_stops.empty?

            train = route.train
            train.distance = route.visited_stops.size
            train.name = train.distance.to_s
          end
        end

        def adjustable_train_list?
          true
        end

        def adjustable_train_sizes?
          true
        end

        def reset_adjustable_trains!(routes)
          @corporation_trains[routes[0].train.owner] = nil
        end

        def add_route_train(routes)
          entity = routes[0].train.owner
          trains = @corporation_trains[entity]
          current_distance = trains.sum(&:distance)
          return if @corporation_power[entity] - current_distance < MIN_TRAIN[@phase.name]

          new_train = entity.trains.find { |t| !trains.include?(t) }
          new_train.distance = MIN_TRAIN[@phase.name]
          new_train.name = MIN_TRAIN[@phase.name].to_s
          @corporation_trains[entity] << new_train
        end

        def delete_route_train(route)
          train = route.train
          @corporation_trains[train.owner].delete(train)
        end

        def increase_route_train(route)
          train = route.train
          corp = train.owner
          return if train.distance == MAX_TRAIN
          return if route.routes.map(&:train).sum(&:distance) >= @corporation_power[corp]

          train.distance += 1
          train.name = train.distance.to_s
        end

        def decrease_route_train(route)
          train = route.train
          return if train.distance == MIN_TRAIN[@phase.name]

          train.distance -= 1
          train.name = train.distance.to_s
        end

        def check_distance(route, visits)
          if route.train.name == 'Convert'
            raise GameError, 'Route must be specified' if visits.empty?
            raise GameError, 'Route cannot begin/end in a town' if visits.first.town? || visits.last.town?
          end

          super
        end

        def check_connected(route, token)
          return if route.train.name == 'Convert'

          super
        end

        def check_other(route)
          if route.train.name == 'Convert'
            raise GameError, 'Route must have Southern track' unless route.paths.any? { |p| p.track != :broad }
          else
            if route.routes.sum { |r| r.train.distance } > @corporation_power[route.train.owner]
              raise GameError, 'Train sizes exceed train power'
            end

            track_types = {}
            route.paths.each { |path| track_types[path.track] = 1 }
            raise GameError, 'Train cannot use more than one gauge' unless track_types.keys.one?
          end
        end
      end
    end
  end
end
