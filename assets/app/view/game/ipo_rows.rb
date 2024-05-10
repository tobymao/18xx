# frozen_string_literal: true

require 'lib/settings'
require 'view/game/company'

module View
  module Game
    class IpoRows < Snabberb::Component
      include Lib::Settings

      needs :game
      needs :display, default: 'inline-block'

      def render
        @owner = @game.bank
        ipo_rows = @game.ipo_rows

        props = {
          style: { margin: '1rem 0 1.5rem 0' },
        }

        ipo_cards = ipo_rows.map.with_index do |ipo_row, index|
          render_ipo_row(ipo_row, index + 1)
        end

        h('div.ipo.cards', props, ipo_cards.compact)
      end

      def render_ipo_row(ipo_row, number)
        card_style = {
          border: '1px solid gainsboro',
          paddingBottom: '0.2rem',
        }
        card_style[:display] = @display

        divs = [
          render_title(number),
          # render_companies(ipo_row),
        ]
        divs << render_companies(ipo_row)

        h('div.ipo.card', { style: card_style }, divs)
      end

      def render_title(number)
        bg_color = color_for(:bg2)
        props = {
          style: {
            padding: '0.4rem',
            backgroundColor: bg_color,
            color: contrast_on(bg_color),
          },
        }

        h('div.ipo.title.nowrap', props, "IPO Row #{number}")
      end

      def render_companies(ipo_row)
        companies = ipo_row.flat_map do |c|
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
