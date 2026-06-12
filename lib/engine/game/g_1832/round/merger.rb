# frozen_string_literal: true

require_relative '../../../round/merger'

module Engine
  module Game
    module G1832
      module Round
        class Merger < Engine::Round::Merger
          attr_reader :entities

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

            if (pme = @post_merge_entity)
              @post_merge_entity = nil
              @steps.each(&:unpass!)
              @steps.each(&:setup)

              inserted = false
              unless @entities.include?(pme)
                @entities.insert(@entity_index + 1, pme)
                inserted = true
              end

              pme_idx = @entities.find_index(pme)
              @game.next_turn!
              @entity_index = pme_idx

              if @steps.any? { |s| s.active? && s.blocking? }
                skip_steps
                unless finished?
                  # Post-merge entity has targets — let it act
                  return
                end
              end

              # No targets: remove inserted system and fall through to advance
              @entities.delete(pme) if inserted
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

          # Suppress the normal entity-change triggered by close_corporation during a merger
          def force_next_entity!
            # No-op: mergers in game.rb manage entity advancement themselves
          end
        end
      end
    end
  end
end
