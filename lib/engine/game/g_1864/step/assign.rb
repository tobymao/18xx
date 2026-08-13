# frozen_string_literal: true

require_relative '../../../step/assign'

module Engine
  module Game
    module G1864
      module Step
        class Assign < Engine::Step::Assign
          def actions(entity)
            return [] unless local_contract?(entity)
            return [] if @game.local_contract_placed?(entity)

            ACTIONS
          end

          def process_assign(action)
            company = action.entity
            raise GameError, "#{company.name} cannot be assigned" unless local_contract?(company)

            hex = action.target
            raise GameError, "#{company.name} can only be assigned to one of its own stations" \
              unless local_contract_hexes(company).include?(hex)

            @game.place_local_contract!(company, hex)
          end

          def available_hex(entity, hex)
            return unless local_contract?(entity)

            local_contract_hexes(entity).include?(hex)
          end

          def blocks?
            false
          end

          private

          def local_contract?(entity)
            entity.company? && entity.name == Entities::LOCAL_CONTRACT && !entity.closed?
          end

          def local_contract_hexes(company)
            @game.local_contract_hexes(company)
          end
        end
      end
    end
  end
end
