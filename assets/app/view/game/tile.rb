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

      # if false, then the revenue is rendered by Part::Cities or Part::Towns
      def should_render_revenue?
        revenue = @tile.revenue_to_render

        return false if revenue.empty?

        return false if revenue.first.is_a?(Numeric) && (@tile.cities + @tile.towns).one?

        return false if revenue.uniq.size > 1

        return false if revenue.size == 2

        true
      end

      def render
        # hash mapping the different regions to a number representing how much
        # they've been used; it gets passed to the different tile parts and is
        # modified before being passed on to the next one
        @region_use = Hash.new(0)

        children = []

        children << h(Part::Borders, tile: @tile) if @tile.borders.any?
        children << render_tile_part(Part::Track, routes: @routes) if @tile.exits.any?
        children << render_tile_part(Part::Cities) if @tile.cities.any?
        children << render_tile_part(Part::Towns, routes: @routes) if @tile.towns.any?

        # OO tiles have different rules...
        children << render_tile_part(Part::LocationName) if @tile.location_name && @tile.cities.size > 1

        children << render_tile_part(Part::Revenue) if should_render_revenue?

        children << render_tile_part(Part::Label) if @tile.label
        children << render_tile_part(Part::Upgrades) if @tile.upgrades.any?
        children << render_tile_part(Part::Blocker) if should_render_blocker?
        children << render_tile_part(Part::LocationName) if @tile.location_name && (@tile.cities.size <= 1)

        children.flatten!

        h('g.tile', children)
      end
    end
  end
end
