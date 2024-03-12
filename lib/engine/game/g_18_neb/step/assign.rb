# frozen_string_literal: true

require_relative '../../../step/assign'

module Engine
  module Game
    module G18Neb
      module Step
        class Assign < Engine::Step::Assign
          def process_assign(action)
            company = action.entity
            target = action.target

            unless (ability = @game.abilities(company, :assign_hexes))
              raise GameError,
                    "Could not assign #{company.name} to #{target.name}; :assign_hexes ability not found"
            end

            @log << "#{company.owner.name} (#{company.name}) places open cattle token on #{target.name}"
            target.assign!(@game.class::CATTLE_OPEN_ICON)
            company.owner.assign!(@game.class::CATTLE_OPEN_ICON)
            ability.use!
            @game.cattle_token_assigned!(target)
          end
        end
      end
    end
  end
end
