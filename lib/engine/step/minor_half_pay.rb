# frozen_string_literal: true

module Engine
  module Step
    module MinorHalfPay
      def payout(entity, revenue)
        return super if entity.corporation?

        @log << "#{entity.name} pays out #{@game.format_currency(revenue)}"

        amount = revenue / 2

        [entity, entity.owner].each do |entity|
          @log << "#{entity.name} receives #{@game.format_currency(amount)}"
          @game.bank.spend(amount, entity)
        end
      end
    end
  end
end
