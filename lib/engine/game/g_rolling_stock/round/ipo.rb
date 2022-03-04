# frozen_string_literal: true

require_relative '../../../round/base'

module Engine
  module Game
    module GRollingStock
      module Round
        class IPO < Engine::Round::Base
          def self.round_name
            'IPO Round'
          end

          def self.short_name
            'IPO'
          end

          def name
            'Phase 9 - IPO'
          end

          # need Par view
          def stock?
            true
          end

          def setup
            start_ipo
          end

          def start_ipo
            entity = @entities[@entity_index]
            @log << "#{@game.acting_for_entity(entity).name} acts for #{entity.sym}" unless finished?
            skip_steps
            next_entity! if finished?
          end

          def select_entities
            @game.ipo_companies
          end

          def after_process(action)
            return if action.type == 'message'

            if active_step
              entity = @entities[@entity_index]
              return if entity.owner&.player?
            end

            next_entity!
          end

          def next_entity!
            return if @entity_index == @entities.size - 1

            next_entity_index!

            @steps.each(&:unpass!)
            @steps.each(&:setup)
            start_ipo
          end
        end
      end
    end
  end
end
