# frozen_string_literal: true

module Engine
  module Game
    module G1822CA
      module Tracker
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
