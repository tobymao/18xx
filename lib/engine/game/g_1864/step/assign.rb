# frozen_string_literal: true

require_relative '../../../step/assign'

module Engine
  module Game
    module G1864
      module Step
        class Assign < Engine::Step::Assign
          def process_assign(action)
            company = action.entity
            hex = action.target
            ability = @game.abilities(company, :assign_hexes)
            if !ability || !station_hexes(company).include?(hex)
              raise GameError, "#{company.name} can only be placed in one of #{company.owner.name}'s stations"
            end

            city = hex.tile.cities.find { |c| c.tokened_by?(company.owner) }
            @game.place_local_contract!(company, city)
            ability.use!
            @log << "#{company.name} is placed in #{hex.location_name || hex.name}"
          end

          def available_hex(entity, hex)
            entity.company? && !!@game.abilities(entity, :assign_hexes) && station_hexes(entity).include?(hex)
          end

          private

          def station_hexes(company)
            company.owner.tokens.select(&:used).map { |token| token.city.hex }
          end
        end
      end
    end
  end
end
