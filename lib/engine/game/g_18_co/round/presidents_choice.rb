# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G18CO
      module Round
        class PresidentsChoice < Engine::Round::Stock
          def self.short_name
            'PCR'
          end

          def name
            'President\'s Choice Round'
          end

          def setup
            start_entity
          end

          def select_entities
            @game.players.dup
          end

          def after_process(action)
            return if action.free?

            if action.pass?
              @entities.delete(action.entity)
              return finish_round if finished?

              passed_next_entity_index!
            else
              next_entity_index!
            end

            start_entity
          end

          def passed_next_entity_index!
            @game.next_turn!
            @entity_index = @entity_index % @entities.size
          end

          def skip_to_next_entity!
            @entities.delete_at(@entity_index)
            return finish_round if finished?

            passed_next_entity_index!
            start_entity
          end

          def start_entity
            @steps.each(&:unpass!)
            @steps.each(&:setup)

            skip_steps
            skip_to_next_entity! unless active_step
          end

          def finished?
            @game.finished || @game.presidents_choice == :done || @entities.empty?
          end

          def show_in_history?
            false
          end

          private

          def finish_round
            @game.presidents_choice = :done
          end
        end
      end
    end
  end
end
