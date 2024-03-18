# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G1854
      module Step
        class Track < Engine::Step::Track
          def old_paths_maintained?(hex, tile)
            from = hex.tile
            to = tile
            # paths get wonky here, so just maintain exits
            return from.exits.sort == to.exits.sort if @game.double_dit_upgrade?(from, to)

            super
          end
        end
      end
    end
  end
end
