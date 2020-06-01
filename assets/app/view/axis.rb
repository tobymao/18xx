# frozen_string_literal: true

require 'view/hex'

module View
  class Axis < Snabberb::Component
    needs :cols # 1-N, representing A,B,C...
    needs :rows # 1-N
    needs :layout

    # labels will work with any non-negative gap passed in, but automatic
    # resizing/positioning based on font size is not yet working
    needs :font_size, default: 25
    needs :text_length, default: 25
    needs :gap

    def render
      attrs = {
        id: 'map-axis',
        'stroke-width': 1,
        stroke: 'black',
        fill: 'black',
        'text-anchor': 'middle',
        'dominant-baseline': 'baseline',
        'font-size': "#{@font_size}px",
      }

      h(:g, { attrs: attrs }, [
          *col_labels,
          *row_labels,
        ])
    end

    private

    def hex_size
      View::Hex::LAYOUT[@layout]
    end

    def col_labels
      hex_x, hex_y = hex_size

      labels = @cols.map do |c|
        x = (hex_x / 2) + (hex_x * (c.to_i - 1))
        label = ('A'..'Z').to_a[c - 1]
        h(:text, { attrs: { x: x, y: @font_size } }, label)
      end

      t_x = 50 + @gap
      t_y = (hex_y * (@rows.size.to_i + 1)) + (2 * @gap)

      [
        h(:g, { attrs: { transform: "translate(#{t_x} 0)" } }, labels),
        h(:g, { attrs: { 'dominant-baseline': 'hanging', transform: "translate(#{t_x} #{t_y})" } }, labels),
      ]
    end

    def row_labels
      hex_x, hex_y = hex_size

      labels = @rows.map do |row|
        y = (hex_y * row.to_i)
        h(:text, { attrs: { x: @font_size, y: y } }, row)
      end

      t_x = (hex_x * (@cols.size.to_i + 1)) + (2 * @gap) - 100
      t_y = 29 + @gap

      [
        h(:g,
          { attrs: { 'dominant-baseline': 'middle',
                     textLength: @text_length,
                     transform: "translate(0 #{t_y})",
                     'text-anchor': 'end' } },
          labels),
        h(:g,
          { attrs: { 'dominant-baseline': 'middle',
                     textLength: @text_length,
                     transform: "translate(#{t_x} #{t_y})",
                     'text-anchor': 'start' } },
          labels),
      ]
    end
  end
end
