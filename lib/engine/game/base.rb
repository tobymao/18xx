# frozen_string_literal: true

if RUBY_ENGINE == 'opal'
  require_tree '../action'
  require_tree '../round'
else
  require 'require_all'
  require 'json'
  require_rel '../action'
  require_rel '../round'
end

require_relative '../bank'
require_relative '../company'
require_relative '../corporation'
require_relative '../depot'
require_relative '../hex'
require_relative '../phase'
require_relative '../player'
require_relative '../share_pool'
require_relative '../stock_market'
require_relative '../tile'
require_relative '../train'

module Engine
  module Game
    class Base
      attr_reader :actions, :bank, :cert_limit, :cities, :companies, :corporations,
                  :depot, :finished, :hexes, :id, :log, :phase, :players, :round,
                  :share_pool, :special, :stock_market, :tiles, :turn, :undo_possible, :redo_possible
      DEV_STAGE = :prealpha
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
            '4' => 300,
            '5' => 300,
            '6' => 300,
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

      CERT_LIMIT_COLORS = %i[brown orange yellow].freeze

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

      def self.title
        name.split('::').last.slice(1..-1)
      end

      def self.load_from_json(json)
        data = JSON.parse(json)

        # Make sure player objects have numeric keys
        data['bankCash'].transform_keys!(&:to_i) if data['bankCash'].is_a?(Hash)
        data['certLimit'].transform_keys!(&:to_i) if data['certLimit'].is_a?(Hash)
        data['startingCash'].transform_keys!(&:to_i) if data['startingCash'].is_a?(Hash)

        data['phases'].map! do |phase|
          phase.transform_keys!(&:to_sym)
          phase[:tiles]&.map!(&:to_sym)
          phase[:events]&.transform_keys!(&:to_sym)

          phase
        end

        data['trains'].map! do |train|
          train.transform_keys!(&:to_sym)
        end

        data['companies'].map! do |company|
          company.transform_keys!(&:to_sym)
          company[:abilities]&.map! do |ability|
            ability.transform_keys!(&:to_sym)
            ability.transform_values! do |value|
              value.respond_to?(:to_sym) ? value.to_sym : value
            end
          end
          company
        end

        data['corporations'].map! do |company|
          company.transform_keys!(&:to_sym)
        end

        data['hexes'].transform_keys!(&:to_sym)
        data['hexes'].transform_values!(&:invert)

        const_set(:CURRENCY_FORMAT_STR, data['currencyFormatStr'])
        const_set(:BANK_CASH, data['bankCash'])
        const_set(:CERT_LIMIT, data['certLimit'])
        const_set(:STARTING_CASH, data['startingCash'])
        const_set(:TILES, data['tiles'])
        const_set(:LOCATION_NAMES, data['locationNames'])
        const_set(:MARKET, data['market'])
        const_set(:PHASES, data['phases'])
        const_set(:TRAINS, data['trains'])
        const_set(:COMPANIES, data['companies'])
        const_set(:CORPORATIONS, data['corporations'])
        const_set(:HEXES, data['hexes'])
      end

      def initialize(names, id: 0, actions: [])
        @id = id
        @turn = 1
        @finished = false
        @log = []
        @actions = []
        @names = names.freeze
        @players = @names.map { |name| Player.new(name) }

        case self.class::DEV_STAGE
        when :prealpha
          @log << "#{self.class.title} is in prealpha state, no support is provided at all"
        when :alpha
          @log << "#{self.class.title} is currently considered 'alpha',"\
          ' the rules implementation is likely to not be complete.'
          @log << 'As the implementation improves, games that are not compatible'\
          ' with the latest version will be deleted.'
          @log << 'We suggest that any alpha quality game is concluded within 7 days.'
        when :beta
          @log << "#{self.class.title} is currently considered 'beta',"\
          ' the rules implementation may allow illegal moves.'
          @log << 'As the implementation improves, games that are not compatible'\
          ' with the latest version will be given 7 days to be completed before being deleted.'
          @log << 'Because of this we suggest not playing games that may take months to complete.'
        end

        @companies = init_companies(@players)
        @stock_market = init_stock_market
        @corporations = init_corporations(@stock_market)
        @bank = init_bank
        @tiles = init_tiles
        @cert_limit = init_cert_limit

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

        initialize_actions(actions)
      end

      def inspect
        "#{self.class.name} - #{self.class.title} #{@players.map(&:name)}"
      end

      def result
        @players
          .sort_by(&:value)
          .reverse
          .map { |p| [p.name, p.value] }
          .to_h
      end

      def current_entity
        @round.current_entity
      end

      def active_players
        @round.active_entities.map(&:owner)
      end

      # Initialize actions respecting the undo state
      def initialize_actions(actions)
        active_undos = []
        filtered_actions = Array.new(actions.size)

        actions.each.with_index do |action, index|
          case action['type']
          when 'undo'
            i = filtered_actions.rindex { |a| a && a['type'] != 'message' }
            active_undos << [filtered_actions[i], i]
            filtered_actions[i] = nil
          when 'redo'
            a, i = active_undos.pop
            filtered_actions[i] = a
          when 'message'
            # Messages do not get undoed.
            # warning adding more types of action here will break existing game
            filtered_actions[index] = action
          else
            active_undos = []
            filtered_actions[index] = action
          end
        end

        @undo_possible = false
        # replay all actions with a copy
        filtered_actions.each.with_index do |action, index|
          if !action.nil?
            action = action.copy(self) if action.is_a?(Action::Base)
            process_action(action)
          else
            # Restore the original action to the list to ensure action ids remain consistent but don't apply them
            @actions << actions[index]
          end
        end
        @redo_possible = active_undos.any?
      end

      def process_action(action)
        action = action_from_h(action) if action.is_a?(Hash)
        action.id = current_action_id

        if action.is_a?(Action::Undo) || action.is_a?(Action::Redo)
          @actions << action
          return clone(@actions)
        end

        return self if @finished && !action.is_a?(Action::Message)

        @phase.process_action(action)
        # company special power actions are processed by a different round handler
        if action.entity.is_a?(Company)
          @special.process_action(action)
        else
          @round.process_action(action)
        end

        unless action.is_a?(Action::Message)
          @redo_possible = false
          @undo_possible = true
        end

        @actions << action
        next_round! while @round.finished? && !@finished
        self
      rescue GameError => e
        # Fill in the action id
        e.action_id = current_action_id
        raise
      end

      def current_action_id
        @actions.size + 1
      end

      def action_from_h(h)
        Object
          .const_get("Engine::Action::#{Action::Base.type(h['type'])}")
          .from_h(h, self)
      end

      def clone(actions)
        self.class.new(@names, id: @id, actions: actions)
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
        cash = self.class::BANK_CASH
        cash = cash[players.size] if cash.is_a?(Hash)

        Bank.new(cash, log: @log)
      end

      def init_cert_limit
        cert_limit = self.class::CERT_LIMIT
        cert_limit.is_a?(Hash) ? cert_limit[players.size] : cert_limit
      end

      def init_phase
        Phase.new(self.class::PHASES, self)
      end

      def init_round
        new_auction_round
      end

      def init_stock_market
        StockMarket.new(self.class::MARKET, self.class::CERT_LIMIT_COLORS)
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
              blocker = companies.find { |c| c.abilities(:blocks_hexes)&.dig(:hexes)&.include?(coord) }
              tile.add_blocker!(blocker) unless blocker.nil?

              # reserve corporation home spots
              corporations.select { |c| c.coordinates == coord }.each do |c|
                tile.cities.first.add_reservation!(c.name)
              end

              # name the location (city/town)
              location_name = self.class::LOCATION_NAMES[coord]

              Hex.new(coord, layout: layout, tile: tile, location_name: location_name)
            end
          end
        end.flatten
      end

      def init_tiles
        self.class::TILES.flat_map do |name, val|
          if val.is_a?(Integer)
            count = val
            count.times.map { |i| Tile.for(name, index: i) }
          else
            count = val[:count]
            color = val[:color]
            code = val[:code]
            count.times.map { |i| Tile.from_code(name, color, code, index: i) }
          end
        end
      end

      def init_starting_cash(players, bank)
        cash = self.class::STARTING_CASH
        cash = cash[players.size] if cash.is_a?(Hash)

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

        @hexes.select { |h| h.tile.cities.any? || h.tile.exits.any? }.each(&:connect!)
      end

      def next_round!
        @round.entities.each(&:unpass!)

        return end_game if @round.end_game

        @round =
          case @round
          when Round::Auction
            reorder_players
            new_stock_round
          when Round::Stock
            reorder_players
            new_operating_round
          when Round::Operating
            return end_game if @round.bankrupt

            if @round.round_num < @operating_rounds
              new_operating_round(@round.round_num + 1)
            elsif @bank.broken?
              end_game
            else
              @turn += 1
              @operating_rounds = @phase.operating_rounds
              new_stock_round
            end
          else
            raise "Unexected round type #{@round}"
          end
      end

      def end_game
        @finished = true
        scores = result.map { |name, value| "#{name} (#{format_currency(value)})" }
        @log << "Game over: #{scores.join(', ')}"
        @round
      end

      def priority_deal_player
        if @round.current_entity.player?
          # We're in a round that iterates over players, so the
          # priority deal card goes to the player who will go first if
          # everyone passes starting now.  last_to_act is nil before
          # anyone has gone, in which case the first player has PD.
          last_to_act = @round.last_to_act
          priority_idx = last_to_act ? (@players.find_index(last_to_act) + 1) % @players.size : 0
          @players[priority_idx]
        else
          # We're in a round that iterates over something else, like
          # corporations.  The player list was already rotated when we
          # left a player-focused round to put the PD player first.
          @players[0]
        end
      end

      def reorder_players
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
        Round::Operating.new(
          @corporations.select(&:floated?).sort,
          game: self,
          round_num: round_num,
        )
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
