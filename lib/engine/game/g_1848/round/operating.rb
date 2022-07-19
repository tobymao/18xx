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
            return super if entity.name != :COM

            com_operates = @game.sydney_adelaide_connected || @game.com_can_operate
            @log << 'COM does not operate, Sydney and Addelaide are not connected or phase 6 has not started' unless com_operates
            !com_operates
          end
        end
      end
    end
  end
end
