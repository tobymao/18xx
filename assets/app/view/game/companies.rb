# frozen_string_literal: true

require 'view/game/company'

module View
  module Game
    class Companies < Snabberb::Component
      needs :game
      needs :user, default: nil
      needs :owner, default: nil

      def render
        companies = @owner.companies.map do |c|
          h(Company, company: c, layout: 'table')
        end

        table_props = {
          style: {
            padding: '0 0.5rem',
          },
        }
        row_props = {
          style: {
            grid: @owner.player? ? '1fr / 4fr 1fr 1fr' : '1fr / 5fr 1fr',
            justifySelf: 'stretch',
            gap: '0 0.2rem',
          },
        }

        h('div#company_table', table_props, [
          h('div.bold', row_props, [
            h(:div, 'Company'),
            @owner.player? ? h('div.right', 'Value') : '',
            h('div.right', 'Income'),
          ]),
          h(:div, companies),
        ])
      end
    end
  end
end
