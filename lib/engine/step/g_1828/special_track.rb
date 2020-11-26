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

        def process_lay_tile(action)
          if action.entity.id == 'E&K' && !@company
            track_step = @round.steps.find { |step| step.is_a?(Track) }
            @game.game_error("Cannot use #{action.entity.name} after a tile upgrade") if track_step.upgraded
            track_step.no_upgrades = true
          end

          super
        end
      end
    end
  end
end
