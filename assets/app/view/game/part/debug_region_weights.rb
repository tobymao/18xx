# frozen_string_literal: true

require 'lib/hex'
require 'view/game/part/base'
require 'view/game/part/region_coordinates'

module View
  module Game
    module Part
      class DebugRegionWeights < Base
        include RegionCoordinates

        needs :region_use, default: nil

        def render_part
          return [] if @region_use.nil?

          children = []

          REGION_CENTER_COORDINATES[layout].each do |tri, tri_coords|
            text_attrs = {
              'dominant-baseline': 'middle',
              'font-size': 'large',
              'stroke-width': '0.5',
              fill: 'cyan',
              transform: "#{rotation_for_layout} translate(#{tri_coords[:x]} #{tri_coords[:y]})",
            }

            children << h(:text, { attrs: text_attrs }, @region_use[tri].round(1))
          end

          h(:g, children)
        end
      end
    end
  end
end
