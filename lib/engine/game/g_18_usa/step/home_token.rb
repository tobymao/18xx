# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module G18USA
      module Step
        class HomeToken < Engine::Step::HomeToken
          def generate_subsidy_company(subsidy)
            Engine::Company.new({
                                  sym: subsidy['id'],
                                  name: subsidy['name'],
                                  desc: subsidy['desc'],
                                  value: subsidy['value'] || 0,
                                })
          end

          def process_place_token(action)
            # If the corporation's location has a subsidy add it
            corporation = token.corporation
            subsidy = @game.subsidies_by_hex.delete(action.city.hex.coordinates)
            if subsidy
              action.city.hex.tile.icons.reject! { |icon| icon.name.include?('subsidy') }
              subsidy_company = generate_subsidy_company(subsidy)
              subsidy_company.owner = corporation
              corporation.companies << subsidy_company
            end
            super
          end
        end
      end
    end
  end
end
