# frozen_string_literal: true

require_relative '../../../step/track'
require_relative 'acquire_va_tunnel_coal_marker'

module Engine
  module Game
    module G1828
      module Step
        class Track < Engine::Step::Track
          include AcquireVaTunnelCoalMarker
        end
      end
    end
  end
end
