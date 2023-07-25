# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/emergency_money'
require 'view/game/loans'
require 'view/game/issue_shares'

module View
  module Game
    class CashCrisis < Snabberb::Component
      include Actionable
      include EmergencyMoney
      needs :selected_corporation, default: nil, store: true

      def render
        children = []
        funds_required = @game.round.active_step.needed_cash(entity)
        children << h('div.margined',
                      "#{entity.name} owes the bank #{@game.format_currency(funds_required)} and must raise cash if possible.")

        if entity.player?
          children.concat(render_emergency_money_raising(entity))
        elsif entity.corporation?
          children.concat(corporation_cash_crisis(entity, funds_required))
        end

        h(:div, children)
      end

      def corporation_cash_crisis(entity, funds_required)
        actions = @game.round.actions_for(entity)
        owner = entity.player
        owner_actions = @game.round.actions_for(owner)
        step = @game.round.active_step

        children = []

        if actions.include?('sell_shares')
          if step.respond_to?(:show_cash?) && step.show_cash?(entity)
            children << h('div.margined', "#{entity.name} has #{step.available_cash_str(entity)}")
          end

          bundle = step.issuable_shares(entity).max_by(&:price)
          issue_verb = step.respond_to?(:issue_verb) ? step.issue_verb(entity) : 'issue'
          issuable_cash = step.respond_to?(:issuable_cash) ? step.issuable_cash(entity) : bundle.price
          children << h('div.margined',
                        "#{entity.name} can #{issue_verb} shares to raise up to #{@game.format_currency(issuable_cash)}.")
        end
        if actions.include?('take_loan')
          num_loans = @game.num_emergency_loans(entity, funds_required)
          children << h('div.margined',
                        "#{entity.name} can take loans to raise #{@game.format_currency(@game.loan_value(entity) * num_loans)}.")
        end
        if president_may_contribute?(entity)
          owner_funds = step.respond_to?(:owner_funds) ? step.owner_funds(entity) : funds_required
          children << h('div.margined',
                        "#{owner.name} must contribute #{@game.format_currency(owner_funds)} to payoff #{entity.name}'s debt.")
          children << h('div.margined', "#{owner.name} has #{@game.format_currency(owner.cash)} in cash.")
          cash_in_stocks = @game.liquidity(owner, emergency: true) - owner.cash
          children << h('div.margined', "#{owner.name} has #{@game.format_currency(cash_in_stocks)} in sellable shares.")

          children << h(IssueShares, entity: entity) if actions.include?('sell_shares')
          children << h(Loans, corporation: entity) if actions.include?('take_loan')
          children << h('div.margined', [payoff_debt_button(owner)]) if owner_actions.include?('payoff_debt')
          children.concat(render_emergency_money_raising(owner)) if owner_actions.include?('sell_shares')
        end

        children
      end

      def president_may_contribute?(entity)
        step = @game.round.active_step
        step.respond_to?(:president_may_contribute?) ? step.president_may_contribute?(entity) : true
      end

      def payoff_debt_button(entity)
        contribute_cash = lambda do
          process_action(Engine::Action::PayoffDebt.new(entity))
        end
        h(:button, { on: { click: contribute_cash } }, 'Contribute Cash')
      end
    end
  end
end
