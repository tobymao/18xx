# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module G18USA
      module Step
        class HomeToken < Engine::Step::HomeToken
          def round_state
            super.merge(
              {
                needed_city_subsidy: 0,
              }
            )
          end

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
            @round.needed_city_subsidy = 0
            super
          end

          def assign_boomtown_subsidy(hex, corporation)
            subsidy = @game.company_by_id('S8')
            subsidy.all_abilities.each do |ability|
              ability.hexes << hex.id if ability.type == :tile_lay
              ability.corporation = corporation.id if ability.type == :close
            end
          end

          def available_hex(_entity, hex)
            return false unless super
            return true if @round.needed_city_subsidy.zero?

            city_subsidy = (subsidy = @game.subsidies_by_hex[hex.coordinates]) ? subsidy[:value] : 0
            city_subsidy >= @round.needed_city_subsidy
          end
        end
      end
    end
  end
end
