# frozen_string_literal: true

require_relative 'bonus'

module Engine
  module Ability
    class EastWestBonus < Bonus
      def calculate_revenue(route)
        stops = route.stops
        revenue = route.base_revenue

        east = stops.find { |stop| stop.groups.include?('E') }
        west = stops.find { |stop| stop.tile.label&.to_s == 'W' }

        if east && west
          revenue += east.tile.icons.sum { |icon| icon.name.to_i }
          revenue += west.tile.icons.sum { |icon| icon.name.to_i }
        end

        revenue
      end
    end
  end
end
