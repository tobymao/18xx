# frozen_string_literal: true

require_relative '../../../round/merger'

module Engine
  module Game
    module G1822PNW
      module Round
        class Merger < Engine::Round::Merger
          def name
            'Merger Round'
          end

          def self.round_name
            'Merger Round'
          end

          def self.short_name
            'MR'
          end

          def select_entities
            @game.operating_order.select { |c| c.type == :minor }
          end

          def setup
            super
            skip_steps
            next_entity! if finished?
          end

          def next_entity!
            return if @entities.empty?
            return if @entity_index == @entities.size - 1

            next_entity_index!

            @steps.each(&:unpass!)
            @steps.each(&:setup)

            skip_steps
            next_entity! if finished?
          end

          def after_process(action)
            return if action.free?
            return if active_step

            next_entity!
          end
        end
      end
    end
  end
end
