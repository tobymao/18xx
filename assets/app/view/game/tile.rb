# frozen_string_literal: true

require 'lib/settings'
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
      include Lib::Settings

      needs :game, default: nil
      needs :tile
      needs :routes, default: []
      needs :show_coords, default: nil

      # helper method to pass @tile and @region_use to every part
      def render_tile_part(part_class, **kwargs)
        h(part_class, region_use: @region_use, tile: @tile, **kwargs)
      end

      def render_tile_parts_by_loc(part_class, parts: nil, **kwargs)
        return [] if !parts || parts.empty?

        loc_to_parts = Hash.new { |h, k| h[k] = [] }
        parts.each do |part|
          loc_to_parts[part.loc] << part
        end

        loc_to_parts.map do |loc, _parts|
          render_tile_part(part_class, loc: loc, **kwargs)
        end
      end

      # if false, then the revenue is rendered by Part::Cities or Part::Towns
      def should_render_revenue?
        revenue = @tile.revenue_to_render

        # special case: city with multi-revenue - no choice but to draw separate revenue
        return true if revenue.any? { |r| !r.is_a?(Numeric) }

        return false if revenue.empty?

        return false if revenue.first.is_a?(Numeric) && @tile.city_towns.one?

        return false if revenue.uniq.size > 1

        # avoid obscuring track with revenues
        return true if @tile.cities.empty? && @tile.city_towns.size == 2 && @tile.exits.size > 4

        return false if @tile.cities.sum(&:slots) < 3 && @tile.city_towns.size == 2

        true
      end

      def render
        # hash mapping the different regions to a number representing how much
        # they've been used; it gets passed to the different tile parts and is
        # modified before being passed on to the next one
        @region_use = Hash.new(0)

        # array of parts to render
        # - `render_tile_part` is called in the order they impact the region
        #   usage
        # - the order of this array determines the order the parts are added to
        #   the DOM; parts at the end of the array render on top of ealier parts
        children = []

        render_revenue = should_render_revenue?
        if !@tile.paths.empty? || !@tile.stubs.empty? || !@tile.future_paths.empty?
          children << render_tile_part(Part::Track, routes: @routes)
        end
        children << render_tile_part(Part::Cities, show_revenue: !render_revenue) unless @tile.cities.empty?

        children << render_tile_part(Part::Towns, routes: @routes, show_revenue: !render_revenue) unless @tile.towns.empty?

        borders = render_tile_part(Part::Borders) if @tile.borders.any?(&:type)
        # OO tiles have different rules...
        if @tile.location_name && @tile.cities.size > 1 && !@tile.hex.hide_location_name
          rendered_loc_name = render_tile_part(Part::LocationName)
        end
        revenue = render_tile_part(Part::Revenue) if render_revenue
        @tile.labels.each { |l| children << render_tile_part(Part::Label, label: l) }

        render_tile_parts_by_loc(Part::Upgrades, parts: @tile.upgrades).each { |p| children << p }
        children << render_tile_part(Part::Blocker)

        if @tile.location_name && (@tile.cities.size <= 1) && !@tile.hex.hide_location_name
          rendered_loc_name = render_tile_part(Part::LocationName)
        end
        @tile.reservations.each { |r| children << render_tile_part(Part::Reservation, reservation: r) }

        large, normal = @tile.icons.partition(&:large)
        render_tile_parts_by_loc(Part::Icons, parts: normal).each { |i| children << i }
        children << render_tile_part(Part::LargeIcons) unless large.empty?
        children << render_tile_part(Part::FutureLabel) if @tile.future_label

        children << render_tile_part(Part::Assignments) unless @tile.hex&.assignments&.empty?

        # these parts should always be on the top layer
        children << revenue if revenue
        children << borders if borders
        children << render_tile_part(Part::Partitions) unless @tile.partitions.empty?

        # location name and coordinates on top of other "top" layer since they
        # can be hidden
        children << rendered_loc_name if rendered_loc_name && setting_for(:show_location_names, @game)
        children << render_coords if @show_coords

        children.flatten!

        h('g.tile', children)
      end

      def rotation
        @rotation ||=
          if @tile.hex.layout == :pointy
            'rotate(-30) translate(62 40.5)'
          else
            'rotate(0) translate(32 70.02)'
          end
      end

      def render_coords
        props = {
          attrs: {
            'dominant-baseline': 'central',
            fill: 'black',
            transform: rotation,
          },
          style: {
            fontSize: '24px',
          },
        }

        h(:g, [
          h(:text, props, @tile.hex.coordinates),
          ])
      end
    end
  end
end
