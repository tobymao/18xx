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
            when 'P6'
              raise GameError, "#{target.name} not an offboard location" if target.tile.color != :red
              if !@game.loading && !connected_to_hex?(company.owner, target)
                raise GameError, "#{company.owner} not connected to #{target.name}"
              end

              hexes = @game.mexico_hexes.include?(target) ? @game.mexico_hexes : [target]
              location_name = hexes.find(&:location_name)&.location_name
              hexes.each { |hex| hex.tile.nodes.first.parse_revenue(@game.p6_offboard_revenue) }
              @log << "#{company.owner.name} (#{company.id}) assigns 30/40/50/80 value token to #{location_name}"
              @log << "#{company.name} closes"
              company.close!
            end
          end

          def available_hex(entity, hex)
            return connected_to_hex?(entity.owner, hex) && hex.tile.color == :red if entity.id == 'P6'
            return super unless %w[P2 P22 P21].include?(entity&.id)

            valid = super

            valid &&= !(hex.id == 'I19' && @game.metro_new_orleans)
            valid &&= !(!@game.bridge_city_hex?(hex.id) && !hex.name.include?('CTown'))
            valid && @game.graph.reachable_hexes(entity.owner)[hex]
          end

          def connected_to_hex?(entity, hex)
            @game.graph.connected_hexes(entity)[hex]
          end
        end
      end
    end
  end
end
