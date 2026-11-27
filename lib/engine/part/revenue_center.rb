# frozen_string_literal: true

require_relative '../game_error'
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
        @routable = [true, '1', 'true'].include?(opts[:routable])
        @revisitable = opts[:revisitable] || false
      end

      def routable?
        @routable
      end

      def revisitable?
        @revisitable
      end

      # number, or something like "yellow_30|green_40|brown_50|gray_70|diesel_90",
      # or keyed by phase name with optional box colors: "I/II_30+yellow+green|III_40+brown|V_50+gray".
      # Phase-keyed revenue must list every phase of the game; see #route_base_revenue.
      def parse_revenue(revenue, format = nil)
        @phase_styles = nil
        @revenue =
          if revenue.include?('|')
            rev = {}
            render = {}
            styles = []
            revenue.split('|').each do |entry|
              keys, _, value_and_colors = entry.rpartition('_')
              value, *colors = value_and_colors.split('+')
              value = value.to_i
              phases = keys.split('/').map(&:to_sym)
              phases.each { |p| rev[p] = value }
              render[phases.first] = format ? format % value : value
              next if colors.empty?

              colors.map! { |c| c.start_with?('#') ? c : c.to_sym }
              styles << { phase: phases.first, label: keys, colors: colors }
            end
            @revenue_to_render = render
            @phase_styles = styles unless styles.empty?
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
        @phase_keyed = @revenue.keys.any? { |k| !self.class::PHASES.include?(k) }
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
        return phase_revenue(phase) if @phase_keyed

        phase.tiles.reverse_each { |color| return @revenue[color] if @revenue[color] }
        0
      end

      # A missing phase is a map definition error, so fail loudly instead of quietly paying 0.
      def phase_revenue(phase)
        @revenue.fetch(phase.name.to_sym) { raise GameError, "#{hex&.id} has no revenue for phase #{phase.name}" }
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
