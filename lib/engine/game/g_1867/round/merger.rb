# frozen_string_literal: true

require_relative '../../../round/merger'

module Engine
  module Game
    module G1867
      module Round
        class Merger < Engine::Round::Merger
          def self.round_name
            'Merger Round'
          end

          def self.short_name
            'MR'
          end

          def select_entities
            @game.merge_corporations.sort
          end

          def setup
            super
            skip_steps
            next_entity! if finished?
          end

          def after_process(action)
            return if action.free?
            return if active_step

            @converted = nil

            @game.players.each(&:unpass!)
            next_entity!
          end

          def next_entity!
            next_entity_index! if @entities.any?
            return if @entity_index.zero?

            @steps.each(&:unpass!)
            @steps.each(&:setup)

            skip_steps
            next_entity! if finished?
          end

          def entities
            if @converted
              @game.players
            else
              @entities
            end
          end

          def force_next_entity!
            # called from the close corporation, ignore it
          end
        end
      end
    end
  end
end
