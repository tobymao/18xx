# frozen_string_literal: true

require_relative 'base'
require_relative '../action/buy_shares'
require_relative '../action/par'
require_relative '../action/sell_shares'

module Engine
  module Round
    class Stock < Base
      attr_reader :last_to_act, :share_pool, :stock_market

      PURCHASE_ACTIONS = [Action::BuyShares, Action::Par].freeze

      def initialize(entities, game:, sell_buy_order: :sell_buy_or_buy_sell)
        super
        @share_pool = game.share_pool
        @stock_market = game.stock_market
        @corporations = game.corporations
        @sellable_turn = game.sellable_turn?
        @sell_buy_order = sell_buy_order
        # player => corporation => :now or :prev
        # this differentiates between preventing users from buying shares they sold
        # and preventing users from selling the same shares separately in the some action
        @players_sold = Hash.new { |h, k| h[k] = {} }
        @current_actions = []
        @last_to_act = nil
      end

      def name
        'Stock Round'
      end

      def description
        case @sell_buy_order
        when :sell_buy_or_buy_sell
          'Buy and Sell Shares'
        when :sell_buy
          'Sell then Buy Shares'
        when :sell_buy_sell
          'Sell then Buy Shares then Sell'
        end
      end

      def pass_description
        if @current_actions.empty?
          'Pass (Share)'
        else
          'Done (Share)'
        end
      end

      def stock?
        true
      end

      # Returns if a share can be bought via a normal buy actions
      # If a player has sold shares they cannot buy in many 18xx games
      # Some 18xx games can only buy one share per turn.
      def can_buy?(bundle)
        return unless bundle

        corporation = bundle.corporation

        @current_entity.cash >= bundle.price && can_gain?(bundle, @current_entity) &&
          !@players_sold[@current_entity][corporation] &&
          (@current_actions & self.class::PURCHASE_ACTIONS).none?
      end

      def must_sell?
        @current_entity.num_certs > @game.cert_limit ||
          !@corporations.all? { |corp| corp.holding_ok?(@current_entity) }
      end

      def can_sell?(bundle)
        corporation = bundle.corporation

        timing =
          case @game.class::SELL_AFTER
          when :first
            @game.turn > 1
          when :operate
            corporation.operated?
          when :p_any_operate
            corporation.operated? || corporation.president?(@current_entity)
          else
            raise NotImplementedError
          end

        timing &&
          !(@game.class::MUST_SELL_IN_BLOCKS && @players_sold[@current_entity][corporation] == :now) &&
          can_sell_order? &&
          @share_pool.fit_in_bank?(bundle) &&
          bundle.can_dump?(@current_entity)
      end

      def can_sell_order?
        case @sell_buy_order
        when :sell_buy_or_buy_sell
          !(@current_actions.uniq.size == 2 && self.class::PURCHASE_ACTIONS.include?(@current_actions.last))
        when :sell_buy
          (self.class::PURCHASE_ACTIONS & @current_actions).empty?
        when :sell_buy_sell
          true
        end
      end

      def did_sell?(corporation, entity)
        @players_sold[entity][corporation]
      end

      private

      def _process_action(action)
        entity = action.entity

        case action
        when Action::DiscardTrain
          discard_train(action)
        when Action::BuyShares
          buy_shares(entity, action.bundle)
        when Action::SellShares
          sell_shares(action.bundle)
        when Action::Par

          share_price = action.share_price
          corporation = action.corporation
          raise GameError, "#{corporation} cannot be parred" unless corporation.can_par?

          @stock_market.set_par(corporation, share_price)
          share = corporation.shares.first
          buy_shares(entity, share.to_bundle)
        end
      end

      def action_processed(action)
        return if action.is_a?(Action::DiscardTrain)

        entity = action.entity
        @current_actions << action.class
        @last_to_act = entity
        entity.unpass!
      end

      def nothing_to_do?
        bundles = @current_entity
          .shares
          .uniq { |share| [share.corporation.id, share.president] }
          .map { |share| ShareBundle.new(share, 10) }

        bundles.none? { |bundle| can_sell?(bundle) } &&
          @share_pool.shares.none? { |s| can_buy?(s.to_bundle) } &&
          @corporations.none? { |c| can_buy?(c.shares.first&.to_bundle) } &&
          !must_sell? # this forces a deadlock and a user must undo
      end

      def change_entity(_action)
        return if !@current_entity.passed? && !nothing_to_do?

        @current_entity.unpass! if @current_actions.any?
        @current_actions.clear
        @players_sold[@current_entity].each do |k, _|
          @players_sold[@current_entity][k] = :prev
        end
        @current_entity = next_entity
      end

      def action_finalized(_action)
        while !finished? && nothing_to_do?
          @current_entity.pass!
          @log << "#{@current_entity.name} has no valid actions and passes"
          @current_entity = next_entity
        end

        return unless finished?

        sold_out = @corporations.select { |c| c.share_holders.values.sum == 100 }

        sold_out.sort.each do |corporation|
          prev = corporation.share_price.price
          @stock_market.move_up(corporation)
          log_share_price(corporation, prev)
        end
      end

      def sell_shares(shares)
        raise GameError, "Cannot sell shares of #{shares.corporation.name}" unless can_sell?(shares)

        @players_sold[shares.owner][shares.corporation] = :now
        sell_and_change_price(shares, @share_pool, @stock_market)
      end

      def buy_shares(entity, shares)
        raise GameError, "Cannot buy a share of #{shares&.corporation&.name}" unless can_buy?(shares)

        @share_pool.buy_shares(entity, shares)
        corporation = shares.corporation
        place_home_token(corporation) if @game.class::HOME_TOKEN_TIMING == :float && corporation.floated?
      end

      def distance(player_a, player_b)
        a = @entities.find_index(player_a)
        b = @entities.find_index(player_b)
        a < b ? b - a : b - (a - @entities.size)
      end

      def log_pass(entity)
        return super if @current_actions.empty?

        action = if @current_actions.include?(Action::BuyShares) || @current_actions.include?(Action::Par)
                   'selling'
                 else
                   'buying'
                 end
        @log << "#{entity.name} passes #{action} shares"
      end
    end
  end
end
