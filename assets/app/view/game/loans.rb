# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class Loans < Snabberb::Component
      include Actionable

      needs :corporation

      def render
        actions = @game.round.actions_for(@corporation)
        children = []
        step = @game.round.active_step

        if actions.include?('payoff_loan')
          payoff_loan_button_text = step.respond_to?(:payoff_loan_button_text) ? step.payoff_loan_button_text : 'Payoff Loan'
          children <<
          h(:button, {
              on: {
                click: lambda do
                  process_action(Engine::Action::PayoffLoan.new(@corporation, loan: @corporation.loans[0]))
                end,
              },
            },
            payoff_loan_button_text,)
        end

        if actions.include?('take_loan')
          take_loan_button_text = step.respond_to?(:take_loan_button_text) ? step.take_loan_button_text : 'Take Loan'
          children << h(:button, {
                          on: {
                            click: lambda do
                                     process_action(Engine::Action::TakeLoan.new(@corporation, loan: @game.loans[0]))
                                   end,
                          },
                        },
                        take_loan_button_text,)
        end

        h(:div, children)
      end
    end
  end
end
