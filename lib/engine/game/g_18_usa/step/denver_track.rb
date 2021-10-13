# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/tracker'
require_relative '../../../step/tokener'

module Engine
  module Game
    module G18USA
      module Step
        class DenverTrack < Engine::Step::Base
          include Engine::Step::Tracker
          include Engine::Step::Tokener
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
            'Lay Denver'
          end

          def any_tiles?(_entity)
            pending_track[:hexes].first
          end

          def process_pass(action)
            log_pass(action.entity)
            @round.pending_tracks.shift
            pass!
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

          def legal_tile_rotation?
            true
          end
        end
      end
    end
  end
end
