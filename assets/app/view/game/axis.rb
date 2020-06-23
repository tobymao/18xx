# frozen_string_literal: true

require 'view/game/hex'

module View
  module Game
    class Axis < Snabberb::Component
      needs :cols
      needs :rows
      needs :layout
      needs :axes

      needs :font_size, default: 25
      needs :text_length, default: 25
      needs :gap
      needs :map_x, default: 0
      needs :map_y, default: 0

      X_OFFSET = 100
      LETTERS = ('A'..'Z').to_a.freeze

      def render
        attrs = {
          'stroke-width': 1,
          stroke: 'currentColor',
          fill: 'currentColor',
          'text-anchor': 'middle',
          'font-size': "#{@font_size}px",
        }

        h('g#map-axis', { attrs: attrs }, [
          col_labels,
          row_labels,
        ])
      end

      private

      def hex_size
        Hex::LAYOUT[@layout]
      end

      def col_labels
        hex_x, hex_y = hex_size

        labels = @cols.map do |col|
          x = hex_x * (col.to_i - 1)

          label =
            if @axes[:x] == :letter
              LETTERS[col - 1]
            else
              col
            end
          h(:text, { attrs: { x: x, dy: '1em' } }, label)
        end

        t_x = X_OFFSET + @gap

        rows_offset = @layout == :flat ? (@rows.size + 1) : @rows.size
        bottom_t_y = (hex_y * rows_offset) + (@font_size * 2) + (@gap * 2)

        bottom_t_y += @font_size * 2 if @layout == :pointy

        h(:g,
          { attrs: { transform: "translate(#{t_x + @font_size} 0)" } },
          [
            h(:g,
              { attrs: { 'dominant-baseline': 'top' } },
              labels),
            h(:g,
              { attrs: { transform: "translate(0 #{bottom_t_y - @font_size})",
                         'dominant-baseline': 'baseline' } },
              labels),
          ])
      end

      def row_labels
        hex_x, hex_y = hex_size

        labels = @rows.map do |row|
          multiplier = row.to_i
          multiplier -= 0.5 if @layout == :pointy
          y = hex_y * multiplier

          label =
            if @axes[:y] == :letter
              LETTERS[row - 1]
            else
              row
            end

          h(:text, { attrs: { y: y } }, label)
        end

        t_x = @font_size / 2
        t_y = @map_y + (@layout == :flat ? 0 : @font_size / 2)

        cols_offset = @layout == :flat ? (@cols.size.to_i + 1) : (@cols.size.to_i + 2)
        right_t_x = (hex_x * cols_offset) - X_OFFSET + (2 * @gap) + @font_size

        right_t_x += @font_size if @layout == :pointy

        h(:g, { attrs: { 'dominant-baseline': 'hanging',
                         transform: "translate(#{t_x} #{t_y})",
                         textLength: @font_size } },
          [
            h(:g,
              { attrs: { 'text-anchor': 'middle' } },
              labels),
            h(:g,
              { attrs: { transform: "translate(#{right_t_x} 0)",
                         'text-anchor': 'middle' } },
              labels),
          ])
      end
    end
  end
end
