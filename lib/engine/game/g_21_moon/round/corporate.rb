# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G21Moon
      module Round
        class Corporate < Engine::Round::Stock
          def self.short_name
            'CR'
          end

          def name
            'Corporate Round'
          end

          def select_entities
            @game.corporations.reject(&:closed?).select(&:ipoed).sort
          end

          def setup
            start_operating unless @entities.empty?
          end

          def next_entity!
            return if @entity_index == @entities.size - 1

            next_entity_index!

            @steps.each(&:unpass!)
            @steps.each(&:setup)
            start_operating
          end

          def start_operating
            entity = @entities[@entity_index]
            @current_operator = entity
            @current_operator_acted = false
            @log << "#{@game.acting_for_entity(entity).name} performs corporate actions for #{entity.name}" unless finished?
            skip_steps
            next_entity! if finished?
          end

          def reorder_entities!
            remaining = @entities[@entity_index..-1].sort.reverse
            @entities[@entity_index..-1] = remaining
          end

          def finished?
            !active_step
          end

          def show_auto?
            false
          end
        end
      end
    end
  end
end
