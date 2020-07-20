# frozen_string_literal: true

module View
  class Logo < Snabberb::Component
    needs :user, default: nil, store: true

    def render
      h1_props = {
        style: {
          margin: '0',
          fontSize: '1rem',
          whiteSpace: 'nowrap',
        },
      }
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
          lineHeight: '3rem',
          background: "url(/images/logo_polygon_#{logo_color}.svg) left/2.5rem no-repeat",
          color: logo_color == 'red' ? '#ffffff' : '#000000',
          'text-align': 'center',
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
