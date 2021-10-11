# frozen_string_literal: true

require_relative '../../../step/assign'

module Engine
  module Game
    module G18USA
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
            when 'P2', 'P22', 'P21'
              id = 'bridge'
              raise GameError, "Bridge already on #{target.name}" if target.assigned?(id)
              raise GameError, 'Cannot lay bridge on metro New Orleans' if target.id == 'I19' && @game.metro_new_orleans
              raise GameError, 'Cannot lay bridge on plain track' if !@game.bridge_city_hex?(target.id) &&
                  !target.name.include?('CTown')

              target.assign!(id)
              ability.use!
              @log << "#{company.name} builds bridge on #{target.name}"
            end
          end

          def available_hex(entity, hex)
            return super unless %w[P2 P22 P21].include?(entity&.id)

            valid = super

            valid &&= !(hex.id == 'I19' && @game.metro_new_orleans)
            valid &&= !(!@game.bridge_city_hex?(hex.id) && !hex.name.include?('CTown'))
            valid && @game.graph.reachable_hexes(entity.owner)[hex]
          end
        end
      end
    end
  end
end
