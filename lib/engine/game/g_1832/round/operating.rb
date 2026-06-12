# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1832
      module Round
        class Operating < Engine::Round::Operating
          def select_entities
            # Used when resuming a mid-OR after the 6-train merger round.
            if @game.mid_or_resume_entities
              entities = @game.mid_or_resume_entities
              @game.mid_or_resume_entities = nil
              return entities
            end

            super
          end

          def next_entity!
            # When the first 6-train triggers a mid-OR merger, interrupt after this
            # entity's turn instead of advancing to the next entity.
            if @game.final_merger_triggered?
              remaining = @entities[(@entity_index + 1)..].reject(&:closed?)
              operated = @entities[0..@entity_index]
              @game.save_mid_or_state(remaining, operated, round_num)
              @entity_index = @entities.size  # advance past end → round.finished? → next_round!
              return
            end

            super
          end
        end
      end
    end
  end
end
