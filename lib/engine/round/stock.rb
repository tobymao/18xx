# frozen_string_literal: true

require 'engine/action/buy_share'
require 'engine/action/par'
require 'engine/action/sell_share'

module Engine
  module Round
    class Stock < Base
      def initialize(entities, share_pool:, stock_market:)
        super

        @share_pool = share_pool
        @stock_market = stock_market
      end

      def pass
        @current_entity.pass!
      end

      def finished?
        active_entities.all?(&:passed?)
      end

      def stock?
        true
      end

      private

      def _process_action(action)
        @current_entity.unpass!
        entity = action.entity

        case action
        when Action::BuyShare
          buy_share(entity, action.share)
          @share_pool.buy_share(entity, action.share)
        when Action::SellShare
          @share_pool.sell_share(entity, action.share)
          @stock_market.move_down(action.corporation)
        when Action::Par
          corporation = action.corporation
          share_price = action.share_price
          @stock_market.set_par(corporation, share_price)
          @log << "#{entity.name} pars #{corporation.name} at $#{corporation.par_price.price}"

          share = action.corporation.shares.first
          buy_share(entity, share)
        end
      end

      def buy_share(entity, share)
        corporation = share.corporation
        floated = corporation.floated?
        @share_pool.buy_share(entity, share)
        @log << "#{entity.name} buys a #{share.percent}% share of #{corporation.name} for $#{share.price}"
        return if floated == corporation.floated?

        corporation.cash = corporation.par_price.price * 10
        @log << "#{corporation.name} floats with $#{corporation.cash} and tokens #{corporation.coordinates}"
      end
    end
  end
end
