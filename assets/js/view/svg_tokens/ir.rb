# frozen_string_literal: true

require 'snabberb/component'

module View
  module SvgTokens
    # 1889 - Iyo Railway
    class IR < Snabberb::Component
      def render
        h(:g, { attrs: { 'fill-rule' => 'evenodd',
                         'stroke-width' => '.26',
                         'transform' => 'translate(-195.323 -150.186) scale(3.90769)' } },
          [
            h(:circle, attrs: { class: 'color-main color-orange',
                                fill: '#f68121',
                                cx: '56.484',
                                cy: '44.933',
                                r: '6.5' }),
            h(:path, attrs: { class: 'color-white',
                              fill: '#f2f2ff',
                              d: 'M56.486 42.12l3.972 2.812-3.977 2.815-3.97-2.815z' }),
            h(:path, attrs: { class: 'color-orange',
                              fill: '#f68121',
                              d: 'M56.5 42.387v1.084l-.53.167v1.293h-.936v-.865l-2.24.877h1.495l.26.371h1.901v.6h-1.288l1.306 1.566v-1.084l.53-.167v-1.293h.936v.865l2.241-.878H58.68l-.26-.37h-1.902v-.6h1.289z' }),
          ])
      end
    end
  end
end
