# frozen_string_literal: true

require_relative '../../../step/tokener'
require_relative '../../../step/token'

module Engine
  module Game
    module G1824Cisleithania
      module Step
        class Token < Engine::Step::Token
          def actions(entity)
            return [] if @game.two_player? && @game.bond_railway?(entity)

            super
          end
        end
      end
    end
  end
end
