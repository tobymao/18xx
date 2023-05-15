# frozen_string_literal: true

require 'view/game/company'

module View
  module Game
    class Companies < Snabberb::Component
      needs :game
      needs :owner, default: nil
      needs :show_hidden, default: false

      def render
        owned_companies = @owner.companies

        if @show_hidden
          round = @game.round
          current_entity = round.current_entity
          step = round.active_step
          owned_companies = step.choices[current_entity]
        end

        companies = @game.companies_sort(owned_companies).flat_map do |c|
          h(Company, company: c, layout: :table)
        end

        table_props = {
          style: {
            padding: '0 0.5rem 0.2rem',
            grid: @game.show_value_of_companies?(@owner) ? 'auto / 1fr auto auto' : 'auto / 1fr auto',
            gap: '0 0.3rem',
          },
        }

        if @game.respond_to?(:company_card_only?) && @game.company_card_only?
          h(:div, companies)
        else
          h('div.company_table', table_props, [
            h('div.bold', @game.company_table_header),
            @game.show_value_of_companies?(@owner) ? h('div.bold.right', 'Value') : '',
            h('div.bold.right', 'Income'),
            *companies,
          ])
        end
      end
    end
  end
end
