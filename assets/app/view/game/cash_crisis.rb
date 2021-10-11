# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/emergency_money'

module View
  module Game
    class CashCrisis < Snabberb::Component
      include Actionable
      include EmergencyMoney
      needs :selected_corporation, default: nil, store: true

      def render
        player = @game.round.active_step.current_entity

        children = []

        funds_required = @game.round.active_step.needed_cash(player)
        children << h('div',
                      "Player owes the bank #{@game.format_currency(funds_required)} and must sell shares if possible.")

        children.concat(render_emergency_money_raising(player))

        h(:div, children)
      end
    end
  end
end
