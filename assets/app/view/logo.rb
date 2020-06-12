# frozen_string_literal: true

require 'lib/color'

module View
  class Logo < Snabberb::Component
    needs :user, default: nil, store: true

    def render
      a_props = {
        attrs: { href: '/', title: '18xx.Games' },
        style: {
          color: 'currentColor',
          'font-weight': 'bold',
          'text-decoration': 'none',
        },
      }
      logo_color = @user&.dig(:settings, :red_logo) ? 'red' : 'yellow'
      logo_props = {
        style: {
          display: 'inline-block',
          height: '3rem',
          width: '2.5rem',
          background: "url(/images/logo_polygon_#{logo_color}.svg) left/2.5rem no-repeat",
          color: @user&.dig(:settings, :red_logo) ? '#ffffff' : '#000000',
          'text-align': 'center',
        },
      }

      h('div#logo', [
        h(:a, a_props, [
          h(:span, logo_props, '18xx'),
          h(:span, '.Games'),
        ]),
      ])
    end
  end
end
