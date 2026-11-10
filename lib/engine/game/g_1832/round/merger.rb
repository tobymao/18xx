# frozen_string_literal: true

require_relative '../../../round/merger'

module Engine
  module Game
    module G1832
      module Round
        class Merger < Engine::Round::Merger
          def self.round_name
            'Merger and Takeover Round'
          end

          def self.short_name
            'M & T'
          end

          def select_entities
            @game.merge_corporations.select(&:operated?).sort
          end

          def setup
            super
            skip_steps
            next_entity! if finished?
          end

          def after_process(action)
            return if action.free?

            if (system = @post_merge_entity)
              @post_merge_entity = nil
              @steps.each(&:unpass!)
              @steps.each(&:setup)

              inserted = false
              unless @entities.include?(system)
                @entities.insert(@entity_index + 1, system)
                inserted = true
              end

              system_idx = @entities.find_index(system)
              @game.next_turn!
              @entity_index = system_idx

              if @steps.any? { |s| s.active? && s.blocking? }
                skip_steps
                return unless finished?
              end

              @entities.delete(system) if inserted
            end

            return if active_step

            @game.players.each(&:unpass!)
            next_entity!
          end

          def next_entity!
            next_entity_index! if @entities.any?
            return if @entities.empty? || @entity_index.zero?

            @steps.each(&:unpass!)
            @steps.each(&:setup)

            skip_steps
            next_entity! if finished?
          end

          def force_next_entity!
            # Suppress the normal entity-change triggered by close_corporation during a merger
          end
        end
      end
    end
  end
end
