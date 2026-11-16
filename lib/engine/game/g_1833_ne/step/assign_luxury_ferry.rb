# frozen_string_literal: true

require_relative '../../../step/assign'

module Engine
  module Game
    module G1833NE
      module Step
        class AssignLuxuryFerry < Engine::Step::Assign
          ACTIONS_WITH_PASS = %w[assign pass].freeze

          def company
            @game.luxury_ferry_service
          end

          def assigned_to_ferry?
            @game.ferry_hexes.any? { |hex| hex.assigned?(company.id) }
          end

          def blockable?
            return false unless company&.owner&.corporation?

            !assigned_to_ferry?
          end

          def active_entities
            blockable? ? [company] : []
          end

          def active?
            blockable?
          end

          def blocks?
            blockable?
          end

          def actions(entity)
            return ACTIONS_WITH_PASS if entity == company && blockable?

            []
          end

          def available_hex(entity, hex)
            return unless @game.luxury_ferry_assignable?(entity, hex)

            super
          end

          def description
            'Assign Luxury Ferry Service'
          end

          def pass_description
            'Skip Assign'
          end

          def process_pass(action)
            @log << "#{action.entity.owner.name} skips assigning #{company.name}"
            pass!
          end
        end
      end
    end
  end
end
