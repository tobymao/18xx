# frozen_string_literal: true

require_relative '../special_track'
require_relative 'acquire_va_tunnel_coal_marker'

module Engine
  module Step
    module G1828
      class SpecialTrack < SpecialTrack
        include AcquireVaTunnelCoalMarker
      end
    end
  end
end
