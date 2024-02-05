# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/tracker'

module Engine
  module Game
    module G21Moon
      module Step
        class OLSTrack < Engine::Step::Base
          include Engine::Step::Tracker
          ACTIONS = %w[lay_tile].freeze

          def actions(entity)
            return [] unless entity == pending_entity

            ACTIONS
          end

          def visible?
            true
          end

          def players_visible?
            true
          end

          def available
            []
          end

          def show_map
            true
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
            'Lay OLS track'
          end

          def process_pass(action)
            log_pass(action.entity)
            @round.pending_tracks.shift
            pass!
          end

          def get_tile_lay(_entity)
            { lay: true, upgrade: true, cost: 0, upgrade_cost: 0, cannot_reuse_same_hex: false }
          end

          def update_tile_lists(tile, old_tile)
            old_tile.icons.dup.each do |old_icon|
              old_tile.icons.delete(old_icon)
              new_icon = @game.update_icon(old_icon, tile)
              tile.icons << new_icon if new_icon
            end
            super
          end

          def process_lay_tile(action)
            ols_minor = pending_entity
            ols_hex = action.hex
            ols_tile = action.tile
            @round.num_laid_track = 0
            lay_tile_action(action)
            @round.pending_tracks.shift

            ols_token = ols_minor.find_token_by_type
            if ols_tile.cities.one?
              @log << "OLS places a token on #{ols_hex.name}"
              city = ols_tile.cities.first
              city.place_token(ols_minor, ols_token)
            else
              @log << "#{ols_minor.owner.name} must choose city for OLS token"
              @round.pending_tokens << {
                entity: ols_minor,
                hexes: [ols_hex],
                token: ols_token,
              }
              @round.clear_cache!
            end
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

          def hex_neighbors(_entity, hex)
            edges = {}
            hex.neighbors.each { |e, _| edges[e] = true }
            edges.keys
          end

          def pay_tile_cost!(_entity_or_entities, _tile, _rotation, _hex, _spender, _cost, _extra_cost); end
        end
      end
    end
  end
end
