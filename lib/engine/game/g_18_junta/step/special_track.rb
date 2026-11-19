# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G18Junta
      module Step
        # Rules summary 11 (F): the extra lay of Ingeniería Real is a yellow tile on an empty hex. Like
        # any first tile in a paramilitary hex, it starts the choice of side (6.2).
        class SpecialTrack < Engine::Step::SpecialTrack
          def potential_tiles(entity_or_entities, hex)
            tiles = super
            return tiles unless private_f?(Array(entity_or_entities).first)
            return [] unless hex.tile.color == :white

            tiles.select { |tile| tile.color == :yellow }
          end

          def process_lay_tile(action)
            entity = action.entity
            if private_f?(entity) && (action.hex.tile.color != :white || action.tile.color != :yellow)
              raise GameError, "#{entity.name} can only lay a yellow tile on an empty hex"
            end

            super
            corporation = entity.company? ? entity.owner : entity
            @game.claim_paramilitary_hex!(action.hex, corporation) if @game.paramilitary_hex_unclaimed?(action.hex)
          end

          private

          def private_f?(entity)
            entity&.company? && entity.sym == '(F)'
          end
        end
      end
    end
  end
end
