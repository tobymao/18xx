# frozen_string_literal: true

require_relative '../../../step/base'
require_relative 'tracker'

module Engine
  module Game
    module G1860
      module Step
        class HomeTrack < Engine::Step::Base
          include Engine::Game::G1860::Tracker
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

          def any_tiles?(entity)
            hex = pending_track[:hexes].first
            any_upgradeable_tiles?(entity, hex)
          end

          def process_pass(action)
            log_pass(action.entity)
            @round.pending_tracks.shift
            pass!
          end

          def get_tile_lay(_entity)
            { lay: true, upgrade: false, cost: 0, upgrade_cost: 0, cannot_reuse_same_hex: false }
          end

          def process_lay_tile(action)
            @round.num_laid_track = 0
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
        end
      end
    end
  end
end
