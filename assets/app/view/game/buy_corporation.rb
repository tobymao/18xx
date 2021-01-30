# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/corporation'

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

        hidden_corps = false
        @show_other_players = true if @step.show_other_players
        @game.corporations.select { |item| @step.can_buy?(@corporation, item) }.each do |target|
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
                        'Show corporations from other players')
        elsif @show_other_players
          children << h('button',
                        { on: { click: -> { store(:show_other_players, false) } } },
                        'Hide corporations from other players')
        end

        h(:div, children)
      end

      def render_input
        max_price = (@selected_corporation.share_price.price * 1.5).ceil
        min_price = (@selected_corporation.share_price.price * 0.5).ceil
        input = h(:input, style: { marginRight: '1rem' }, props: {
                    value: @selected_corporation.share_price.price,
                    type: 'number',
                    min: min_price,
                    max: max_price,
                    size: max_price,
                  })

        buy_click = lambda do
          price = input.JS['elm'].JS['value'].to_i
          buy = lambda do
            process_action(Engine::Action::BuyCorporation.new(
              @corporation,
              corporation: @selected_corporation,
              price: price,
            ))
            store(:selected_corporation, nil, skip: true)
          end

          if @selected_corporation.owner == @corporation.owner
            buy.call
          else
            check_consent(@selected_corporation.owner, buy)
          end
        end

        props = {
          style: {
            textAlign: 'center',
            margin: '1rem',
          },
        }

        h(:div, props, [
          input,
          h(:button, { on: { click: buy_click } }, 'Buy'),
        ])
      end
    end
  end
end
