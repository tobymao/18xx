# frozen_string_literal: true

require 'view/game/part/city'

module View
  module Game
    module Part
      class Cities < Base
        needs :should_render_revenue
        def render
          @tile.cities.map do |city|
            h(City, should_render_revenue: @should_render_revenue, region_use: @region_use, tile: @tile, city: city)
          end
        end
      end
    end
  end
end
