# frozen_string_literal: true

require 'lib/settings'

module View
  class Logo < Snabberb::Component
    include Lib::Settings

    needs :user, default: nil, store: true
    needs :app_route, default: nil, store: true

    def render
      show_home = lambda do
        store(:app_route, '/')
        `document.getElementById('app').scrollIntoView();`
      end

      h1_props = {
        style: {
          margin: '0',
          fontSize: '1rem',
          whiteSpace: 'nowrap',
        },
      }
      a_props = {
        attrs: {
          href: '/',
          title: '18xx.Games - Main Line',
          onclick: 'return false',
        },
        style: {
          color: 'currentColor',
          fontWeight: 'bold',
          textDecoration: 'none',
        },
        on: {
          click: show_home,
        },
      }
      logo_color = setting_for(:red_logo) ? 'red' : 'yellow'
      logo_props = {
        style: {
          display: 'inline-block',
          height: '3rem',
          width: '2.5rem',
          lineHeight: '3rem',
          background: "url(/images/logo_polygon_#{logo_color}.svg) left/2.5rem no-repeat",
          color: logo_color == 'red' ? '#ffffff' : '#000000',
          textAlign: 'center',
        },
      }

      h('h1#logo', h1_props, [
        h(:a, a_props, [
          h(:span, logo_props, '18xx'),
          h(:span, ' . Games'),
        ]),
      ])
    end
  end
end
