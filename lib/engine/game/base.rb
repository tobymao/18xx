# frozen_string_literal: true

require 'engine/bank'
require 'engine/map'
require 'engine/phase'
require 'engine/player'
require 'engine/share_pool'
require 'engine/stock_market'
require 'engine/round/auction'
require 'engine/round/operating'
require 'engine/round/stock'
require 'engine/train/base'
require 'engine/train/depot'

module Engine
  module Game
    class Base
      attr_reader :actions, :bank, :companies, :corporations, :depot, :hexes, :log,
                  :map, :phase, :players, :round, :share_pool, :stock_market, :tiles, :turn

      STARTING_CASH = {
        2 => 1200,
        3 => 800,
        4 => 600,
        5 => 480,
        6 => 400,
      }.freeze

      HEXES = {
        white: {
          %w[A1] => 'blank',
          %w[B2] => 'city',
          %w[A3] => 'c=r:0;l=A;u=c:30',
        },
      }.freeze

      PHASES = [
        Phase::YELLOW,
        Phase::GREEN,
        Phase::GREEN.merge(on: '4', train_limit: 3, events: { rust: '2' }),
        Phase::BROWN,
        Phase::BROWN.merge(on: '6', events: { rusts: '3' }),
        Phase::GRAY,
      ].freeze

      LOCATION_NAMES = {
        'A3' => 'Exampleville',
      }.freeze

      def initialize(names, actions: [])
        @turn = 1
        @log = []
        @actions = []
        @names = names.freeze
        @players = @names.map { |name| Player.new(name) }

        @companies = init_companies
        @corporations = init_corporations
        @stock_market = init_stock_market
        @bank = init_bank
        @tiles = init_tiles

        @depot = init_train_handler(@bank)
        init_starting_cash(@players, @bank)
        @share_pool = SharePool.new(@corporations, @bank)
        @hexes = init_hexes(@companies, @corporations)
        @map = Map.new(@hexes)

        @phase = init_phase(@depot.trains, @log)
        @operating_rounds = @phase.operating_rounds

        @round = init_round
        set_ids
        connect_hexes

        # replay all actions with a copy
        actions.each { |action| process_action(action.copy(self)) }
      end

      def current_entity
        @round.current_entity
      end

      def process_action(action)
        @round.process_action(action)
        @phase.process_action(action)
        @actions << action
        next_round! while @round.finished?
      end

      def rollback
        self.class.new(@names, actions: @actions[0...-1])
      end

      def player_by_name(name)
        @_players ||= @players.map { |p| [p.name, p] }.to_h
        @_players[name]
      end

      def corporation_by_name(name)
        @_corporations ||= @corporations.map { |c| [c.name, c] }.to_h
        @_corporations[name]
      end

      def company_by_name(name)
        @_companies ||= @companies.map { |c| [c.name, c] }.to_h
        @_companies[name]
      end

      def hex_by_name(name)
        @_hexes ||= @hexes.map { |h| [h.name, h] }.to_h
        @_hexes[name]
      end

      def tile_by_id(id)
        @_tiles ||= @tiles.map { |t| [t.id, t] }.to_h
        @_tiles[id]
      end

      def city_by_id(id)
        @_cities ||= @cities.map { |c| [c.id, c] }.to_h
        @_cities[id]
      end

      def train_by_id(id)
        @_trains ||= @depot.trains.map { |t| [c.id, t] }.to_h
        @_trains[id]
      end

      def share_by_name(name)
        @_shares ||= @corporations.flat_map do |c|
          c.shares.map { |s| [s.name, s] }
        end
        @_shares[name]
      end

      def layout
        :flat
      end

      private

      def init_bank
        Bank.new(12_000)
      end

      def init_phase(trains, log)
        Phase.new(self.class::PHASES, trains, log)
      end

      def init_round
        new_auction_round
      end

      def init_stock_market
        StockMarket.new(self.class::MARKET)
      end

      def init_companies
        [
          Company::Base.new('Mohawk', value: 20, income: 5),
          Company::TileLaying.new('PRR', value: 30, income: 5),
        ]
      end

      def init_train_handler(bank)
        trains = 6.times.map { Train::Base.new('2', distance: 2, price: 80) } +
          5.times.map { Train::Base.new('3', distance: 3, price: 180) } +
          4.times.map { Train::Base.new('4', distance: 4, price: 300) } +
          3.times.map { Train::Base.new('5', distance: 5, price: 450) } +
          2.times.map { Train::Base.new('6', distance: 6, price: 630) } +
          20.times.map { Train::Base.new('D', distance: 999, price: 1100) }
        Train::Depot.new(trains, bank: bank)
      end

      def init_corporations
        []
      end

      def init_hexes(companies, corporations)
        self.class::HEXES.map do |color, hexes|
          hexes.map do |coords, tile_string|
            coords.map do |coord|
              tile =
                begin
                  Tile.for(tile_string)
                rescue Engine::GameError
                  name = coords
                  code = tile_string
                  Tile.from_code(name, color, code)
                end

              # add private companies that block tile lays on this hex
              blocker = companies.find { |c| c.blocks_hex == coord }
              tile.add_blocker!(blocker) unless blocker.nil?

              # reserve corporation home spots
              corporations.select { |c| c.coordinates == coord }.each do |c|
                tile.cities.first.add_reservation!(c.sym)
              end

              # name the location (city/town)
              location_name = self.class::LOCATION_NAMES[coord]

              Hex.new(coord, layout: layout, tile: tile, location_name: location_name)
            end
          end
        end.flatten
      end

      def init_tiles; end

      def init_starting_cash(players, bank)
        cash = self.class::STARTING_CASH[players.size]

        players.each do |player|
          bank.spend(cash, player)
        end
      end

      def connect_hexes
        coordinates = @hexes.map { |h| [[h.x, h.y], h] }.to_h

        @hexes.each do |hex|
          Hex::DIRECTIONS[hex.layout].each do |xy, direction|
            x, y = xy
            neighbor = coordinates[[hex.x + x, hex.y + y]]
            next unless neighbor
            next if neighbor.tile.color == :gray && !neighbor.targeting?(hex)

            hex.neighbors[direction] = neighbor
          end
        end
      end

      def next_round!
        @round.entities.each(&:unpass!)

        @round =
          case @round
          when Round::Auction
            rotate_players(@round.last_to_act)
            @companies.all?(&:owner) ? new_stock_round : new_operating_round
          when Round::Stock
            rotate_players(@round.last_to_act)
            new_operating_round
          when Round::Operating
            if @round.round_num < @operating_rounds
              new_operating_round(@round.round_num + 1)
            else
              @turn += 1
              @operating_rounds = @phase.operating_rounds
              @companies.all?(&:owner) ? new_stock_round : new_auction_round
            end
          else
            raise "Unexected round type #{@round}"
          end
      end

      def rotate_players(last_to_act)
        @players.rotate!(@players.find_index(last_to_act) + 1) if last_to_act
      end

      def new_auction_round
        @log << "-- Auction Round #{@turn} --"
        Round::Auction.new(@players, log: @log, companies: @companies, bank: @bank)
      end

      def new_stock_round
        @log << "-- Stock Round #{@turn} --"
        Round::Stock.new(
          @players,
          log: @log,
          can_sell: @turn > 1,
          share_pool: @share_pool,
          stock_market: @stock_market,
        )
      end

      def new_operating_round(round_num = 1)
        @log << "-- Operating Round #{@turn}.#{round_num} --"

        corps = @corporations.select(&:floated?).sort_by do |corporation|
          share_price = corporation.share_price
          _, column = share_price.coordinates
          [-share_price.price, -column, share_price.corporations.find_index(corporation)]
        end

        Round::Operating.new(
          corps,
          log: @log,
          hexes: @hexes,
          tiles: @tiles,
          phase: @phase,
          companies: @companies,
          bank: @bank,
          depot: @depot,
          players: @players,
          stock_market: @stock_market,
          round_num: round_num,
        )
      end

      def set_ids
        @tiles.each.with_index do |tile, index|
          tile.id = index
        end

        @tiles.flat_map(&:cities).each.with_index do |city, index|
          city.id = index
        end

        @depot.upcoming.each.with_index do |train, index|
          train.id = index
        end
      end
    end
  end
end
