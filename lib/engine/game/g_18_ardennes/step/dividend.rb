# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G18Ardennes
      module Step
        class Dividend < Engine::Step::Dividend
          # Public companies cannot enter the left-handmost space on the market.
          MAJOR_MIN_PRICE = 50

          def auto_actions(entity)
            return super unless entity.receivership?

            [Action::Dividend.new(entity, kind: 'payout')]
          end

          def payout(entity, revenue)
            return half(entity, revenue) if entity.type == :minor

            super
          end

          def half(_entity, revenue)
            withheld = (revenue / 2.0).ceil
            { corporation: withheld, per_share: revenue - withheld }
          end

          def share_price_change(entity, revenue = 0)
            price = entity.share_price.price
            revenue *= 2 if entity.type == :minor

            if revenue.zero? && (price > MAJOR_MIN_PRICE || entity.type == :minor)
              { share_direction: :left, share_times: 1 }
            elsif (revenue >= price * 2) &&
                  (entity.type != :'10-share') &&
                  !price.zero?
              { share_direction: :right, share_times: 2 }
            elsif revenue >= price
              { share_direction: :right, share_times: 1 }
            else
              {}
            end
          end

          def holder_for_corporation(entity)
            # This is needed to stop minor companies in receivership being
            # paid for their president's certificate in the share pool.
            entity
          end
        end
      end
    end
  end
end
