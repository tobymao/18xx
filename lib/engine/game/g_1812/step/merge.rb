# frozen_string_literal: true

require_relative '../../g_1867/step/merge'

module Engine
  module Game
    module G1812
      module Step
        class Merge < G1867::Step::Merge
          def can_convert?(entity)
            entity.type == :minor && entity.share_price.price >= minimum_price
          end

          def convert_price(corporation)
            new_public_price(corporation.share_price.price)
          end

          def finish_convert(action)
            super
            target = action.corporation
            @game.share_pool.buy_shares(target.owner, target.shares.first.to_bundle, exchange: :free)
          end

          private

          def minimum_price
            @game.stock_market.share_prices_with_types(%i[convert_range]).map(&:price).min
          end

          def new_public_price(price)
            row = @game.stock_market.market.first
            space = row[row.rindex { |sp| sp && sp.price <= price } - 4]
            [space, @game.stock_market.par_prices.max_by(&:price)].min_by(&:price)
          end
        end
      end
    end
  end
end
