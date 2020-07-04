# frozen_string_literal: true

module Engine
  module Round
    module HalfPay
      def half(revenue)
        withheld = (revenue / 2 / 10).to_i * 10
        @bank.spend(withheld, @current_entity)
        @log << "#{@current_entity.name} runs for #{@game.format_currency(revenue)} and pays half"
        @log << "#{@current_entity.name} witholds #{@game.format_currency(withheld)}"
        payout(revenue - withheld)
      end
    end
  end
end
