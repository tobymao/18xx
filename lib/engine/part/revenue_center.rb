# frozen_string_literal: true

require_relative 'node'

module Engine
  module Part
    class RevenueCenter < Node
      attr_reader :groups, :hide, :revenue, :revenue_to_render, :visit_cost, :route

      PHASES = %i[yellow green brown gray diesel].freeze

      def initialize(revenue, **opts)
        @revenue = parse_revenue(revenue, opts[:format])
        @groups = (opts[:groups] || '').split('|')
        @hide = opts[:hide]
        @visit_cost = (opts[:visit_cost] || 1).to_i

        @route = (opts[:route] || :mandatory).to_sym
      end

      # number, or something like "yellow_30|green_40|brown_50|gray_70|diesel_90"
      def parse_revenue(revenue, format)
        @revenue =
          if revenue.include?('|')
            rev = revenue.split('|').map { |s| s.split('_') }.map { |c, r| [c.to_sym, r.to_i] }.to_h
            @revenue_to_render = rev
            @revenue_to_render =
              if format
                rev.map { |c, r| [c, format % r] }.to_h
              else
                rev
              end
            rev
          else
            @revenue_to_render =
              if format
                format % revenue.to_i
              else
                revenue.to_i
              end
            self.class::PHASES.map { |phase| [phase, revenue.to_i] }.to_h
          end
        @revenue
      end

      def max_revenue
        @revenue.values.max
      end

      def route_revenue(phase, train)
        return @revenue[:diesel] if train.name.upcase == 'D' && @revenue[:diesel]

        phase.tiles.reverse.each { |color| return @revenue[color] if @revenue[color] }
      end

      def uniq_revenues
        @uniq_revenues ||= revenue.values.uniq
      end
    end
  end
end
