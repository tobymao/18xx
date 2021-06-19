# frozen_string_literal: true

require_relative 'reassign_trains'

module Engine
  module Game
    module G1840
      module Step
        class InterruptingReassignTrains < ReassignTrains
          def active_entities
            [reassigning_entity]
          end

          def round_state
            {
              corporation_needs_reassign: [],
            }
          end

          def active?
            reassigning_entity
          end

          def current_entity
            reassigning_entity
          end

          def reassigning_entity
            corporation[:entity]
          end

          def corporation
            @round.corporation_needs_reassign&.first || {}
          end

          def pass!
            @round.corporation_needs_reassign.shift
            super
          end
        end
      end
    end
  end
end
