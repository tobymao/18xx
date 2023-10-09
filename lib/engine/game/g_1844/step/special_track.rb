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

            tunnel_track_exits = tile.paths.flat_map { |p| p.track == :narrow ? p.exits : [] }
            super && tunnel_track_exits.none? { |edge| hex.neighbors[edge]&.tile&.color == :purple }
          end
        end
      end
    end
  end
end
