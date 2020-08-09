# frozen_string_literal: true

require 'lib/params'
require 'view/link'
require 'view/game/actionable'

module View
  module Game
    class HistoryControls < Snabberb::Component
      include Actionable
      needs :app_route, default: nil, store: true
      needs :num_actions, default: 0
      needs :game, store: true
      needs :round_history, default: nil, store: true

      def render
        return h(:div) if @num_actions.zero?

        divs = [h('b.margined', 'History')]
        cursor = Lib::Params['action']&.to_i

        unless cursor&.zero?
          divs << link('|<', 'Start', 0)

          last_round =
            if cursor == @game.actions.size
              @game.round_history[-2]
            else
              @game.round_history[-1]
            end
          divs << link('<<', 'Previous Round', last_round) if last_round

          divs << link('<', 'Previous Action', cursor ? cursor - 1 : @num_actions - 1)
        end

        if cursor
          divs << link('>', 'Next Action', cursor + 1 < @num_actions ? cursor + 1 : nil)
          store(:round_history, @game.round_history, skip: true) unless @round_history
          next_round = @round_history[@game.round_history.size]
          divs << link('>>', 'Next Round', next_round) if next_round
          divs << link('>|', 'Current')
        end

        h(:div, divs)
      end

      def link(text, title, action_id = nil)
        route = Lib::Params.add(@app_route, 'action', action_id)

        click = lambda do
          store(:round_history, @game.round_history, skip: true) unless @round_history
          store(:round_history, nil, skip: true) unless action_id
          store(:app_route, route)
          clear_ui_state
        end

        h(
          Link,
          href: route,
          click: click,
          title: title,
          children: text,
          style: {
            color: 'currentColor',
            marginRight: '2rem',
            textDecoration: 'none',
          },
        )
      end
    end
  end
end
