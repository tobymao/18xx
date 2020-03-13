# frozen_string_literal: true

require 'snabberb/component'

require 'engine/game/g_1889'
require 'view/token'

module View
  class AllTokens < Snabberb::Component
    def render
      corporations = Engine::Game::G1889.new([]).corporations

      children = corporations.map { |c| render_token_block(c) }

      h(
        :div,
        { attrs: { id: 'tiles' } },
        children,
      )
    end

    def render_token_block(corporation)
      radius = 38

      h(:div, { style: {
          display: 'inline-block',
          width: '76px',
          height: '100px',
          'outline-style': 'solid',
          'outline-width': 'thin',
          'margin-top': '10px',
          'margin-right': '1px',
        } }, [
          h(:div, { style: { 'text-align': 'center' } }, corporation.sym),
          h(:svg, { attrs: { width: (2 * radius), height: (2 * radius) } }, [
              h(:g, { attrs: { transform: "translate(#{radius} #{radius})" } }, [
                  h(View::Token, corporation: corporation, radius: radius),
                ])
            ])
        ])
    end
  end
end
