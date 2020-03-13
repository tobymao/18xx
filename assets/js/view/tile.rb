# frozen_string_literal: true

require 'snabberb/component'

require 'lib/tile'
require 'view/part/blocker'
require 'view/part/cities'
require 'view/part/label'
require 'view/part/location_name'
require 'view/part/revenue'
require 'view/part/towns'
require 'view/part/track'
require 'view/part/upgrades'

module View
  class Tile < Snabberb::Component
    needs :tile
    needs :routes, default: [], store: true

    def render_tile_part(part_class, **kwargs)
      h(part_class, region_use: @region_use, tile: @tile, **kwargs)
    end

    def render
      # hash mapping the different regions to a number representing how much
      # they've been used; it gets passed to the different tile parts and is
      # modified before being passed on to the next one
      @region_use = Lib::Tile::REGIONS.map { |r| [r, 0] }.to_h

      # parts are rendered in the order in which they appear in this array
      children =
        [
          render_tile_part(Part::Track, routes: @routes),
          render_tile_part(Part::Cities),
          render_tile_part(Part::Towns), # TODO: towns on paths
          render_tile_part(Part::Label),
          render_tile_part(Part::Revenue),
          render_tile_part(Part::LocationName),
          render_tile_part(Part::Upgrades),
          render_tile_part(Part::Blocker),
        ].flatten.compact

      attrs = {
        fill: 'none',
        'stroke-width' => 1,
      }
      h(:g, { attrs: attrs }, children)
    end
  end
end
