# frozen_string_literal: true

module View
  module Game
    class Token < Snabberb::Component
      needs :token
      needs :radius

      def render
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
    end
  end
end
