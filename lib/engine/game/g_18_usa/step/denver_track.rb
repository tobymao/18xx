# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/tracker'

module Engine
  module Game
    module G18USA
      module Step
        class DenverTrack < Engine::Step::Base
          include Engine::Step::Tracker
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
                num_laid_track: 0,
                upgraded_track: false,
                laid_hexes: [],
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
            'Choose Denver track orientation'
          end

          def any_tiles?(_entity)
            pending_track[:hexes].first
          end

          def process_lay_tile(action)
            lay_tile(action)
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

          def check_track_restrictions!(_entity, _old_tile, _new_tile); end

          def legal_tile_rotation?(_entity, _hex, _tile)
            true
          end
        end
      end
    end
  end
end
