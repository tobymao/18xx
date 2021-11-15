# frozen_string_literal: true

require_relative '../../../round/merger'

module Engine
  module Game
    module G18NY
      module Round
        class NYCFormation < Engine::Round::Merger
          def self.round_name
            'NYC Formation'
          end

          def self.short_name
            'NYC'
          end

          def select_entities
            @game.active_minors
          end

          def connected_minors
            @connected_minors ||= @game.minors_connected_to_albany
          end

          def setup
            super
            start
          end

          def next_entity!
            next_entity_index! unless @entities.empty?
            return if @entity_index.zero?

            @steps.each(&:unpass!)
            @steps.each(&:setup)
            start
          end

          def start
            entity = @entities[@entity_index]
            @current_operator = entity
            @current_operator_acted = false
            skip_steps
            next_entity! if finished?
          end
        end
      end
    end
  end
end
