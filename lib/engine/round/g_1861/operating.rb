# frozen_string_literal: true

require_relative '../g_1867/operating'

module Engine
  module Round
    module G1861
      class Operating < G1867::Operating
        NATIONAL_START_PHASE = 4
        NATIONAL_END_PHASE = 8
        def skip_entity?(entity)
          return super if entity.type != :national

          @game.phase.name.to_i < NATIONAL_START_PHASE || @game.phase.name.to_i >= NATIONAL_END_PHASE
        end
      end
    end
  end
end
