# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G1828
      module Step
        class Route < Engine::Step::Route
          def available_hex(entity, hex)
            return @game.coal_marker?(entity) if hex.id == Engine::Game::G1828::Game::VA_COALFIELDS_HEX

            super
          end
        end
      end
    end
  end
end
