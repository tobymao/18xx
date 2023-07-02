# frozen_string_literal: true

require 'view/game/part/city'

module View
  module Game
    module Part
      class Cities < Base
        needs :show_revenue
        needs :selected_token, default: nil, store: true
        def render
          @tile.cities.map do |city|
            h(City, show_revenue: @show_revenue, region_use: @region_use, tile: @tile, city: city,
                    selected_token: @selected_token)
          end
        end
      end
    end
  end
end
