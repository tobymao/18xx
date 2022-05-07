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

        children = []

        render_revenue = should_render_revenue?
        children << render_tile_part(Part::Track, routes: @routes) if !@tile.paths.empty? || !@tile.stubs.empty?
        children << render_tile_part(Part::Cities, show_revenue: !render_revenue) unless @tile.cities.empty?

        children << render_tile_part(Part::Towns, routes: @routes, show_revenue: !render_revenue) unless @tile.towns.empty?

        borders = render_tile_part(Part::Borders) if @tile.borders.any?(&:type)
        # OO tiles have different rules...
        rendered_loc_name = render_tile_part(Part::LocationName) if @tile.location_name && @tile.cities.size > 1
        children << render_tile_part(Part::Revenue) if render_revenue
        @tile.labels.each { |x| children << render_tile_part(Part::Label, label: x) }

        children << render_tile_part(Part::Upgrades) unless @tile.upgrades.empty?
        children << render_tile_part(Part::Blocker)
        rendered_loc_name = render_tile_part(Part::LocationName) if @tile.location_name && (@tile.cities.size <= 1)
        @tile.reservations.each { |x| children << render_tile_part(Part::Reservation, reservation: x) }
        large, normal = @tile.icons.partition(&:large)
        children << render_tile_part(Part::Icons) unless normal.empty?
        children << render_tile_part(Part::LargeIcons) unless large.empty?
        children << render_tile_part(Part::FutureLabel) if @tile.future_label

        children << render_tile_part(Part::Assignments) unless @tile.hex&.assignments&.empty?
        # borders should always be the top layer
        children << borders if borders
        children << render_tile_part(Part::Partitions) unless @tile.partitions.empty?

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
