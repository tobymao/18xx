# frozen_string_literal: true

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

    # helper method to pass @tile and @region_use to every part
    def render_tile_part(part_class, **kwargs)
      h(part_class, region_use: @region_use, tile: @tile, **kwargs)
    end

    def should_render_blocker?
      blocker = @tile.blockers.first

      # blocking company should exist...
      return false if blocker.nil?

      # ...and be open
      return false if blocker.closed?

      # ...and not have been sold into a corporation yet
      return false if blocker.owned_by_corporation?

      true
    end

    def render
      # hash mapping the different regions to a number representing how much
      # they've been used; it gets passed to the different tile parts and is
      # modified before being passed on to the next one
      @region_use = Hash.new(0)

      children = []

      children << render_tile_part(Part::Track, routes: @routes) if @tile.exits.any?
      children << render_tile_part(Part::Cities) if @tile.cities.any?
      children << render_tile_part(Part::Towns, routes: @routes) if @tile.towns.any?
      children << render_tile_part(Part::Label) if @tile.label
      children << render_tile_part(Part::Revenue) if @tile.stops.any?
      children << render_tile_part(Part::Upgrades) if @tile.upgrades
      children << render_tile_part(Part::LocationName) if @tile.location_name
      children << render_tile_part(Part::Blocker) if should_render_blocker?

      children.flatten!

      attrs = {
        fill: 'none',
        'stroke-width' => 1,
      }
      h(:g, { attrs: attrs }, children)
    end
  end
end
