# frozen_string_literal: true

require 'engine/action/buy_train'
require 'engine/action/dividend'
require 'engine/action/lay_tile'
require 'engine/action/run_routes'
require 'engine/round/base'

module Engine
  module Round
    class Operating < Base
      attr_reader :depot, :phase, :round_num, :step

      STEPS = %i[
        track
        token
        route
        dividend
        train
      ].freeze

      STEP_DESCRIPTION = {
        track: 'Lay Track',
        token: 'Place a Token',
        route: 'Run Routes',
        dividend: 'Pay or Withold Dividends',
        train: 'Buy Trains',
      }.freeze

      # rubocop:disable Metrics/ParameterLists
      def initialize(entities, log:, hexes:, tiles:, phase:, companies:, bank:,
                     depot:, players:, stock_market:, round_num: 1)
        # rubocop:enable Metrics/ParameterLists
        super
        @round_num = round_num
        @hexes = hexes
        @tiles = tiles
        @phase = phase
        @companies = companies
        @bank = bank
        @depot = depot
        @players = players
        @stock_market = stock_market
        @step = self.class::STEPS.first
        @current_routes = []

        companies_payout
        place_home_stations
      end

      def description
        self.class::STEP_DESCRIPTION[@step]
      end

      def pass(_entity)
        next_step!
      end

      def next_step!
        current_index = self.class::STEPS.find_index(@step)

        if current_index < self.class::STEPS.size - 1
          case (@step = self.class::STEPS[current_index + 1])
          when :token
            return next_step! if @current_entity.tokens.none?

            next_step! unless layable_hexes.keys.any? do |hex|
              hex.tile.cities.any? do |city|
                city.tokenable?(@current_entity)
              end
            end
          when :route
            next_step! unless @current_entity.trains.any?
          when :dividend
            if @current_routes.empty?
              withhold
              next_step!
            end
            # TODO: when :train check limit and money
          end
        else
          @step = self.class::STEPS.first
          @current_entity.pass!
        end
      end

      def next_entity
        @step == self.class::STEPS.first ? @current_entity : super
      end

      def companies_payout
        @companies.select(&:owner).each do |company|
          owner = company.owner
          income = company.income
          @bank.spend(income, owner)
          @log << "#{owner.name} collects $#{income} from #{company.name}"
        end
      end

      def place_home_stations
        @entities.each do |corporation|
          hex = @hexes.find { |h| h.coordinates == corporation.coordinates }
          city = hex.tile.cities.find { |c| c.reserved_by?(corporation) } || hex.tile.cities.first
          city.place_token(corporation) if city.tokenable?(corporation)
        end
      end

      def layable_hexes
        @layable_hexes ||=
          begin
            # hexes is a map hex => exits
            hexes = Hash.new { |h, k| h[k] = [] }

            starting_hexes = @hexes.select do |hex|
              hex.tile.cities.any? { |c| c.tokened_by?(@current_entity) }
            end
            starting_hexes.each { |h| hexes[h] = h.tile.exits }

            queue = starting_hexes.dup

            until queue.empty?
              hex = queue.pop
              next unless hex.tile

              hexes[hex].each do |direction|
                next unless (neighbor = hex.neighbors[direction])

                queue << neighbor if !hexes.key?(neighbor) && hex.connected?(neighbor)
                hexes[neighbor] |= neighbor.connected_exits(hex) | [Hex.invert(direction)]
              end
            end

            starting_hexes.each { |h| hexes[h] |= h.neighbors.keys }

            hexes
          end
      end

      def legal_rotations(hex, tile)
        original_exits = hex.tile.exits

        (0..5).select do |rotation|
          exits = tile.exits.map { |e| tile.rotate(e, rotation) }
          # connected to a legal route and not pointed into an offboard space
          (exits & layable_hexes[hex]).any? &&
            ((original_exits & exits).size == original_exits.size) &&
            exits.all? { |direction| hex.neighbors[direction] }
        end
      end

      def operating?
        true
      end

      private

      def _process_action(action)
        entity = action.entity

        case action
        when Action::LayTile
          tile = action.tile
          hex = action.hex
          rotation = action.rotation
          @tiles.reject! { |t| tile.equal?(t) }
          @tiles << hex.tile if hex.tile.color != :white
          tile.rotate!(rotation)
          hex.lay(tile)
          @log << "#{entity.name} lays tile #{tile.name} with rotation #{rotation} on #{hex.name}"
          next_step!
        when Action::PlaceToken
          action.city.place_token(entity)
          next_step!
        when Action::RunRoutes
          @current_routes = action.routes
          @current_routes.each do |route|
            hexes = route.hexes.map(&:name).join(', ')
            @log << "#{entity.name} runs a #{route.train.name} train for $#{route.revenue} (#{hexes})"
          end
          next_step!
        when Action::Dividend
          revenue = @current_routes.sum(&:revenue)

          case action.type
          when :payout
            payout(revenue)
          when :withhold
            withhold(revenue)
          else
            raise GameError, "Unknown dividend type #{action.type}"
          end
          next_step!
        when Action::BuyTrain
          train = action.train
          price = action.price
          @log << "#{entity.name} buys a #{train.name} train for $#{price}"
          entity.buy_train(action.train, price)
        end
        @layable_hexes = nil
      end

      def withhold(revenue = nil)
        name = @current_entity.name
        if revenue
          @log << "#{name} withholds $#{revenue}"
          @bank.spend(revenue, @current_entity)
        else
          @log << "#{name} does not run"
        end
        change_share_price(:left)
      end

      def payout(revenue)
        per_share = revenue / 10
        name = @current_entity.name
        @log << "#{name} pays out $#{revenue} - $#{per_share} per share"
        @players.each do |player|
          percent = player.shares_by_corporation[@current_entity].sum(&:percent)
          next if percent.zero?

          shares = percent / 10
          player_revenue = shares * per_share
          @log << "#{player.name} receives $#{player_revenue} - $#{per_share} x #{shares}"
          @bank.spend(player_revenue, player)
        end
        # TODO: payout sold shares to corporation
        change_share_price(:right)
      end

      def change_share_price(direction)
        prev = @current_entity.share_price.price

        case direction
        when :left
          @stock_market.move_left(@current_entity)
        when :right
          @stock_market.move_right(@current_entity)
        else
          raise GameError, "Don't know how to move direction #{direction}"
        end

        @log << "#{@current_entity.name}'s share price changes from $#{prev} to $#{@current_entity.share_price.price} "
      end
    end
  end
end
