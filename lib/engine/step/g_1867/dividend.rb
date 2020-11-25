# frozen_string_literal: true

require_relative '../dividend'
require_relative '../half_pay'
require_relative '../minor_half_pay'

module Engine
  module Step
    module G1867
      class Dividend < Dividend
        DIVIDEND_TYPES = %i[payout half withhold].freeze
        include HalfPay

        def actions(entity)
          return [] if entity.total_shares == 2

          super
        end

        def skip!
          return super unless current_entity.total_shares == 2

          revenue = @game.routes_revenue(routes)
          process_dividend(Action::Dividend.new(
            current_entity,
            kind: revenue.positive? ? 'payout' : 'withhold',
          ))
        end

        def payout(entity, revenue)
          return super unless entity.total_shares == 2

          amount = revenue / 2
          { corporation: amount, per_share: amount }
        end

        def payout_shares(entity, revenue)
          return super unless entity.total_shares == 2

          @log << "#{entity.owner.name} receives #{@game.format_currency(revenue)}"
          @game.bank.spend(revenue, entity.owner)
        end

        def share_price_change(entity, revenue = 0)
          if entity.total_shares == 2
            super
          else

            price = entity.share_price.price
            return { share_direction: :left, share_times: 1 } unless revenue.positive?

            if revenue >= price
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
