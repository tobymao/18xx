# frozen_string_literal: true

require 'lib/color'

module View
  class Logo < Snabberb::Component
    needs :user, default: nil, store: true

    def render
      h('div#logo', [
        h('a', { attrs: { href: '/', title: '18xx.Games' } }, [
          h("span#logo__18xx.#{@user&.dig(:settings, :red_logo) ? 'red' : 'yellow'}", '18xx'),
          h('span#logo__games', '.Games'),
        ]),
      ])
    end
  end
end
