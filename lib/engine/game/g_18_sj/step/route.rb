# frozen_string_literal: true

require_relative '../../../game_error'
require_relative '../../../step/route'

module Engine
  module Game
    module G18SJ
      module Step
        class Route < Engine::Step::Route
          def chart(_entity)
            [
              %w[Name Bonus],
              ['Lapplandspilen (N-S)', @game.format_currency(100)],
              ['Öst-Väst (Ö-V)', @game.format_currency(120)],
              ['Malmfälten 1 (M-m)', @game.format_currency(50)],
              ['Malmfälten 2 (M-m-m)', @game.format_currency(100)],
              ['Bergslagen 1 (B-b)', @game.format_currency(50)],
              ['Bergslagen 2 (B-b-b)', @game.format_currency(100)],
            ]
          end

          def process_run_routes(action)
            entity = action.entity
            routes = action.routes
            super

            return unless entity == @game.gkb.owner

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
