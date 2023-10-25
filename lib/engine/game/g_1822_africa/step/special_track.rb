# frozen_string_literal: true

require_relative '../../g_1822/step/special_track'

module Engine
  module Game
    module G1822Africa
      module Step
        class SpecialTrack < G1822::Step::SpecialTrack
          def available_hex(entity_or_entities, hex)
            entities = Array(entity_or_entities)

            # check for P5 (Add Town)
            return nil if entities.any? { |e| @game.must_add_town?(e) } && (!hex.tile.towns.empty? || !hex.tile.cities.empty?)

            super
          end

          def legal_tile_rotation?(entity_or_entities, hex, tile)
            entities = Array(entity_or_entities)
            entity, *_combo_entities = entities

            # check for P5 (Add Town)
            return legal_tile_rotation_remove_town?(entity.owner, hex, tile) if entities.any? { |e| @game.must_add_town?(e) }

            super
          end
        end
      end
    end
  end
end
