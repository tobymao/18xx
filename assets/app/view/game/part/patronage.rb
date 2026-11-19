# frozen_string_literal: true

require 'lib/settings'
require 'view/game/part/base'

module View
  module Game
    module Part
      class Patronage < Base
        include Lib::Settings

        CELL_WIDTH = 50
        CELL_HEIGHT = 26
        TITLE_HEIGHT = 16

        FLAT_LOCATION = {
          region_weights: { [14, 15, 16, 20, 21, 22] => 1.0, [13, 17, 19, 23] => 0.5 },
          x: 0,
          y: 0,
        }.freeze

        POINTY_LOCATION = {
          region_weights: { [15, 16, 17, 21, 22, 23] => 1.0, [18, 20] => 0.5 },
          x: 0,
          y: 0,
        }.freeze

        def preferred_render_locations
          [layout == :flat ? FLAT_LOCATION : POINTY_LOCATION]
        end

        def load_from_tile
          @payouts = @tile.patronage.to_a
          @per_row = (@payouts.size / 2.0).ceil
          @width = @per_row * CELL_WIDTH
          @left = -@width / 2.0
        end

        def render_part
          rows = (@payouts.size / @per_row.to_f).ceil
          outline = rect(@left, 0, @width, TITLE_HEIGHT + (rows * CELL_HEIGHT), 'none', 'stroke-width': 2)

          h(:g, { attrs: { transform: "#{rotation_for_layout} #{translate}" } }, [*render_title, *render_cells, outline])
        end

        private

        def render_title
          text_attrs = {
            x: 0,
            y: TITLE_HEIGHT / 2.0,
            fill: 'black',
            'text-anchor': 'middle',
            'dominant-baseline': 'central',
            'font-weight': 'bold',
            'font-size': '12px',
            'letter-spacing': '1px',
          }

          [
            rect(@left, 0, @width, TITLE_HEIGHT, 'white'),
            h(:text, { attrs: text_attrs }, 'PATRONAGE'),
          ]
        end

        def render_cells
          @payouts.each_with_index.flat_map do |(color, amount), index|
            x = @left + ((index % @per_row) * CELL_WIDTH)
            y = TITLE_HEIGHT + ((index / @per_row).floor * CELL_HEIGHT)
            fill = color_for(color)
            text_attrs = {
              x: x + (CELL_WIDTH / 2.0),
              y: y + (CELL_HEIGHT / 2.0),
              fill: contrast_on(fill),
              'text-anchor': 'middle',
              'dominant-baseline': 'central',
            }

            [
              rect(x, y, CELL_WIDTH, CELL_HEIGHT, fill),
              h('text.number', { attrs: text_attrs }, amount.to_s),
            ]
          end
        end

        def rect(x, y, width, height, fill, **attrs)
          h(:rect, attrs: { x: x, y: y, width: width, height: height, fill: fill, stroke: 'black', **attrs })
        end
      end
    end
  end
end
