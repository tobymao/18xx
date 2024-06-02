# frozen_string_literal: true

require 'view/game/hex'
require '../lib/settings'

module View
  module Game
    class Axis < Snabberb::Component
      include Lib::Settings
      needs :cols
      needs :rows
      needs :layout
      needs :axes

      needs :font_size, default: 25
      needs :text_length, default: 25
      needs :gap
      needs :map_x, default: 0
      needs :map_y, default: 0
      needs :start_pos, default: [1, 1]

      X_OFFSET = 100
      LETTERS = ('A'..'Z').to_a + ('AA'..'AZ').to_a

      def render
        attrs = {
          'stroke-width': 1,
          stroke: 'currentColor',
          fill: 'currentColor',
          'text-anchor': 'middle',
          'font-size': "#{@font_size}px",
        }

        rotate_map = setting_for(:rotate_map, @game)
        layout =
          if rotate_map
            @layout == :flat ? :pointy : :flat
          else
            @layout
          end
        h('g#map-axis', { attrs: attrs }, [
          col_labels(rotate_map, layout),
          row_labels(rotate_map, layout),
        ])
      end

      private

      def hex_size(layout)
        Hex::LAYOUT[layout]
      end

      def create_col_labels(rotate_map, layout)
        hex_x, _hex_y = hex_size(layout)
        list = rotate_map ? @rows : @cols
        list.map do |col|
          pos = rotate_map ? list.size - col.to_i + 1 : col.to_i
          x = hex_x * (pos - @start_pos[0])

          axes = rotate_map ? @axes[:y] : @axes[:x]
          label =
            if axes == :letter
              LETTERS[col - 1]
            else
              col
            end
          h(:text, { attrs: { x: x, dy: '1em' } }, label)
        end
      end

      def col_labels(rotate_map, layout)
        _hex_x, hex_y = hex_size(layout)

        t_x = X_OFFSET + @gap

        rows_offset = rotate_map ? @cols.size : @rows.size
        rows_offset += 1 if layout == :flat
        bottom_t_y = (hex_y * rows_offset) + (@font_size * 2) + (@gap * 2)

        bottom_t_y += @font_size * 2 if layout == :pointy
        h(:g,
          { attrs: { transform: "translate(#{t_x + @font_size} 0)" } },
          [
            h(:g, { attrs: { 'dominant-baseline': 'top' } }, create_col_labels(rotate_map, layout)),
            h(:g, {
                attrs: {
                  transform: "translate(0 #{bottom_t_y - @font_size})",
                  'dominant-baseline': 'baseline',
                },
              }, create_col_labels(rotate_map, layout)),
          ])
      end

      def create_row_labels(rotate_map, layout)
        _hex_x, hex_y = hex_size(layout)
        list = rotate_map ? @cols : @rows
        list.map do |row|
          multiplier = row.to_i - @start_pos[1] + 1
          multiplier -= 0.5 if layout == :pointy
          y = hex_y * multiplier

          axes = rotate_map ? @axes[:x] : @axes[:y]
          label =
            if axes == :letter
              LETTERS[row - 1]
            else
              row
            end

          h(:text, { attrs: { y: y } }, label)
        end
      end

      def row_labels(rotate_map, layout)
        hex_x, _hex_y = hex_size(layout)

        t_x = @font_size / 2
        t_y = @map_y + (layout == :flat ? 0 : @font_size / 2)
        cols_offset = rotate_map ? @rows.size.to_i : @cols.size.to_i
        cols_offset = layout == :flat ? (cols_offset + 1) : (cols_offset + 2)
        right_t_x = (hex_x * cols_offset) - X_OFFSET + (2 * @gap) + @font_size

        right_t_x += @font_size if layout == :pointy

        h(:g, {
            attrs: {
              'dominant-baseline': 'hanging',
              transform: "translate(#{t_x} #{t_y})",
              textLength: @font_size,
            },
          },
          [
            h(:g,
              { attrs: { 'text-anchor': 'middle' } },
              create_row_labels(rotate_map, layout)),
            h(:g,
              {
                attrs: {
                  transform: "translate(#{right_t_x} 0)",
                  'text-anchor': 'middle',
                },
              },
              create_row_labels(rotate_map, layout)),
          ])
      end
    end
  end
end
