# frozen_string_literal: true

require 'view/game/company'

module View
  module Game
    class Companies < Snabberb::Component
      needs :game
      needs :user, default: nil
      needs :owner, default: nil

      def render
        companies = @owner.companies.flat_map do |c|
          h(Company, company: c, layout: :table)
        end

        table_props = {
          style: {
            padding: '0 0.5rem',
            grid: @owner.player? ? 'auto / 4fr 1fr 1fr' : 'auto / 5fr 1fr',
            gap: '0 0.2rem',
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
