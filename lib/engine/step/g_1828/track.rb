# frozen_string_literal: true

require_relative '../track'
require_relative 'acquire_va_tunnel_coal_marker'

module Engine
  module Step
    module G1828
      class Track < Track
        include AcquireVaTunnelCoalMarker
      end
    end
  end
end
