# frozen_string_literal: true

require 'lib/settings'
require 'view/game/token'

module View
  module Game
    class StockMarket < Snabberb::Component
      include Lib::Settings

      needs :game
      needs :show_bank, default: false
      needs :explain_colors, default: false

      COLOR_MAP = {
        red: '#ffaaaa',
        blue: '#35a7ff',
        brown: '#8b4513',
        orange: '#ffbb55',
        yellow: '#ffff99',
        black: '#000000',
        gray: '#888888',
      }.freeze

      # All markets
      PAD = 5                                     # between box contents and border
      BORDER = 1
      WIDTH_TOTAL = 50                            # of entire box, including border
      TOKEN_SIZE = 25

      # 1D markets
      VERTICAL_TOKEN_PAD = 4                      # vertical space between tokens
      MIN_NUM_TOKENS = 4                          # guarantee space for this many tokens
      PRICE_HEIGHT = 20                           # depends on font and size!

      # 2D markets
      HEIGHT_TOTAL = 50
      TOKEN_PAD = 3                               # left/right padding of tokens within box
      BOX_WIDTH = WIDTH_TOTAL - 2 * BORDER
      LEFT_MARGIN = TOKEN_PAD                     # left edge of leftmost token
      RIGHT_MARGIN = BOX_WIDTH - TOKEN_PAD        # right edge of rightmost token
      LEFT_TOKEN_POS = LEFT_MARGIN
      RIGHT_TOKEN_POS = RIGHT_MARGIN - TOKEN_SIZE # left edge of rightmost token
      MID_TOKEN_POS = (LEFT_TOKEN_POS + RIGHT_TOKEN_POS) / 2

      def cell_style(box_style, price)
        style = box_style.merge(backgroundColor: price.color ? COLOR_MAP[price.color] : color_for(:bg2))
        if price.color == :black
          style[:color] = 'gainsboro'
          style[:borderColor] = color_for(:font)
        end
        style
      end

      def grid_1d
        box_style = {
          position: 'relative',
          display: 'inline-block',
          padding: "#{PAD}px",
          margin: '0',
          verticalAlign: 'top',
          width: "#{WIDTH_TOTAL - 2 * PAD - 2 * BORDER}px",
          border: "solid #{BORDER}px rgba(0,0,0,0.2)",
          color: color_for(:font2),
        }

        tokens_style = {
          textAlign: 'center',
          lineHeight: '0',
        }

        price_style = {
          fontSize: '100%',
          textAlign: 'center',
        }

        max_num_corps = @game.stock_market.market.first.map { |p| p.corporations.size }.push(MIN_NUM_TOKENS).max
        box_height = max_num_corps * (TOKEN_SIZE + VERTICAL_TOKEN_PAD) + VERTICAL_TOKEN_PAD + PRICE_HEIGHT + 2 * PAD
        box_style[:height] = "#{box_height - 2 * PAD - 2 * BORDER}px"

        row = @game.stock_market.market.first.map do |price|
          tokens = price.corporations.map do |corporation|
            props = {
              attrs: { data: corporation.logo, width: "#{TOKEN_SIZE}px" },
              style: { marginTop: "#{VERTICAL_TOKEN_PAD}px" },
            }
            h(:object, props)
          end

          h(:div, { style: cell_style(box_style, price) }, [
            h(:div, { style: price_style }, price.price),
            h(:div, { style: tokens_style }, tokens),
          ])
        end

        [h(:div, { style: { width: 'max-content' } }, row)]
      end

      def grid_2d
        @game.stock_market.market.flat_map do |row_prices|
          row = row_prices.map do |price|
            if price
              corporations = price.corporations
              num = corporations.size
              spacing = num > 1 ? (RIGHT_TOKEN_POS - LEFT_TOKEN_POS) / (num - 1) : 0

              tokens = corporations.map.with_index do |corporation, index|
                props = {
                  attrs: { data: corporation.logo, width: "#{TOKEN_SIZE}px" },
                  style: {
                    position: 'absolute',
                    left: num > 1 ? "#{LEFT_TOKEN_POS + ((num - index - 1) * spacing)}px" : "#{MID_TOKEN_POS}px",
                    zIndex: num - index,
                  },
                }
                h(:object, props)
              end

              h(:div, { style: cell_style(@box_style_2d, price) }, [
                h(:div, { style: { fontSize: '80%' } }, price.price),
                h(:div, tokens),
              ])
            else
              h(:div, { style: @space_style_2d }, '')
            end
          end

          h(:div, { style: { width: 'max-content' } }, row)
        end
      end

      def render
        # For locations in the grid with no cells
        @space_style_2d = {
          position: 'relative',
          display: 'inline-block',
          padding: "#{PAD}px",
          width: "#{WIDTH_TOTAL - 2 * PAD - 2 * BORDER}px",
          height: "#{HEIGHT_TOTAL - 2 * PAD - 2 * BORDER}px",
          border: "solid #{BORDER}px rgba(0,0,0,0)",
          margin: '0',
          verticalAlign: 'top',
        }

        # For cells with prices
        @box_style_2d = @space_style_2d.merge(
          border: "solid #{BORDER}px rgba(0,0,0,0.2)",
          color: color_for(:font2),
        )

        grid = @game.stock_market.one_d? ? grid_1d : grid_2d

        children = [h(Bank, game: @game)]
        children.concat(grid)

        if @explain_colors
          type_text = [
            [:par, 'Par value'],
            [:no_cert_limit, 'Corporation shares do not count towards cert limit'],
            [:unlimited, 'Corporation shares can be held above 60%'],
            [:multiple_buy, 'Can buy more than one share in the corporation per turn'],
            [:close, 'Corporation closes'],
            [:endgame, 'End game trigger'],
            [:liquidation, 'Liquidation'],
            [:acquisition, 'Acquisition'],
          ]

          types_in_market = @game.stock_market.market.flatten.compact.map { |p| [p.type, p.color] }.to_h

          type_text.each do |type, text|
            next unless types_in_market.include?(type)

            color = types_in_market[type]

            style = @box_style_2d.merge(backgroundColor: COLOR_MAP[color])
            style[:borderColor] = color_for(:font) if color == :black

            line_props = {
              style: {
                display: 'grid',
                grid: '1fr / auto 1fr',
                gap: '0.5rem',
                alignItems: 'center',
                marginTop: '1rem',
              },
            }

            children << h(:div, line_props, [
              h(:div, { style: style }, []),
              h(:div, text),
            ])
          end
        end

        props = {
          style: {
            width: '100%',
            overflow: 'auto',
          },
        }

        h(:div, props, children)
      end
    end
  end
end
