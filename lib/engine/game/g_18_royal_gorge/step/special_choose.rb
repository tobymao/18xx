# frozen_string_literal: true

require_relative '../../../step/special_choose'

module Engine
  module Game
    module G18RoyalGorge
      module Step
        class SpecialChoose < Engine::Step::SpecialChoose
          def process_choose_ability(action)
            return unless action.choice == 'pay_debt'

            debt_company = action.entity
            corporation = debt_company.owner

            ability = abilities(corporation)
            ability.use!

            debtor, = @game.indebted[corporation]

            amount = @game.debt_corp.share_price.price
            corporation.spend(amount, debtor)
            @log << "#{corporation.name} pays #{@game.format_currency(amount)} to #{debtor.name} for one DEBT token"

            @game.indebted[corporation][1] -= 1

            return unless @game.indebted[corporation][1].zero?

            @log << "#{corporation.name}'s DEBT is paid off."
            @game.indebted.delete(corporation)
            debt_company.close!
          end
        end
      end
    end
  end
end
