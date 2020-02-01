# frozen_string_literal: true

require 'snabberb/component'

module View
  module SvgTokens
    # 1889 - Uwajima Railway
    class UR < Snabberb::Component
      def render
        h(:g, { attrs: { 'fill-rule' => 'evenodd',
                         'stroke-width' => '.26',
                         'transform' => 'translate(-53.3 -50.441) scale(3.90769)' } },
          [
            h(:circle, attrs: { class: 'color-main color-brown',
                                fill: '#6f533e',
                                cx: '20.14',
                                cy: '19.408',
                                r: '6.5' }),
            h(:path, attrs: { class: 'color-white',
                              fill: '#fff',
                              color: '#000',
                              'font-family': 'sans-serif',
                              'font-weight': '400',
                              overflow: 'visible',
                              style: 'line-height:normal;font-variant-ligatures:normal;font-variant-position:normal;font-variant-caps:normal;font-variant-numeric:normal;font-variant-alternates:normal;font-feature-settings:normal;text-indent:0;text-align:start;text-decoration-line:none;text-decoration-style:solid;text-decoration-color:#000;text-transform:none;text-orientation:mixed;white-space:normal;shape-padding:0;isolation:auto;mix-blend-mode:normal;solid-color:#000;solid-opacity:1',
                              d: 'M19.96 15.662a.3.3 0 00-.3.3v.127h-.002v.087a.197.197 0 01-.15.19 3.43 3.43 0 00-2.794 3.363 3.432 3.432 0 003.426 3.426 3.432 3.432 0 003.425-3.426 3.429 3.429 0 00-2.83-3.367.198.198 0 01-.147-.177v-.224a.3.3 0 00-.3-.3zm.18 1.39a2.67 2.67 0 012.676 2.677 2.671 2.671 0 01-1.889 2.558.475.475 0 01-.476-.477v-2.18c0-.06.044-.108.102-.12h.712c.07 0 .125-.055.125-.124v-.49h-.003c-.02-.145-.233-.258-.497-.258h-1.545c-.264 0-.477.113-.496.257h-.004v.49c0 .07.056.126.125.126h.752a.123.123 0 01.101.12v1.648l-.003.018v.513c0 .27-.213.477-.48.474a2.67 2.67 0 01-1.876-2.555 2.67 2.67 0 012.676-2.676z', }),
          ])
      end
    end
  end
end
