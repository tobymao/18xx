# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G1844
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def available_hex(entity, hex)
            return super unless @game.tunnel_companies.include?(entity)

            super && hex.tile.paths.none? { |p| p.track == :narrow }
          end

          def process_lay_tile(action)
            if @game.tunnel_companies.include?(action.entity)
              action.tile.rotate!(action.rotation)
              tile = @game.create_tunnel_tile(action.hex, action.tile)
              action = Engine::Action::LayTile.new(action.entity, tile: tile, hex: action.hex, rotation: 0)
            end

            super(action)
            return unless @game.tunnel_companies.include?(action.entity)

            action.tile.hex.assign!(action.entity.id)
          end

          def potential_tile_colors(entity, _hex)
            return super unless @game.tunnel_companies.include?(entity)

            [:purple]
          end

          def legal_tile_rotations(entity_or_entities, hex, tile)
            Engine::Tile::ALL_EDGES.select do |rotation|
              tile.rotate!(rotation)
              legal_tile_rotation?(
                entity_or_entities,
                hex,
                @game.tunnel_companies.include?(entity_or_entities) ? @game.create_tunnel_tile(hex, tile) : tile
              )
            end
          end

          def legal_tile_rotation?(entity, hex, tile)
            return super unless @game.tunnel_companies.include?(entity)

            tunnel_track_path = tile.paths.find { |p| p.track == :narrow }
            super &&
              tunnel_track_path.exits.none? { |edge| hex.neighbors[edge]&.tile&.color == :purple } &&
              (hex.tile.paths.flat_map(&:exits) & tunnel_track_path.exits).empty?
          end

          def check_track_restrictions!(entity, old_tile, new_tile)
            super
            return if @game.loading || !@game.tunnel_companies.include?(entity)

            tunnel_track_path = new_tile.paths.find { |p| p.track == :narrow }
            return if @game.graph.connected_paths(@round.current_operator)[tunnel_track_path]

            raise GameError, 'Tunnel track must be connected'
          end
        end
      end
    end
  end
end
