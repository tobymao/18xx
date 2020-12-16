# frozen_string_literal: true

require_relative '../base'
require_relative 'tracker'

module Engine
  module Step
    module G1860
      class HomeTrack < Base
        include Tracker
        ACTIONS = %w[lay_tile].freeze

        def actions(entity)
          return [] unless entity == pending_entity

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

        def process_lay_tile(action)
          lay_tile_action(action)
          @round.pending_tracks.shift
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
      end
    end
  end
end
