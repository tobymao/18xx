# frozen_string_literal: true

require_relative '../dividend'
require_relative '../half_pay'

module Engine
  module Step
    module G1822
      class Dividend < Dividend
        DIVIDEND_TYPES = %i[payout half withhold].freeze
        include HalfPay

        def actions(entity)
          return [] if entity.type == :minor

          super
        end

        def half_pay_withhold_amount(entity, revenue)
          entity.type == :minor ? revenue / 2.0 : super
        end

        def skip!
          return super if current_entity.type == :major

          revenue = @game.routes_revenue(routes)
          process_dividend(Action::Dividend.new(
            current_entity,
            kind: revenue.positive? ? 'half' : 'withhold',
          ))
        end

        def share_price_change(entity, revenue = 0)
          return { share_direction: :left, share_times: 1 } unless revenue.positive?

          if revenue >= entity.share_price.price || entity.type == :minor
            { share_direction: :right, share_times: 1 }
          else
            {}
          end
        end
      end
    end
  end
end
