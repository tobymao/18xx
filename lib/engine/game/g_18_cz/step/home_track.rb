# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/tracker'
require_relative '../../../step/tokener'

module Engine
  module Game
    module G18CZ
      module Step
        class HomeTrack < Engine::Step::Base
          include Engine::Step::Tracker
          include Engine::Step::Tokener
          ACTIONS = %w[lay_tile].freeze

          def actions(entity)
            return [] unless entity == pending_entity

            ACTIONS
          end

          def active_entities
            [pending_entity]
          end

          def round_state
            super.merge(
              {
                pending_tracks: [],
              }
            )
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

          def process_lay_tile(action)
            lay_tile_action(action)
            action.hex.tile.borders.clear

            action.hex.neighbors.each do |neighbor|
              edge = neighbor[0]
              neighbor[1].tile.borders.map! { |nb| nb.edge == action.hex.invert(edge) ? nil : nb }.compact!
            end

            @round.pending_tracks.shift

            place_token(
              action.entity,
              action.hex.tile.cities[0],
              action.entity.find_token_by_type,
              connected: false,
              extra_action: true
            )
          end

          def hex_neighbors(_entity, hex)
            pending_track[:hexes].include?(hex)
          end

          def available_hex(entity, hex)
            hex_neighbors(entity, hex)
          end

          def potential_tiles(entity, _hex)
            @game.potential_tiles(entity)
          end

          def legal_tile_rotation?(entity, hex, tile)
            return false unless @game.legal_tile_rotation?(entity, hex, tile)

            old_paths = hex.tile.paths

            new_paths = tile.paths
            new_exits = tile.exits

            new_exits.all? { |edge| hex.neighbors[edge] } &&
              old_paths.all? { |path| new_paths.any? { |p| path <= p } }
          end

          def upgraded_track(_from, to, _hex)
            @round.upgraded_track = true if to.color != :yellow && to.color != :red
          end
        end
      end
    end
  end
end
