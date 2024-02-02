# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G18Uruguay
      module Round
        class Nationalization < Engine::Round::Operating
          def after_end_of_turn(action)
            super
          end

          def after_process(action)
            super
          end
        end
      end
    end
  end
end
