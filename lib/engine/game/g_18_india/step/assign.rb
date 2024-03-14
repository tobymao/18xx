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
            return unless hex.tile.city_towns.empty? # hex doesn't have a town or city

            @game.hex_by_id(hex.id).neighbors.keys
          end

          # Perform addional steps after using P6
          def process_assign(action)
            super
            if action.entity.id == 'P6'
              @game.claim_concession(['JEWELRY'], current_entity)
              action.target.location_name = 'JEWELRY'
              action.target.tile.location_name = 'JEWELRY'
            end
          end
        end
      end
    end
  end
end
