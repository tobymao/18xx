# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1868WY
      module Round
        class Bust < Engine::Round::Operating
          def self.short_name
            'BUST'
          end

          def name
            'BUST Round'
          end

          def select_entities
            @game.abilities(@game.no_bust, :assign_hexes) ? [@game.no_bust] : []
          end

          def start_operating
            entity = @entities[@entity_index]
            return next_entity! if skip_entity?(entity)

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
