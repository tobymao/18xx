# frozen_string_literal: true

module Lib
  module WhatsThis
    module AutoRoute
      def auto_route_whats_this
        h(Component,
          tooltip: 'Allows players to request automatic route suggestions. Using them is optional.',
          url: 'https://github.com/tobymao/18xx/wiki/Auto-Routing')
      end
    end

    class Component < Snabberb::Component
      needs :tooltip
      needs :url

      def render
        h(:span,
          {
            style: {
              'font-size' => '0.8rem',
              'vertical-align' => 'super',
            },
          },
          [
            ' (',
            h(:a,
              {
                attrs: {
                  href: @url,
                  title: @tooltip,
                },
                style: { 'text-decoration' => 'underline dotted' },
              },
              '?'),
            ')',
          ])
      end
    end
  end
end
