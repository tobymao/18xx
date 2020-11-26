# frozen_string_literal: true

require_relative '../special_track'
require_relative 'acquire_va_tunnel_coal_marker'
require_relative '../track_lay_when_company_sold'

module Engine
  module Step
    module G1828
      class SpecialTrack < SpecialTrack
        include AcquireVaTunnelCoalMarker
        include TrackLayWhenCompanySold
      end
    end
  end
end
