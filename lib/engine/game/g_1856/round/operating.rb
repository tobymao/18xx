# frozen_string_literal: true

require_relative '../../../round/operating'
require_relative '../../../step/route'

module Engine
  module Game
    module G1856
      module Round
        class Operating < Engine::Round::Operating
          attr_accessor :cash_crisis_player, :wsrc_activated
          attr_reader :paid_interest, :took_loan, :redeemed_loan,
                      :interest_penalty, :player_interest_penalty,
                      :cash_crisis_due_to_interest, :cash_crisis_due_to_forced_repay,
                      :after_track

          def after_setup
            @paid_interest = {}
            @after_track = {}
            @redeemed_loan = {}
            @took_loan = {}
            @interest_penalty = {}
            @player_interest_penalty = {}
            @wsrc_activated = false
            super
          end

          def finished?
            finished = super
            if @wsrc_activated && finished
              @game.log << "#{@game.wsrc.name} closes"
              @game.wsrc.close!
              @wsrc_activated = false
            end
            finished
          end

          def start_operating
            corporation = @entities[@entity_index]
            if !corporation.floated? && corporation.floatable?
              @log << "#{corporation.name} floats"
              corporation.float!
            end
            unless corporation.floated?
              @log << "#{corporation.name} failed to float and is skipped"
              return force_next_entity!
            end
            super
          end

          def after_process_before_skip(_action)
            # Keep track of last_player for Cash Crisis
            entity = @entities[@entity_index]
            @cash_crisis_player = entity.player
            pay_interest!(entity)
            after_track[entity] = true if step_passed?(G1856::Step::Track)
            force_repay_loans!(entity)
            super
          end

          def skip_steps
            # We must be careful not to skip through Dividends because the game can end between Route and Dividends
            super unless @cash_crisis_player&.cash&.negative? || @game.bankrupted
          end

          def force_repay_loans!(entity)
            loans_to_payoff = entity.loans.size - @game.maximum_loans(entity)
            @cash_crisis_due_to_forced_repay = nil
            return unless step_passed?(Engine::Step::BuyTrain) && loans_to_payoff.positive?

            bank = @game.bank
            owed = 100 * loans_to_payoff
            owed_fmt = @game.format_currency(owed)
            loans_fmt = loans_to_payoff == 1 ? 'loan' : 'loans'
            @log << "#{entity.name} must repay #{loans_to_payoff} #{loans_fmt} and owes #{owed_fmt}"

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
            return unless step_passed?(Engine::Step::Route)

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
            @log << "#{entity.name} cannot afford remaining "\
                    "#{owed_fmt} interest and president must cover the difference"
            @cash_crisis_due_to_interest = entity
            entity.owner.spend(owed, bank, check_cash: false)
          end
        end
      end
    end
  end
end
