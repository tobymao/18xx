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

        ipo_cards = ipo_rows.map.with_index do |ipo_row, index|
          h(:div, [render_ipo_row(ipo_row, index + 1)])
        end
      end

      def render_ipo_row(ipo_row, number)
        card_style = {
          border: '1px solid gainsboro',
          paddingBottom: '0.2rem',
        }
        card_style[:display] = @display

        divs = [
          render_title(number),
        ]

        divs << render_companies(ipo_row)

        h('div.player.card', { style: card_style }, divs)
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

        h('div.player.title.nowrap', props, ["IPO Row #{number}"])
      end

      def render_companies(ipo_row)
        row_companies = ipo_row

        companies = row_companies.flat_map do |c|
          h(Company, company: c, layout: :table)
        end

        top_padding = row_companies.empty? ? '0' : '1em'
        table_props = {
          style: {
            padding: "#{top_padding} 0.5rem 0.2rem",
            grid: @game.show_value_of_companies?(@owner) ? 'auto / 1fr auto auto' : 'auto / 1fr auto',
            gap: '0 0.3rem',
          },
        }

        h('div.hand_company_table', table_props, [
          h('div.bold', 'Certificates'),
          @game.show_value_of_companies?(@owner) ? h('div.bold.right', 'Value') : '',
          h('div.bold.right', 'Income'),
          *companies,
        ])
      end
    end
  end
end
