# frozen_string_literal: true

require_relative '../../../round/operating'
require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18SJ
      module Round
        class Operating < Engine::Round::Operating
          def cash_crisis_player
            @game.cash_crisis_player
          end

          def start_operating
            entity = @entities[@entity_index]
            @current_operator = entity
            super
          end
        end
      end
    end
  end
end
