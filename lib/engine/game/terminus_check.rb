# frozen_string_literal: true

#
# This module can be included and then called from
# the revenue_for method in a subclass to the Engine::Game class.
#
# It will ensure that cities that cannot be passed through are
# only termini stops in the route.
#
# This is used in games that have off-board cities that does not
# allow pass-through.
#
module TerminusCheck
  def ensure_termini_not_passed_through(route, termini)
    route.hexes[1...-1].each do |hex|
      next unless termini.include?(hex.name)

      raise GameError, "#{hex.location_name} must be first or last in route"
    end
  end
end
