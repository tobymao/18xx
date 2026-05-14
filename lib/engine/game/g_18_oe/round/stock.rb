# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Round
    module G18OE
      class Stock < Engine::Round::Stock
        protected

        def finish_round
          corporations_to_move_price.sort_by { |c| -c.share_price.price }.each do |corp|
            next unless corp.share_price

            old_price = corp.share_price

            sold_out_stock_movement(corp) if sold_out?(corp) && @game.sold_out_increase?(corp)

            pool_share_drop = @game.class::POOL_SHARE_DROP
            if pool_share_drop != :none && corp.num_market_shares.positive?
              case pool_share_drop
              when :down_block
                @game.stock_market.move_down(corp)
              when :down_share
                corp.num_market_shares.times { @game.stock_market.move_down(corp) }
              when :left_block
                @game.stock_market.move_left(corp)
              end
            end

            @game.log_share_price(corp, old_price)
          end
        end
      end
    end
  end
end
