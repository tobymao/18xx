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
          return [] if !entity.corporation? || entity.type == :minor

          super
        end

        def skip!
          return super if current_entity.type == :major

          revenue = @game.routes_revenue(routes)
          process_dividend(Action::Dividend.new(
            current_entity,
            kind: revenue.positive? ? 'payout' : 'withhold',
          ))
        end

        def payout(entity, revenue)
          return super if entity.type == :major

          amount = revenue / 2
          { corporation: amount, per_share: amount }
        end

        def payout_shares(entity, revenue)
          return super if entity.type == :major

          @log << "#{entity.owner.name} receives #{@game.format_currency(revenue)}"
          @game.bank.spend(revenue, entity.owner) if revenue.positive?
        end

        def share_price_change(entity, revenue = 0)
          if entity.type == :minor
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
