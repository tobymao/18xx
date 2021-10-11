# frozen_string_literal: true

require_relative '../../g_1867/round/operating'

module Engine
  module Game
    module G1861
      module Round
        class Operating < G1867::Round::Operating
          NATIONAL_START_PHASE = 4
          NATIONAL_END_PHASE = 8
          def skip_entity?(entity)
            return super if entity.type != :national

            @game.phase.name.to_i < NATIONAL_START_PHASE || @game.phase.name.to_i >= NATIONAL_END_PHASE
          end

          def start_operating
            # RSR places home token when starting to operate
            @game.place_rsr_home_token if @entities[@entity_index].type == :national
            super
          end
        end
      end
    end
  end
end
