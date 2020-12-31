# frozen_string_literal: true

require_relative '../assign'

module Engine
  module Step
    module G1856
      class Assign < Assign
        def process_assign(action)
          company = action.entity
          target = action.target

          unless (ability = @game.abilities(company, :assign_hexes))
            raise GameError, "Could not assign #{company.name} to #{target.name}; :assign_hexes ability not found"
          end

          case company.id
          when 'GLSC'
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
