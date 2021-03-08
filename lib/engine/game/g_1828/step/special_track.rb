# frozen_string_literal: true

require_relative '../../../step/special_track'
require_relative 'acquire_va_tunnel_coal_marker'
require_relative '../../../step/track_lay_when_company_sold'

module Engine
  module Game
    module G1828
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          include AcquireVaTunnelCoalMarker
          include Engine::Step::TrackLayWhenCompanySold

          def process_lay_tile(action)
            super

            return if action.entity.id != 'E&K' || action.tile.hex.id == 'E7'

            raise GameError, "Cannot use #{action.entity.name} after a tile upgrade" if @round.upgraded_track

            @round.upgraded_track = true
          end
        end
      end
    end
  end
end
