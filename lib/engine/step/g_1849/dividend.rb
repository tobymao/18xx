# frozen_string_literal: true

require_relative '../dividend'

module Engine
  module Step
    module G1849
      class Dividend < Dividend
        def share_price_change(entity, revenue = 0)
          price = entity.share_price.price

          case
          when revenue.zero?
            { share_direction: :left, share_times: 1 }
          when revenue < price
            {}
          when revenue >= price
            { share_direction: :right, share_times: 1 }
          end
        end

        def pass!
          super
          @game.old_operating_order = @game.corporations.sort
        end
      end
    end
  end
end
