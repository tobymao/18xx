# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/company'

module View
  module Game
    class BuyCompaniesAtFaceValue < Snabberb::Component
      include Actionable

      def render
        props = {
          style: {
            display: 'inline-block',
            verticalAlign: 'top',
          },
        }
        buyable_companies = @game.round.active_step.purchasable_unsold_companies.map do |company|
          children = [h(Company, company: company)]
          children << render_company_buy(company)
          h(:div, props, children)
        end
        h('div.buyable_companies', props, buyable_companies)
      end

      private

      def render_company_buy(company)
        price = company.value
        buy_company = lambda do
          process_action(Engine::Action::BuyCompany.new(
            @game.current_entity,
            company: company,
            price: price,
          ))
        end
        h(:button, { on: { click: buy_company } }, "Buy (#{@game.format_currency(price)})")
      end
    end
  end
end
