# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G18BF
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def process_lay_tile(action)
            super

            company = action.entity
            ability = @game.abilities(company, :tile_lay)
            company.remove_ability(ability) unless ability.laid_hexes.none?
          end
        end
      end
    end
  end
end
