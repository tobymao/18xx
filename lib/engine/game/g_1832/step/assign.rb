# frozen_string_literal: true

require_relative '../../../step/assign'
require_relative '../../g_1870/step/assign'

module Engine
  module Game
    module G1832
      module Step
        class Assign < G1870::Step::Assign
          ATLANTA_HEX = 'F10'
          PENDING_CITY = -1

          # Atlanta has been clicked but a city not yet chosen
          def pending_city_selection?(entity, hex)
            entity == @game.port_company &&
              hex.id == ATLANTA_HEX &&
              hex.assigned?(entity.id) &&
              hex.assignments[entity.id] == PENDING_CITY
          end

          # Atlanta is eligible for assignment and hasn't been clicked yet
          def needs_city_selection?(entity, hex)
            entity == @game.port_company &&
              hex.id == ATLANTA_HEX &&
              hex.tile.cities.size > 1 &&
              !hex.assigned?(entity.id)
          end

          # City slots in Atlanta become clickable once it's been selected (pending)
          def available_city(entity, _city, hex)
            pending_city_selection?(entity, hex)
          end

          def process_assign(action)
            entity = action.entity
            target = action.target

            return super unless target.is_a?(Engine::Hex) &&
                                entity == @game.port_company &&
                                target.id == ATLANTA_HEX &&
                                target.tile.cities.size > 1

            unless (ability = @game.abilities(entity, :assign_hexes))
              raise GameError, "Could not assign #{entity.name} to #{target.name}; :assign_hexes ability not found"
            end

            if action.city.nil?
              # First click: mark Atlanta as pending and log
              if pending_city_selection?(entity, target)
                raise GameError, "#{entity.name} is already awaiting city selection at #{target.location_name}"
              end

              assignable_hexes = ability.hexes.map { |h| @game.hex_by_id(h) }.compact
              Engine::Assignable.remove_from_all!(assignable_hexes, entity.id) do |unassigned|
                @log << "#{entity.name} is unassigned from #{unassigned.name}"
              end
              target.assign!(entity.id, PENDING_CITY)
              @log << "#{target.location_name} selected - must choose which city to assign the #{entity.name} to"
            else
              # City chosen: complete the assignment
              unless pending_city_selection?(entity, target)
                raise GameError, "#{target.location_name} must be selected before choosing a city"
              end

              target.assign!(entity.id, action.city)
              ability.use!
              @log << "#{entity.name} is assigned to #{target.location_name} (city #{action.city + 1})"

              return if !ability.count&.zero? || !ability.closed_when_used_up

              @game.company_closing_after_using_ability(entity)
              entity.close!
            end
          end
        end
      end
    end
  end
end
