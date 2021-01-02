# frozen_string_literal: true

require 'view/game/actionable'
require 'lib/settings'

module View
  module Game
    class GameLog < Snabberb::Component
      include Actionable
      include Lib::Settings

      needs :user
      needs :negative_pad, default: false
      needs :follow_scroll, default: true, store: true
      needs :action_id, default: nil, store: true

      def render
        children = [log]

        @player = @game.player_by_id(@user['id']) if @user

        enter = lambda do |event|
          event = Native(event)
          code = event['keyCode']

          if code && code == 13
            message = event['target']['value']
            if message.strip != ''
              event['target']['value'] = ''
              sender = @player || Engine::Player.new(@game_data['user']['id'], @game_data['user']['name'])
              process_action(Engine::Action::Message.new(sender, message: message))
            end
          end
        end

        if participant?
          children << h(:div, { style: {
            margin: '1vmin 0',
            display: 'flex',
            flexDirection: 'row',
          } }, [
            h(:span, { style: {
              fontWeight: 'bold',
              margin: 'auto 0',
            } }, [@user['name'] + ':']),
            h(:input,
              style: {
              marginLeft: '0.5rem',
              flex: '1',
            },
              on: { keyup: enter }),
            ])
        end

        props = {
          style: {
            display: 'inline-block',
            width: '100%',
          },
        }

        h(:div, props, children)
      end

      def log
        scroll_to_bottom = lambda do |vnode|
          next unless @follow_scroll

          elm = Native(vnode)['elm']
          elm.scrollTop = elm.scrollHeight
        end

        scroll_handler = lambda do |event|
          elm = Native(event).target
          bottom = elm.scrollHeight - elm.scrollTop <= elm.clientHeight + 5
          store(:follow_scroll, bottom, skip: true) if @follow_scroll != bottom
        end

        props = {
          key: 'log',
          hook: {
            postpatch: ->(_, vnode) { scroll_to_bottom.call(vnode) },
            insert: ->(vnode) { scroll_to_bottom.call(vnode) },
            destroy: -> { store(:follow_scroll, true, skip: true) },
          },
          on: { scroll: scroll_handler },
          style: {
            overflow: 'auto',
            padding: '0.5rem',
            backgroundColor: color_for(:bg2),
            color: color_for(:font2),
            wordBreak: 'break-word',
          },
        }

        if @negative_pad
          props[:style][:padding] = '0.5rem 2vmin'
          props[:style][:margin] = '0 -2vmin'
        else
          props[:style][:boxSizing] = 'border-box'
        end

        messages = @game.log.group_by(&:action).flat_map do |action_id, entries|
          has_game_action = false
          group = entries.map do |entry|
            line_props = { style: { marginTop: '0.5em',
                                    marginBottom: '0.2rem',
                                    paddingLeft: '0.5rem',
                                    textIndent: '-0.5rem' },
                           on: { click: -> { store(:action_id, action_id) } } }

            line = entry.message
            if line.is_a?(String)
              has_game_action = true
              line_props[:style][:fontWeight] = 'bold' if line.start_with?('--')
              h(:div, line_props, line)
            elsif line.is_a?(Engine::Action::Message)
              sender = line.entity.name || line.user
              h(:div, { style: { fontWeight: 'bold' } }, "#{sender}: #{line.message}")
            end
          end

          group << action_buttons if has_game_action && @action_id == action_id && @game.last_game_action != action_id
          group
        end

        h('div#chatlog', props, messages)
      end

      def action_buttons
        rewind_action = lambda do
          process_action(Engine::Action::Undo.new(@game.current_entity, action_id: @action_id))
          store(:action_id, nil, skip: true)
        end

        h(:div, [history_link('Review from Here', '', @action_id, {}, true),
                 h(:button, { on: { click: rewind_action } }, 'Rewind to Here')])
      end
    end
  end
end
