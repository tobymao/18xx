# frozen_string_literal: true

require_relative '../stock'

module Engine
  module Round
    module G18CO
      class PresidentsChoice < Stock
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
          return if action.type == :message

          if action.type == :pass
            @entities.reject! { |e| e == action.entity }
            return finish_round if finished?

            passed_next_entity_index!
          else
            next_entity_index!
          end

          start_entity
        end

        def passed_next_entity_index!
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
          @game.finished || @entities.empty?
        end

        private

        def finish_round
          @game.presidents_choice = :done
        end
      end
    end
  end
end
