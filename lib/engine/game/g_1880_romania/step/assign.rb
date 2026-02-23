# frozen_string_literal: true

require_relative '../../g_1880/step/assign'

module Engine
  module Game
    module G1880Romania
      module Step
        class Assign < G1880::Step::Assign
          def process_assign(action)
            company = action.entity
            target = action.target

            return super unless company == @game.danube_port

            ability = @game.abilities(company, :assign_hexes)
            ability.use!

            target.assign!(company.id)
            @log << "#{company.name} builds port on #{target.name}"
          end
        end
      end
    end
  end
end
