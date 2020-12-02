# frozen_string_literal: true

require_relative '../stock'

module Engine
  module Round
    module G1828
      class Stock < Stock
        def finish_round
          @game.corporations.select(&:floated?).sort.each do |corp|
            @game.stock_market.move_up(corp) if corp.share_price.type == :unlimited
            @game.stock_market.move_up(corp) if corp.owner.num_shares_of(corp) >= 8
          end

          super
        end
      end
    end
  end
end
