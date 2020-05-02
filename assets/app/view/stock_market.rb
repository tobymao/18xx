# frozen_string_literal: true

require 'view/token'

module View
  class StockMarket < Snabberb::Component
    needs :game
    needs :show_bank, default: false

    COLOR_MAP = {
      red: '#ffaaaa',
      brown: '#8b4513',
      orange: '#ffbb55',
      yellow: '#ffff99'
    }.freeze

    def render
      space_style = {
        position: 'relative',
        display: 'inline-block',
        padding: '5px',
        width: '40px',
        height: '40px',
        margin: '0',
        'vertical-align': 'top',
      }

      box_style = space_style.merge(
        width: '38px',
        height: '38px',
        border: 'solid 1px rgba(0,0,0,0.2)',
      )

      grid = @game.stock_market.market.flat_map do |prices|
        rows = prices.map do |price|
          if price
            style = box_style.merge('background-color' => COLOR_MAP[price.color])

            corporations = price.corporations
            num_corps = corporations.size
            spacing = 35 / num_corps

            tokens = corporations.map.with_index do |corporation, index|
              props = {
                attrs: { data: corporation.logo, width: '25px' },
                style: {
                  position: 'absolute',
                  left: "#{index * spacing}px",
                  'z-index' => num_corps - index,
                }
              }
              h(:object, props)
            end

            h(:div, { style: style }, [
              h(:div, { style: { 'font-size': '80%' } }, price.price),
              h(:div, tokens),
            ])
          else
            h(:div, { style: space_style }, '')
          end
        end

        h(:div, { style: { width: 'max-content' } }, rows)
      end

      bank_props = {
        style: {
          'margin-bottom': '1rem'
        }
      }

      children = []

      children << h(:div, bank_props, "Bank Cash: #{@game.format_currency(@game.bank.cash)}") if @show_bank
      children.concat(grid)

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
