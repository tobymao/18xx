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

      def can_sell?(share)
        return unless share
        return false unless @can_sell

        corporation = share.corporation

        !@players_sold[@current_entity][corporation] &&
          !(@current_actions.uniq.size == 2 && [Action::BuyShare, Action::Par].include?(@current_actions.last)) &&
          (!share.president || @entities.any? { |e| e != share.owner && e.percent_of(corporation) > 10 })
      end

      def can_sell_anything?
        @current_entity.shares.any? { |s| can_sell?(s) }
      end

      def can_buy_anything?
        @share_pool.shares.any? { |s| can_buy?(s) }
      end

      def next_entity
        if @current_entity.passed? || (!can_buy_anything? && !can_sell_anything?)
          @current_entity.unpass! if @current_actions.any?
          @current_actions.clear
          super
        else
          @current_entity
        end
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
          sell_shares(entity, action.shares)
        when Action::Par
          share_price = action.share_price
          @stock_market.set_par(corporation, share_price)
          @log << "#{entity.name} pars #{corporation.name} at $#{corporation.par_price.price} and becomes the president"

          share = corporation.shares.first
          buy_share(entity, share)
        end
      end

      def sell_shares(entity, shares)
        num = shares.size
        percent = shares.sum(&:percent)
        corporation = shares.first.corporation
        @players_sold[entity][corporation] = true
        old_p = corporation.owner

        shares.each { |share| @share_pool.sell_share(share) }
        @log << "#{entity.name} sells #{num} share#{num > 1 ? 's' : ''} " \
          "(%#{percent}) of #{corporation.name} and receives $#{Engine::Share.price(shares)}"

        if old_p == entity
          presidential_share_swap(
            old_p,
            @entities.min_by { |e| [-e.percent_of(corporation), distance(entity, e)] },
            shares.find(&:president) || old_p.shares_of(corporation).find(&:president),
          )
        end

        prev = corporation.share_price.price
        shares.each do |share|
          @stock_market.move_down(corporation)
          @stock_market.move_down(corporation) if share.president
        end
        log_share_price(corporation, prev)
      end

      def buy_share(entity, share)
        corporation = share.corporation
        floated = corporation.floated?
        @share_pool.buy_share(entity, share)
        @log << "#{entity.name} buys a #{share.percent}% share of #{corporation.name} for $#{share.price}"

        old_p = corporation.owner

        if old_p != entity
          presidential_share_swap(
            old_p,
            entity,
            old_p.shares_of(corporation).find(&:president),
          )
        end

        return if floated == corporation.floated?

        corporation.cash = corporation.par_price.price * 10
        @log << "#{corporation.name} floats with $#{corporation.cash} and tokens #{corporation.coordinates}"
      end

      def distance(player_a, player_b)
        a = @entities.find_index(player_a)
        b = @entities.find_index(player_b)
        a < b ? b - a : b - (a - @entities.size)
      end

      def presidential_share_swap(old_p, new_p, p_share)
        return if old_p.nil? || new_p.nil?

        corporation = p_share.corporation
        return if old_p.percent_of(corporation) >= new_p.percent_of(corporation)

        corporation = p_share.corporation

        new_p.shares_of(corporation).take(2).each do |share|
          @share_pool.transfer_share(share, p_share.owner)
        end
        @share_pool.transfer_share(p_share, new_p)
        @log << "#{new_p.name} becomes the president of #{corporation.name}"
      end
    end
  end
end
