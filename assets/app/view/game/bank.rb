# frozen_string_literal: true

require 'lib/settings'

module View
  module Game
    class Bank < Snabberb::Component
      include Lib::Settings

      needs :game
      needs :layout, default: nil

      def render
        if @layout == :card
          render_card
        else
          props = {
            style: {
              marginBottom: '1rem',
            },
          }
          h(:div, props, "Bank Cash: #{@game.format_currency(@game.bank.cash)}")
        end
      end

      def render_card
        title_props = {
          style: {
            padding: '0.4rem',
            backgroundColor: color_for(:bg2),
            color: color_for(:font2),
          },
        }
        body_props = {
          style: {
            margin: '0.3rem 0.5rem 0.4rem',
            display: 'grid',
            grid: 'auto / 1fr',
            gap: '0.5rem',
            justifyItems: 'center',
          },
        }

        h('div.bank.card', [
          h('div.title.nowrap', title_props, [h(:em, 'The Bank')]),
          h(:div, body_props, [
            h(:div, @game.format_currency(@game.bank.cash)),
            h(GameInfo, game: @game, layout: 'discarded_trains'),
          ]),
        ])
      end
    end
  end
end
