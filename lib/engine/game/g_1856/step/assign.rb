# frozen_string_literal: true

require_relative '../../../step/assign'

module Engine
  module Game
    module G1856
      module Step
        class Assign < Engine::Step::Assign
          def process_assign(action)
            company = action.entity
            target = action.target

            unless (ability = @game.abilities(company, :assign_hexes))
              raise GameError,
                    "Could not assign #{company.name} to #{target.name}; :assign_hexes ability not found"
            end
            case company.id
            when @game.port.id
              target.assign!(company.id)
              ability.use!
              @log << "#{company.name} builds port on #{target.name} and closes"
              company.close!
            end
          end
        end
      end
    end
  end
end
