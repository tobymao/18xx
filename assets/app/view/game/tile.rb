# frozen_string_literal: true

require 'view/game/part/blocker'
require 'view/game/part/borders'
require 'view/game/part/cities'
require 'view/game/part/label'
require 'view/game/part/location_name'
require 'view/game/part/revenue'
require 'view/game/part/towns'
require 'view/game/part/track'
require 'view/game/part/upgrades'

module View
  module Game
    class Tile < Snabberb::Component
      needs :tile
      needs :routes, default: [], store: true

      # helper method to pass @tile and @region_use to every part
      def render_tile_part(part_class, **kwargs)
        h(part_class, region_use: @region_use, tile: @tile, **kwargs)
      end

      # if false, then the revenue is rendered by Part::Cities or Part::Towns
      def should_render_revenue?
        revenue = @tile.revenue_to_render

        # special case: city with multi-revenue - no choice but to draw separate revenue
        return true if revenue.any? { |r| !r.is_a?(Numeric) }

        return false if revenue.empty?

        return false if revenue.first.is_a?(Numeric) && @tile.city_towns.one?

        return false if revenue.uniq.size > 1

        return false if @tile.cities.sum(&:slots) < 3 && @tile.city_towns.size == 2

        true
      end

      def render
        # hash mapping the different regions to a number representing how much
        # they've been used; it gets passed to the different tile parts and is
        # modified before being passed on to the next one
        @region_use = Hash.new(0)

        children = []

        render_revenue = should_render_revenue?
        children << render_tile_part(Part::Track, routes: @routes) if @tile.paths.any? || @tile.stubs.any?
        children << render_tile_part(Part::Cities, show_revenue: !render_revenue) if @tile.cities.any?
        children << render_tile_part(Part::Towns, routes: @routes) if @tile.towns.any?

        borders = render_tile_part(Part::Borders) if @tile.borders.any?
        # OO tiles have different rules...
        rendered_loc_name = render_tile_part(Part::LocationName) if @tile.location_name && @tile.cities.size > 1

        children << render_tile_part(Part::Revenue) if render_revenue
        children << render_tile_part(Part::Label) if @tile.label

        children << render_tile_part(Part::Upgrades) if @tile.upgrades.any?
        children << render_tile_part(Part::Blocker)
        rendered_loc_name = render_tile_part(Part::LocationName) if @tile.location_name && (@tile.cities.size <= 1)
        @tile.reservations.each { |x| children << render_tile_part(Part::Reservation, reservation: x) }
        children << render_tile_part(Part::Icons) if @tile.icons.any?

        children << render_tile_part(Part::Assignments) if @tile.hex.assignments.any?
        # borders should always be the top layer
        children << borders if borders

        children << rendered_loc_name if rendered_loc_name

        children.flatten!

        h('g.tile', children)
      end
    end
  end
end
