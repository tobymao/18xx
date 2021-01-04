# frozen_string_literal: true

module Engine
  module Step
    module UpgradeTrackMaxExits
      # Used by 1817 & 1867
      def upgradeable_tiles(_entity, hex)
        return super if hex.tile.color != :green || hex.tile.cities.none?

        tiles = super

        # When upgrading normal cities to brown, players must use tiles with as many exits as will fit.
        # Find maximum number of exits
        max_edges = tiles.map { |t| t.edges.length }.max
        tiles.select { |t| t.edges.size == max_edges }
      end
    end
  end
end
