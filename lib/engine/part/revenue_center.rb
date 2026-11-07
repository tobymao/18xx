# frozen_string_literal: true

require_relative 'node'

module Engine
  module Part
    class RevenueCenter < Node
      attr_accessor :groups, :revenue
      attr_reader :hide, :revenue_to_render, :visit_cost, :route, :loc, :rows, :phase_styles

      PHASES = %i[yellow green brown gray diesel].freeze

      def initialize(revenue, **opts)
        @revenue = parse_revenue(revenue, opts[:format])
        @groups = (opts[:groups] || '').split('|')
        @hide = opts[:hide]
        @visit_cost = (opts[:visit_cost] || 1).to_i
        @loc = opts[:loc]
        @rows = (opts[:rows] || 1).to_i
        @route = (opts[:route] || :mandatory).to_sym
      end

      # number, or something like "yellow_30|green_40|brown_50|gray_70|diesel_90"
      # also possible to use something like  "I/II_30+yellow+green|III_40+brown|V_50+gray"
      def parse_revenue(revenue, format = nil)
        @phase_styles = nil
        @revenue =
          if revenue.include?('|')
            rev = {}
            render = {}
            styles = []
            revenue.split('|').each do |entry|
              keys, _, value_and_colors = entry.rpartition('_')  # split on the LAST underscore
              value, *colors = value_and_colors.split('+')
              value = value.to_i
              colors = colors.map { |c| c.start_with?('#') ? c : c.to_sym }
              phases = keys.split('/')
              phases.each { |p| rev[p.to_sym] = value }
              render[phases.first.to_sym] = format ? format % value : value
              styles << { phase: phases.first.to_sym, label: keys, colors: colors } unless colors.empty?
            end
            @revenue_to_render = render
            @phase_styles = styles.empty? ? nil : styles
            rev
          else
            @revenue_to_render =
              if format
                format % revenue.to_i
              else
                revenue.to_i
              end
            self.class::PHASES.to_h { |phase| [phase, revenue.to_i] }
          end
        tile&.revenue_changed
        @revenue
      end

      def max_revenue
        @revenue.values.max
      end

      def route_revenue(phase, train)
        revenue_multiplier(train) * route_base_revenue(phase, train)
      end

      def route_base_revenue(phase, train)
        return @revenue[:diesel] if train.name.upcase == 'D' && @revenue[:diesel]

        by_name = @revenue[phase.name.to_sym]
        return by_name if by_name

        phase.tiles.reverse_each { |color| return @revenue[color] if @revenue[color] }
        0
      end

      def revenue_multiplier(train)
        distance = train.distance
        base_multiplier = train.multiplier || 1

        return base_multiplier if distance.is_a?(Numeric)

        row = distance.index do |h|
          h['nodes'].include?(type)
        end
        return base_multiplier unless row

        distance[row].fetch('multiplier', base_multiplier)
      end

      def uniq_revenues
        @uniq_revenues ||= revenue.values.uniq
      end
    end
  end
end
