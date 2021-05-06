# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G1840
      module Step
        class SpecialTrack < Engine::Step::Track
          ACTIONS_WITH_PASS = %w[lay_tile pass].freeze

          def actions(entity)
            return [] unless entity == pending_entity

            ACTIONS_WITH_PASS
          end

          def round_state
            super.merge(
              {
                pending_tile_lays: [],
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
            pending_tile_lay[:entity]
          end

          def color
            pending_tile_lay[:color]
          end

          def pending_tile_lay
            @round.pending_tile_lays&.first || {}
          end

          def available_hex(entity, hex)
            return false if @game.orange_framed?(hex.tile)

            return @game.class::RED_TILES.include?(hex.coordinates) if color == 'red' &&
             hex.tile == hex.original_tile

            return hex.tile.color == color if color == 'purple' &&  hex.tile == hex.original_tile

            connected = @game.graph_for_entity(entity).connected_hexes(entity)[hex]
            return false unless connected

            return hex.tile.color == 'white' if color == 'yellow'

            hex.tile.color == 'yellow'
          end

          def potential_tiles(_entity, hex)
            if color == 'red'
              return @game.tiles
              .select { |tile| color == tile.color }
            end

            if color == 'purple'
              if (tiles = @game.class::PURPLE_SPECIAL_TILES[hex.coordinates])
                return @game.tiles.select { |tile| tiles.include?(tile.name) }
              end

              return @game.tiles.select do |tile|
                       color == tile.color && !@game.class::TILES_FIXED_ROTATION.include?(tile.name)
                     end
            end

            tiles = super
            return tiles.select { |tile| @game.orange_framed?(tile) } if @game.orange_framed?(hex.tile)

            tiles.reject { |tile| @game.orange_framed?(tile) }
          end

          def process_lay_tile(action)
            lay_tile(action)
            @round.laid_hexes << action.hex
            @round.pending_tile_lays.shift
          end

          def process_pass(action)
            super
            @round.pending_tile_lays.shift
          end

          def hex_neighbors(_entity, hex)
            return @game.hex_by_id(hex.id).neighbors.keys if (hex.tile.color == 'purple') ||
                                                              (hex.tile.color == 'red')

            super
          end

          def legal_tile_rotation?(_entity, hex, tile)
            return tile.rotation.zero? if color == 'purple' && @game.class::TILES_FIXED_ROTATION.include?(tile.name)
            return true if color == 'purple'

            super
          end

          def show_other
            @game.owning_major_corporation(current_entity)
          end
        end
      end
    end
  end
end
