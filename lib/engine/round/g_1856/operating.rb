# frozen_string_literal: true

require_relative '../operating'
require_relative '../../step/route'

module Engine
  module Round
    module G1856
      class Operating < Operating
        attr_accessor :cash_crisis_player
        attr_reader :paid_loans

        def after_setup
          @paid_loans = {}
          super
        end

        def after_process(_action)
          # Keep track of last_player for Cash Crisis
          entity = @entities[@entity_index]
          @cash_crisis_player = entity.player
          pay_interest!(entity)
          super
        end

        def pay_interest!(entity)
          @cash_crisis_due_to_interest = nil
          return if @paid_loans[entity]
          return unless @steps.any? { |step| step.passed? && step.is_a?(Step::Route) }

          @paid_loans[entity] = true
          return if entity.loans.empty?

          bank = @game.bank
          owed = @game.interest_owed(entity)
          owed_fmt = @game.format_currency(owed)
          @log << "#{entity.name} owes #{owed_fmt} interest for #{entity.loans.size} loans"
          # Pay as much interest as possible from treasury in multiples of 10
          payment = [owed, entity.cash - (entity.cash % 10)].min
          if payment.positive?
            owed -= payment
            payment_fmt = @game.format_currency(payment)
            entity.spend(payment, bank)
            @log << "#{entity.name} pays #{payment_fmt} interest"
          end
          return unless owed.positive?

          owed_fmt = @game.format_currency(owed)
          @log << "#{entity.name} still owes #{owed_fmt} interest"

          # Deduct from routes
          routes = @routes
          routes_revenue = @game.routes_revenue(routes)
          routes_deduction = [owed, routes_revenue].min
          if routes_deduction.positive?
            owed -= routes_deduction
            routes_deduction_fmt = @game.format_currency(routes_deduction)
            @log << "#{entity.name} deducts #{routes_deduction_fmt} from its run"
          end
          return unless owed > 0

          owed_fmt = @game.format_currency(owed)
          @log << "#{entity.name} cannot afford remaining #{owed_fmt} interest and president must cover the difference"
          entity.owner.spend(owed, bank, check_cash: false)
          @cash_crisis_due_to_interest = entity
        end
      end
    end
  end
end
