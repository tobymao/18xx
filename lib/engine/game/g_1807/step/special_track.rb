# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G1807
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def actions(entity)
            ability = abilities(entity)
            return [] unless ability&.type == :tile_lay
            return [] if ability.hexes.none? { |coord| @game.hex_by_id(coord).tile.color == :white }

            ACTIONS_WITH_PASS
          end

          def process_lay_tile(action)
            super

            company = action.entity
            ability = @game.abilities(company, :tile_lay)
            company.remove_ability(ability) unless ability.laid_hexes.empty?
          end
        end
      end
    end
  end
end
