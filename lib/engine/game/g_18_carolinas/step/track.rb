# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18Carolinas
      module Step
        class Track < Engine::Step::Track
          LAY_ACTIONS = %w[lay_tile pass].freeze
          ALL_ACTIONS = %w[lay_tile choose pass].freeze

          def actions(entity)
            return [] unless entity == current_entity
            return [] if entity.corporation? && entity.receivership?
            return [] if entity.company? || (!can_lay_tile?(entity) && !conversion_available?)

            conversion_available? ? ALL_ACTIONS : LAY_ACTIONS
          end

          def conversion_available?
            @game.final_gauge && @round.num_laid_track.zero?
          end

          def round_state
            super.merge(
              {
                convert_mode: nil,
              }
            )
          end

          def setup
            super
            @round.convert_mode = nil
          end

          def choice_name
            'Switch to'
          end

          def choices
            {
              conversion: 'Track Conversion Mode',
            }
          end

          def process_choose(_action)
            @round.convert_mode = true
            @log << 'Switching to Track Conversion Mode'
            pass!
          end

          def end_subset?(this, other)
            return true if (this.city? || this.town?) && (other.city? || other.town?)

            this <= other
          end

          # this is basically the path '<=' method except towns and cities match
          # both this and other are paths
          def path_subset?(this, other)
            other_ends = other.ends
            this.ends.all? do |t|
              other_ends.any? do |o|
                end_subset?(t, o)
              end
            end && (this.ignore_gauge_compare || this.tracks_match?(other))
          end

          def legal_tile_rotation?(entity, hex, tile)
            return super unless @game.force_dit_upgrade?(hex.tile, tile)

            # basically a simplified version of the super except with a modified path check to allow dits to upgrade to cities
            return false unless @game.legal_tile_rotation?(entity, hex, tile)

            old_paths = hex.tile.paths
            old_ctedges = hex.tile.city_town_edges

            new_paths = tile.paths
            new_exits = tile.exits
            new_ctedges = tile.city_town_edges
            multi_city_upgrade = new_ctedges.size > 1 && old_ctedges.size > 1

            new_exits.all? { |edge| hex.neighbors[edge] } &&
              !(new_exits & hex_neighbors(entity, hex)).empty? &&
              # substituted path check:
              old_paths.all? { |path| new_paths.any? { |p| path_subset?(p, path) } } &&
              (!multi_city_upgrade || old_ctedges.all? { |oldct| new_ctedges.one? { |newct| (oldct & newct) == oldct } })
          end

          def check_track_restrictions!(entity, old_tile, new_tile)
            return if @game.loading || !entity.operator?

            super

            # if this is a yellow tile, make sure it is either
            # 1) the first tile lay for a corporation
            # 2) extends track of the same gauge being laid
            return unless new_tile.color == :yellow

            any_neighbor = false
            connected_paths = @game.graph_for_entity(entity).connected_paths(entity)
            raise 'Track must connect to existing track' if new_tile.paths.none? { |p| connected_paths.include?(p) }

            return if new_tile.paths.any? do |path|
              next unless connected_paths.include?(path) # needed for Charlotte and Wilmington

              path.edges.any? do |edge|
                edge = edge.num
                next unless (neighbor = new_tile.hex.neighbors[edge])

                np_edge = new_tile.hex.invert(edge)
                any_neighbor = true unless neighbor.paths[np_edge].empty?
                neighbor.paths[np_edge].any? { |np| connected_paths.include?(np) && path.tracks_match?(np, dual_ok: true) }
              end
            end

            raise GameError, 'Tile must extend a route with the same gauge of track' if any_neighbor
          end
        end
      end
    end
  end
end
