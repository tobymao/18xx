# frozen_string_literal: true

require 'view/game/company'

module View
  module Game
    class Companies < Snabberb::Component
      needs :game
      needs :user, default: nil
      needs :owner, default: nil
      needs :layout, default: 'list'

      def render
        case @layout
        when 'table'
          render_companies_table(@owner)
        when 'list'
          h(:div, @game.companies.sort_by(&:name).map { |c| h(Company, company: c) })
        else
          children = @game
            .companies
            .select(&:owner)
            .group_by(&:owner)
            .sort_by { |owner, _| owner.name == @user&.dig(:name) ? '' : owner.name }
            .map { |owner, companies| render_companies(owner, companies) }

          h(:div, children)
        end
      end

      def render_companies(owner, companies)
        h(:div, { style: { 'margin-bottom': '0.5rem' } }, [
          h(:div, { style: { 'border-bottom': '1px solid gainsboro' } }, owner.name),
          *companies.map { |c| h(Company, company: c) },
        ])
      end

      def render_companies_table(owner)
        companies = owner.companies.map do |c|
          h(Company, company: c, layout: 'table')
        end

        table_props = {
          style: {
            padding: '0 0.5rem',
          },
        }
        row_props = {
          style: {
            grid: owner.player? ? '1fr / 4fr 1fr 1fr' : '1fr / 5fr 1fr',
            justifySelf: 'stretch',
            gap: '0 0.2rem',
          },
        }

        h('div#company_table', table_props, [
          h('div.bold', row_props, [
            h(:div, 'Company'),
            owner.player? ? h('div.right', 'Value') : '',
            h('div.right', 'Income'),
          ]),
          h(:div, companies),
        ])
      end
    end
  end
end
