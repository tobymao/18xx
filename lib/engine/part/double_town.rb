# frozen_string_literal: true

require_relative 'town'

module Engine
  module Part
    class DoubleTown < Town
      DEFAULT_REVENUE_LOCS = [1.5, 4.5].freeze

      attr_reader :towns, :axis, :revenue_locs

      def initialize(revenue, axis: nil, revenue_loc: nil, **town_opts)
        super(revenue, loc: 'center', style: 'hidden', **town_opts)
        @towns = Array.new(2) { Town.new(revenue, loc: 'center', **town_opts) }
        @axis = axis&.to_f || 0.0
        @revenue_locs = revenue_loc ? revenue_loc.split('|').map(&:to_f) : DEFAULT_REVENUE_LOCS.dup
      end

      def stops
        @towns
      end

      def tile=(tile)
        super
        @towns.each { |town| town.tile = tile }
      end

      def double_town?
        true
      end

      def overrides_tile_revenue?
        true
      end
    end
  end
end
