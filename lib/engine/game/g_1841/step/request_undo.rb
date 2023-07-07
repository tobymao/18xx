# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1841
      module Step
        class RequestUndo < Engine::Step::Base
          def actions(entity)
            return [] if entity != current_entity

            ['request_undo']
          end

          def round_state
            super.merge(
              {
                pending_undo_requests: [],
              }
            )
          end

          def active?
            pending_entity
          end

          def current_entity
            pending_entity
          end

          def pending_entity
            pending_undo[:entity]
          end

          def pending_message
            pending_undo[:message]
          end

          def pending_undo
            @round.pending_undo_requests&.first || {}
          end

          def description
            'Undo to point prior to merger'
          end

          def undo_message
            pending_message
          end
        end
      end
    end
  end
end
