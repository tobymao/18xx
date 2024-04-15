# frozen_string_literal: true

require_relative '../../g_1817/round/operating'

module Engine
  module Game
    module G18Hiawatha
      module Round
        class Operating < G1817::Round::Operating
          def start_operating
            entity = @entities[@entity_index]
            return next_entity! if skip_entity?(entity)

            @current_operator = entity
            @current_operator_acted = false
            entity.trains.each { |train| train.operated = false }
            @game.payable_loans = entity.loans.size
            @log << "#{@game.acting_for_entity(entity).name} operates #{entity.name}" unless finished?
            @game.place_home_token(entity) if @home_token_timing == :operate
            skip_steps
            return unless finished?

            after_end_of_turn(entity)
            next_entity!
          end
        end
      end
    end
  end
end
