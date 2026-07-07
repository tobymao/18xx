# frozen_string_literal: true

require_relative '../../../round/draft'

module Engine
  module Game
    module G1835
      module Round
        # Rename class to ClemensDraft to prevent namespace collision
        class ClemensDraft < Engine::Round::Draft
          def setup
            super
            # Clear player pass flags to prevent the cross-round freeze bug
            @entities.each(&:unpass!)
            @clemens_turn = 0
            @entity_index = current_clemens_index
          end

          def current_entity
            entities[current_clemens_index]
          end

          def current_clemens_index
            num_players = entities.size
            return 0 if num_players.zero?

            if @clemens_turn < num_players
              # Reverse phase: passes from last down to first (CBA...)
              num_players - 1 - @clemens_turn
            elsif @clemens_turn < 2 * num_players
              # Forward snake phase: first player goes twice, climbs back (...ABC...)
              @clemens_turn - num_players
            else
              # Standard clockwise iteration phase for the remainder of the draft
              (@clemens_turn - (2 * num_players)) % num_players
            end
          end

          def next_entity_index!
            @clemens_turn += 1
            @entity_index = current_clemens_index
          end

          def select_entities
            @game.players
          end

          def after_process(_action)
            return if active_step

            next_entity!
          end

          def next_entity!
            next_entity_index!
            if finished?
              @game.draft_finished = all_drafted?
              return
            end

            @steps.each(&:unpass!)
            skip_steps
            next_entity! unless active_step
          end

          def all_drafted?
            @game.companies.all? { |c| c.owner || c.closed? }
          end

          def finished?
            all_drafted? || @entities.all?(&:passed?)
          end
        end
      end
    end
  end
end