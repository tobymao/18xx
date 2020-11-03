# frozen_string_literal: true

module Engine
  module Step
    module G1828
      module AcquireVaTunnelCoalMarker
        def process_lay_tile(action)
          super

          @game.acquire_va_tunnel_coal_marker(action.entity) if action.hex.id == Engine::Game::G1828::VA_TUNNEL_HEX
        end
      end
    end
  end
end
