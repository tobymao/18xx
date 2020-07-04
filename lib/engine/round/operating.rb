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
        home_token
        track
        token
        route
        dividend
        train
        company
      ].freeze

      STEP_DESCRIPTION = {
        home_token: 'Lay Home Token',
        track: 'Lay Track',
        token: 'Place a Token',
        route: 'Run Routes',
        dividend: 'Pay or Withhold Dividends',
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

      DIVIDEND_TYPES = %i[payout withhold].freeze

      def initialize(entities, game:, round_num: 1, **opts)
        super(select(entities, game, round_num), game: game, **opts)
        @round_num = round_num
        @home_token_timing = @game.class::HOME_TOKEN_TIMING
        @ebuy_other_value = @game.class::EBUY_OTHER_VALUE
        @hexes = game.hexes
        @phase = game.phase
        @bank = game.bank
        @depot = game.depot
        @players = game.players
        @stock_market = game.stock_market
        @share_pool = game.share_pool
        @graph = game.graph
        @just_sold_company = nil
        @last_share_sold_price = nil
        @bankrupt = false

        @last_action_step = steps.last
        @current_routes = []
        @current_actions = []
        @teleported = false
        @ambiguous_hex_token = []

        payout_companies
        @entities.each { |c| place_home_token(c) } if @home_token_timing == :operating_round
        start_operating
      end

      def select(entities, _game, _round_num)
        entities.select(&:floated?).sort
      end

      def name
        'Operating Round'
      end

      def description
        if (token = ambiguous_token)
          return "Must choose token for #{token.corporation.name} at #{@ambiguous_hex_token[0].name}"
        end

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
        !@current_entity.rusted_self && @current_entity.trains.empty? && route?
      end

      def buyable_trains
        depot_trains = @depot.depot_trains
        other_trains = @depot.other_trains(current_entity)

        # If the corporation cannot buy a train, then it can only buy the cheapest available
        min_depot_train = @depot.min_depot_train
        if min_depot_train.price > current_entity.cash
          depot_trains = [min_depot_train]

          if @last_share_sold_price
            # 1889, a player cannot contribute to buy a train from another corporation
            return depot_trains unless @ebuy_other_value

            # 18Chesapeake and most others, it's legal to buy trains from other corps until
            # if the player has just sold a share they can buy a train between cash-price_last_share_sold and cash
            # e.g. If you had $40 cash, and if the train costs $100 and you've sold a share for $80,
            # you now have $120 cash the $100 train should still be available to buy
            min_available_cash = (current_entity.cash + current_entity.owner.cash) - @last_share_sold_price
            return depot_trains + (other_trains.reject { |x| x.price < min_available_cash })
          end
        end
        depot_trains + other_trains
      end

      def dividend_types
        self.class::DIVIDEND_TYPES
      end

      def active_entities
        super + crowded_corps
      end

      def corp_has_room?
        @current_entity.trains.reject(&:obsolete).size < @phase.train_limit
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
        player = bundle.owner
        # Can't sell president's share
        return false unless bundle.can_dump?(player)

        # Can only sell as much as you need to afford the train

        total_cash = bundle.price + player.cash + @current_entity.cash
        return false if total_cash >= @depot.min_depot_price + bundle.price_per_share

        # Can't swap presidency
        corporation = bundle.corporation
        if corporation.president?(player) &&
            (!@game.class::EBUY_PRES_SWAP || corporation == @current_entity)
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
        @step == :token || @step == :home_token || ambiguous_token
      end

      def ambiguous_token
        @ambiguous_hex_token[1]
      end

      def steps
        self.class::STEPS
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

      def reachable_hexes
        return { @ambiguous_hex_token[0] => true } if ambiguous_token
        return { @game.hex_by_id(@current_entity.coordinates) => true } if @step == :home_token

        @graph.reachable_hexes(@current_entity)
      end

      def route?
        @graph.route?(@current_entity)
      end

      def operating?
        true
      end

      def skip_current_entity
        @current_entity.pass!
        change_entity(nil)
      end

      private

      def next_step!
        current_index = steps.find_index(@step)

        if current_index < steps.size - 1
          @step = steps[current_index + 1]
          next_step! if send("skip_#{@step}")
        else
          @current_entity.pass!
        end
      end

      def skip_home_token
        !(@home_token_timing == :operate &&
          @game.hex_by_id(@current_entity.coordinates)&.tile&.reserved_by?(@current_entity))
      end

      def skip_track; end

      def skip_token
        return true unless (token = @current_entity.next_token)

        min_token_price(token) > @current_entity.cash ||
          !@graph.can_token?(@current_entity)
      end

      def skip_route
        @current_entity.runnable_trains.empty? || !route?
      end

      def skip_dividend
        return false if @current_routes.any?

        process_dividend(Action::Dividend.new(@current_entity, kind: 'withhold'))

        true
      end

      def skip_train
        !can_buy_train? && !must_buy_train?
      end

      def skip_company
        !can_buy_companies?
      end

      def _process_action(action)
        send("process_#{action.type}", action)
      end

      def process_lay_tile(action)
        previous_tile = action.hex.tile

        hex_id = action.hex.id

        # companies with block_hexes should block hexes
        @game.companies.each do |company|
          next if company.closed?
          next unless (ability = company.abilities(:blocks_hexes))

          raise GameError, "#{hex_id} is blocked by #{company.name}" if ability.hexes.include?(hex_id)
        end

        lay_tile(action)
        @current_entity.abilities(:teleport) do |ability, _|
          @teleported = ability.hexes.include?(hex_id) &&
          ability.tiles.include?(action.tile.name)
        end

        new_tile = action.hex.tile
        cities = new_tile.cities
        if previous_tile.paths.empty? &&
          new_tile.paths.any? &&
          cities.size > 1 &&
          cities.flat_map(&:tokens).any?
          token = cities.flat_map(&:tokens).find(&:itself)
          @ambiguous_hex_token = [action.hex, token]
          token.remove!
        end
      end

      def process_place_token(action)
        place_token(action)
      end

      def process_move_token(action)
        move_token(action)
        @ambiguous_hex_token = []
      end

      def process_run_routes(action)
        @current_routes = action.routes
        trains = {}
        @current_routes.each do |route|
          train = route.train
          if train.owner && train.owner != @current_entity
            raise GameError, "Cannot run another corporation's train. refresh"
          end
          raise GameError, 'Cannot run train twice' if trains[train]
          raise GameError, 'Cannot run train that operated' if train.operated

          trains[train] = true
          hexes = route.hexes.map(&:name).join(', ')
          @log << "#{@current_entity.name} runs a #{train.name} train for "\
            "#{@game.format_currency(route.revenue)} (#{hexes})"
        end
      end

      def process_dividend(action)
        revenue = @current_routes.sum(&:revenue)
        rust_obsolete_trains!(@current_entity.trains)
        @current_entity.operating_history[[@game.turn, @round_num]] = OperatingInfo.new(
          @current_routes,
          action,
          revenue
        )
        @current_entity.trains.each { |train| train.operated = true }
        @current_routes = []
        send(action.kind, revenue)
      end

      def process_buy_train(action)
        buy_train(action.entity, action.train, action.price, action.exchange)
        @last_share_sold_price = nil
      end

      def process_discard_train(action)
        discard_train(action)
      end

      def process_sell_shares(action)
        @last_share_sold_price = action.bundle.price_per_share
        sell_shares(action.bundle)
      end

      def process_buy_company(action)
        company = action.company
        buy_company(company, action.price)
        @graph.clear if company.abilities(:teleport)
      end

      def process_bankrupt(action)
        liquidate(action.entity.owner)
      end

      def start_operating
        return if finished?

        @step = steps.first
        @current_actions.clear
        log_operation(@current_entity)
        @current_entity.trains.each { |train| train.operated = false }
        place_home_token(@current_entity) if @home_token_timing == :operate

        next_step! if send("skip_#{@step}")
      end

      def change_entity(_action)
        return unless @current_entity.passed?

        # default operating action is to payout 0, i.e. withhold
        @current_entity.operating_history[[@game.turn, @round_num]] ||= OperatingInfo.new(
          [],
          Action::Dividend.new(@game.current_entity, kind: 'withhold'),
          0
        )

        if @teleported
          @teleported = false
          @current_entity.abilities(:teleport) do |_, company|
            company.remove_ability(:teleport)
          end
        end
        @last_share_sold_price = nil
        @current_entity = next_entity
        start_operating
      end

      def action_processed(action)
        @last_action_step = @step
        @current_actions << action
        remove_just_sold_company_abilities unless action.is_a?(Action::BuyCompany)
        return if @bankrupt
        return if ignore_action?(action)

        next_step!
      end

      def ignore_action?(action)
        case action
        when Action::SellShares, Action::MoveToken
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
        change_share_price(0)
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

        if @current_entity.capitalization == :incremental
          payout_entity(@current_entity, per_share, @current_entity)
        else
          payout_entity(@share_pool, per_share, @current_entity)
        end
        change_share_price(revenue)
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

      def change_share_price(revenue)
        prev = @current_entity.share_price.price
        revenue.zero? ? @stock_market.move_left(@current_entity) : @stock_market.move_right(@current_entity)
        log_share_price(@current_entity, prev)
      end

      def buy_train(entity, train, price, exchange)
        # Check if the train is actually buyable in the current situation
        raise GameError, 'Not a buyable train' unless buyable_trains.include?(train)

        remaining = price - entity.cash

        if remaining.positive? && must_buy_train?
          cheapest = @depot.min_depot_train
          if train != cheapest && (!@ebuy_other_value || train.from_depot?)
            raise GameError, "Cannot purchase #{train.name} train: #{cheapest.name} train available"
          end
          raise GameError, 'Cannot contribute funds when exchanging' if exchange
          raise GameError, 'Cannot buy for more than cost' if price > train.price

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

        source = @depot.discarded.include?(train) ? 'The Discard' : train.owner.name

        @log << "#{entity.name} #{verb} a #{train.name} train for "\
          "#{@game.format_currency(price)} from #{source}"
        entity.buy_train(train, price)
      end

      def sell_shares(bundle)
        sell_and_change_price(bundle, @share_pool, @stock_market)
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

        company.abilities(:assign_corporation) do |ability|
          @current_entity.assign!(company.sym)
          ability.use!
        end
        remove_just_sold_company_abilities
        @just_sold_company = company

        @current_entity.companies << company
        @current_entity.spend(price, entity)
        @log << "#{@current_entity.name} buys #{company.name} from #{entity.name} for #{@game.format_currency(price)}"
      end

      def move_token(action)
        action.token.move!(action.city)
        @log << "#{@current_entity.name} moves a token on #{action.city.hex.name}"
      end

      def place_token(action)
        entity = action.entity
        hex = action.city.hex

        if !@game.loading && @step != :home_token && !connected_nodes[action.city]
          raise GameError, "Cannot place token on #{hex.name} because it is not connected"
        end

        token = action.token
        raise GameError, 'Token is already used' if token.used

        token, ability_type = adjust_token_price_ability!(token, hex)
        @current_entity.remove_ability(ability_type)
        free = !token.price.positive?
        action.city.place_token(entity, token, free: free)
        unless free
          entity.spend(token.price, @bank)
          price_log = " for #{@game.format_currency(token.price)}"
        end

        case token.type
        when :neutral
          entity.tokens.delete(token)
          token.corporation.tokens << token
          @log << "#{entity.name} places a neutral token on #{action.city.hex.name}#{price_log}"
        else
          @log << "#{entity.name} places a token on #{action.city.hex.name}#{price_log}"
        end

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

      def min_token_price(token)
        return 0 if @teleported

        prices = [token.price]

        @current_entity.abilities(:token) do |ability, _|
          prices << ability.price
          prices << ability.teleport_price
        end

        prices.compact.min
      end

      def adjust_token_price_ability!(token, hex)
        if @teleported
          token.price = 0
          return [token, :teleport]
        end

        @current_entity.abilities(:token) do |ability, _|
          next unless ability.hexes.include?(hex.id)

          token = Token.new(@current_entity) if ability.extra
          token.price = ability.teleport_price if ability.teleport_price
          token.price = ability.price if reachable_hexes[hex]
          return [token, :token]
        end

        [token, nil]
      end

      def rust_obsolete_trains!(trains)
        rusted_trains = []
        # need to clone since rust! mutates the original
        trains = trains.clone

        trains.each do |train|
          next unless train.obsolete
          rusted_trains << train.name
          train.rust!
        end

        @log << '-- Event: Obsolete trains rust --' if rusted_trains.any?
      end
    end
  end
end
