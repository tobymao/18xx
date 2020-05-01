# frozen_string_literal: true

module View
  class Token < Snabberb::Component
    needs :corporation
    needs :radius

    def render
      h(:image, attrs: { href: @corporation.logo,
                         x: -@radius,
                         y: -@radius,
                         height: (2 * @radius),
                         width: (2 * @radius) })
    end
  end
end
