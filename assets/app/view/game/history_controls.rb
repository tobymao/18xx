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

        divs = [h(:h3, { style: { margin: '0', justifySelf: 'left' } }, 'History')]
        cursor = Lib::Params['action']&.to_i
        style_extra = { padding: '0.2rem 0.5rem', width: '100%' }

        unless cursor&.zero?
          divs << history_link('|<', 'Start', 0, style_extra, true, 'Home')

          last_round =
            if cursor == @game.raw_actions.size
              @game.round_history[-2]
            else
              @game.round_history[-1]
            end
          if last_round
            divs << history_link('<<', 'Previous Round', last_round,
                                 { gridColumnStart: '3', **style_extra }, true, 'ArrowUp')
          end

          prev_action =
            if @game.exception
              @game.last_processed_action
            else
              @game.previous_action_id_from(@game.last_game_action_id)
            end
          divs << history_link('<', 'Previous Action', prev_action,
                               { gridColumnStart: '4', **style_extra }, true, 'ArrowLeft')
        end

        if cursor && !@game.exception
          divs << history_link('>', 'Next Action', @game.next_action_id_from(@game.last_game_action_id),
                               { gridColumnStart: '5', **style_extra }, true, 'ArrowRight')
          store(:round_history, @game.round_history, skip: true) unless @round_history
          next_round = @round_history[@game.round_history.size]
          if next_round
            divs << history_link('>>', 'Next Round', next_round,
                                 { gridColumnStart: '6', **style_extra }, true, 'ArrowDown')
          end
          divs << history_link('>|', 'Current Action', nil, { gridColumnStart: '7', **style_extra }, true, 'End')
        end

        props = {
          style: {
            display: 'grid',
            grid: '1fr / 4.2rem repeat(6, minmax(2rem, 2.5rem))',
            justifyItems: 'center',
            gap: '0 0.5rem',
          },
        }

        h(:div, props, divs)
      end
    end
  end
end
