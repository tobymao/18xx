# frozen_string_literal: true

require 'view/create_game'

module View
  class Navigation < Snabberb::Component
    needs :app_route, default: '/', store: true

    LINKS = [
      %w[18xx.games /],
    ].freeze

    def render
      props = {
        style: {
          padding: '1rem 0',
          'box-shadow' => '0 2px 0 0 #f5f5f5',
        }
      }

      items = LINKS.map { |name, href| item(name, href) }

      h('div.pure-menu', props, items)
    end

    def item(name, href)
      h('a.pure-menu-heading', { attrs: { href: href } }, name)
    end
  end
end
