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
        has_timestamps = @game.actions.any? { |a| a.is_a?(Engine::Action::Base) && a.created_at }

        # Create a fake action zero, so special handling isn't required throughout
        action_zero = Engine::Action::Base.new(@game.players.first)
        action_zero.id = 0
        action_zero.created_at = (@game.actions[0]&.created_at || Time.now) if has_timestamps

        last_action = nil
        the_log = @game.log.group_by(&:action_id).flat_map do |action_id, entries|
          children = []
          action = action_id.zero? ? action_zero : @game.actions[action_id - 1]

          if has_timestamps
            action.created_at ||= Time.now

            if !last_action || Time.at(action.created_at).yday != Time.at(last_action.created_at).yday
              children << date_banner(action.created_at)
            end
          end
          last_action = action

          children << log_for_action(entries, action, has_timestamps)
          children
        end

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

        h('div#chatlog', props, the_log)
      end

      def log_for_action(log, action, include_timestamps)
        timestamp_props = { style: { margin: '0 0.2rem',
                                     fontSize: 'smaller' } }
        message_props = { style: { margin: '0 0.2rem' } }

        timestamp = "[#{Time.at(action.created_at || Time.now).strftime('%R')}]" if include_timestamps

        action_log = log.flat_map do |entry|
          line = entry.message

          line_props = { style: { marginTop: '0.5em',
                                  marginBottom: '0.2rem',
                                  paddingLeft: '0.5rem',
                                  textIndent: '-0.5rem' },
                         on: { click: -> { store(:action_id, action.id) } } }
          line_props[:style][:fontWeight] = 'bold' if line.is_a?(String) && line.start_with?('--')

          if line.is_a?(Engine::Action::Message)
            line_props[:style][:fontWeight] = 'bold'

            sender = line.entity.name || line.user
            line = "#{sender}: #{line.message}"
          end

          children = []
          children << h('span.timestamp', timestamp_props, timestamp) if include_timestamps
          children << h('span.message', message_props, line)
          h('div.chatline', line_props, children)
        end

        if !action.is_a?(Engine::Action::Message) && @action_id == action.id && @game.last_game_action != action.id
          action_log << action_buttons(action.id)
        end

        h(:div, action_log)
      end

      def action_buttons(action_id)
        rewind_action = lambda do
          process_action(Engine::Action::Undo.new(@game.current_entity, action_id: action_id))
          store(:action_id, nil, skip: true)
        end

        h(:div, [history_link('Review from Here', '', action_id, {}, true),
                 h(:button, { on: { click: rewind_action } }, 'Rewind to Here')])
      end

      def date_banner(time)
        date = "-- #{Time.at(time).strftime('%F')} --"
        h('div.chatline', { style: { textAlign: :center } }, date)
      end
    end
  end
end
