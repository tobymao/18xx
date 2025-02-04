# frozen_string_literal: true

require_relative '../../../round/choices'

module Engine
  module Game
    module G1837
      module Round
        class Exchange < Engine::Round::Choices
          def name
            'Exchange Round'
          end

          def self.short_name
            'ER'
          end

          def select_entities
            @game.exchange_order
          end

          def setup
            super
            skip_steps
            next_entity! if finished?
          end

          def after_process(_action)
            return if active_step

            next_entity!
          end

          def next_entity!
            return if @entities.empty? || (@entity_index == @entities.size - 1)

            next_entity_index!
            @steps.each(&:unpass!)
            @steps.each(&:setup)

            skip_steps
            next_entity! if finished?
          end

          def force_next_entity!
            @steps.each(&:pass!)
            next_entity!
            clear_cache!
          end
        end
      end
    end
  end
end
