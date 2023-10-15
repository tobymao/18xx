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
            entities = []
            entities << @game.lhp_private if @game.lhp_train_pending?
            entities << @game.no_bust if @game.abilities(@game.no_bust, :assign_hexes)
            entities
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
