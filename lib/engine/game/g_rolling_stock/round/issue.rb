# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module GRollingStock
      module Round
        class Issue < Engine::Round::Operating
          def name
            'Issue Shares'
          end

          def self.short_name
            'ISS'
          end

          def setup
            @current_operator = nil
            after_setup
          end

          def start_operating
            entity = @entities[@entity_index]
            return next_entity! if skip_entity?(entity)

            @current_operator = entity
            @current_operator_acted = false
            @log << "#{@game.acting_for_entity(entity).name} acts for #{entity.name}" unless finished?
            skip_steps
            next_entity! if finished?
          end
        end
      end
    end
  end
end
