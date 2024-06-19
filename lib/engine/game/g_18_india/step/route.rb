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

            routes.each do |route|
              @game.commodity_bonus(route)
              @round.commodities_used.each do |commodity|
                @log << "#{entity.name} delivered #{commodity}"
                @game.claim_concession(entity, commodity) unless ability.description.include?(commodity)
              end
              @round.commodities_used = [] # clear for next route
            end
          end

          def round_state
            super.merge(
              {
                commodities_used: [],
              }
            )
          end

          def help
            return [] if @game.gauge_change_markers.empty?

            [
              'Note: You do not need to click on Gauge Change Markers.',
              'They are included if the route passes though it',
              'They count as a zero revenue city location.',
            ]
          end
        end
      end
    end
  end
end
