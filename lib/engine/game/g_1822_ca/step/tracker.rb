# frozen_string_literal: true

require_relative '../../g_1822/step/tracker'

module Engine
  module Game
    module G1822CA
      module Tracker
        include G1822::Tracker

        def old_paths_maintained?(hex, tile)
          if hex.tile.name == 'AG13' && hex.tile.color == :white
            %w[5 6 57].include?(tile.name)
          else
            super
          end
        end
      end
    end
  end
end
