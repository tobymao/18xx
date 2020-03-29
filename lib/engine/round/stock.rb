# frozen_string_literal: true

require 'engine/action/buy_share'
require 'engine/action/par'
require 'engine/action/sell_shares'

module Engine
  module Round
    class Stock < Base
      attr_reader :last_to_act

      def initialize(entities, share_pool:, can_sell: true, stock_market:)
        super

        @share_pool = share_pool
        @stock_market = stock_market
        @can_sell = can_sell
        @players_sold = Hash.new { |h, k| h[k] = {} }
        @current_actions = []
        @last_to_act = nil
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
          @current_entity.percent_of(corporation) < 60 &&
          !@players_sold[@current_entity][corporation] &&
          (@current_actions & [Action::BuyShare, Action::Par]).none?
      end

      def can_sell?(shares)
        return false unless @can_sell
        return false if shares.empty?

        corporation = shares.first.corporation

        !@players_sold[@current_entity][corporation] &&
          !(@current_actions.uniq.size == 2 && [Action::BuyShare, Action::Par].include?(@current_actions.last)) &&
          (shares.none?(&:president) ||
           corporation.share_holders.reject { |k, _| k == @current_entity }.values.max > 10)
      end

      private

      def _process_action(action)
        entity = action.entity
        corporation = action.corporation

        @current_actions << action.class
        @last_to_act = entity

        case action
        when Action::BuyShare
          buy_share(entity, action.share)
        when Action::SellShares
          sell_shares(action.shares)
        when Action::Par
          share_price = action.share_price
          @stock_market.set_par(corporation, share_price)
          share = corporation.shares.first
          buy_share(entity, share)
        end
      end

      def nothing_to_do?
        !can_sell?([@current_entity.shares.min_by(&:price)].compact) &&
          @share_pool.shares.none? { |s| can_buy?(s) }
      end

      def change_entity(_action)
        return if !@current_entity.passed? && !nothing_to_do?

        @current_entity.unpass! if @current_actions.any?
        @current_actions.clear
        @current_entity = next_entity
      end

      def action_finalized(_action)
        while !finished? && nothing_to_do?
          @current_entity.pass!
          @current_entity = next_entity
        end
      end

      def sell_shares(shares)
        share = shares.first
        entity = share.owner
        corporation = share.corporation
        old_p = corporation.owner
        @players_sold[entity][corporation] = true
        sell_and_change_price(shares, @share_pool, @stock_market)

        return if old_p != entity

        presidential_share_swap(
          corporation,
          @entities.min_by { |e| [-e.percent_of(corporation), distance(entity, e)] },
          old_p,
          shares.find(&:president),
        )
      end

      def buy_share(entity, share)
        corporation = share.corporation
        @share_pool.buy_share(entity, share)
        presidential_share_swap(corporation, entity) if corporation.owner != entity
      end

      def distance(player_a, player_b)
        a = @entities.find_index(player_a)
        b = @entities.find_index(player_b)
        a < b ? b - a : b - (a - @entities.size)
      end

      def presidential_share_swap(corporation, new_p, old_p = nil, p_share = nil)
        old_p ||= corporation.owner
        return unless new_p
        return if old_p.percent_of(corporation) >= new_p.percent_of(corporation)

        p_share ||= old_p.shares_of(corporation).find(&:president)

        new_p.shares_of(corporation).take(2).each do |share|
          @share_pool.transfer_share(share, p_share.owner)
        end
        @share_pool.transfer_share(p_share, new_p)
        @log << "#{new_p.name} becomes the president of #{corporation.name}"
      end
    end
  end
end
