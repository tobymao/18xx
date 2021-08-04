# frozen_string_literal: true

module Engine
  module Game
    module G1828
      module AcquireVaTunnelCoalMarker
        def process_lay_tile(action)
          @game.acquire_va_tunnel_coal_marker(action.entity) if action.hex.id == Engine::Game::G1828::Game::VA_TUNNEL_HEX

          super
        end
      end
    end
  end
end
