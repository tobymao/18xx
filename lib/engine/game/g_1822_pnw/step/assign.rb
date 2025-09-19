# frozen_string_literal: true

require_relative '../../../step/acquire_company'

module Engine
  module Game
    module G1822PNW
      module Step
        class Assign < Engine::Step::Assign
          def process_assign(action)
            entity = action.entity
            if (hex = action.target).is_a?(Engine::Hex)
              if @game.mill_company?(entity)
                raise GameError, "Cannot place Paper Mill in Rockport Coal Mine hex #{hex.id}" if @game.coal_hex?(hex)
                raise GameError, "Cannot place Paper Mill in Ski Haus hex #{hex.id}" if @game.ski_hex?(hex)
              end
              if @game.ski_company?(entity)
                raise GameError, "Cannot place Ski Haus in Rockport Coal Mine hex #{hex.id}" if @game.coal_hex?(hex)
                raise GameError, "Cannot place Ski Haus in Paper Mill hex #{hex.id}" if @game.mill_hex?(hex)
              end
            end

            super
          end

          def available_hex(entity, hex)
            return available_hex_mill(entity, hex) if @game.mill_company?(entity)
            return available_hex_ski(entity, hex) if @game.ski_company?(entity)

            super
          end

          def available_hex_mill(entity, hex)
            return false if @game.coal_hex?(hex)
            return false if @game.ski_hex?(hex)

            return false unless @game.abilities(entity, :assign_hexes).hexes.include?(hex.id)

            hex.tile.exits.each do |e|
              neighbor = hex.neighbors[e]
              return true if neighbor.tile.exits.include?((e + 3) % 6) && neighbor.assigned?('forest')
            end
            false
          end

          def available_hex_ski(entity, hex)
            return false if @game.coal_hex?(hex)
            return false if @game.mill_hex?(hex)

            return unless @game.abilities(entity, :assign_hexes)&.hexes&.include?(hex.id)
            return if hex.assigned?(entity.id)

            @game.hex_by_id(hex.id).neighbors.keys
          end
        end
      end
    end
  end
end
