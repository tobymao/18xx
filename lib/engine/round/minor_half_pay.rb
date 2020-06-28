# frozen_string_literal: true

module Engine
  module Round
    module MinorHalfPay
      def payout(revenue)
        return super if @current_entity.corporation?

        @log << "#{@current_entity.name} pays out #{@game.format_currency(revenue)}"

        amount = revenue / 2

        [@current_entity, @current_entity.owner].each do |entity|
          @log << "#{entity.name} receives #{@game.format_currency(amount)}"
          @bank.spend(amount, entity)
        end
      end
    end
  end
end
