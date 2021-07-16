# frozen_string_literal: true

require_relative '../../../step/tracker'
require_relative '../../../step/track'
require_relative '../../../step/upgrade_track_max_exits'

module Engine
  module Game
    module G18USA
      module Step
        class Track < Engine::Step::Track
          include Engine::Step::UpgradeTrackMaxExits

          def check_track_restrictions!(entity, old_tile, new_tile)
            return if @game.loading || !entity.operator?

            graph = @game.graph_for_entity(entity)

            raise GameError, 'New track must override old one' if !@game.class::ALLOW_REMOVING_TOWNS &&
                old_tile.city_towns.any? do |old_city|
                  new_tile.city_towns.none? { |new_city| (old_city.exits - new_city.exits).empty? }
                end

            old_paths = old_tile.paths
            changed_city = false
            used_new_track = old_paths.empty?

            new_tile.paths.each do |np|
              next unless graph.connected_paths(entity)[np]

              op = old_paths.find { |path| np <= path }
              used_new_track = true unless op
              old_revenues = op&.nodes && op.nodes.map(&:max_revenue).sort
              new_revenues = np&.nodes && np.nodes.map(&:max_revenue).sort
              changed_city = true unless old_revenues == new_revenues
            end
            return if used_new_track || changed_city || new_tile.id.include?('iron')
            raise GameError, 'Must use new track or change city value' if !used_new_track && !changed_city
          end
        end
      end
    end
  end
end
