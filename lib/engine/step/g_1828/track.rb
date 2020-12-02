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
        end

        def get_tile_lay(entity)
          action = super
          return unless action

          action[:upgrade] = false if @no_upgrades
          action
        end
      end
    end
  end
end
