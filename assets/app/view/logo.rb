# frozen_string_literal: true

require 'lib/color'

module View
  class Logo < Snabberb::Component
    needs :user, default: nil, store: true

    RED = '#ec232a'
    YELLOW = '#f0e68c'

    def render
      logo_class = 'default'
      if (bg_color = @user&.dig(:settings, :bg_color))
        logo_class = Lib::Color.contrast(RED, bg_color) > Lib::Color.contrast(YELLOW, bg_color) ? 'red' : 'yellow'
      end
      h('div#logo', [
        h('a', { attrs: { href: '/', title: '18xx.Games' } }, [
          h("span#logo__18xx.#{logo_class}", '18xx'),
          h('span#logo__games', '.Games'),
        ]),
      ])
    end
  end
end
