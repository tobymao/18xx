# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1832
      module Round
        class Operating < Engine::Round::Operating
          def setup
            return super unless self == @game.saved_or_round

            @game.saved_or_round = nil
            @entities = resumed_entities
            @entity_index = 0
            @steps.each(&:unpass!)
            @steps.each(&:setup)
            clear_cache!
            start_operating if any_to_act?
          end

          def finished?
            return super unless self == @game.saved_or_round

            @current_operator = nil
            true
          end

          # The first 6-train interrupts the round after the current entity, instead of advancing to the next.
          def next_entity!
            return @game.interrupt_operating_round!(self) if @game.final_merger_triggered?

            super
          end

          private

          def resumed_entities
            operated = @entities[0..@entity_index]
            operated_ids = operated.map(&:id)
            remaining = (@entities - operated).reject(&:closed?)

            formed_systems = (@game.operating_order - @entities).select do |entity|
              @game.system?(entity) && entity.system_shells.none? { |id| operated_ids.include?(id) }
            end
            formed_systems.sort_by { |system| [-system.share_price.price, system.id] }.each do |system|
              idx = remaining.find_index { |entity| (entity.share_price&.price || 0) < system.share_price.price }
              remaining.insert(idx || remaining.size, system)
            end

            remaining
          end
        end
      end
    end
  end
end
