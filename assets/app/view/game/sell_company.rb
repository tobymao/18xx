# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class SellCompany < Snabberb::Component
      include Actionable

      needs :selected_company, default: nil, store: true

      def render
        return h(:span) unless @selected_company&.abilities(:sell_to_bank)

        step = @game.round.active_step(@selected_company)
        price = step.buy_price(@selected_company)

        sell = lambda do
          process_action(Engine::Action::SellCompany.new(@selected_company, price: price))
          store(:selected_company, nil, skip: true)
        end

        h(:span,
          [h(:button,
             { on: { click: sell } },
             "Sell #{@selected_company.sym} to bank for #{@game.format_currency(price)}")],)
      end
    end
  end
end
