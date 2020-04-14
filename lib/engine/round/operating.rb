# frozen_string_literal: true

require_relative '../action/buy_company'
require_relative '../action/buy_train'
require_relative '../action/dividend'
require_relative '../action/lay_tile'
require_relative '../action/run_routes'
require_relative '../action/sell_shares'
require_relative '../corporation'
require_relative 'base'

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
        company
      ].freeze

      STEP_DESCRIPTION = {
        track: 'Lay Track',
        token: 'Place a Token',
        route: 'Run Routes',
        dividend: 'Pay or Withold Dividends',
        train: 'Buy Trains',
        company: 'Purchase Companies',
      }.freeze

      def initialize(entities, game:, round_num: 1)
        super
        @round_num = round_num
        @hexes = game.hexes
        @phase = game.phase
        @companies = game.companies
        @bank = game.bank
        @depot = game.depot
        @players = game.players
        @stock_market = game.stock_market
        @share_pool = game.share_pool
        @just_sold_company = nil

        @step = self.class::STEPS.first
        @current_routes = []

        payout_companies
        place_home_stations
      end

      def log_new_round
        @log << "-- #{name} #{@turn}.#{round_num} --"
      end

      def name
        'Operating Round'
      end

      def description
        self.class::STEP_DESCRIPTION[@step]
      end

      def pass(_action)
        next_step!
      end

      def can_buy_companies?
        return unless (companies = @current_entity.owner&.companies)

        @phase.buy_companies &&
          companies.any? &&
          companies.map(&:min_price).min <= @current_entity.cash
      end

      def must_buy_train?
        @current_entity.trains.empty? # TODO: check if there's a route
      end

      def can_buy_train?
        @current_entity.trains.size < @phase.train_limit &&
          @depot.available(@current_entity).any? { |t| @current_entity.cash >= t.min_price }
      end

      def can_act?(entity)
        return true if @step == :train && active_entities.map(&:owner).include?(entity)

        active_entities.include?(entity)
      end

      def can_sell?(shares)
        # can't sell president's share
        return false if shares.any?(&:president)

        # can only sell as much as you need to afford the train
        corporation = shares.first.corporation
        player = corporation.owner
        value = shares.sum(&:price)
        percentage = shares.sum(&:percent)
        price_per_share = value * percentage / 10.0
        return false if value + player.cash >= @depot.min_price + price_per_share

        # can't swap presidency
        share_holders = corporation.share_holders
        remaining = share_holders[player] - percentage
        next_highest = share_holders.reject { |k, _| k == player }.values.max || 0
        remaining >= next_highest
      end

      def can_lay_track?
        @step == :track
      end

      def can_place_token?
        @step == :token
      end

      def next_step!
        current_index = self.class::STEPS.find_index(@step)

        if current_index < self.class::STEPS.size - 1
          case (@step = self.class::STEPS[current_index + 1])
          when :token
            return next_step! if @current_entity.tokens.none?

            next_step! unless reachable_hexes.any? do |hex, exits|
              hex.tile.paths.any? do |path|
                path.city &&
                  (path.exits & exits).any? &&
                  path.city.tokenable?(@current_entity)
              end
            end
          when :route
            next_step! unless @current_entity.trains.any?
          when :dividend
            if @current_routes.empty?
              withhold
              next_step!
            end
          when :train
            next_step! if !can_buy_train? && !must_buy_train?
          when :company
            next_step! unless can_buy_companies?
          end
        else
          clear_route_cache
          @step = self.class::STEPS.first
          @current_entity.pass!
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

            queue = []
            starting_hexes = []

            @hexes.each do |hex|
              cities = tokened_cities(hex)
              next unless cities.any?

              queue << hex
              starting_hexes << hex

              hexes[hex] = hex
                .tile
                .paths
                .select { |path| cities.include?(path.city) }
                .flat_map(&:exits)
                .uniq
            end

            until queue.empty?
              hex = queue.pop

              hexes[hex].each do |direction|
                next unless (neighbor = hex.neighbors[direction])

                queue << neighbor if !hexes.key?(neighbor) && hex.connected?(neighbor)
                hexes[neighbor] |= neighbor.connected_exits(hex) | [Hex.invert(direction)]
              end
            end

            starting_hexes.each { |h| hexes[h] |= h.neighbors.keys }
            hexes.default = nil

            hexes
          end
      end

      def reachable_hexes
        @reachable_hexes ||= layable_hexes.select { |hex, exits| (hex.tile.exits & exits).any? }
      end

      # def routes
      #   routes = []

      #   reachable_hexes.keys.each do |hex|
      #     paths_for_cities(hex, tokened_cities(hex)).each do |path|
      #       path.exits.each { |direction| routes << [hex, direction] }
      #     end
      #   end

      #   routes.each do |hex, direction|
      #     neighbor = hex.neighbors[direction]
      #     next unless reachable_hexes[neighbor]

      #     neighbor.connected_paths(hex).each do |path|
      #       path.city || path.town
      #     end
      #   end
      # end

      def paths_for_cities(hex, cities)
        hex.tile.paths.select { |path| cities.include?(path.city) }
      end

      def tokened_cities(hex)
        hex.tile.cities.select { |c| c.tokened_by?(@current_entity) }
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
          lay_tile(action)
          clear_route_cache
        when Action::PlaceToken
          place_token(action)
        when Action::RunRoutes
          @current_routes = action.routes
          @current_routes.each do |route|
            hexes = route.hexes.map(&:name).join(', ')
            @log << "#{entity.name} runs a #{route.train.name} train for $#{route.revenue} (#{hexes})"
          end
        when Action::Dividend
          revenue = @current_routes.sum(&:revenue)

          case action.kind
          when 'payout'
            payout(revenue)
          when 'withhold'
            withhold(revenue)
          else
            raise GameError, "Unknown dividend type #{action.kind}"
          end
        when Action::BuyTrain
          buy_train(entity, action.train, action.price)
        when Action::SellShares
          sell_shares(action.shares)
        when Action::BuyCompany
          buy_company(action.company, action.price)
        end
      end

      def change_entity(action)
        return if action.is_a?(Action::BuyCompany)
        return if @step != self.class::STEPS.first

        @current_entity = next_entity
      end

      def action_processed(action)
        remove_just_sold_company_abilities unless action.is_a?(Action::BuyCompany)
        return if action.is_a?(Action::BuyCompany) && (@step != :company || can_buy_companies?)
        return if action.is_a?(Action::SellShares)
        return if action.is_a?(Action::BuyTrain) && can_buy_train?

        next_step!
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
        @log << "#{@current_entity.name} pays out $#{revenue} - $#{per_share} per share"
        @players.each do |player|
          payout_entity(player, per_share)
        end
        payout_entity(@share_pool, per_share, @current_entity)
        change_share_price(:right)
      end

      def payout_entity(holder, per_share, receiver = nil)
        return if (percent = holder.percent_of(@current_entity)).zero?

        receiver ||= holder
        shares = percent / 10
        amount = shares * per_share
        @log << "#{receiver.name} receives $#{amount} - $#{per_share} x #{shares}"
        @bank.spend(amount, receiver)
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

        log_share_price(@current_entity, prev)
      end

      def buy_train(entity, train, price)
        remaining = price - entity.cash
        if remaining.positive?
          player = entity.owner
          player.spend(remaining, entity)
          @log << "#{player.name} contributes $#{remaining}"
        end
        @log << "#{entity.name} buys a #{train.name} train for $#{price} from #{train.owner.name}"
        entity.buy_train(train, price)
      end

      def sell_shares(shares)
        sell_and_change_price(shares, @share_pool, @stock_market)
      end

      def buy_company(company, price)
        player = company.owner
        raise GameError, "Cannot buy #{company.name} from #{player.name}" if player.is_a?(Corporation)

        company.owner = @current_entity
        player.companies.delete(company)

        remove_just_sold_company_abilities
        @just_sold_company = company

        @current_entity.companies << company
        @current_entity.spend(price, player)
        @log << "#{@current_entity.name} buys #{company.name} from #{player.name} for $#{price}"
      end

      def place_token(action)
        entity = action.entity
        hex = action.city.hex
        unless layable_hexes[action.city.hex]
          raise GameError, "Cannot place token on #{hex.name} because it is not connected"
        end

        action.city.place_token(entity)
        @log << "#{entity.name} places a token on #{action.city.hex.name}"
        clear_route_cache
      end

      def remove_just_sold_company_abilities
        return unless @just_sold_company

        @just_sold_company.remove_ability_when(:sold)
        @just_sold_company = nil
      end

      def clear_route_cache
        @layable_hexes = nil
        @reachable_hexes = nil
      end
    end
  end
end
