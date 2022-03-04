# frozen_string_literal: true

require_relative '../../../step/special_token'

module Engine
  module Game
    module G18USA
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          def process_place_token(action)
            super

            entity = action.entity
            @game.log << "#{entity.name} closes"
            entity.close!
          end

          def available_hex(entity, hex)
            return s9_available_hex(entity, hex) if entity.id == 'S9'
            return false unless entity.id == 'P20'
            return false if @game.class::COMPANY_TOWN_TILES.include?(hex.tile.name)

            corporation = entity.owner
            hex.tile.cities.any? { |c| c.available_slots.zero? && !c.tokened_by?(corporation) } &&
              @game.graph.connected_hexes(corporation)[hex]
          end

          def s9_available_hex(entity, hex)
            !hex.tile.cities.empty? &&
              !hex.tile.cities.first.tokened_by?(entity.owner) &&
              @game.graph.reachable_hexes(entity.owner).include?(hex)
          end

          def ability(entity)
            return unless entity&.company?

            possible_times = [
              '%current_step%',
              'owning_corp_or_turn',
            ]

            @game.abilities(entity, :token, time: possible_times)
          end
        end
      end
    end
  end
end
