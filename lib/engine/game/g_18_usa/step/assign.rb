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
            owner = company.owner

            unless (ability = @game.abilities(company, :assign_hexes))
              raise GameError,
                    "Could not assign #{company.name} to #{target.name}; :assign_hexes ability not found"
            end

            case company.id
            when 'P2', 'P22', 'P21'
              id = 'bridge'
              raise GameError, "Bridge already on #{target.name}" if target.assigned?(id)
              raise GameError, 'Cannot lay bridge on New Orleans Metropolis' if target.id == 'I19' && @game.metro_new_orleans
              raise GameError, 'Bridge must be placed on a city or rural junction in a river hex' unless bridge_hex?(target)

              target.assign!(id)
              ability.use!
              @log << "#{company.name} builds bridge on #{target.name}"
            when 'P6'
              validate_offboard_assignment(target, owner) unless @game.loading

              hexes = offboard_area_hexes(target)
              location_name = hexes.find(&:location_name)&.location_name
              hexes.each { |hex| hex.tile.nodes.first.parse_revenue(@game.p6_offboard_revenue) }
              @log << "#{owner.name} (#{company.id}) assigns 30/40/50/80 value token to #{location_name}"
              @log << "#{company.name} closes"
              company.close!
            when 'P8'
              validate_offboard_assignment(target, owner) unless @game.loading

              token = Engine::Token.new(owner)
              owner.tokens << token
              hexes = offboard_area_hexes(target)
              assigned_hex = hexes.find(&:location_name)
              assigned_hex.place_token(token)
              @game.p8_hexes = hexes
              @log << "#{owner.name} assigns #{company.name} token to #{assigned_hex.location_name}"

              # Can only be assigned once
              company.remove_ability(ability)
            end
          end

          def validate_offboard_assignment(hex, corporation)
            raise GameError, "#{hex.name} not an offboard location" if hex.tile.color != :red
            raise GameError, "#{corporation.name} not connected to #{hex.name}" if !@game.loading &&
                                                                                   !connected_to_hex?(corporation, hex)
          end

          def bridge_hex?(hex)
            @game.river_hex?(hex) &&
              !(hex.id == 'I19' && @game.metro_new_orleans) &&
              (!hex.tile.cities.empty? || !hex.tile.towns.empty?)
          end

          def offboard_area_hexes(hex)
            @game.mexico_hexes.include?(hex) ? @game.mexico_hexes : [hex]
          end

          def available_hex(entity, hex)
            return connected_to_hex?(entity.owner, hex) && hex.tile.color == :red if %w[P6 P8].include?(entity.id)

            valid = super
            return valid unless %w[P2 P22 P21].include?(entity&.id)

            valid && bridge_hex?(hex) && connected_to_hex?(entity.owner, hex)
          end

          def connected_to_hex?(entity, hex)
            @game.graph.reachable_hexes(entity)[hex]
          end
        end
      end
    end
  end
end
