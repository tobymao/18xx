# frozen_string_literal: true

require_relative 'base'
require_relative '../action/buy_share'
require_relative '../action/par'
require_relative '../action/sell_shares'

module Engine
  module Round
    class Stock < Base
      attr_reader :last_to_act, :share_pool, :stock_market

      PURCHASE_ACTIONS = [Action::BuyShare, Action::Par].freeze

      def initialize(entities, game:, sell_buy_order: :sell_buy_or_buy_sell)
        super
        @share_pool = game.share_pool
        @stock_market = game.stock_market
        @corporations = game.corporations
        @turn = game.turn
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
        'Buy and Sell Shares'
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
      def can_buy?(share)
        return unless share

        corporation = share.corporation

        @current_entity.cash >= share.price && can_gain?(share, @current_entity) &&
          !@players_sold[@current_entity][corporation] &&
          (@current_actions & self.class::PURCHASE_ACTIONS).none?
      end

      def must_sell?
        @current_entity.num_certs > @game.cert_limit ||
          !@corporations.all? { |corp| corp.holding_ok?(@current_entity) }
      end

      def can_sell?(bundle)
        @players_sold[@current_entity][bundle.corporation] != :now &&
          can_sell_order? &&
          bundle.liquid_bundle?(@turn, @share_pool, @current_entity)
      end

      def can_sell_order?
        case @sell_buy_order
        when :sell_buy_or_buy_sell
          !(@current_actions.uniq.size == 2 && self.class::PURCHASE_ACTIONS.include?(@current_actions.last))
        when :sell_buy
          (self.class::PURCHASE_ACTIONS & @current_actions).empty?
        end
      end

      def did_sell?(corporation, entity)
        @players_sold[entity][corporation]
      end

      private

      def _process_action(action)
        entity = action.entity

        case action
        when Action::BuyShare
          buy_share(entity, action.share)
        when Action::SellShares
          sell_shares(action.shares)
        when Action::Par
          share_price = action.share_price
          corporation = action.corporation
          @stock_market.set_par(corporation, share_price)
          share = corporation.shares.first
          buy_share(entity, share)
        end
      end

      def action_processed(action)
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
          @share_pool.shares.none? { |s| can_buy?(s) } &&
          @corporations.none? { |c| can_buy?(c.shares.first) } &&
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

      def buy_share(entity, share)
        raise GameError, "Cannot buy a share of #{share&.corporation&.name}" unless can_buy?(share)

        @share_pool.buy_share(entity, share)
      end

      def distance(player_a, player_b)
        a = @entities.find_index(player_a)
        b = @entities.find_index(player_b)
        a < b ? b - a : b - (a - @entities.size)
      end

      def log_pass(entity)
        return super if @current_actions.empty?

        action = if @current_actions.include?(Action::BuyShare) || @current_actions.include?(Action::Par)
                   'selling'
                 else
                   'buying'
                 end
        @log << "#{entity.name} passes #{action} shares"
      end
    end
  end
end
