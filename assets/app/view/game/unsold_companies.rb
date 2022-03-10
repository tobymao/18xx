# frozen_string_literal: true

require 'view/game/company'

module View
  module Game
    class UnsoldCompanies < Snabberb::Component
      needs :game
      needs :owner, default: nil

      def render
        unsold_companies = @owner.unsold_companies

        companies = unsold_companies.flat_map do |c|
          h(Company, company: c, layout: :table)
        end

        top_padding = @owner.companies.empty? ? '0' : '1em'
        table_props = {
          style: {
            padding: "#{top_padding} 0.5rem 0.2rem",
            grid: @game.show_value_of_companies?(@owner) ? 'auto / 1fr auto auto' : 'auto / 1fr auto',
            gap: '0 0.3rem',
          },
        }

        h('div.unsold_company_table', table_props, [
          h('div.bold', 'Unsold'),
          @game.show_value_of_companies?(@owner) ? h('div.bold.right', 'Value') : '',
          h('div.bold.right', 'Income'),
          *companies,
        ])
      end
    end
  end
end
