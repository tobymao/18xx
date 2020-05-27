# frozen_string_literal: true

module Engine
  module Part
    module RevenueCenter
      attr_reader :revenue

      PHASES = %i[yellow green brown gray diesel].freeze

      # number, or something like "yellow_30|green_40|brown_50|gray_70|diesel_90"
      def parse_revenue(revenue)
        @revenue =
          if revenue.include?('|')
            revenue.split('|').map { |s| s.split('_') }.map { |c, r| [c.to_sym, r.to_i] }.to_h
          else
            self.class::PHASES.map { |phase| [phase, revenue.to_i] }.to_h
          end
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
