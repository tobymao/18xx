# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/minor_half_pay'

module Engine
  module Game
    module G18SJ
      module Step
        class Dividend < Engine::Step::Dividend
          include Engine::Step::MinorHalfPay

          def share_price_change(entity, revenue = 0)
            return {} if entity.minor?

            price = entity.share_price.price
            return { share_direction: :left, share_times: 1 } unless revenue.positive?

            times = 0
            times = 1 if revenue >= price
            times = 2 if revenue >= price * 2 && price > 82
            if times.positive?
              { share_direction: :right, share_times: times }
            else
              {}
            end
          end

          # In 18SJ, full cap corporations does not receive any dividends for pool shares (see rule 15.2 step 5)
          def dividends_for_entity(entity, holder, per_share)
            return 0 if !@game.oscarian_era &&
                        entity.corporation? &&
                        entity.capitalization == :full &&
                        holder == @game.share_pool

            super
          end

          def process_dividend(action)
            super

            # Do some clean up for the entity in the OR
            @game.clean_up_after_dividend
          end
        end
      end
    end
  end
end
