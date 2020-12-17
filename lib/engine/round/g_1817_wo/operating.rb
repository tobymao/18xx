# frozen_string_literal: true

require_relative '../g_1817/operating'

module Engine
  module Round
    module G1817WO
      class Operating < G1817::Operating
        def pay_interest!(entity)
          @cash_crisis_due_to_interest = nil
          return if @paid_loans[entity]

          return unless @steps.any? { |step| step.passed? && step.is_a?(Step::BuyTrain) }

          @paid_loans[entity] = true
          return if entity.loans.empty? && !@game.corp_has_new_zealand?(entity)

          bank = @game.bank
          return unless (owed = @game.pay_interest!(entity))

          owed_fmt = @game.format_currency(owed)

          owner = entity.owner
          @game.liquidate!(entity)
          transferred = ''

          if entity.cash.positive?
            transferred = ", transferring #{@game.format_currency(entity.cash)} to #{owner.name}"
            entity.spend(entity.cash, owner)
          end
          @log << "#{entity.name} cannot afford #{owed_fmt} interest and goes into liquidation#{transferred}"

          owner.spend(owed, bank, check_cash: false)
          @cash_crisis_due_to_interest = entity
          @log << "#{owner.name} pays #{owed_fmt} interest for #{entity.loans.size} loans"
        end
      end
    end
  end
end
