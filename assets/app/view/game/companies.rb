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

        companies = owned_companies.flat_map do |c|
          h(Company, company: c, layout: :table)
        end

        table_props = {
          style: {
            padding: '0 0.5rem',
            grid: @owner.player? ? 'auto / 4fr 1fr 1fr' : 'auto / 5fr 1fr',
            gap: '0 0.3rem',
          },
        }

        h('div#company_table', table_props, [
          h('div.bold', 'Company'),
          @owner.player? ? h('div.bold.right', 'Value') : '',
          h('div.bold.right', 'Income'),
          *companies,
        ])
      end
    end
  end
end
