# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G18RoyalGorge
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def actions(entity)
            return [] unless entity.owner == current_entity

            super
          end

          def legal_tile_rotation?(entity, hex, tile)
            if entity == @game.sulphur_springs &&
               hex.id == @game.class::SULPHUR_SPRINGS_HEX &&
               %w[RG1 RG2 RG3].include?(tile.name)

              return hex.tile.color == tile.color && tile.rotation.zero?
            end

            super
          end
        end
      end
    end
  end
end
