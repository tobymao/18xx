# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1825
      module Round
        class Operating < Engine::Round::Operating
          def start_operating
            entity = @entities[@entity_index]
            @current_operator = entity
            @current_operator_acted = false
            entity.trains.each { |train| train.operated = false }
            actor = @game.acting_for_entity(entity)
            if actor == entity.owner
              @log << "#{actor.name} operates #{entity.name}" unless finished?
            else
              @log << "#{actor.name} selected to operate #{entity.name} (in Receivership)" unless finished?
            end
            @game.place_home_token(entity) if @home_token_timing == :operate || @game.minor_deferred_token?(entity)
            skip_steps
            next_entity! if finished?
          end
        end
      end
    end
  end
end
