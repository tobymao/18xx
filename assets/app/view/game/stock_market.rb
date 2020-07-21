# frozen_string_literal: true

require 'lib/settings'
require 'view/game/bank'
require 'view/game/token'

module View
  module Game
    class StockMarket < Snabberb::Component
      include Lib::Settings

      needs :game
      needs :show_bank, default: false
      needs :explain_colors, default: false
      needs :splayed, default: nil, store: true

      COLOR_MAP = {
        red: '#ffaaaa',
        blue: '#35a7ff',
        brown: '#8b4513',
        orange: '#ffbb55',
        yellow: '#ffff99',
        black: '#000000',
      }.freeze

      BORDER = 1
      WIDTH_TOTAL = 50                            # of entire box, including border
      HEIGHT_TOTAL = 50
      TOKEN_PAD = 2                               # left/right padding of tokens within box
      TOKEN_SIZE = 25
      BOX_WIDTH = WIDTH_TOTAL - 2 * BORDER
      LEFT_MARGIN = TOKEN_PAD                     # left edge of leftmost token
      RIGHT_MARGIN = BOX_WIDTH - TOKEN_PAD        # right edge of rightmost token
      LEFT_TOKEN_POS = LEFT_MARGIN
      RIGHT_TOKEN_POS = RIGHT_MARGIN - TOKEN_SIZE # left edge of rightmost token
      MID_TOKEN_POS = (LEFT_TOKEN_POS + RIGHT_TOKEN_POS) / 2

      def render
        space_style = {
          position: 'relative',
          display: 'inline-block',
          padding: '5px',
          boxSizing: 'border-box',
          width: "#{WIDTH_TOTAL}px",
          height: "#{HEIGHT_TOTAL}px",
          verticalAlign: 'top',
        }

        box_style = space_style.merge(
          border: "solid #{BORDER}px rgba(0,0,0,0.2)",
          color: color_for(:font2),
        )

        colors_in_market = []
        grid = @game.stock_market.market.flat_map do |prices|
          rows = prices.map do |price|
            if price
              style = box_style.merge(backgroundColor: price.color ? COLOR_MAP[price.color] : color_for(:bg2))
              if price.color == :black
                style[:color] = 'gainsboro'
                style[:borderColor] = color_for(:font)
              end
              colors_in_market << price.color unless colors_in_market.include?(price.color)
              corporations = price.corporations
              num = corporations.size
              spacing = num > 1 ? (RIGHT_TOKEN_POS - LEFT_TOKEN_POS) / (num - 1) : 0

              tokens = corporations.map.with_index do |corporation, index|
                props = {
                  attrs: { data: corporation.logo, width: "#{TOKEN_SIZE}px", alt: corporation.name },
                  style: {
                    left: num > 1 ? "#{LEFT_TOKEN_POS + ((num - index - 1) * spacing)}px" : "#{MID_TOKEN_POS}px",
                    zIndex: num - index,
                    pointerEvents: 'none',
                  },
                }
                h(:object, props)
              end

              if tokens.size > 2
                id = corporations[0].name
                box_props = {
                  attrs: { title: "#{@splayed == id ? 'stack' : 'splay'} tokens" },
                  style: { cursor: 'pointer', **style },
                  on: { click: -> { store(:splayed, @splayed == id ? nil : id) } },
                }
                token_div = h(:div, { class: { splayed: @splayed == id } }, tokens)
              else
                box_props = { style: style }
                token_div = h(:div, tokens)
              end

              h(:div, box_props, [
                h(:div, { style: { 'font-size': '80%' } }, price.price),
                token_div,
              ])
            else
              h(:div, { style: space_style }, '')
            end
          end

          h(:div, { style: { width: 'max-content' } }, rows)
        end

        children = [h(Bank, game: @game)]
        children.concat(grid)

        if @explain_colors
          colors_text = {
            red: 'Par values',
            yellow: 'Corporation shares do not count towards cert limit',
            orange: 'Corporation shares can be held above 60%',
            brown: 'Can buy more than one share in the Corporation per turn',
            black: 'Corporation closes',
            blue: 'End game trigger',
          }
          legend_items = colors_text.flat_map do |color, text|
            next unless colors_in_market.include?(color)

            style = box_style.merge(backgroundColor: COLOR_MAP[color])
            style[:borderColor] = color_for(:font) if color == :black
            [h(:div, { style: style }, ''), h(:div, text)]
          end

          legend_props = {
            style: {
              display: 'grid',
              grid: 'auto / max-content 1fr',
              gap: '1rem',
              marginTop: '1rem',
              alignItems: 'center',
            },
          }
          children << h(:div, legend_props, legend_items.compact)
        end

        props = {
          style: {
            width: '100%',
            overflow: 'auto',
          },
        }

        h('div#stock_market', props, children)
      end
    end
  end
end
