# frozen_string_literal: true

require 'snabberb/component'

module View
  module SvgTokens
    # 1889 - Awa Railway
    class AR < Snabberb::Component
      def render
        h(:g, { attrs: { 'fill-rule' => 'evenodd',
                         'stroke-width' => '.26',
                         'transform' => 'translate(-128.95 -151.709) scale(3.90769)' } },
          [
            h(:circle, attrs: { class: 'color-main color-black',
                                fill: '#38383a',
                                cx: '39.499',
                                cy: '45.323',
                                r: '6.5' }),
            h(:path, attrs: { class: 'color-white',
                              fill: '#fff',
                              d: 'M38.957 42.277c-.498 0-.9.223-.9.5v.427a.375.375 0 000 .008.375.375 0 00.3.367h.002c.412.063.734.705.734 1.494v.463c0 .786-.32 1.426-.728 1.494a.375.375 0 00-.308.369.375.375 0 000 .006v.464c0 .277.401.5.9.5h1.084c.498 0 .9-.223.9-.5v-.464a.375.375 0 000-.006.375.375 0 00-.308-.369c-.41-.068-.728-.708-.728-1.494v-.463c0-.79.322-1.431.734-1.494h.001a.375.375 0 00.3-.367.375.375 0 000-.008v-.427c0-.277-.4-.5-.9-.5h-.545z' }),
          ])
      end
    end
  end
end
