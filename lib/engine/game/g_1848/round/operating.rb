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
        end
      end
    end
  end
end
