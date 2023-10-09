# frozen_string_literal: true

require_relative '../../../step/assign'

module Engine
  module Game
    module G1822Africa
      module Step
        class Assign < Engine::Step::Assign
          def process_assign(action)
            corporation = action.entity.owner

            super

            bonus = @game.class::COFFEE_PLANTATION_PLACEMENT_BONUS
            @game.bank.spend(bonus, corporation)
            @game.log << "#{corporation.id} receives Coffee Plantation bonus of #{@game.format_currency(bonus)}"
          end

          def available_hex(entity, hex)
            return unless hex.tile.color == :white

            super
          end
        end
      end
    end
  end
end
