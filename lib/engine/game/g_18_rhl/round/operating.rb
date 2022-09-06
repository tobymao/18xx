# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G18Rhl
      module Round
        class Operating < Engine::Round::Operating
          attr_accessor :teleport_ability

          def start_operating
            super

            return if finished?

            @game.update_token_blocking_in_rhine_metropolies(@current_operator)
          end
        end
      end
    end
  end
end
