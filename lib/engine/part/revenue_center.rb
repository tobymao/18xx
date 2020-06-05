# frozen_string_literal: true

require_relative 'node'

module Engine
  module Part
    class RevenueCenter < Node
      attr_reader :groups, :hide, :revenue, :revenue_to_render

      PHASES = %i[yellow green brown gray diesel].freeze

      def initialize(revenue, groups = nil, hide = false)
        @revenue = parse_revenue(revenue)
        @groups = (groups || '').split('|')
        @hide = hide
      end

      # number, or something like "yellow_30|green_40|brown_50|gray_70|diesel_90"
      def parse_revenue(revenue)
        @revenue =
          if revenue.include?('|')
            rev = revenue.split('|').map { |s| s.split('_') }.map { |c, r| [c.to_sym, r.to_i] }.to_h
            @revenue_to_render = rev
            rev
          else
            @revenue_to_render = revenue.to_i
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
