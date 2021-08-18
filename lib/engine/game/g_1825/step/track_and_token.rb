# frozen_string_literal: true

require_relative '../../../step/track_and_token'

module Engine
  module Game
    module G1825
      module Step
        class TrackAndToken < Engine::Step::TrackAndToken
          # 1825: it is only an "upgrade" if the new tile replaces another laid tile
          def lay_tile_action(action, entity: nil, spender: nil)
            tile = action.tile
            entity ||= action.entity
            old_tile = action.hex.tile
            tile_lay = get_tile_lay(action.entity)
            raise GameError, 'Cannot upgrade now' if !old_tile.preprinted && !(tile_lay && tile_lay[:upgrade])
            raise GameError, 'Cannot lay a tile now' if old_tile.preprinted && !(tile_lay && tile_lay[:lay])
            if tile_lay[:cannot_reuse_same_hex] && @round.laid_hexes.include?(action.hex)
              raise GameError, "#{action.hex.id} cannot be layed as this hex was already layed on this turn"
            end

            check_adjacent(old_tile.hex) if @round.num_laid_track.positive?

            extra_cost = tile.color == :yellow ? tile_lay[:cost] : tile_lay[:upgrade_cost]

            lay_tile(action, extra_cost: extra_cost, entity: entity, spender: spender)
            upgraded_track(old_tile, tile, action.hex)
            @round.num_laid_track += 1
            @round.laid_hexes << action.hex

            return unless (ability = @game.abilities(entity, :blocks_hexes))

            # if this corp laid a hex on its reserved hex, remove the ability
            entity.abilities.delete(ability) if @game.hex_blocked_by_ability?(entity, ability, action.hex)
          end

          def upgraded_track(from, _to, _hex)
            @round.upgraded_track = true unless from.preprinted
          end

          def check_adjacent(new_hex)
            coordinates = @round.laid_hexes.map { |h| [[h.x, h.y], h] }.to_h
            Engine::Hex::DIRECTIONS[new_hex.layout].each do |xy, _direction|
              x, y = xy
              raise GameError, 'Cannot lay tiles in adjacent hexes' if coordinates[[new_hex.x + x, new_hex.y + y]]
            end
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

          def reachable_node?(entity, node, max_distance)
            return false if max_distance.zero?

            node_distances = @game.distance_graph.node_distances(entity)
            return false unless node_distances[node]

            node_distances[node][:node] < max_distance
          end

          # 1825 rule: any upgraded station must be reachable with a train
          def check_track_restrictions!(entity, old_tile, new_tile)
            return if @game.loading || !entity.operator?

            super

            return if old_tile.preprinted || new_tile.nodes.empty?

            if (max_distance = @game.biggest_train_distance(entity)).zero?
              raise GameError, 'Cannot upgrade a city/town without a train'
            end

            @game.distance_graph.clear
            new_tile.nodes.each do |node|
              unless reachable_node?(entity, node, max_distance)
                raise GameError, 'Unable to reach city/town on upgraded tile with any train'
              end
            end
          end

          def tokenable_hex?(entity, hex)
            return false if @round.tokened || (tokens = available_tokens(entity)).empty?
            return false unless min_token_price(tokens) <= buying_power(entity)
            return false if hex.tile.cities.empty?

            @game.graph.reachable_hexes(entity)[hex]
          end

          def available_hex(entity, hex)
            return true if can_lay_tile?(entity) && super

            tokenable_hex?(entity, hex)
          end
        end
      end
    end
  end
end
