# frozen_string_literal: true

require_relative '../../../step/tracker'

module Engine
  module Game
    module G1860
      module Tracker
        include Engine::Step::Tracker

        def setup
          @laid_city = false
          @saved_revenues = []
          super
        end

        def get_tile_lay(entity)
          action = @game.tile_lays(entity)[@round.num_laid_track]&.clone
          return unless action

          action[:lay] = !@round.upgraded_track && !@laid_city if action[:lay] == :not_if_upgraded_or_city
          action[:upgrade] = !@round.upgraded_track if action[:upgrade] == :not_if_upgraded
          action[:cost] = action[:cost] || 0
          action[:cannot_reuse_same_hex] = action[:cannot_reuse_same_hex] || false
          action
        end

        def lay_tile_action(action)
          tile = action.tile
          tile_lay = get_tile_lay(action.entity)
          raise GameError, 'Cannot lay an upgrade now' if tile.color != :yellow && !tile_lay[:upgrade]
          raise GameError, 'Cannot lay an yellow now' if tile.color == :yellow && !tile_lay[:lay]
          raise GameError, 'Cannot lay a city tile now' if tile.cities.any? && @round.num_laid_track.positive?
          if tile_lay[:cannot_reuse_same_hex] && @round.laid_hexes.include?(action.hex)
            raise GameError, "#{action.hex.id} cannot be layed as this hex was already layed on this turn"
          end

          @saved_revenues = revenues(action.hex.tile, action.entity)
          lay_tile(action, extra_cost: tile_lay[:cost])
          @round.upgraded_track = true if action.tile.color != :yellow
          @laid_city = true if action.tile.cities.any?
          @round.num_laid_track += 1
          @round.laid_hexes << action.hex
        end

        def pay_tile_cost!(entity, tile, rotation, hex, spender, cost, _extra_cost)
          raise GameError, "#{spender.id} cannot pay for a tile when insolvent" if @game.insolvent?(spender) && cost.positive?

          super
        end

        # this must be called before graphs are updated with new tile
        def revenues(tile, entity)
          return [] if @game.loading || tile.color == :white || !entity.operator?

          tile.nodes.select { |n| reachable_node?(entity, n, @game.biggest_train_distance(entity)) }
            .map(&:max_revenue).sort
        end

        def check_track_restrictions!(entity, old_tile, new_tile)
          @game.clear_distances
          return if @game.loading || !entity.operator?

          tr_distance = @game.biggest_train_distance(entity)

          changed_city = false
          if old_tile.color != :white
            # add requirement that paths/nodes be reachable with train
            raise GameError, 'Tile must be reachable with train' unless reachable_hex?(entity, new_tile.hex,
                                                                                       tr_distance)

            # check to see revenues reachable from old graph have changed
            new_revenues = new_tile.nodes.select { |n| reachable_node?(entity, n, tr_distance) }
                             .map(&:max_revenue).sort
            changed_city = @saved_revenues != new_revenues
          end

          old_paths = old_tile.paths
          used_new_track = old_paths.empty?

          new_tile.paths.each do |np|
            next unless @game.graph.connected_paths(entity)[np]
            next if old_tile.color != :white && !reachable_path?(entity, np, tr_distance)

            op = old_paths.find { |path| np <= path }
            used_new_track = true unless op

            next unless old_tile.color == :white

            # check to see if revenues on tile have changed
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

        # can be used by Step to see if any layable tiles exist for a given hex
        # This has fewer side-effects than the base upgradeable_tiles method
        def any_upgradeable_tiles?(entity, hex)
          potential_tiles(entity, hex).each do |tile|
            return true if tile.legal_rotations.any?

            tile.rotate!(0) # reset tile to no rotation since calculations are absolute
            tile.legal_rotations = legal_tile_rotations(entity, hex, tile)
            next if tile.legal_rotations.empty?

            tile.rotate! # rotate it to the first legal rotation
            return true
          end
          false
        end
      end
    end
  end
end
