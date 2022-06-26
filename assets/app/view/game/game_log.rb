# frozen_string_literal: true

require 'view/game/actionable'
require 'lib/settings'

module View
  module Game
    class GameLog < Snabberb::Component
      include Actionable
      include Lib::Settings

      needs :user, default: nil
      needs :negative_pad, default: false
      needs :follow_scroll, default: true, store: true
      needs :selected_action_id, default: nil, store: true
      needs :limit, default: nil
      needs :scroll_pos, default: nil
      needs :chat_input, default: ''
      needs :show_chat, default: true, store: true
      needs :show_log, default: true, store: true

      def render
        children = [render_log_choices, render_log]

        @player = @game.player_by_id(@user['id']) if @user

        key_event = lambda do |event|
          event = Native(event)
          key = event['key']

          case key
          when 'Enter'
            message = event['target']['value']
            if message.strip != ''
              event['target']['value'] = ''
              sender = @player || Engine::Player.new(@game_data['user']['id'], @game_data['user']['name'])
              process_action(Engine::Action::Message.new(sender, message: message))
            end
          when 'Escape'
            `document.getElementById('game').focus()`
          end
        end

        prevent_default = lambda do |event|
          event = Native(event)
          event.preventDefault
        end

        if participant?
          children << h(:div, {
                          style: {
                            margin: '0 0 1vmin 0',
                            display: 'flex',
                            flexDirection: 'row',
                          },
                        }, [
            h(:span, {
                style: {
                  fontWeight: 'bold',
                  margin: 'auto 0',
                },
              }, [@user['name'] + ':']),
            h(:form, {
                style: { display: 'contents' },
                on: { submit: prevent_default },
              }, [
              h('input#chatbar',
                attrs: {
                  autocomplete: 'off',
                  title: 'hotkey: c – esc to leave',
                  type: 'text',
                  value: @chat_input,
                  placeholder: 'Use @player command to ping a player',
                },
                style: {
                  marginLeft: '0.5rem',
                  flex: '1',
                  cursor: 'text',
                },
                on: { keyup: key_event }),
              ]),
            ])
        end

        props = {
          style: {
            cursor: 'pointer',
            display: 'inline-block',
            width: '100%',
          },
        }

        h(:div, props, children)
      end

      def render_log
        # Create a fake action zero, so special handling isn't required throughout
        blank_action = Engine::Action::Base.new(@game.players.first)
        blank_action.id = 0
        blank_action.created_at = @game.actions[0]&.created_at || Time.now

        last_action = nil

        actions = @game.actions.to_h { |a| [a.id, a] }

        log = @limit ? @game.log.last(@limit) : @game.log
        the_log = log.group_by(&:action_id).flat_map do |action_id, entries|
          children = []
          action = actions[action_id] || blank_action

          if !last_action || Time.at(action.created_at).yday != Time.at(last_action.created_at).yday
            children << render_date_banner(action.created_at)
          end
          last_action = action

          children << render_log_for_action(entries, action)
          children
        end

        scroll_to_bottom = lambda do |vnode|
          next unless @follow_scroll

          elm = Native(vnode)['elm']
          elm.scrollTop = elm.scrollHeight
        end

        scroll_to_pos = lambda do |vnode|
          Native(vnode)['elm'].scrollTop = @scroll_pos
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
            insert: ->(vnode) { @scroll_pos ? scroll_to_pos.call(vnode) : scroll_to_bottom.call(vnode) },
            destroy: -> { store(:follow_scroll, true, skip: true) },
          },
          on: { scroll: scroll_handler },
          style: {
            overflow: 'auto',
            padding: '0.5rem',
            backgroundColor: color_for(:bg2),
            color: color_for(:font2),
            wordBreak: 'break-word',
            cursor: 'text',
          },
        }

        if @negative_pad
          props[:style][:padding] = '0.5rem 2vmin'
          props[:style][:margin] = '0 -2vmin'
        else
          props[:style][:boxSizing] = 'border-box'
        end

        h('div#chatlog', props, the_log)
      end

      def render_log_for_action(log, action)
        timestamp_props = {
          style: {
            fontSize: 'smaller',
          },
        }
        message_props = { style: { margin: '0 0.2rem' } }

        timestamp = "[#{Time.at(action.created_at || Time.now).strftime('%R')}] "

        click = lambda do
          store(:selected_action_id, @selected_action_id == action.id ? nil : action.id)
        end

        action_log = log.flat_map do |entry|
          line = entry.message

          next [] if line.is_a?(String) && !@show_log
          next [] if !line.is_a?(String) && !@show_chat

          line_props = {
            style: {
              marginBottom: '0.2rem',
              paddingLeft: '0.5rem',
              textIndent: '-0.5rem',
            },
            on: { click: click },
          }
          line_props[:style][:fontWeight] = 'bold' if line.is_a?(String) && line.start_with?('--')

          if line.is_a?(Engine::Action::Message)
            line_props[:style][:fontWeight] = 'bold'
            line_props[:style][:marginTop] = '0.5em'

            sender = line.entity.name || line.user
            line = "#{sender}: #{line.message}"
          end

          h('div.chatline', line_props,
            [h('span.timestamp', timestamp_props, timestamp), h('span.message', message_props, line)])
        end

        if !action.is_a?(Engine::Action::Message) &&
          @selected_action_id == action.id &&
          @game.last_game_action_id != action.id
          action_log << render_action_buttons(action.id)
        end

        h(:div, action_log)
      end

      def render_action_buttons(action_id)
        rewind_action = lambda do
          process_action(Engine::Action::Undo.new(@game.current_entity, action_id: action_id))
          store(:selected_action_id, nil, skip: true)
        end

        h(:div, [history_link('Review from Here', '', action_id, { margin: '0 1rem 0.5rem 0' }, true),
                 h(:button, { style: { margin: '0 0 0.5rem 0' }, on: { click: rewind_action } }, 'Undo to Here')])
      end

      def render_date_banner(time)
        date = "-- #{Time.at(time).strftime('%F')} --"
        h('div.chatline', { style: { textAlign: :center } }, date)
      end

      def copy_log_transcript
        actions = @game.actions.to_h { |a| [a.id, a] }
        log_text = []
        @game.log.map.group_by(&:action_id).flat_map do |action_id, entries|
          action = actions[action_id]
          entries.flat_map do |entry|
            time = action&.created_at ? "[#{Time.at(action.created_at || Time.now).strftime('%R')}]" : ''
            line = entry.message
            if line.is_a?(Engine::Action::Message)
              sender = line.entity.name || line.user
              line = "#{sender}: #{line.message}"
            end
            log_text << (time ? "#{time} #{line}" : line)
          end
        end
        `navigator.clipboard.writeText(log_text.join('\n'))`
        store(:flash_opts, { message: 'Game log transcript copied to clipboard', color: 'lightgreen' }, skip: false)
      end

      def render_log_choices
        h(:div, { style: { marginBottom: '0.3rem', display: 'flex', justifyContent: 'space-between' } }, [
          h(:div, { style: { textAlign: 'left' } }, [
            h(:button,
              {
                style: { marginTop: '0' },
                on: { click: -> { copy_log_transcript } },
              },
              'Copy Transcript 📋'),
          ]),
          h(:div, { style: { textAlign: 'right' } }, [
            h(:button,
              {
                style: { marginTop: '0' },
                on: { click: -> { store(:show_log, !@show_log) } },
              },
              "Log #{@show_log ? '✅' : '❌'}"),
            h(:button,
              {
                style: { marginTop: '0' },
                on: { click: -> { store(:show_chat, !@show_chat) } },
              },
              "Chat #{@show_chat ? '✅' : '❌'}"),
          ]),
        ])
      end
    end
  end
end
