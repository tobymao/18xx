# frozen_string_literal: true

require_relative '../../../round/draft'

module Engine
  module Game
    module G1847AE
      module Round
        class Draft < Engine::Round::Draft
          def initialize(game, steps, **opts)
            super

            @players_reordered_for_next_round = false
          end

          def next_entity_index!
            # First round of draft is perforemd in reverse player order, then it must be reversed back to normal
            if @entity_index == @entities.size - 1 && !@game.draft_first_round_finished
              @entities.reverse!
              @game.draft_first_round_finished = true
            end

            super
          end

          def process_action(action, suppress_log = false)
            type = action.type
            clear_cache!

            before_process(action)

            step = @steps.find do |s|
              next unless s.active?

              process = s.actions(action.entity).include?(type)
              blocking = s.blocking?

              raise GameError, "Blocking step #{s.description} cannot process action #{action.id}" if blocking && !process

              blocking || process
            end

            raise GameError, "No step found for action #{type} at #{action.id}: #{action.to_h}" unless step

            step.acted = true
            step.send("process_#{action.type}", action, suppress_log)

            @at_start = false

            after_process_before_skip(action)
            skip_steps
            clear_cache!
            after_process(action)
          end

          def reset_entity_index!
            @game.next_turn!
            @entity_index = (@entity_index + 1) % @entities.size

            return if @players_reordered_for_next_round

            # Reorder players for the next round of draft
            @game.reorder_players
            @players_reordered_for_next_round = true
          end
        end
      end
    end
  end
end
