# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module G18USA
      module Step
        class HomeToken < Engine::Step::HomeToken
          def process_place_token(action)
            # If the corporation's location has a subsidy add it
            corporation = token.corporation
            hex = action.city.hex
            subsidy = @game.subsidies_by_hex.delete(hex.coordinates)
            if subsidy
              action.city.hex.tile.icons.reject! { |icon| icon.name.include?('subsidy') }
              subsidy_company = @game.create_company_from_subsidy(subsidy)
              assign_boomtown_subsidy(hex, corporation) if subsidy_company.id == 'S8'
              subsidy_company.owner = corporation
              corporation.companies << subsidy_company
            end
            super
          end

          def assign_boomtown_subsidy(hex, corporation)
            subsidy = @game.company_by_id('S8')
            subsidy.all_abilities.each do |ability|
              ability.hexes << hex.id if ability.type == :tile_lay
              ability.corporation = corporation.id if ability.type == :close
            end
          end
        end
      end
    end
  end
end
