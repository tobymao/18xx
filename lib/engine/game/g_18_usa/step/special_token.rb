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
            return unless entity.id == 'P20'

            @game.log << "#{entity.name} closes"
            entity.close!
          end

          def available_hex(entity, hex)
            return false unless entity.id == 'P20'
            return false if @game.class::COMPANY_TOWN_TILES.include?(hex.tile.name)

            corporation = entity.owner
            hex.tile.cities.any? { |c| c.available_slots.zero? && !c.tokened_by?(corporation) } &&
              @game.graph.connected_hexes(corporation)[hex]
          end

          def ability(entity)
            return unless entity&.company?

            @game.abilities(entity, :token, time: '%current_step%')
          end
        end
      end
    end
  end
end
