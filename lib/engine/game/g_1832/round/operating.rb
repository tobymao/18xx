# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1832
      module Round
        class Operating < Engine::Round::Operating
          def select_entities
            if @game.mid_or_resume_entities
              entities = @game.mid_or_resume_entities
              @game.mid_or_resume_entities = nil
              return entities
            end

            super
          end

          # The first 6-train interrupts the round after the current entity, instead of advancing to the next.
          def next_entity!
            if @game.final_merger_triggered?
              remaining = @entities[(@entity_index + 1)..].reject(&:closed?)
              operated = @entities[0..@entity_index]
              @game.save_mid_or_state(remaining, operated, round_num)
              @entity_index = @entities.size
              clear_cache!
              return
            end

            super
          end
        end
      end
    end
  end
end
