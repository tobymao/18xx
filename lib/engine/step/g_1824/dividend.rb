# frozen_string_literal: true

require_relative '../dividend'

module Engine
  module Step
    module G1824
      class Dividend < Dividend
        def actions(entity)
          return [] if minor_style_dividend?(entity)

          super
        end

        def setup
          @mine_revenue = 0
        end

        def skip!
          return super unless minor_style_dividend?(current_entity)

          revenue = @game.routes_revenue(routes)
          @mine_revenue = @game.mine_revenue(routes)

          process_dividend(Action::Dividend.new(
            current_entity,
            kind: revenue.positive? ? 'payout' : 'withhold',
          ))
        end

        def share_price_change(entity, revenue = 0)
          return super unless minor_style_dividend?(entity)

          {}
        end

        def payout(entity, revenue)
          return super unless minor_style_dividend?(entity)

          mine_revenue = @mine_revenue || 0
          amount = (revenue - mine_revenue) / 2
          { corporation: amount + mine_revenue, per_share: amount }
        end

        def payout_shares(entity, revenue)
          return super unless minor_style_dividend?(entity)

          @log << "#{entity.owner.name} receives #{@game.format_currency(revenue)}"
          @game.bank.spend(revenue, entity.owner)
        end

        private

        def minor_style_dividend?(entity)
          @game.pre_staatsbahn?(entity) || @game.coal_railway?(entity)
        end
      end
    end
  end
end
