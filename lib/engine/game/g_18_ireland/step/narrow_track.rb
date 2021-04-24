# frozen_string_literal: true

module Engine
  module Game
    module G18Ireland
      module Step
        module NarrowTrack
          def process_lay_tile(action)
            super
            @game.clear_narrow_graph
          end

          def check_track_restrictions!(entity, old_tile, new_tile)
            return if @game.loading || !entity.operator?

            connected_paths = if @game.tile_uses_broad_rules?(old_tile, new_tile)
                                @game.graph_for_entity(entity).connected_paths(entity)
                              else
                                # Must update the graph now.
                                @game.clear_narrow_graph
                                @game.narrow_connected_paths(entity)
                              end

            old_paths = old_tile.paths
            changed_city = false
            used_new_track = old_paths.empty?

            new_tile.paths.each do |np|
              next unless connected_paths[np]

              op = old_paths.find { |path| np <= path }
              used_new_track = true unless op
              old_revenues = op&.nodes && op.nodes.map(&:max_revenue).sort
              new_revenues = np&.nodes && np.nodes.map(&:max_revenue).sort
              changed_city = true unless old_revenues == new_revenues
            end

            case @game.class::TRACK_RESTRICTION
            when :permissive
              true
            when :city_permissive
              raise GameError, 'Must be city tile or use new track' if new_tile.cities.none? && !used_new_track
            when :restrictive
              raise GameError, 'Must use new track' unless used_new_track
            when :semi_restrictive
              raise GameError, 'Must use new track or change city value' if !used_new_track && !changed_city
            else
              raise
            end
          end
        end
      end
    end
  end
end
