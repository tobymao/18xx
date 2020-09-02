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

        if actions.include?('take_loan')
          children << h(
            :button,
            { on: { click: lambda do
              process_action(Engine::Action::TakeLoan.new(@corporation, loan: @game.loans[0]))
            end } },
            'Take Loan',
          )
        end

        if actions.include?('payoff_loan')
          children << h(
            :button,
            { on: { click: lambda do
              process_action(Engine::Action::PayoffLoan.new(@corporation, loan: @corporation.loans[0]))
            end } },
            'Payoff Loan',
          )
        end

        h(:div, children)
      end
    end
  end
end
