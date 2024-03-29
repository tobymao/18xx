# frozen_string_literal: true

module Engine
  module Step
    module MinorHalfPay
      def actions(entity)
        return [] if entity.minor?
        return [] if entity.corporation? && entity.type == :minor

        super
      end

      def skip!
        return super if current_entity.corporation? && current_entity.type != :minor

        revenue = @game.routes_revenue(routes)
        process_dividend(Action::Dividend.new(
          current_entity,
          kind: revenue.positive? ? 'payout' : 'withhold',
        ))
      end

      def share_price_change(entity, revenue = 0)
        return super if entity.corporation? && entity.type != :minor

        {}
      end

      def payout(entity, revenue)
        return super if entity.corporation? && entity.type != :minor

        amount = revenue / 2
        { corporation: amount, per_share: amount }
      end

      def payout_shares(entity, revenue)
        return super if entity.corporation? && entity.type != :minor

        @log << "#{entity.owner.name} receives #{@game.format_currency(revenue)}"
        @game.bank.spend(revenue, entity.owner)
      end
    end
  end
end
