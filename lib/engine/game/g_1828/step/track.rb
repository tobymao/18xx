# frozen_string_literal: true

require_relative '../../../step/track'
require_relative 'acquire_va_tunnel_coal_marker'

module Engine
  module Game
    module G1828
      module Step
        class Track < Engine::Step::Track
          include AcquireVaTunnelCoalMarker

          def update_token!(action, entity, tile, old_tile)
            if action.hex.id == 'E15' && (token = tile.cities.flat_map(&:tokens).find(&:itself))
              # If there are blocking tokens in both cities, no decisions to be made
              return if @game.blocking_token?(token)

              # Otherwise, the token owner gets to decide the token location
              entity = token.corporation
            end

            super(action, entity, tile, old_tile)
          end
        end
      end
    end
  end
end
