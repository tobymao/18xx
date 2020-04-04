# frozen_string_literal: true

require 'view/actionable'
require 'view/company'

require 'engine/action/buy_company'

module View
  class BuyCompanies < Snabberb::Component
    include Actionable

    needs :selected_company, default: nil, store: true

    def render
      @round = @game.round
      @corporation = @round.current_entity
      @player = @corporation.owner

      h(:div, 'Buy Private Companies', [
        *render_companies,
        *render_input,
      ].compact)
    end

    def render_companies
      @player.companies.map do |company|
        h(Company, company: company)
      end
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
