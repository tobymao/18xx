# frozen_string_literal: true

require '../lib/settings'

module View
  module Game
    class MapLegend < Snabberb::Component
      include Actionable
      include Lib::Settings
      needs :game, store: true

      def render
        table_props, header, *chart = @game.map_legend(
          color_for(:font),
          color_for(:yellow),
          color_for(:green),
          color_for(:brown),
          color_for(:gray),
          action_processor: ->(a) { process_action(a) },
        )

        head = header.map do |cell|
          item = cell[:text] || h(:image, { attrs: { href: cell[:image] } })
          if cell[:props]
            h(:th, cell[:props], item)
          else
            h(:th, item)
          end
        end

        rows = chart.map do |r|
          columns = r.map do |cell|
            item = cell[:text] || [h(:img, { attrs: { src: cell[:image], height: cell[:image_height] } })]
            if cell[:props]
              h(:td, cell[:props], item)
            else
              h(:td, item)
            end
          end
          h(:tr, columns)
        end

        h(:table, table_props, [
          h(:thead, [
            h(:tr, head),
          ]),
          h(:tbody, rows),
        ])
      end
    end
  end
end
