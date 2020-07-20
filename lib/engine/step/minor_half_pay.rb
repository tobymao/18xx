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

        revenue = routes.sum(&:revenue)
        process_dividend(Action::Dividend.new(
          current_entity,
          kind: revenue.positive? ? 'payout' : 'withhold',
        ))
      end

      def payout(entity, revenue)
        return super if entity.corporation?

        @log << "#{entity.name} pays out #{@game.format_currency(revenue)}"

        amount = revenue / 2

        [entity, entity.owner].each do |entity2|
          @log << "#{entity2.name} receives #{@game.format_currency(amount)}"
          @game.bank.spend(amount, entity2)
        end
      end
    end
  end
end
