# frozen_string_literal: true

require 'lib/params'
require 'view/link'

module View
  class HistoryControls < Snabberb::Component
    needs :app_route, default: nil, store: true
    needs :num_actions, default: 0

    def render
      return h(:div) if @num_actions.zero?

      divs = [h('b.margined', 'History')]
      cursor = Lib::Params['action']&.to_i

      unless cursor&.zero?
        divs << link('|<', 0)
        divs << link('<', cursor ? cursor - 1 : @num_actions - 1)
      end

      if cursor
        divs << link('>', cursor + 1 < @num_actions ? cursor + 1 : nil)
        divs << link('>|')
      end

      h(:div, divs)
    end

    def link(text, action_id = nil)
      route = Lib::Params.add(@app_route, 'action', action_id)

      click = lambda do
        puts "** route #{route}"
        store(:app_route, route)
      end

      h(
        Link,
        href: route,
        click: click,
        children: text,
        style: {
          color: 'black',
          'margin-right': '2rem',
          'text-decoration': 'none',
        },
      )
    end
  end
end
