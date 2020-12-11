# frozen_string_literal: true

module View
  module Game
    class Token < Snabberb::Component
      needs :token
      needs :radius

      RED_WIDTH = 7
      WHITE_WIDTH = 2

      def render
        if @token.status != :flipped
          render_token
        else
          children = [render_token]
          children.concat(render_stroke)
          h(:g, children)
        end
      end

      def render_token
        h(
          :image, attrs: {
            href: @token.logo,
            x: -@radius,
            y: -@radius,
            height: (2 * @radius),
            width: (2 * @radius),
          },
        )
      end

      def render_stroke
        s = (@radius / Math.sqrt(2)).round(2)
        d = ((RED_WIDTH + WHITE_WIDTH) / 2.0 / Math.sqrt(2)).round(2)
        [
          h(
            :path, attrs: {
              d: "M #{s} #{-s} L #{-s} #{s}",
              stroke: 'red',
              'stroke-width': RED_WIDTH,
              'stroke-opacity': '0.6',
            },
          ),
          h(
            :path, attrs: {
              d: "M #{s - d} #{-s - d} L #{-s - d} #{s - d}",
              stroke: 'white',
              'stroke-width': WHITE_WIDTH,
              'stroke-opacity': '1.0',
            },
          ),
          h(
            :path, attrs: {
              d: "M #{s + d} #{-s + d} L #{-s + d} #{s + d}",
              stroke: 'white',
              'stroke-width': WHITE_WIDTH,
              'stroke-opacity': '1.0',
            },
          ),
        ]
      end
    end
  end
end
