# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1848
      module Round
        class Operating < Engine::Round::Operating
          attr_accessor :cash_crisis_player

          def after_process(action)
            # Keep track of last_player for Cash Crisis
            entity = @entities[@entity_index]
            @cash_crisis_player = entity.player

            super
          end

          def skip_entity?(entity)
            return super if entity.name != :COM || @game.can_com_operate?

            @log << 'COM does not operate until either Sydney and Adelaide are connected or phase 6 has started'
            !@game.can_com_operate?
          end
        end
      end
    end
  end
end
