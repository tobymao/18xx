# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18PA
      module Step
        class Track < Engine::Step::Track
          def potential_tile_colors(entity, hex)
            colors = super
            entity.minor? ? colors & %i[yellow green] : colors
          end

          def tracker_available_hex(entity, hex)
            return if entity.minor? && terrain_cost?(hex)

            super
          end

          def legal_tile_rotation?(entity_or_entities, hex, tile)
            return false if Array(entity_or_entities).first.minor? && costly_track?(hex, tile.exits)

            super
          end

          def process_lay_tile(action)
            if action.entity.minor?
              hex = action.hex
              tile = action.tile
              unless potential_tile_colors(action.entity, hex).include?(tile.color)
                raise GameError, 'Private companies may only lay yellow track or upgrade to green when available'
              end

              exits = tile.exits.map { |edge| tile.rotate(edge, action.rotation - tile.rotation) }
              raise GameError, 'Private companies may only build track without a cost' if costly_track?(hex, exits)
            end

            super
          end

          private

          def terrain_cost?(hex)
            hex.tile.upgrades.any? { |upgrade| upgrade.cost.positive? }
          end

          def costly_track?(hex, exits)
            terrain_cost?(hex) || hex.tile.borders.any? do |border|
              neighbor = hex.neighbors[border.edge]
              border.cost&.positive? && exits.include?(border.edge) && neighbor&.targeting?(hex)
            end
          end
        end
      end
    end
  end
end
