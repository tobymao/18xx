# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/tracker'

module Engine
  module Game
    module G18Neb
      module Step
        class LocalHomeTrack < Engine::Step::Base
          include Engine::Step::Tracker
          ACTIONS = %w[lay_tile].freeze

          def actions(entity)
            return [] unless entity == current_entity

            ACTIONS
          end

          def active_entities
            [current_entity]
          end

          def round_state
            super.merge(
              {
                num_laid_track: 0,
                upgraded_track: false,
                laid_hexes: [],
                pending_home_track: [],
              }
            )
          end

          def active?
            current_entity
          end

          def current_entity
            @round.pending_home_track[0]
          end

          def home_hex
            @game.hex_by_id(current_entity.coordinates)
          end

          def description
            "Place #{current_entity.name} home track"
          end

          def process_lay_tile(action)
            lay_tile(action)
            @game.place_home_token(current_entity)
            @round.pending_home_track.shift
          end

          def reachable_node?(_entity, _node)
            true
          end

          def reachable_hex?(_entity, _hex)
            true
          end

          def potential_tiles(_entity_or_entities, _hex)
            @game.tiles.select do |tile|
              @game.local_home_track_brown_upgrade?(home_hex.tile, tile)
            end
          end

          def available_hex(_entity, hex)
            hex == home_hex
          end

          def hex_neighbors(_entity, _hex)
            (0..5).to_a
          end

          def old_paths_maintained?(hex, tile)
            (hex.tile.exits & tile.exits) == hex.tile.exits
          end

          def check_track_restrictions!(_entity, _old_tile, _new_tile); end
        end
      end
    end
  end
end
