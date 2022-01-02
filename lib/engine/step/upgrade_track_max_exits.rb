# frozen_string_literal: true

module Engine
  module Step
    module UpgradeTrackMaxExits
      # Used by 1817, 1867, 18USA
      def upgradeable_tiles(_entity, hex)
        return super if hex.tile.cities.empty? && @game.class::TILE_TYPE == :normal

        # When upgrading, players must use tiles with as many exits as will fit.
        # Find maximum number of exits
        super.group_by(&:color).values.flat_map do |group|
          max_edges = group.map { |t| t.edges.length }.max
          group.select { |t| t.edges.size == max_edges }
        end
      end
    end
  end
end
