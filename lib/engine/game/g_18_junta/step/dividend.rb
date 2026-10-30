# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G18Junta
      module Step
        # Rules summary 3.5: withholding moves left and a payout moves right, as in 1830. A high
        # dividend (total payout of at least twice the share price) moves one space right and one up.
        class Dividend < Engine::Step::Dividend
          def share_price_change(entity, revenue = 0)
            return { share_direction: :left, share_times: 1 } unless revenue.positive?
            return { share_direction: :right, share_times: 1 } unless revenue >= entity.share_price.price * 2

            { share_direction: %i[right up], share_times: [1, 1] }
          end

          def process_dividend(action)
            entity = action.entity
            revenue = total_revenue
            @game.pay_private_h_bonus!(entity, revenue) if action.kind == 'payout' && revenue >= entity.share_price.price * 2

            super
          end
        end
      end
    end
  end
end
