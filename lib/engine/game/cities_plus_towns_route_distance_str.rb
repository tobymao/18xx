# frozen_string_literal: true

#
# This module replaces the default route string of "total distance as an integer" with
# one of the format M+N where N is the number of towns and M is everything else
#
module CitiesPlusTownsRouteDistanceStr
  def route_distance_str(route)
    towns = route.visited_stops.count(&:town?)
    cities = route_distance(route) - towns
    towns.positive? ? "#{cities}+#{towns}" : cities.to_s
  end
end
