# frozen_string_literal: true

require_relative '../../../step/track'
require_relative 'acquire_va_tunnel_coal_marker'

module Engine
  module Game
    module G1828
      module Step
        class Track < Engine::Step::Track
          include AcquireVaTunnelCoalMarker

          def update_token!(action, _entity, tile, _old_tile)
            # Nothing to update if blocking tokens have been laid
            return if action.hex.id == 'E15' && @game.blocking_token?(tile.cities.flat_map(&:tokens).find(&:itself))

            super
          end
        end
      end
    end
  end
end
