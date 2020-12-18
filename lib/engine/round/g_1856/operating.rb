# frozen_string_literal: true

require_relative '../operating'
require_relative '../../step/route'

module Engine
  module Round
    module G1856
      class Operating < Operating
        attr_accessor :cash_crisis_player
        attr_reader :paid_interest, :took_loan, :redeemed_loan,
                    :interest_penalty, :player_interest_penalty,
                    :cash_crisis_due_to_interest, :cash_crisis_due_to_forced_repay

        def after_setup
          @paid_interest = {}
          @redeemed_loan = {}
          @took_loan = {}
          @interest_penalty = {}
          @player_interest_penalty = {}
          super
        end

        def after_process(_action)
          # Keep track of last_player for Cash Crisis
          entity = @entities[@entity_index]
          @cash_crisis_player = entity.player
          pay_interest!(entity)
          force_repay_loans!(entity)
          super
        end

        # nil if the entity doesn't need to pay off loans, # otherwise
        def must_payoff?(entity)
          loans_to_repay = entity.loans.size - @game.maximum_loans(entity)
          loans_to_repay.positive? ? loans_to_repay : nil
        end

        def force_repay_loans!(entity)
          @cash_crisis_due_to_forced_repay = nil
          return unless @steps.any? { |step| step.passed? && step.is_a?(Step::BuyTrain) } && must_payoff?(entity)

          bank = @game.bank
          loans_to_payoff = must_payoff?(entity)
          owed = 100 * loans_to_payoff
          owed_fmt = @game.format_currency(owed)
          @log << "#{entity.name} must repay #{must_payoff?(entity)} loans and owes #{owed_fmt}"

          # TODO: In the weird edge case where someone goes bankrupt in a cash crisis over this, are the loans
          # redeemed at the time of end game value? If so, how many?
          # See: https://github.com/tobymao/18xx/issues/2707
          @game.loans << entity.loans.pop(loans_to_payoff)
          @redeemed_loan[entity] = true

          payment = [owed, entity.cash].min
          payment_fmt = @game.format_currency(payment)
          entity.spend(payment, bank) if payment.positive?
          owed -= payment
          @log << "#{entity.name} pays #{payment_fmt} to redeem loans"
          return unless owed.positive?

          owed_fmt = @game.format_currency(owed)
          @log << "#{entity.name} cannot pay remaining #{owed_fmt} in loans and president must cover the difference"
          @cash_crisis_due_to_forced_repay = entity
          entity.owner.spend(owed, bank, check_cash: false)
        end

        def pay_interest!(entity)
          @cash_crisis_due_to_interest = nil
          return if @paid_interest[entity]
          return unless @steps.any? { |step| step.passed? && step.is_a?(Step::Route) }

          # Log interest owed now so that if no interest is owed it is clear
          # why a corporation only gets $90 when taking a loan after this
          bank = @game.bank
          owed = @game.interest_owed(entity)
          owed_fmt = owed.positive? ? @game.format_currency(owed) : 'no'
          interest_desc = entity.loans.size.positive? ? " for #{entity.loans.size} loans" : ''
          @log << "#{entity.name} owes #{owed_fmt} interest#{interest_desc}"

          @paid_interest[entity] = true
          return if entity.loans.empty?

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
            interest_penalty[entity] = routes_deduction
          end
          return unless owed.positive?

          player_interest_penalty[entity] = owed
          owed_fmt = @game.format_currency(owed)
          @log << "#{entity.name} cannot afford remaining #{owed_fmt} interest and president must cover the difference"
          @cash_crisis_due_to_interest = entity
          entity.owner.spend(owed, bank, check_cash: false)
        end
      end
    end
  end
end
