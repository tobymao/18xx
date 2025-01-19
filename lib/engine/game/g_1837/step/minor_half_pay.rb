# frozen_string_literal: true

module Engine
  module Game
    module G1837
      module Step
        module MinorHalfPay
          def actions(entity)
            return super unless entity.minor?

            []
          end

          def skip!
            return super unless current_entity.minor?

            revenue = @game.routes_revenue(routes)
            process_dividend(Action::Dividend.new(
              current_entity,
              kind: revenue.positive? ? 'payout' : 'withhold',
            ))
          end

          def share_price_change(entity, revenue = 0)
            return super unless entity.minor?

            {}
          end

          def payout(entity, revenue)
            return super unless entity.minor?

            amount = revenue / 2
            { corporation: amount, per_share: amount }
          end

          def payout_shares(entity, revenue)
            return super unless entity.minor?

            @log << "#{entity.owner.name} receives #{@game.format_currency(revenue)}"
            @game.bank.spend(revenue, entity.owner)
          end
        end
      end
    end
  end
end
