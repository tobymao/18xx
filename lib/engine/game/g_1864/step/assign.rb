# frozen_string_literal: true

require_relative '../../../step/assign'

module Engine
  module Game
    module G1864
      module Step
        # Local Contract's +$10 marker is a placed choice, not an automatic
        # setup grant, so it needs a genuine player action. It has no
        # `assign_hexes` ability in `Entities::COMPANIES` (its target hex
        # depends on which minor draws the card and where that minor has
        # placed stations by the time it's used - not something fixed at
        # setup), so this overrides the base step's ability lookup entirely
        # rather than relying on one. `ALL_COMPANIES_ASSIGNABLE` (inherited
        # from 1867) is what makes the frontend offer the assign control for
        # any company in the first place; this step supplies the actual
        # server-side gating for Local Contract specifically.
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
            entity.company? && entity.name == 'Local Contract' && !entity.closed?
          end

          def local_contract_hexes(company)
            @game.local_contract_hexes(company)
          end
        end
      end
    end
  end
end
