# frozen_string_literal: true

module Engine
  module Step
    module HalfPay
      def half(entity, revenue)
        withheld = (revenue / 2 / 10).to_i * 10
        @bank.spend(withheld, entity)
        @log << "#{entity.name} runs for #{@game.format_currency(revenue)} and pays half"
        @log << "#{entity.name} witholds #{@game.format_currency(withheld)}"
        payout(revenue - withheld)
      end
    end
  end
end
