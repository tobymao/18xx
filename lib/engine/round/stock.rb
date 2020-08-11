# frozen_string_literal: true

require_relative 'base'
require_relative '../action/buy_shares'
require_relative '../action/par'
require_relative '../action/sell_shares'
require_relative '../step/buy_sell_par_shares'

module Engine
  module Round
    class Stock < Base
      def select_entities
        @game.players.reject(&:bankrupt)
      end

      def name
        'Stock Round'
      end

      def setup
        start_entity
      end

      def after_process(_action)
        return if active_step

        next_entity!
      end

      def next_entity!
        if finished?
          # Need to move entity round once more to be back to the priority deal player
          next_entity_index!

          finish_round
          return
        end

        next_entity_index!
        start_entity
      end

      def start_entity
        @steps.each(&:unpass!)
        @steps.each(&:setup)

        skip_steps
        next_entity! unless active_step
      end

      def finished?
        @game.finished || @entities.all?(&:passed?)
      end

      private

      def finish_round
        @game.corporations.select(&:floated?).sort.each do |corp|
          prev = corp.share_price.price

          @game.stock_market.move_up(corp) if sold_out?(corp)
          pool_share_drop = @game.class::POOL_SHARE_DROP
          price_drops =
            if (pool_share_drop == :none) || (shares_in_pool = corp.num_market_shares).zero?
              0
            elsif pool_share_drop == :one
              1
            else
              shares_in_pool
            end
          price_drops.times { @game.stock_market.move_down(corp) }

          @game.log_share_price(corp, prev)
        end
      end

      def sold_out?(corporation)
        corporation.player_share_holders.values.sum == 100
      end
    end
  end
end
