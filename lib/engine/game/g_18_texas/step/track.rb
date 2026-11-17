# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18Texas
      module Step
        class Track < Engine::Step::Track
          def process_lay_tile(action)
            super

            check_remove_tile_ability!(action)
          end

          def check_remove_tile_ability!(action)
            return unless action.tile.name == '511'
            return unless (company_id = @game.class::TELEPORT_COMPANY_BY_HEX[action.hex.id])
            return unless (company = @game.company_by_id(company_id))
            return unless (ability = company.all_abilities.find { |a| a.type == :tile_lay })

            company.remove_ability(ability)
            @log << "#{company.name} loses its tile lay ability, as #{action.hex.name} is already upgraded to green"
          end
        end
      end
    end
  end
end
