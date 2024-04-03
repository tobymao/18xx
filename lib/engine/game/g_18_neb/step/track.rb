# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18Neb
      module Step
        class Track < Engine::Step::Track
          def legal_tile_rotation?(entity, hex, tile)
            old_tile = hex.tile
            if @game.town_to_city_upgrade?(old_tile, tile) || @game.omaha_green_upgrade?(old_tile, tile)
              return (old_tile.exits & tile.exits) == old_tile.exits
            end

            super
          end

          # Prevent terrain discounts from being applied implicitly.
          def border_cost_discount(_entity, _spender, _border, _cost, _hex)
            0
          end

          def pay_all_tile_income(company, ability)
            income = ability.income
            @game.bank.spend(income, company.owner)
            @log << "#{company.owner.name} (#{company.name}) receives #{@game.format_currency(income)} for the "\
                    'tile lay'
          end
        end
      end
    end
  end
end
