# frozen_string_literal: true

require 'lib/params'
require 'view/link'

module View
  module Game
    class HistoryControls < Snabberb::Component
      needs :app_route, default: nil, store: true
      needs :num_actions, default: 0
      needs :game, store: true
      needs :fullgame, store: true

      def render
        return h(:div) if @num_actions.zero?

        divs = [h('b.margined', 'History')]
        cursor = Lib::Params['action']&.to_i

        unless cursor&.zero?
          divs << link('|<', 0)

          last_round =
            if cursor == @game.actions.size
              @game.round_history[-2]
            else
              @game.round_history[-1]
            end&.dig(:first_action)
          divs << link('<Round', last_round) if last_round

          divs << link('<', cursor ? cursor - 1 : @num_actions - 1)
        end

        if cursor
          divs << link('>', cursor + 1 < @num_actions ? cursor + 1 : nil)
          next_round = @fullgame.round_history[@game.round_history.size]&.dig(:first_action)
          divs << link('>Round', next_round) if next_round
          divs << link('>|')
        end

        h(:div, divs)
      end

      def link(text, action_id = nil)
        route = Lib::Params.add(@app_route, 'action', action_id)

        click = lambda do
          store(:app_route, route)
        end

        h(
          Link,
          href: route,
          click: click,
          children: text,
          style: {
            color: 'currentColor',
            'margin-right': '2rem',
            'text-decoration': 'none',
          },
        )
      end
    end
  end
end
