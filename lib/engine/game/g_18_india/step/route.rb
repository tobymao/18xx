# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G18India
      module Step
        class Route < Engine::Step::Route
          # modified to claim commodities when routes are run
          def process_run_routes(action)
            super
            entity = action.entity
            routes = action.routes
            ability = entity.all_abilities.find { |a| a.type == :commodities }

            routes.each { |route| @game.deliver_commodities(entity, route, ability) }
          end

          def help
            help_str = []
            help_str << 'Route Bonus Key:'
            help_str << '?+ = Variable city Bonus'
            help_str << 'R+ = Route Connection Bonus'
            help_str << 'C+ = Commodity Delivery Bonus'
            return help_str if @game.gauge_change_markers.empty?

            help_str << 'Note: You do not need to click on Gauge Change Markers.'
            help_str << 'They are included if the route passes though it.'
            help_str << 'They count as a zero revenue city location.'
            help_str
          end
        end
      end
    end
  end
end
