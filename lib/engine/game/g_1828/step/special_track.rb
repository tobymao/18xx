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
            if action.entity.id == 'E&K' && !@company
              track_step = @round.steps.find { |step| step.is_a?(Track) }
              raise GameError, "Cannot use #{action.entity.name} after a tile upgrade" if track_step.upgraded

              track_step.no_upgrades = true
            end

            super
          end
        end
      end
    end
  end
end
