# frozen_string_literal: true

require_relative '../../../round/merger'

module Engine
  module Game
    module G1833NE
      module Round
        class Takeover < Engine::Round::Merger
          def self.round_name
            'Takeover Round'
          end

          def self.short_name
            'TR'
          end

          def select_entities
            @game.corporations.select(&:floated?).sort
          end

          def setup
            skip_steps
            next_entity! if finished?
          end

          def after_process(action)
            return if action.free?
            return if active_step

            next_entity!
          end

          def next_entity!
            return if @entity_index >= @entities.size - 1

            next_entity_index!
            return next_entity! if @entities[@entity_index].closed?

            @steps.each(&:unpass!)
            @steps.each(&:setup)
            skip_steps
            next_entity! if finished?
          end

          def force_next_entity!; end
        end
      end
    end
  end
end
