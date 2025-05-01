# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/half_pay'
require_relative '../../../step/minor_half_pay'

module Engine
  module Game
    module G1867
      module Step
        class Dividend < Engine::Step::Dividend
          DIVIDEND_TYPES = %i[payout half withhold].freeze
          include Engine::Step::HalfPay

          def actions(entity)
            return [] if !entity.corporation? || @game.minor?(entity)

            super
          end

          def skip!
            return super unless @game.minor?(current_entity)

            revenue = @game.routes_revenue(routes)
            process_dividend(Action::Dividend.new(
              current_entity,
              kind: revenue.positive? ? 'payout' : 'withhold',
            ))
          end

          def payout(entity, revenue)
            return super unless @game.minor?(current_entity)

            amount = revenue / 2
            { corporation: amount, per_share: amount }
          end

          def payout_shares(entity, revenue)
            return super unless @game.minor?(current_entity)

            @log << "#{entity.owner.name} receives #{@game.format_currency(revenue)}"
            @game.bank.spend(revenue, entity.owner) if revenue.positive?
          end

          def share_price_change(entity, revenue = 0)
            return super if @game.minor?(current_entity)
            return { share_direction: :left, share_times: 1 } unless revenue.positive?

            price = entity.share_price.price
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
