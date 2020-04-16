# frozen_string_literal: true

require 'view/actionable'
require 'view/company'

require 'engine/action/buy_company'

module View
  class BuyCompanies < Snabberb::Component
    include Actionable

    needs :selected_company, default: nil, store: true

    def render
      @corporation = @game.current_entity

      h(:div, 'Buy Private Companies', [
        *render_companies,
        *render_input,
      ].compact)
    end

    def render_companies
      companies = @game.purchasable_companies.sort_by do |company|
        [company.owner == @corporation.owner ? 0 : 1, company.value]
      end
      companies.map { |company| h(Company, company: company) }
    end

    def render_input
      return unless @selected_company

      input = h(:input, props: {
        value: @selected_company.max_price,
        type: 'number',
        min: @selected_company.min_price,
        max: @selected_company.max_price,
      })

      buy = lambda do
        price = input.JS['elm'].JS['value'].to_i
        process_action(Engine::Action::BuyCompany.new(@corporation, @selected_company, price))
        store(:selected_company, nil, skip: true)
      end

      [
        input,
        h(:button, { on: { click: buy } }, 'Buy')
      ]
    end
  end
end
