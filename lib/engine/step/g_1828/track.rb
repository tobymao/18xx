# frozen_string_literal: true

require_relative '../track'
require_relative 'acquire_va_tunnel_coal_marker'

module Engine
  module Step
    module G1828
      class Track < Track
        include AcquireVaTunnelCoalMarker

        attr_accessor :no_upgrades
        attr_reader :upgraded

        def setup
          super
          @no_upgrades = false
          @round.last_tile_lay = nil
        end

        def round_state
          super.merge(
            {
              last_tile_lay: nil,
            }
          )
        end

        def get_tile_lay(entity)
          action = super
          return unless action

          action[:upgrade] = false if @no_upgrades
          action
        end

        def process_lay_tile(action)
          if @round.last_tile_lay && action.hex == @round.last_tile_lay.hex
            raise GameError, 'Cannot lay and upgrade the same tile in the same turn'
          end

          @round.last_tile_lay = action.tile
          super
        end
      end
    end
  end
end
