# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G1860
      module Step
        class Token < Engine::Step::Token
          def actions(entity)
            return [] if entity.receivership? || @game.insolvent?(entity) || @game.sr_after_southern

            super
          end
        end
      end
    end
  end
end
