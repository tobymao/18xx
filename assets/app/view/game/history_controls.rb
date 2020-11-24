# frozen_string_literal: true

require 'lib/params'
require 'view/link'
require 'view/game/actionable'

module View
  module Game
    class HistoryControls < Snabberb::Component
      include Actionable
      needs :num_actions, default: 0
      needs :game, store: true
      needs :round_history, default: nil, store: true

      def render
        return h(:div) if @num_actions.zero?

        divs = [h('b.margined', 'History')]
        cursor = Lib::Params['action']&.to_i
        style_extra = { marginRight: '2rem' }

        unless cursor&.zero?
          divs << link('|<', 'Start', 0, style_extra)

          last_round =
            if cursor == @game.actions.size
              @game.round_history[-2]
            else
              @game.round_history[-1]
            end
          divs << link('<<', 'Previous Round', last_round, style_extra) if last_round

          divs << link('<', 'Previous Action', cursor ? cursor - 1 : @num_actions - 1, style_extra)
        end

        if cursor
          divs << link('>', 'Next Action', cursor + 1 < @num_actions ? cursor + 1 : nil, style_extra)
          store(:round_history, @game.round_history, skip: true) unless @round_history
          next_round = @round_history[@game.round_history.size]
          divs << link('>>', 'Next Round', next_round, style_extra) if next_round
          divs << link('>|', 'Current', nil, style_extra)
        end

        h(:div, divs)
      end
    end
  end
end
