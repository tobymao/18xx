# frozen_string_literal: true

require_relative '../../../step/acquire_company'

module Engine
  module Game
    module G1822PNW
      module Step
        class Assign < Engine::Step::Assign
          def available_hex(entity, hex)
            return super unless @game.mill_company?(entity)
            return false unless @game.abilities(entity, :assign_hexes).hexes.include?(hex.id)

            hex.tile.exits.each do |e|
              neighbor = hex.neighbors[e]
              return true if neighbor.tile.exits.include?((e + 3) % 6) && neighbor.assigned?('forest')
            end
            false
          end
        end
      end
    end
  end
end
