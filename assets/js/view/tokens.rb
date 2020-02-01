# frozen_string_literal: true

require 'snabberb/component'

require 'view/svg_tokens/ar'
require 'view/svg_tokens/ir'
require 'view/svg_tokens/ko'
require 'view/svg_tokens/ku'
require 'view/svg_tokens/sr'
require 'view/svg_tokens/tr'
require 'view/svg_tokens/ur'

module View
  class Tokens < Snabberb::Component
    def render
      svg_token_classes = [
        View::SvgTokens::AR,
        View::SvgTokens::IR,
        View::SvgTokens::KO,
        View::SvgTokens::KU,
        View::SvgTokens::SR,
        View::SvgTokens::TR,
        View::SvgTokens::UR,
      ]

      children = svg_token_classes.map { |t| render_token_block(t) }

      h(
        :div,
        { attrs: { id: 'tiles' } },
        children,
      )
    end

    def render_token_block(token_class)
      h(:div, { style: {
          display: 'inline-block',
          width: '76px',
          height: '100px',
          'outline-style': 'solid',
          'outline-width': 'thin',
          'margin-top': '10px',
          'margin-right': '1px',
        } }, [
          h(:div, { style: { 'text-align': 'center' } }, token_class.name.split('::').last),
          h(:svg, { style: { width: '100%', height: '100%' },
                    attrs: { transform: 'translate(19 26) scale(1.5)' } }, [
              h(token_class)
            ])
        ])
    end
  end
end
