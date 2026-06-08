# frozen_string_literal: true

require 'lib/params'
require 'view/link'
require 'view/game/actionable'

module View
  module Game
    class HistoryControls < Snabberb::Component
      include Actionable
      needs :last_action_id, default: 0
      needs :game, store: true
      needs :round_history, default: nil, store: true

      def render
        return h(:div) if @last_action_id.zero?

        divs = [h(:h3, { style: { margin: '0', justifySelf: 'left' } }, 'History')]
        cursor = Lib::Params['action']&.to_i
        style_extra = { padding: '0.2rem 0.5rem', width: '100%' }

        unless cursor&.zero?
          divs << history_link('|<', 'Start', 0, style_extra, true, 'Home')
          if (last_round = cursor ? @game.round_history.reverse.find { |rh| rh < cursor } : @game.round_history[-1])
            divs << history_link('<<', 'Previous Round', last_round,
                                 { gridColumnStart: '3', **style_extra }, true, 'ArrowUp')
          end

          prev_action =
            if @game.exception
              @game.last_processed_action
            else
              @game.previous_action_id_from(cursor || @game.last_game_action_id)
            end
          divs << history_link('<', 'Previous Action', prev_action,
                               { gridColumnStart: '4', **style_extra }, true, 'ArrowLeft')
        end

        if cursor && !@game.exception
          next_action_id = @game.next_action_id_from(cursor)
          next_action_id = nil if @last_action_id == next_action_id
          divs << history_link('>', 'Next Action', next_action_id,
                               { gridColumnStart: '5', **style_extra }, true, 'ArrowRight')
          store(:round_history, @game.round_history, skip: true) unless @round_history
          if (next_round = @round_history.find { |rh| rh > cursor })
            divs << history_link('>>', 'Next Round', next_round,
                                 { gridColumnStart: '6', **style_extra }, true, 'ArrowDown')
          end
          divs << history_link('>|', 'Current Action', nil, { gridColumnStart: '7', **style_extra }, true, 'End')
        end

        if (ids = player_action_ids) && !ids.empty?
          current_pos = cursor || @game.last_game_action_id
          prev_id = ids.select { |id| id < current_pos }.last
          next_id = ids.find { |id| id > current_pos }
          link_style = { margin: '0', textDecoration: 'none', **style_extra }

          if prev_id
            prev_route = Lib::Params.add(@app_route, 'action', prev_id)
            divs << h(Link, {
              href: prev_route,
              click: lambda {
                store(:round_history, @game.round_history, skip: true) unless @round_history
                store(:app_route, prev_route)
                clear_ui_state
              },
              title: 'My previous action – hotkey: Shift+←',
              children: 'My <',
              style: { gridColumnStart: '8', **link_style },
              class: '#my_prev.button_link',
            })
          end

          if next_id
            next_route = Lib::Params.add(@app_route, 'action', next_id)
            divs << h(Link, {
              href: next_route,
              click: lambda {
                store(:round_history, @game.round_history, skip: true) unless @round_history
                store(:app_route, next_route)
                clear_ui_state
              },
              title: 'My next action – hotkey: Shift+→',
              children: 'My >',
              style: { gridColumnStart: '9', **link_style },
              class: '#my_next.button_link',
            })
          end
        end

        props = {
          style: {
            display: 'grid',
            grid: '1fr / 4.2rem repeat(8, minmax(2rem, 2.5rem))',
            justifyItems: 'center',
            gap: '0 0.5rem',
          },
        }

        h(:div, props, divs)
      end

      def player_for(entity)
        if entity&.player?
          entity
        elsif (owner = entity&.owner)
          owner.player? ? owner : player_for(owner)
        end
      end

      def player_action_ids
        return [] unless @user
        player = @game.player_by_id(@user['id'])
        return [] unless player

        @game.actions.filter_map { |action| action.id if player_for(action.entity) == player }
      end
    end
  end
end
