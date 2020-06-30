# frozen_string_literal: true

module View
  module Game
    class Bank < Snabberb::Component
      needs :game

      def render
        props = {
          style: {
            'margin-bottom': '1rem',
          },
        }
        h(:div, props, "Bank Cash: #{@game.format_currency(@game.bank.cash)}")
      end
    end
  end
end
