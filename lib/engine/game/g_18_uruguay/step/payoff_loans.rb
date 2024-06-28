# frozen_string_literal: true

require_relative '../../../step/assign'
require_relative '../../../step/base'

module Engine
  module Game
    module G18Uruguay
      module Step
        class PayoffLoans < Engine::Step::Base
          def setup
            loans_to_pay_off = [(current_entity.cash / 100).floor, current_entity&.loans&.size].min
            @game.payoff_loan(current_entity, loans_to_pay_off, current_entity) if loans_to_pay_off.positive?
          end

          def log_skip(entity)
            return if entity == @game.fce
            return unless @game.round.round_num == 1
            return if !entity.corporation? || entity != current_entity
            return if entity == @game.rptla
            return unless entity.loans.size.positive?

            super
          end

          def pass_description
            'Skip payoff loans'
          end

          def description
            'Payoff Loans'
          end

          def actions(entity)
            return [] if entity == @game.fce
            return [] unless @game.round.round_num == 1
            return [] if !entity.corporation? || entity != current_entity
            return [] if entity == @game.rptla
            return [] unless entity.loans.size.positive?
            return [] if entity.owner.cash < @game.class::LOAN_VALUE

            actions = []
            actions << 'pass' if blocks?
            actions << 'choose'
            actions
          end

          def blocks?
            true
          end

          def choice_name
            'Payoff loans (Player cash: ' + @game.format_currency(current_entity.owner.cash) + ')'
          end

          def choosing?(entity)
            entity.loans.size.positive?
          end

          def choices
            choices_array = {}
            cash = current_entity&.owner&.cash
            current_entity&.loans&.size&.times do |i|
              return choices_array if cash < (i + 1) * 100

              choices_array[i + 1] = "Payoff #{i + 1} loan" if i.zero?
              choices_array[i + 1] = "Payoff #{i + 1} loans" if i.positive?
            end
            choices_array
          end

          def process_choose(action)
            entity = action.entity
            @game.payoff_loan(entity, action.choice.to_i, current_entity.owner)
            @game.adjust_stock_market_loan_penalty(entity)
            pass!
          end
        end
      end
    end
  end
end
