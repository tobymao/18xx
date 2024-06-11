# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/company'

module View
  module Game
    class CorporateBuyCompanies < Snabberb::Component
      include Actionable
      needs :selected_company, default: nil, store: true

      def render
        @step = @game.round.active_step
        @current_actions = @step.current_actions
        @entity ||= @game.current_entity
        props = { style: { flexGrow: '1', width: '0' } }

        children = render_bank_companies.compact
        children.concat(render_ipo_rows) if @game.show_ipo_rows?

        h(:div, props, children)
      end

      def render_ipo_rows
        div_props = {
          style: {
            display: 'inline-block',
          },
        }
        ipo_cards = h(IpoRows, game: @game, show_first: true)
        [h(:div, div_props, ipo_cards)]
      end

      def render_bank_companies
        props = {
          style: {
            display: 'inline-block',
            verticalAlign: 'top',
          },
        }

        @game.corporate_purchasable_companies(@entity).map do |company|
          inputs = []
          inputs.concat(render_buy_input(company))

          children = []
          children << h(Company, company: company,
                                 interactive: !inputs.empty?)
          if !inputs.empty? && @selected_company == company
            children << h('div.margined_bottom', { style: { width: '20rem' } }, inputs)
          end
          return [] if children.empty?

          h(:div, props, children)
        end
      end

      def render_buy_input(company)
        return [] unless @step.can_buy_company?(@entity, company)

        buy = lambda do
          process_action(Engine::Action::CorporateBuyCompany.new(
            @entity,
            company: company,
            price: company.value,
          ))
          store(:selected_company, nil, skip: true)
        end
        [h(:button,
           { on: { click: buy } },
           "Buy #{company.sym} for #{@game.format_currency(company.value)}")]
      end
    end
  end
end
