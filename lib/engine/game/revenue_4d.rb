# frozen_string_literal: true

#
# This module can be included and then called from
# the revenue_for method in a subclass to the Engine::Game class.
#
# It will double the revenue for all cities and off-board
# hexes in the route.
#
# This is used in any games that uses 4D trains, e.g. 18AL.
#
module Revenue4D
  def adjust_revenue_for_4d_train(route, revenue)
    return revenue unless route.train.name == '4D'

    2 * revenue - route.stops
      .select { |stop| stop.hex.tile.towns.any? }
      .sum { |stop| stop.route_revenue(route.phase, route.train) }
  end
end
