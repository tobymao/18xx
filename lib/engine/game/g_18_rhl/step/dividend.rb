# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G18Rhl
      module Step
        class Dividend < Engine::Step::Dividend
          def actions(entity)
            return [] if entity.corporation? && entity.receivership?

            super
          end

          # In 18Rhl, full cap corporations does not receive any dividends for pool shares
          def dividends_for_entity(entity, holder, per_share)
            return 0 if entity.corporation? &&
                        entity.capitalization == :full &&
                        holder == @game.share_pool

            super
          end

          def share_price_change(entity, revenue = 0)
            return { share_direction: :left, share_times: 1 } unless revenue.positive?

            if revenue >= entity.share_price.price
              { share_direction: :right, share_times: 1 }
            else
              {}
            end
          end
        end
      end
    end
  end
end
