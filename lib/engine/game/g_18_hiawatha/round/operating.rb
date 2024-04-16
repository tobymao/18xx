# frozen_string_literal: true

require_relative '../../g_1817/round/operating'

module Engine
  module Game
    module G18Hiawatha
      module Round
        class Operating < G1817::Round::Operating
          attr_accessor :payable_loans

          def start_operating
            entity = @entities[@entity_index]
            return next_entity! if skip_entity?(entity)

            @current_operator = entity
            @payable_loans = @current_operator.loans.size
            @current_operator_acted = false
            entity.trains.each { |train| train.operated = false }
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
