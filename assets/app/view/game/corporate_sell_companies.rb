# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/company'

module View
  module Game
    class CorporateSellCompanies < Snabberb::Component
      include Actionable
      needs :selected_company, default: nil, store: true

      def render
        @step = @game.round.active_step
        @current_actions = @step.current_actions
        @entity ||= @game.current_entity
        props = { style: { flexGrow: '1', width: '0' } }

        h(:div, props, render_corporate_companies.compact)
      end

      def render_corporate_companies
        props = {
          style: {
            display: 'inline-block',
            verticalAlign: 'top',
          },
        }

        companies = []
        companies = @step.sellable_companies(@entity) if @current_actions.include?('corporate_sell_company')
        return [] if companies.empty?

        companies.map do |company|
          inputs = []
          inputs.concat(render_sell_input(company))

          children = []
          children << h(Company, company: company,
                                 interactive: !inputs.empty?)
          if !inputs.empty? && @selected_company == company
            children << h('div.margined_bottom', { style: { width: '20rem' } }, inputs)
          end
          h(:div, props, children)
        end
      end

      def render_sell_input(company)
        price = @step.sell_price(company)
        buy = lambda do
          process_action(Engine::Action::CorporateSellCompany.new(
            @entity,
            company: company,
            price: price,
          ))
          store(:selected_company, nil, skip: true)
        end
        [h(:button,
           { on: { click: buy } },
           "Sell #{company.sym} to Bank for #{@game.format_currency(company.value)}")]
      end
    end
  end
end
