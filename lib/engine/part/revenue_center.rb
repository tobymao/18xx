# frozen_string_literal: true

module Engine
  module Part
    module RevenueCenter
      attr_reader :revenue

      # number, or list of numbers separated by "/", or something like
      # "yellow_30|green_40|brown_50|gray_70|diesl_90"
      def parse_revenue(revenue)
        @revenue =
          if revenue.is_a?(String)
            if revenue.include?('/')
              revenue.split('/').map(&:to_i)
            elsif revenue.include?('|')
              revenue.split('|').map { |s| s.split('_') }.map { |c, r| [c.to_sym, r.to_i] }.to_h
            else
              revenue.to_i
            end
          else
            revenue
          end
      end

      def route_revenue(game: nil, train: nil)
        return @revenue if game.nil? && train.nil?

        # TODO: determine which revenue to return based on the train running the
        # route and the phase of the game
        #
        # e.g., for 1889, something like...
        #
        # phase =
        #   if train.name.upcase == 'DIESEL'
        #     :diesel
        #   elsif game.phase == :green
        #     :yellow
        #   else
        #     game.phase
        #   end
        # return @revenue[phase]

        @revenue
      end
    end
  end
end
