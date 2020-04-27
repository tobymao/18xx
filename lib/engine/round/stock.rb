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

      def initialize(entities, game:)
        super
        @share_pool = game.share_pool
        @stock_market = game.stock_market
        @corporations = game.corporations
        @can_sell = game.turn > 1
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

      def stock?
        true
      end

      def can_buy?(share)
        return unless share

        corporation = share.corporation

        @current_entity.cash >= share.price &&
          (corporation.share_price&.color == :brown || @current_entity.percent_of(corporation) < 60) &&
          (!corporation.counts_for_limit || @current_entity.num_certs < @game.cert_limit) &&
          !@players_sold[@current_entity][corporation] &&
          (@current_actions & self.class::PURCHASE_ACTIONS).none?
      end

      def must_sell?
        @current_entity.num_certs > @game.cert_limit
      end

      def can_sell?(bundle)
        return false unless @can_sell

        corporation = bundle.corporation

        @players_sold[@current_entity][corporation] != :now &&
          (bundle.percent + @share_pool.percent_of(corporation)) <= 50 &&
          !(@current_actions.uniq.size == 2 && self.class::PURCHASE_ACTIONS.include?(@current_actions.last)) &&
          (!bundle.presidents_share ||
           (corporation.share_holders.reject { |k, _| k == @current_entity }.values.max || 0) > 10)
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
          @corporations.none? { |c| can_buy?(c.shares.first) }
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

        @corporations.each do |corporation|
          next if corporation.share_holders.values.sum < 100

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

        action = @current_actions.include?(Action::SellShares) ? 'buying' : 'selling'
        @log << "#{entity.name} passes #{action} shares"
      end
    end
  end
end
