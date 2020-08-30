# frozen_string_literal: true

module Engine
  module Step
    module MinorHalfPay
      def actions(entity)
        return [] if entity.minor?

        super
      end

      def skip!
        return super if current_entity.corporation?

        revenue = @game.routes_revenue(routes)
        process_dividend(Action::Dividend.new(
          current_entity,
          kind: revenue.positive? ? 'payout' : 'withhold',
        ))
      end

      def share_price(entity, revenue = 0)
        return super if entity.corporation?

        {}
      end

      def payout(entity, revenue)
        return super if entity.corporation?

        amount = revenue / 2
        { corporation: amount, per_share: amount }
      end

      def payout_shares(entity, revenue)
        return super if entity.corporation?

        @log << "#{entity.owner.name} receives #{@game.format_currency(revenue)}"
        @game.bank.spend(revenue, entity.owner)
      end
    end
  end
end
