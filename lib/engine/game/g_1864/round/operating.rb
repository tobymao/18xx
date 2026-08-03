# frozen_string_literal: true

require_relative '../../g_1867/round/operating'

module Engine
  module Game
    module G1864
      module Round
        class Operating < G1867::Round::Operating
          def skip_entity?(entity)
            return super if entity.type != :national

            # The UP starts operating in the OR after the one in which phase 4
            # began, and does not operate while it has no President.
            !@game.up_operating? || entity.owner.nil?
          end

          def start_operating
            entity = @entities[@entity_index]
            @game.reveal_up_consist!(@game.phase.name) if entity.type == :national
            super
          end
        end
      end
    end
  end
end
