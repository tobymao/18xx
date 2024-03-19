# frozen_string_literal: true

require_relative '../../../step/assign'

module Engine
  module Game
    module G18India
      module Step
        class Assign < Engine::Step::Assign
          # Allow company 'P6' to assign to any hex that isn't a town or city
          def available_hex(entity, hex)
            return unless entity.company?
            return unless entity.id == 'P6'
            return if hex.assigned?(entity.id)

            hex.tile.city_towns.empty?
          end

          # Perform addional steps after using P6
          def process_assign(action)
            super
            return unless action.entity.id == 'P6'

            @game.claim_concession(['JEWELRY'], current_entity)
            action.target.location_name = 'JEWELRY'
            action.target.tile.location_name = 'JEWELRY'
          end
        end
      end
    end
  end
end
