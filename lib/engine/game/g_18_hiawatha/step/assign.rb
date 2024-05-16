# frozen_string_literal: true

require_relative '../../../step/assign'

module Engine
  module Game
    module G18Hiawatha
      module Step
        class Assign < Engine::Step::Assign
          def process_assign(action)
            company = action.entity
            target = action.target
            owner = action.entity.owner

            unless (ability = @game.abilities(company, :assign_hexes))
              raise GameError,
                    "Could not assign #{company.name} to #{target.name}; :assign_hexes ability not found"
            end

            case company.id
            # Assign Great Lakes Shipping company to hex
            when 'GLS'
              target.assign!(company.id)
              ability.use!
              @log << "#{company.name} increases value of #{target.name} by #{@game.format_currency(10)} for all corporations."
            # Assign Freight Company to hex
            when 'FC'
              target.assign!(company.id)
              owner.assign!(company.id)
              ability.use!
              @log << "#{company.name} increases value of #{target.name} by #{@game.format_currency(10)} "\
                      "for #{company.owner.name}."
            end
          end
        end
      end
    end
  end
end
