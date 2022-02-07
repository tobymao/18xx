# frozen_string_literal: true

module Engine
  module Game
    module G1894
      module Step
        class Track < Engine::Step::Track
          def legal_tile_rotation?(_entity, hex, tile)
            if hex.id == @game.class::PARIS_HEX && hex.tile.color == :green
              return true if tile.rotation == hex.tile.rotation
            else
              super
            end
          end

          def update_token!(_action, _entity, tile, old_tile)
            return if old_tile.id != @game.class::PARIS_HEX || !old_tile.paths.empty?

            token.move!(tile.cities[0])
            @game.graph.clear
          end
        end
      end
    end
  end
end
