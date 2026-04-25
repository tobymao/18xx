# frozen_string_literal: true

# backtick_javascript: true

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
        @player = @game.player_by_id(@user['id']) if @user

        children = [render_log_choices, render_log]

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
                  placeholder: 'Ping with @player_name or @all',
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
        @last_entity = nil
        @in_or_operation = false
        @eft_corps = nil
        @eft_companies = nil

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

      def ensure_eft_built
        return if @eft_corps

        historical = @game.actions.map(&:entity).uniq
          .reject { |e| @game.players.include?(e) }
          .select { |e| e.respond_to?(:id) }
        @eft_corps = (@game.corporations + @game.minors + historical)
          .uniq
          .sort_by { |e| -[e.name.size, e.id.size].max }
        @eft_companies = @game.companies
          .sort_by { |e| -[e.name.size, e.id.size].max }
      end

      def entity_for_line(line, auctioning_lot = nil)
        return nil unless line.is_a?(String)
        return nil if line.start_with?('--')

        # Build the corps list once per render (memoized). Include historical
        # acting corps from actions so that entities removed mid-game
        # (e.g. nationalized minors in 1861) are still recognised in the log.
        ensure_eft_built

        # Sort longest-first so e.g. "P10" is checked before "P1"
        corps = @eft_corps
        companies = @eft_companies

        # When an auction lot is active, derive the canonical entity key for it
        # so all log lines during that auction group together.
        lot_key = lot_entity_key(auctioning_lot) if auctioning_lot

        corp_in_line = lambda do |text|
          corps.each do |e|
            # Corporation#name == #id == sym; guard short IDs to avoid matching
            # every line that contains the letter, e.g. corp 'E' in "Exemplar1..."
            return e.id if e.id.size >= 2 && text.include?(e.id)
            # Also match by full name for corps whose log text uses the long name
            # rather than the short ID (e.g. 1866 minor nationals: "Sardinia Minor
            # National" in bid lines, while the ID is just "SAR").
            return e.id if e.name.size >= 4 && e.name != e.id && text.include?(e.name)
          end
          nil
        end

        # Like corp_in_line but also searches private companies — for player lines
        # so "Player 1 bids on Tsarskoye Selo Railway" groups with other TSR auction lines
        entity_in_line = lambda do |text|
          result = corp_in_line.call(text)
          return result if result

          companies.each do |e|
            return e.id if text.include?(e.name) || (e.id.size >= 2 && text.include?(e.id))
          end
          nil
        end

        # Corporation/minor at start of line.
        # Require the next character to be a space (or end of string) so corp "1"
        # does not match "1822CA is currently..." and corp "E" does not match
        # "Exemplar1 receives...". Lines like "3's share price..." fall through
        # to the catch-all which handles them via @last_entity.
        corps.each do |e|
          id = e.id
          next unless line.start_with?(id)

          next_char = line[id.size]
          next if next_char && next_char != ' '

          return id
        end

        # Player starts line.
        # Without an active auction lot (subject-centric): group by the acting
        # player. With an active lot (object-centric): all bids/passes group
        # under the lot's canonical entity key.
        @game.players.each do |player|
          next unless line.start_with?(player.name)

          unless auctioning_lot
            # During an OR operation, player lines like "X receives $Y" are
            # consequences of the corp's turn — keep them grouped under the corp.
            return @last_entity if @in_or_operation && @last_entity && @game.players.none? { |p| p.name == @last_entity }

            return player.name
          end

          return lot_key || entity_in_line.call(line) || @last_entity || player.name
        end

        # Private company starts line.
        # With an active auction lot: company is the lot (or acting for the lot),
        # so anchor to lot_key. Without a lot: company acts on behalf of the
        # current entity — stay grouped rather than starting a new group.
        companies.each do |e|
          next if !line.start_with?(e.name) && !line.start_with?(e.id)

          return @last_entity if @last_entity && !auctioning_lot

          return lot_key || corp_in_line.call(line) || e.id
        end

        # Catch-all: unrecognised lines without an active lot stay grouped under
        # the current entity rather than breaking the chain.
        return @last_entity if @last_entity && !auctioning_lot

        nil
      end

      def lot_entity_key(lot)
        # Map an auctioning lot (Company or Corporation) to the canonical entity
        # key used by the log grouping — the id of the matching corp/minor, or
        # the company id as fallback. Lists must already be initialised.
        @eft_corps.each do |e|
          return e.id if e.name == lot.name || e.id == lot.id
        end
        @eft_companies.each do |e|
          return e.id if e.name == lot.name || e.id == lot.id
        end
        lot.id
      end

      def player_for(entity)
        return nil unless entity
        return entity if @game.players.include?(entity)

        if entity.respond_to?(:player)
          found = entity.player
          return found if @game.players.include?(found)
        end

        if entity.respond_to?(:owner)
          owner = entity.owner
          return owner if @game.players.include?(owner)
          return player_for(owner) if owner && owner != entity
        end

        nil
      end

      def render_log_for_action(log, action)
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
          is_banner = line.is_a?(String) && line.start_with?('--')
          line_props[:style][:fontWeight] = 'bold' if is_banner

          indent = false

          if line.is_a?(Engine::Action::Message)
            next [] if line.message.empty?

            line_props[:style][:fontWeight] = 'bold'
            line_props[:style][:marginTop] = '0.5em'
            sender = line.entity.name || 'Owner'
            line = "#{sender}: #{line.message}"
          elsif is_banner
            # Only reset grouping for round/entity changes; let phase changes,
            # train rusts, and other mid-sequence events pass through silently.
            if line.include?(' Round ')
              @last_entity = nil
              @in_or_operation = false
            elsif line.include?(' operates ')
              ensure_eft_built
              operating_name = line.delete_prefix('-- ').delete_suffix(' --').split(' operates ').last
              match = @eft_corps.find { |e| e.name == operating_name || e.id == operating_name }
              @last_entity = match ? match.id : nil
              @in_or_operation = true
            end
          else
            line_entity = entity_for_line(line, entry.auctioning_lot)
            indent = line_entity && line_entity == @last_entity
            @last_entity = line_entity if line_entity
          end

          ts_props = { style: { fontSize: 'smaller' } }
          msg_props = { style: { margin: '0 0.2rem' } }
          msg_props[:style][:marginLeft] = '1.5rem' if indent

          h('div.chatline', line_props, [
            h('span.timestamp', ts_props, timestamp),
            h('span.message', msg_props, line),
          ])
        end

        if !action.is_a?(Engine::Action::Message) &&
          @selected_action_id == action.id &&
          @game.last_game_action_id != action.id
          action_log << render_action_buttons(action.id)
        end

        h(:div, { attrs: { id: "action-#{action.id}" } }, action_log)
      end

      def last_player_action_id
        return nil unless @player

        @game.actions.reverse_each do |action|
          return action.id if player_for(action.entity) == @player
        end
        nil
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
        left_buttons = [
          h(:button,
            {
              style: { marginTop: '0' },
              on: { click: -> { copy_log_transcript } },
            },
            'Copy Transcript 📋'),
        ]

        if @player && (last_id = last_player_action_id)
          jump = lambda do
            store(:selected_action_id, last_id)
            `document.getElementById('action-' + #{last_id}).scrollIntoView({block: 'nearest'})`
          end
          left_buttons << h(:button,
                            {
                              style: { marginTop: '0' },
                              on: { click: jump },
                            },
                            'My Last Move ↑')
        end

        h(:div, { style: { marginBottom: '0.3rem', display: 'flex', justifyContent: 'space-between' } }, [
          h(:div, { style: { textAlign: 'left' } }, left_buttons),
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
