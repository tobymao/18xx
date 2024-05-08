# frozen_string_literal: true

require 'lib/settings'
require 'lib/text'
require 'lib/profile_link'
require 'view/game/companies'
require 'view/game/unsold_companies'
require 'view/share_calculation'

module View
  module Game
    class IpoRows < Snabberb::Component
      include Lib::Settings

      needs :player
      needs :game
      needs :user, default: nil, store: true
      needs :display, default: 'inline-block'
      needs :show_hidden, default: false
      needs :hide_logo, store: true, default: false

      def render
        card_style = {
          border: '1px solid gainsboro',
          paddingBottom: '0.2rem',
        }
        card_style[:display] = @display

        divs = [
          render_title,
          render_body,
        ]

        divs << h(Companies, owner: @player, game: @game)

        h('div.player.card', { style: card_style }, divs)
      end

      def render_title
        bg_color = color_for(:bg2)

        props = {
          style: {
            padding: '0.4rem',
            backgroundColor: bg_color,
            color: contrast_on(bg_color),
          },
        }

        h('div.player.title.nowrap', props, "IPO Row #{}")
      end

      def render_body
        props = {
          style: {
            margin: '0.2rem',
            display: 'grid',
            grid: '1fr / auto-flow',
            justifyItems: 'center',
            alignItems: 'start',
          },
        }

        divs = [

        ]

        # divs << render_shares if @player.shares.any?

        h(:div, props, divs)
      end

    end
  end
end
