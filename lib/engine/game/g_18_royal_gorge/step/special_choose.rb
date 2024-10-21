# frozen_string_literal: true

require_relative '../../../step/special_choose'

module Engine
  module Game
    module G18RoyalGorge
      module Step
        class SpecialChoose < Engine::Step::SpecialChoose
          def actions(entity)
            if @game.indebted.include?(entity) ||
               (entity.company? && %w[RG-D SF-D].include?(entity.sym))
              super
            else
              []
            end
          end

          def process_choose_ability(action)
            return unless action.choice == 'pay_debt'

            debt_company = action.entity
            corporation = debt_company.owner

            ability = Array(abilities(corporation)).find { |a| a.description == 'Pay debt' }
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

            return unless debt_company == @game.sf_debt
            return unless (doc = @game.doc_holliday)

            @log << "#{doc.name} closes"
            doc.close!
          end
        end
      end
    end
  end
end
