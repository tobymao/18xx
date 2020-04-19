# frozen_string_literal: true

require_relative '../action/base'
require_relative '../action/bid'
require_relative '../action/buy_company'
require_relative '../action/buy_share'
require_relative '../action/buy_train'
require_relative '../action/discard_train'
require_relative '../action/dividend'
require_relative '../action/lay_tile'
require_relative '../action/par'
require_relative '../action/pass'
require_relative '../action/place_token'
require_relative '../action/run_routes'
require_relative '../action/sell_shares'

require_relative '../bank'
require_relative '../depot'
require_relative '../phase'
require_relative '../player'
require_relative '../share_pool'
require_relative '../stock_market'
require_relative '../round/auction'
require_relative '../round/operating'
require_relative '../round/special'
require_relative '../round/stock'
require_relative '../train'

module Engine
  module Game
    class Base
      attr_reader :actions, :bank, :cert_limit, :cities, :companies, :corporations,
                  :depot, :finished, :hexes, :log, :phase, :players, :round,
                  :share_pool, :special, :stock_market, :tiles, :turn

      BANK_CASH = 12_000

      CURRENCY_FORMAT_STR = '$%d'

      STARTING_CASH = {
        2 => 1200,
        3 => 800,
        4 => 600,
        5 => 480,
        6 => 400,
      }.freeze

      HEXES = {}.freeze

      TRAINS = [
        {
          name: '2',
          distance: 2,
          price: 80,
          rusts_on: '4',
          num: 6,
        },
        {
          name: '3',
          distance: 3,
          price: 180,
          rusts_on: '6',
          num: 5,
        },
        {
          name: '4',
          distance: 4,
          price: 300,
          rusts_on: 'D',
          num: 4,
        },
        {
          name: '5',
          distance: 5,
          price: 450,
          num: 3,
        },
        {
          name: '6',
          distance: 6,
          price: 630,
          num: 2,
        },
        {
          name: 'D',
          distance: 999,
          price: 1100,
          available_on: '6',
          discount: {
            '4': 300,
            '5': 300,
            '6': 300,
            'D': 300,
          },
          num: 20,
        },
      ].freeze

      CERT_LIMIT = {
        2 => 28,
        3 => 20,
        4 => 16,
        5 => 13,
        6 => 11,
      }.freeze

      COMPANIES = [].freeze

      CORPORATIONS = [].freeze

      PHASES = [
        Phase::TWO,
        Phase::THREE,
        Phase::FOUR,
        Phase::FIVE,
        Phase::SIX,
        Phase::D,
      ].freeze

      LOCATION_NAMES = {}.freeze

      CACHABLE = [
        %i[players player],
        %i[corporations corporation],
        %i[companies company],
        %i[trains train],
        %i[hexes hex],
        %i[tiles tile],
        %i[shares share],
        %i[share_prices share_price],
        %i[cities city],
      ].freeze

      def initialize(names, actions: [])
        @turn = 1
        @finished = false
        @log = []
        @actions = []
        @names = names.freeze
        @players = @names.map { |name| Player.new(name) }

        @companies = init_companies(@players)
        @stock_market = init_stock_market
        @corporations = init_corporations(@stock_market)
        @bank = init_bank
        @tiles = init_tiles
        @cert_limit = self.class::CERT_LIMIT[@players.size]

        @depot = init_train_handler
        init_starting_cash(@players, @bank)
        @share_pool = SharePool.new(self)
        @hexes = init_hexes(@companies, @corporations)

        # call here to set up ids for all cities before any tiles from @tiles
        # can be placed onto the map
        @cities = (@hexes.map(&:tile) + @tiles).map(&:cities).flatten

        @phase = init_phase
        @operating_rounds = @phase.operating_rounds

        @round = init_round
        @special = Round::Special.new(@companies, game: self)

        cache_objects
        connect_hexes

        # replay all actions with a copy
        actions.each do |action|
          action = action.copy(self) if action.is_a?(Action::Base)
          process_action(action)
        end
      end

      def current_entity
        @round.current_entity
      end

      def process_action(action)
        return self if @finished

        action = action_from_h(action) if action.is_a?(Hash)
        action.id = current_action_id
        @phase.process_action(action)
        # company special power actions are processed by a different round handler
        if action.entity.is_a?(Company)
          @special.process_action(action)
        else
          @round.process_action(action)
        end
        @actions << action
        next_round! while @round.finished?
        self
      end

      def current_action_id
        @actions.size + 1
      end

      def action_from_h(h)
        klass =
          case h['type']
          when 'bid'
            Action::Bid
          when 'buy_company'
            Action::BuyCompany
          when 'buy_share'
            Action::BuyShare
          when 'buy_train'
            Action::BuyTrain
          when 'discard_train'
            Action::DiscardTrain
          when 'dividend'
            Action::Dividend
          when 'lay_tile'
            Action::LayTile
          when 'par'
            Action::Par
          when 'pass'
            Action::Pass
          when 'place_token'
            Action::PlaceToken
          when 'run_routes'
            Action::RunRoutes
          when 'sell_shares'
            Action::SellShares
          else
            raise GameError, "Unknow action #{h['type']}"
          end

        klass.from_h(h, self)
      end

      def clone(actions)
        self.class.new(@names, actions: actions)
      end

      def rollback
        clone(@actions[0...-1])
      end

      def trains
        @depot.trains
      end

      def shares
        @corporations.flat_map(&:shares)
      end

      def share_prices
        @stock_market.par_prices
      end

      def layout
        :flat
      end

      def format_currency(val)
        self.class::CURRENCY_FORMAT_STR % val
      end

      def purchasable_companies
        @companies.select { |c| c.owner&.player? }
      end

      private

      def init_bank
        Bank.new(self.class::BANK_CASH, log: @log)
      end

      def init_phase
        Phase.new(self.class::PHASES, self)
      end

      def init_round
        new_auction_round
      end

      def init_stock_market
        StockMarket.new(self.class::MARKET)
      end

      def init_companies(players)
        self.class::COMPANIES.map do |company|
          next if players.size < (company[:min_players] || 0)

          Company.new(**company)
        end.compact
      end

      def init_train_handler
        trains = self.class::TRAINS.flat_map do |train|
          train[:num].times.map do |index|
            Train.new(**train, index: index)
          end
        end

        Depot.new(trains, self)
      end

      def init_corporations(stock_market)
        min_price = stock_market.par_prices.map(&:price).min

        self.class::CORPORATIONS.map do |corporation|
          Corporation.new(min_price: min_price, **corporation)
        end
      end

      def init_hexes(companies, corporations)
        self.class::HEXES.map do |color, hexes|
          hexes.map do |coords, tile_string|
            coords.map.with_index do |coord, index|
              tile =
                begin
                  Tile.for(tile_string, preprinted: true, index: index)
                rescue Engine::GameError
                  Tile.from_code(coord, color, tile_string, preprinted: true, index: index)
                end

              # add private companies that block tile lays on this hex
              blocker = companies.find { |c| c.abilities(:blocks_hex)&.dig(:hex) == coord }
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

      def init_tiles
        self.class::TILES.flat_map do |name, num|
          num.times.map { |index| Tile.for(name, index: index) }
        end
      end

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
            calculate_priority_deal
            new_stock_round
          when Round::Stock
            calculate_priority_deal
            new_operating_round
          when Round::Operating
            if @round.round_num < @operating_rounds
              new_operating_round(@round.round_num + 1)
            elsif @bank.broken?
              @finished = true
              results = @players
                .sort_by(&:value)
                .reverse
                .map { |p| "#{p.name} (#{format_currency(p.value)})" }
              @log << "Game over: #{results.join(', ')}"
              @round
            else
              @turn += 1
              @operating_rounds = @phase.operating_rounds
              new_stock_round
            end
          else
            raise "Unexected round type #{@round}"
          end
      end

      def calculate_priority_deal
        rotate_players(@round.last_to_act)
        @log << "#{current_entity.name} has priority deal"
      end

      def rotate_players(last_to_act)
        @players.rotate!(@players.find_index(last_to_act) + 1) if last_to_act
      end

      def new_auction_round
        Round::Auction.new(@players, game: self)
      end

      def new_stock_round
        @log << "-- Stock Round #{@turn} --"
        Round::Stock.new(@players, game: self)
      end

      def new_operating_round(round_num = 1)
        @log << "-- Operating Round #{@turn}.#{round_num} --"
        corps = @corporations.select(&:floated?).sort_by do |corporation|
          share_price = corporation.share_price
          _, column = share_price.coordinates
          [-share_price.price, -column, share_price.corporations.find_index(corporation)]
        end

        Round::Operating.new(corps, game: self, round_num: round_num)
      end

      def cache_objects
        CACHABLE.each do |type, name|
          ivar = "@_#{type}"
          instance_variable_set(ivar, send(type).map { |x| [x.id, x] }.to_h)

          self.class.define_method("#{name}_by_id") do |id|
            instance_variable_get(ivar)[id]
          end
        end
      end
    end
  end
end
