# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/company'

module View
  module Game
    class BuyCompanies < Snabberb::Component
      include Actionable

      needs :selected_company, default: nil, store: true

      def render
        @corporation = @game.current_entity

        h(:div, 'Buy Private Companies', [
          *render_companies,
        ].compact)
      end

      def render_companies
        props = {
          style: {
            display: 'inline-block',
            'vertical-align': 'top',
          },
        }

        companies = @game.purchasable_companies.sort_by do |company|
          [company.owner == @corporation.owner ? 0 : 1, company.value]
        end

        companies.map do |company|
          children = [h(Company, company: company)]
          children << render_input if @selected_company == company
          h(:div, props, children)
        end
      end

      def render_input
        input = h(:input, style: { 'margin-right': '1rem' }, props: {
          value: @selected_company.max_price,
          type: 'number',
          min: @selected_company.min_price,
          max: @selected_company.max_price,
          size: @corporation.cash.to_s.size,
        })

        buy = lambda do
          price = input.JS['elm'].JS['value'].to_i
          process_action(Engine::Action::BuyCompany.new(@corporation, @selected_company, price))
          store(:selected_company, nil, skip: true)
        end

        props = {
          style: {
            'text-align': 'center',
            'margin': '1rem',
          },
        }

        h(:div, props, [
          input,
          h(:button, { on: { click: buy } }, 'Buy'),
        ])
      end
    end
  end
end
