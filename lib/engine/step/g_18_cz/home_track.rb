# frozen_string_literal: true

require_relative '../base'
require_relative '../tracker'
require_relative '../tokener'

module Engine
  module Step
    module G18CZ
      class HomeTrack < Base
        include Tracker
        include Tokener
        ACTIONS = %w[lay_tile].freeze
        ALL_ACTIONS = %w[pass lay_tile].freeze

        def actions(entity)
          return [] unless entity == pending_entity
          return ALL_ACTIONS unless any_tiles?(entity)

          ACTIONS
        end

        def active_entities
          [pending_entity]
        end

        def round_state
          {
            pending_tracks: [],
          }
        end

        def active?
          pending_entity
        end

        def current_entity
          pending_entity
        end

        def pending_entity
          pending_track[:entity]
        end

        def pending_track
          @round.pending_tracks&.first || {}
        end

        def description
          "Lay home track for #{pending_entity.name}"
        end

        def any_tiles?(_entity)
          true
        end

        def process_pass(action)
          log_pass(action.entity)
          @round.pending_tracks.shift
          pass!
        end

        def process_lay_tile(action)
          lay_tile_action(action)
          @round.pending_tracks.shift

          place_token(
            action.entity,
            action.hex.tile.cities[0],
            action.entity.find_token_by_type,
            teleport: true,
          )
        end

        def reachable_node?(_entity, _node)
          true
        end

        def reachable_hex?(_entity, _hex)
          true
        end

        def available_hex(_entity, hex)
          pending_track[:hexes].include?(hex)
        end

        def hex_neighbors(entity, hex)
          @game.graph.connected_hexes(entity)[hex]
        end

        def potential_tiles(_entity, _hex)
          @game.tiles
            .select { |tile| tile.name == '8896' }
        end

        def legal_tile_rotation?(entity, hex, tile)
          return false unless @game.legal_tile_rotation?(entity, hex, tile)

          old_paths = hex.tile.paths

          new_paths = tile.paths
          new_exits = tile.exits

          new_exits.all? { |edge| hex.neighbors[edge] } &&
            old_paths.all? { |path| new_paths.any? { |p| path <= p } }
        end
      end
    end
  end
end
