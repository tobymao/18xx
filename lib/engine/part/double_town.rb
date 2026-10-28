# frozen_string_literal: true

require_relative 'base'
require_relative 'town'

module Engine
  module Part
    class DoubleTown < Base
      DEFAULT_REVENUE_LOCS = [1.5, 4.5].freeze

      class Town < Part::Town
        def walk(skip_paths: nil, visited_paths: {}, **opts, &block)
          arrived_by = visited_paths.keys.last
          if arrived_by && !arrived_by.edges.empty?
            exit_paths = paths.reject { |path| path.edges.empty? }.to_h { |path| [path, true] }
            skip_paths = (skip_paths || {}).merge(exit_paths)
          end
          super(skip_paths: skip_paths, visited_paths: visited_paths, **opts, &block)
        end
      end

      attr_reader :towns, :axis, :revenue_locs

      def initialize(revenue, axis: nil, revenue_loc: nil, **town_opts)
        @towns = Array.new(2) { Town.new(revenue, loc: 'center', **town_opts, style: 'hidden') }
        @axis = axis&.to_f || 0.0
        @revenue_locs = revenue_loc ? revenue_loc.split('|').map(&:to_f) : DEFAULT_REVENUE_LOCS.dup
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
