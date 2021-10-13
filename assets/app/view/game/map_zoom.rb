# frozen_string_literal: true

require 'lib/storage'
require 'lib/settings'

module View
  module Game
    class MapZoom < Snabberb::Component
      include Lib::Settings

      needs :map_zoom, default: nil, store: true

      def render
        on_click = lambda do |z|
          lambda do
            store(:map_zoom, z)
            Lib::Storage['map_zoom'] = z
          end
        end

        props = {
          style: {
            background: color_for(:bg),
            position: 'absolute',
            left: '0',
            top: '0',
            padding: '0 2px 2px 0',
            borderRadius: '5px',
          },
        }

        h('div#map_zoom.inline-block', props, [
          render_button('-', "Zoom to #{(@map_zoom / 0.011).round} % – hotkey: -", on_click.call(@map_zoom / 1.1)),
          render_button('0', 'Reset zoom to 100 % – hotkey: 0', on_click.call(1)),
          render_button('+', "Zoom to #{(@map_zoom * 110).round} % – hotkey: +", on_click.call(@map_zoom * 1.1)),
        ])
      end

      def render_button(text, title, action)
        props = {
          attrs: {
            title: title,
          },
          style: {
            height: '1.5rem',
            width: '1.5rem',
            marginTop: '0',
            padding: '0',
          },
          on: {
            click: action,
          },
        }

        h("button#zoom#{text}.small", props, text)
      end
    end
  end
end
