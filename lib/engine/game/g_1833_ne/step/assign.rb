# frozen_string_literal: true

require_relative '../../../step/assign'

module Engine
  module Game
    module G1833NE
      module Step
        class Assign < Engine::Step::Assign
          def actions(entity)
            return [] if luxury_ferry_service?(entity) && @game.luxury_ferry_hexes(entity).empty?

            super
          end

          def available_hex(entity, hex)
            super if assignable_hex?(entity, hex)
          end

          def process_assign(action)
            company = action.entity
            unless assignable_hex?(company, action.target)
              raise GameError, "#{company.name} can only be assigned to a ferry owned by #{company.owner.name}"
            end

            super
          end

          private

          def luxury_ferry_service?(entity)
            entity == @game.luxury_ferry_service
          end

          def assignable_hex?(entity, hex)
            !luxury_ferry_service?(entity) || @game.luxury_ferry_hexes(entity).include?(hex)
          end
        end
      end
    end
  end
end
