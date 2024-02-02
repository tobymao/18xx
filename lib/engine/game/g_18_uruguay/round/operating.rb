# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G18Uruguay
      module Round
        class Operating < Engine::Round::Operating
          def after_end_of_turn(action)
            @game.transition_to_next_round! if @game.nationalization_triggered
            super
          end
        end
      end
    end
  end
end
