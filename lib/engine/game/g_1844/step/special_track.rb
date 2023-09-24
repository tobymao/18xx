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
            super
            return unless @game.tunnel_companies.include?(action.entity)

            action.tile.hex.assign!(action.entity.id)
          end

          def potential_tile_colors(entity, _hex)
            return super unless @game.tunnel_companies.include?(entity)

            [:purple]
          end

          def legal_tile_rotation?(entity, hex, tile)
            return super unless @game.tunnel_companies.include?(entity)

            super &&
              tile.exits.none? { |edge| hex.neighbors[edge].tile.color == :purple }
          end
        end
      end
    end
  end
end
