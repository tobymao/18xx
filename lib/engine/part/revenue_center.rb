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

      def route_revenue(phase, train)
        revenue_type =
          if train.name.upcase == 'DIESEL'
            :diesal
          elsif phase == :green
            :yellow
          else
            phase
          end
        @revenue[revenue_type]
      end
    end
  end
end
