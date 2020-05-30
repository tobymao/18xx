# frozen_string_literal: true

if RUBY_ENGINE == 'opal'
  require_tree '../action'
else
  require 'require_all'
  require_rel '../action'
end

require_relative '../corporation'
require_relative 'base'
require_relative '../operating_info'

module Engine
  module Round
    class Operating < Base
      attr_reader :bankrupt, :depot, :phase, :round_num, :step, :current_routes

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

      # Shorter forms of the step description
      SHORT_STEP_DESCRIPTION = {
        track: 'Track',
        token: 'Token',
        train: 'Trains',
        company: 'Companies',
      }.freeze

      def initialize(entities, game:, round_num: 1)
        super
        @round_num = round_num
        @hexes = game.hexes
        @phase = game.phase
        @bank = game.bank
        @depot = game.depot
        @players = game.players
        @stock_market = game.stock_market
        @share_pool = game.share_pool
        @graph = game.graph
        @just_sold_company = nil
        @bankrupt = false

        @step = self.class::STEPS.first
        @last_action_step = self.class::STEPS.last
        @current_routes = []
        @teleported = false

        payout_companies
        place_home_stations
        log_operation(@current_entity)
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

      def pass_description
        (@step == @last_action_step ? 'Done' : 'Skip') + ' (' + self.class::SHORT_STEP_DESCRIPTION[@step] + ')'
      end

      def pass(_action)
        next_step!
      end

      def finished?
        @end_game || @bankrupt || super
      end

      def can_buy_companies?
        return false unless @phase.buy_companies

        companies = @game.purchasable_companies
        companies.any? && companies.map(&:min_price).min <= @current_entity.cash
      end

      def must_buy_train?
        # TODO: this is a hack and doesn't actually check reachable cities
        # OO tiles and other complex track will break this
        @current_entity.trains.empty? && route?
      end

      def route?
        connected_nodes.size > 1
      end

      def active_entities
        super + crowded_corps
      end

      def corp_has_room?
        @current_entity.trains.size < @phase.train_limit
      end

      def can_buy_train?
        can_buy_normal = corp_has_room? &&
          @current_entity.cash >= @depot.min_price(@current_entity)

        can_buy_normal || @depot
          .discountable_trains_for(@current_entity)
          .any? { |_, _, price| @current_entity.cash >= price }
      end

      def can_act?(entity)
        return true if @step == :train && active_entities.map(&:owner).include?(entity)

        active_entities.include?(entity)
      end

      def can_sell?(bundle)
        # Can't sell president's share
        return false if bundle.presidents_share

        # Can only sell as much as you need to afford the train
        player = bundle.owner
        total_cash = bundle.price + player.cash + @current_entity.cash
        return false if total_cash >= @depot.min_depot_price + bundle.price_per_share

        # Can't swap presidency
        corporation = bundle.corporation
        if corporation.president?(player)
          share_holders = corporation.share_holders
          remaining = share_holders[player] - bundle.percent
          next_highest = share_holders.reject { |k, _| k == player }.values.max || 0
          return false if remaining < next_highest
        end

        # Can't oversaturate the market
        return false unless @share_pool.fit_in_bank?(bundle)

        # Otherwise we're good
        true
      end

      def can_lay_track?
        @step == :track
      end

      def can_run_routes?
        @step == :route
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

            next_step! unless connected_nodes.any? { |node, _| node.tokenable?(@current_entity) }
          when :route
            next_step! if @current_entity.trains.empty? || !route?
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

      def connected_hexes
        @graph.connected_hexes(@current_entity)
      end

      def connected_nodes
        @graph.connected_nodes(@current_entity)
      end

      def connected_paths
        @graph.connected_paths(@current_entity)
      end

      def operating?
        true
      end

      private

      def _process_action(action)
        entity = action.entity

        case action
        when Action::LayTile
          hex_id = action.hex.id

          # companies with block_hexes should block hexes
          @game.companies.each do |company|
            next if company.closed?
            next unless (ability = company.abilities(:blocks_hexes))

            raise GameError, "#{hex_id} is blocked by #{company.name}" if ability[:hexes].include?(hex_id)
          end

          lay_tile(action)
          @current_entity.abilities(:teleport) do |ability, _|
            @teleported = ability[:hexes].include?(hex_id) &&
              ability[:tiles].include?(action.tile.name)
          end
        when Action::PlaceToken
          place_token(action)
        when Action::RunRoutes
          @current_routes = action.routes
          @current_routes.each do |route|
            hexes = route.hexes.map(&:name).join(', ')
            @log << "#{entity.name} runs a #{route.train.name} train for "\
                    "#{@game.format_currency(route.revenue)} (#{hexes})"
          end
        when Action::Dividend
          revenue = @current_routes.sum(&:revenue)
          or_info = OperatingInfo.new(@current_routes, action, revenue)
          @current_entity.add_operating_info!(@game.turn, @round_num, or_info)
          @current_routes = []

          case action.kind
          when 'payout'
            payout(revenue)
          when 'withhold'
            withhold(revenue)
          else
            raise GameError, "Unknown dividend type #{action.kind}"
          end
        when Action::BuyTrain
          buy_train(entity, action.train, action.price, action.exchange)
        when Action::DiscardTrain
          discard_train(action)
        when Action::SellShares
          sell_shares(action.shares)
        when Action::BuyCompany
          company = action.company
          buy_company(company, action.price)
          @graph.clear if company.abilities(:teleport)
        when Action::Bankrupt
          liquidate(entity.owner)
        end
      end

      def change_entity(_action)
        return unless @current_entity.passed?

        if @teleported
          @teleported = false
          @current_entity.abilities(:teleport) do |_, company|
            company.remove_ability(:teleport)
          end
        end
        @current_entity = next_entity
        log_operation(@current_entity) unless finished?
      end

      def action_processed(action)
        @last_action_step = @step
        remove_just_sold_company_abilities unless action.is_a?(Action::BuyCompany)
        return if @bankrupt
        return if ignore_action?(action)

        next_step!
      end

      def ignore_action?(action)
        case action
        when Action::SellShares
          true
        when Action::DiscardTrain, Action::BuyTrain
          crowded_corps.any? || can_buy_train?
        when Action::BuyCompany
          @step != :company || can_buy_companies?
        end
      end

      def withhold(revenue = 0)
        name = @current_entity.name
        if revenue.positive?
          @log << "#{name} withholds #{@game.format_currency(revenue)}"
          @bank.spend(revenue, @current_entity)
        else
          @log << "#{name} does not run"
        end
        change_share_price(:left)
      end

      def payout(revenue)
        # TODO: actually count shares when we implement 1817, 18Ireland, 18US, etc
        share_count = 10
        per_share = revenue / share_count
        @log << "#{@current_entity.name} pays out #{@game.format_currency(revenue)} = "\
                "#{@game.format_currency(per_share)} x #{share_count} shares"
        @players.each do |player|
          payout_entity(player, per_share)
        end
        payout_entity(@share_pool, per_share, @current_entity)
        change_share_price(:right)
      end

      def payout_entity(holder, per_share, receiver = nil)
        return if (percent = holder.percent_of(@current_entity)).zero?

        receiver ||= holder
        # TODO: actually count shares when we implement 1817, 18Ireland, 18US, etc
        share_count = 10
        shares = percent / (100 / share_count)
        amount = shares * per_share
        @log << "#{receiver.name} receives #{@game.format_currency(amount)} = "\
                "#{@game.format_currency(per_share)} x #{shares} shares"
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

      def buy_train(entity, train, price, exchange)
        remaining = price - entity.cash

        if train.from_depot? && remaining.positive? && train.name == @depot.min_depot_train.name && must_buy_train?
          raise GameError, 'Cannot contribute funds when exchanging' if exchange

          player = entity.owner
          player.spend(remaining, entity)
          @log << "#{player.name} contributes #{@game.format_currency(remaining)}"
        end

        if exchange
          verb = "exchanges a #{exchange.name} for"
          @depot.reclaim_train(exchange)
        else
          verb = 'buys'
        end

        @log << "#{entity.name} #{verb} a #{train.name} train for "\
          "#{@game.format_currency(price)} from #{train.owner.name}"
        entity.buy_train(train, price)
      end

      def sell_shares(shares)
        sell_and_change_price(shares, @share_pool, @stock_market)
        recalculate_order
      end

      def buy_company(company, price)
        entity = company.owner
        raise GameError, "Cannot buy #{company.name} from #{entity.name}" if entity.is_a?(Corporation)

        min = company.min_price
        max = company.max_price
        unless price.between?(min, max)
          raise GameError, "Price must be between #{@game.format_currency(min)} and #{@game.format_currency(max)}"
        end

        company.owner = @current_entity
        entity.companies.delete(company)

        remove_just_sold_company_abilities
        @just_sold_company = company

        @current_entity.companies << company
        @current_entity.spend(price, entity)
        @log << "#{@current_entity.name} buys #{company.name} from #{entity.name} for #{@game.format_currency(price)}"
      end

      def place_token(action)
        entity = action.entity
        hex = action.city.hex
        if !connected_nodes[action.city] && !@teleported
          raise GameError, "Cannot place token on #{hex.name} because it is not connected"
        end

        price = entity.next_token&.price || 0
        action.city.place_token(entity)
        if price.positive? && !@teleported
          entity.spend(price, @bank)
          price_log = " for #{@game.format_currency(price)}"
        end
        @log << "#{entity.name} places a token on #{action.city.hex.name}#{price_log}"

        @graph.clear
      end

      def remove_just_sold_company_abilities
        return unless @just_sold_company

        @just_sold_company.remove_ability_when(:sold)
        @just_sold_company = nil
      end

      def log_pass(entity)
        verb = @step == @last_action_step ? 'finishes' : 'skips'
        case @step
        when :track
          @log << "#{entity.name} #{verb} laying track"
        when :token
          @log << "#{entity.name} #{verb} placing a token"
        when :train
          @log << "#{entity.name} #{verb} buying trains"
        when :company
          @log << "#{entity.name} #{verb} buying companies"
        else
          super
        end
      end

      def log_operation(entity)
        return unless entity

        @log << "#{entity.owner.name} operates #{entity.name}"
      end

      def liquidate(player)
        @log << "#{player.name} goes bankrupt and sells remaining shares"

        player.shares_by_corporation.each do |corporation, _|
          next unless corporation.share_price # if a corporation has not parred
          next unless (bundle = sellable_bundles(player, corporation).max_by(&:price))

          sell_shares(bundle)
        end

        player.spend(player.cash, @bank)

        @bankrupt = true
      end

      def recalculate_order
        # Selling shares may have caused the corporations that haven't operated yet
        # to change order. Re-sort only them.
        index = @entities.find_index(@current_entity) + 1
        @entities[index..-1] = @entities[index..-1].sort if index < @entities.size - 1
      end
    end
  end
end
