# frozen_string_literal: true

require_relative '../../../game_error'
require_relative '../../../step/route'

module Engine
  module Game
    module G18SJ
      module Step
        class Route < Engine::Step::Route
          def process_run_routes(action)
            entity = action.entity
            routes = action.routes
            super

            return if !@game.gkb || entity != @game.gkb.owner

            gbd = []
            routes.each { |r| gbd.concat(@game.gkb_bonuses_details(r)) }
            return if gbd.empty?

            max_gbd = gbd.max_by { |item| item[:amount] }
            amount = @game.format_currency(max_gbd[:amount])
            hex = max_gbd[:hex]
            @log << "Removes the highest used Göta kanal token, which was #{amount} in #{hex.name}"
            hex.remove_assignment!(max_gbd[:key])
          end
        end
      end
    end
  end
end
