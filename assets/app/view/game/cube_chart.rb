# frozen_string_literal: true

# attrs frozen_string_literal: true

require 'view/game/actionable'
require 'lib/settings'

module View
  module Game
    class CubeChart < Snabberb::Component
      include Actionable
      include Lib::Settings

      PAD = 4                                     # between box contents and border
      BORDER = 1
      WIDTH_TOTAL = 50                            # of entire box, including border
      HEIGHT_TOTAL = 50

      def render
        @cube_chart = @game.cube_chart

        @box_style = {
          position: 'relative',
          display: 'inline-block',
          padding: "#{PAD}px",
          width: "#{WIDTH_TOTAL - (2 * PAD) - (2 * BORDER)}px",
          height: "#{HEIGHT_TOTAL - (2 * PAD) - (2 * BORDER)}px",
          border: "solid #{BORDER}px rgba(0,0,0,0.2)",
          margin: '0',
          verticalAlign: 'top',
          backgroundColor: '#DCDCDC',
          color: color_for(:font2),
        }

        @box_style_row_label = @box_style.merge(
          lineHeight: "#{HEIGHT_TOTAL - (2 * PAD) - (2 * BORDER)}px",
          textAlign: 'center',
          fontSize: '130%',
          backgroundColor: '#ACACAC',
        )

        grid_props = {
          style: {
            overflow: 'auto',
          },
        }

        h(:div, grid_props, chart)
      end

      def chart
        [h(:div, @cube_chart.header), h(:div, grid), h(:div, @cube_chart.footer)]
      end

      def grid
        @cube_chart.layout.map.with_index do |r, index|
          row_label = render_row_label_box(@cube_chart.row_labels[index])
          row = r.map do |cell|
            render_box(cell)
          end
          row.unshift(row_label)
          h(:div, { style: { width: 'max-content' } }, row)
        end
      end

      def render_row_label(label)
        props = {
          style: {
            'font-size': '120%',
            'text-align': 'center',
          },
        }
        h(:div, props, label)
      end

      def render_row_label_box(label)
        contents = []
        contents << render_row_label(label)
        h(:div, { style: @box_style_row_label }, label)
      end

      def render_label(label)
        props = {
          style: {
            'font-size': '80%',
            'text-align': 'center',
          },
        }
        h(:div, props, label)
      end

      def render_cube
        props = {
          style: {
            display: 'block',
            'margin-left': 'auto',
            'margin-right': 'auto',
            width: '25px',
            height: '25px',
          },
        }

        image_props = {
          attrs: {
            src: '../icons/red_cube.svg',
            title: 'cube',
          },
          style: {
            width: '80%',
          },
        }

        h(:div, props, [h(:img, image_props)])
      end

      def render_box(cell)
        contents = []
        contents << render_label(cell['label'])
        contents << render_cube if cell['cube']
        h(:div, { style: @box_style }, contents)
      end
    end
  end
end
