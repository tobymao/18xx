# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/corporation'
require 'view/game/buy_value_input'

module View
  module Game
    class BuyCorporation < Snabberb::Component
      include Actionable
      needs :selected_corporation, default: nil, store: true
      needs :show_other_players, default: nil, store: true

      def render
        @step = @game.active_step
        @corporation = @game.current_entity
        children = []

        children << h(:h3, @step.buyable_text(@corporation)) if @step.respond_to?(:buyable_text)

        hidden_corps = false
        @show_other_players = true if @step.show_other_players
        @step.buyable_entities(@corporation).each do |target|
          if @show_other_players || target.owner == @corporation.owner || !target.owner
            children << h(Corporation, corporation: target, selected_corporation: @selected_corporation)
            children << render_input if target == @selected_corporation
          else
            hidden_corps = true
          end
        end

        if hidden_corps
          children << h('button',
                        { on: { click: -> { store(:show_other_players, true) } } },
                        "Show #{@step.buyable_types} from other players")
        elsif @show_other_players
          children << h('button',
                        { on: { click: -> { store(:show_other_players, false) } } },
                        "Hide #{@step.buyable_types} from other players")
        end

        h(:div, children)
      end

      def render_input
        min_price, max_price = @step.price_range(@corporation, @selected_corporation)

        h(BuyValueInput, value: @step.buy_value(@selected_corporation), min_value: min_price,
                         max_value: max_price,
                         size: max_price,
                         selected_entity: @selected_corporation)
      end
    end
  end
end
