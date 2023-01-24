# frozen_string_literal: true

require 'game_manager'
require 'lib/connection'
require 'lib/params'
require 'lib/settings'
require 'lib/storage'
require_tree './game'

module View
  class GamePage < Snabberb::Component
    include GameManager
    include Lib::Settings

    needs :selected_company, default: nil, store: true
    needs :tile_selector, default: nil, store: true
    needs :user
    needs :connected, default: false, store: true
    needs :scroll_pos, default: nil, store: true
    needs :chat_input, default: '', store: true

    APP_PADDING_BOTTOM = '2vmin'

    def render_broken_game(e)
      inner = [h(:div, "We're sorry this game cannot be continued due to #{e}")]

      json = `JSON.stringify(#{@game.broken_action&.to_h&.to_n}, null, 2)`
      inner << h(:div, "Broken action: #{json}")

      # don't ask for a link for hotseat games
      action = @game.last_processed_action || 0
      url = "#{`window.location.origin`}/game/#{@game_data['id']}?action=#{action - 1}"
      game_link =
        if @game.id.is_a?(Integer)
          [
            'this link (',
            h(:a, { attrs: { href: url } }, url),
            ')',
          ]
        else
          []
        end

      inner << h(:div, [
        'Please ',
        h(:a, { attrs: { href: 'https://github.com/tobymao/18xx/issues/' } }, 'raise a bug report'),
        ' and include ',
        *game_link,
      ])
      inner << h(Game::GameData,
                 actions: @game_data['actions'],
                 allow_clone: false,
                 allow_delete: @game_data[:mode] == :hotseat)
      h(:div, { style: { 'margin-bottom': '25px' } }, inner)
    end

    def render_bad_options(s)
      h(:div, "Option Error: #{s}")
    end

    def cursor
      @cursor ||= Lib::Params['action']&.to_i
    end

    def load_game
      game_id = @game_data['id']
      actions = @game_data['actions']
      @last_action_id = actions&.last&.fetch('id') || 0
      last_processed_action_id = @game&.raw_actions&.last&.fetch('id') || 0
      return if game_id == @game&.id &&
        (@game.exception ||
         (!cursor && last_processed_action_id == @last_action_id) ||
         (cursor == @game.last_game_action_id))

      return @game.process_to_action(cursor) if game_id == @game&.id && cursor && cursor > @game.last_game_action_id

      load_game_with_class = lambda do
        @game = Engine::Game.load(@game_data, at_action: cursor, user: @user&.dig('id'))
        store(:game, @game, skip: true)
      end

      title = @game_data['title']
      load_game_class(title, load_game_with_class)
      return unless @game_classes_loaded[title]

      load_game_with_class.call
    end

    def render
      @pin = @game_data.dig('settings', 'pin')

      begin
        load_game
      rescue Engine::OptionError => e
        return render_bad_options(e.message)
      end

      return h('div.padded', 'Loading game...') unless @game

      page =
        case route_anchor
        when nil
          render_game
        when 'map'
          h(Game::Map, game: @game, opacity: 1.0, tile_selector: @tile_selector)
        when 'market'
          h(Game::StockMarket, game: @game, explain_colors: true)
        when 'tiles'
          h(Game::TileManifest, game: @game, tile_selector: @tile_selector)
        when 'entities'
          h(Game::Entities, game: @game, user: @user)
        when 'info'
          h(Game::GameInfo, game: @game)
        when 'spreadsheet'
          h(Game::Spreadsheet, game: @game)
        when 'tools'
          h(Game::Tools, game: @game, game_data: @game_data, user: @user)
        when 'auto'
          h(Game::Auto, game: @game, game_data: @game_data, user: @user)
        end

      @connection = nil if @game_data[:mode] == :hotseat || cursor

      unless @connected
        @connection&.subscribe(game_path) do |data|
          # make sure we're using the newest stored vars
          # since connection is only created on the initial view
          # and views are ephemeral
          game = store['game']
          game_data = store['game_data']
          n_id = data['id']
          o_id = game.current_action_id

          if n_id == o_id + 1
            game_data['actions'] << data
            store(:game_data, game_data, skip: true)
            store(:game, game.process_action(data))
          else
            store['connection'].get(game_path) do |new_data|
              unless new_data['error']
                store(:game_data, new_data, skip: true)
                store(:game, game.clone(new_data['actions']))
              end
            end
          end
        end
      end

      store(:connected, true, skip: true)

      destroy = lambda do
        @connection&.unsubscribe(game_path)
        store(:selected_company, nil, skip: true)
        store(:connected, false, skip: true)
      end

      render_title

      props = {
        attrs: {
          tabindex: -1, # necessary to be focusable so keyup works; -1 == not accessible by tabbing
        },
        key: 'game_page',
        hook: {
          destroy: destroy,
          insert: lambda {
            scroll_to_game_menu
            `document.getElementById('game').focus()`
          },
          postpatch: lambda {
            unless %w[input textarea].include?(Native(`document.activeElement`).localName)
              `document.getElementById('game').focus()`
            end
          },
        },
        on: {
          keydown: ->(event) { hotkey_check(event) },
        },
        style: {
          # ensure sufficient height for scroll_to_game_menu
          minHeight: "calc(#{`window.innerHeight`}px - #{APP_PADDING_BOTTOM})",
        },
      }

      children = [
        menu,
        page,
      ]
      children.unshift(render_broken_game(@game.exception)) if @game.exception

      h('div#game', props, children)
    end

    def scroll_to_game_menu
      `window.scroll(0, document.getElementById('header').offsetHeight)`
    end

    def change_anchor(anchor)
      unless route_anchor
        elm = Native(`document.getElementById('chatlog')`)
        # only store when scrolled up at least one line (20px)
        store(:scroll_pos, elm.scrollTop < elm.scrollHeight - elm.offsetHeight - 20 ? elm.scrollTop : nil, skip: true)
        if (chatbar = Native(`document.getElementById('chatbar')`))
          store(:chat_input, chatbar.value, skip: true)
        end
      end
      store(:tile_selector, nil, skip: true)
      base = @app_route.split('#').first
      new_route = base + anchor
      new_route = base if @app_route == new_route
      scroll_to_game_menu
      store(:app_route, new_route)
    end

    def button_click(id)
      Native(`document.getElementById(#{id})`)&.click()
    end

    def hotkey_check(event)
      # 'search for text when you start typing' feature of browser prevents execution
      # catch modifiers to not interfere with OS shortcuts
      event = Native(event)
      active = Native(`document.activeElement`)
      return if %w[input textarea].include?(active.localName) || event.getModifierState('Alt') ||
                event.getModifierState('AltGraph') || event.getModifierState('Meta') || event.getModifierState('OS')

      key = event['key']
      if event.getModifierState('Control')
        case key
        when 'y'
          button_click('redo')
        when 'z'
          button_click('undo')
        end
      elsif event.getModifierState('Shift')
        button_click('zoom+') if key == '+' # + on qwerty
      else
        case key
        when 'g'
          change_anchor('')
        when 'e'
          change_anchor('#entities')
        when 'm'
          change_anchor('#map')
        when 'k'
          change_anchor('#market')
        when 'i'
          change_anchor('#info')
        when 't'
          change_anchor('#tiles')
        when 's'
          change_anchor('#spreadsheet')
        when 'o'
          change_anchor('#tools')
        when 'a'
          change_anchor('#auto')
        when 'c'
          if (chatbar = Native(`document.getElementById('chatbar')`))
            chatbar.focus
            chatbar.selectionStart = chatbar.value.length
            event.preventDefault
          end
        when '-', '0', '+' # + on qwertz
          button_click('zoom' + key)
        when 'Home', 'End', 'ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight'
          button_click('hist_' + key)
          event.preventDefault
        end
      end
    end

    def game_path
      url(@game_data)
    end

    private

    def render_title
      title = "#{@game.class.display_title} - #{@game.id} - 18xx.Games"
      title = "* #{title}" if @game.active_players_id.include?(@user&.dig('id'))
      `document.title = #{title}`
      change_favicon(active_player)
      change_tab_color(active_player)
    end

    def active_player
      @game_data[:mode] != :hotseat &&
        !cursor &&
        @game.active_players_id.include?(@user&.dig('id'))
    end

    def menu
      bg_color =
        if @game_data['mode'] == :hotseat
          color_for(:hotseat_game)
        elsif active_player
          color_for(:your_turn)
        else
          color_for(:bg2)
        end

      nav_props = {
        attrs: {
          role: 'navigation',
          'aria-label': 'Game',
        },
        style: {
          overflow: 'auto',
          position: 'sticky',
          margin: '0 -2vmin 2vmin -2vmin',
          top: '0',
          borderBottom: "1px solid #{color_for(:font2)}",
          borderTop: "1px solid #{color_for(:font2)}",
          boxShadow: "0 5px 0 0 #{color_for(@game.nav_bar_color)}, 0 6px 0 0 #{color_for(:bg)}",
          backgroundColor: bg_color,
          color: active_player ? contrast_on(bg_color) : color_for(:font2),
          fontSize: 'large',
          zIndex: '9999',
        },
      }

      note = !@game_data.dig('user_settings', 'notepad').to_s.empty?
      menu_items = []
      menu_items << item('G|ame', '')
      menu_items << item('E|ntities', '#entities')
      menu_items << item('M|ap', '#map') unless @game.layout == :none
      menu_items << item('Mark|et', '#market')
      menu_items << item('I|nfo', '#info')
      menu_items << item('T|iles', '#tiles') unless @game.layout == :none
      menu_items << item('S|preadsheet', '#spreadsheet')
      menu_items << item("To|ols#{' 📝' if note}", '#tools')

      enabled = !@game.programmed_actions[@game.player_by_id(@user['id'])].empty? if @user
      menu_items << item("A|uto#{' ✅' if enabled}", '#auto') if @game_data[:mode] != :hotseat && !cursor

      h('nav#game_menu', nav_props, [
        h('ul.no_margin.no_padding', { style: { width: 'max-content' } }, menu_items),
      ])
    end

    def item(name, anchor)
      name = name.split(/(\|)/).each_slice(2).flat_map do |text, pipe|
        if pipe
          head = text[0..-2]
          tail = text[-1]
          [h(:span, head), h(:span, { style: { textDecoration: 'underline' } }, tail)]
        else
          h(:span, text)
        end
      end

      a_props = {
        attrs: {
          href: anchor,
          onclick: 'return false',
        },
        style: { textDecoration: route_anchor == anchor[1..-1] ? 'underline' : 'none' },
        on: { click: ->(_event) { change_anchor(anchor) } },
      }
      li_props = {
        style: {
          float: 'left',
          margin: '0 0.5rem',
          listStyle: 'none',
        },
      }

      h(:li, li_props, [h(:a, a_props, name)])
    end

    def route_anchor
      @app_route.split('#')[1]
    end

    def render_round
      description = @game_data['mode'] == :hotseat ? '[HOTSEAT] ' : ''
      description += "#{@game.class.display_title}: "
      description += "#{@game.round_phase_string} - "
      name = @round.class.name.split(':').last
      description += @game.round_description(name)
      description += @game.finished ? ' - Game Over' : " - #{@round.description}"
      game_end = @game.game_ending_description
      description += " - #{game_end}" if game_end
      description += " - Pinned to Version: #{@pin}" if @pin
      h(:h4, description)
    end

    def render_action
      return h(Game::GameEnd) if @game.finished

      if current_entity_actions.include?('discard_train') &&
        current_entity_actions.include?('swap_train')
        return h(Game::UpgradeOrDiscardTrains)
      end
      return h(Game::DiscardTrains) if current_entity_actions.include?('discard_train')

      if current_entity_actions.include?('par') &&
          step.respond_to?(:corporation_pending_par) && step.corporation_pending_par
        return h(Game::CorporationPendingPar, corporation: step.corporation_pending_par)
      end

      case @round
      when Engine::Round::Stock
        if current_entity_actions.include?('place_token') && step.respond_to?(:map_action_optional?) && step.map_action_optional?
          h(:div, [
              h(Game::Round::Stock, game: @game),
              h(Game::Map, game: @game),
            ])
        elsif !(%w[place_token lay_tile remove_token] & current_entity_actions).empty?
          h(Game::Map, game: @game)
        else
          h(Game::Round::Stock, game: @game)
        end
      when Engine::Round::Operating
        if current_entity_actions.include?('merge')
          h(Game::Round::Merger, game: @game)
        elsif current_entity_actions.include?('buy_shares') && @game.current_entity&.player?
          h(Game::Round::Stock, game: @game)
        elsif current_entity_actions.include?('bid')
          h(Game::Round::Auction, game: @game, user: @user)
        else
          h(Game::Round::Operating, game: @game)
        end
      when Engine::Round::Choices
        h(Game::Round::Choices, game: @game)
      when Engine::Round::Auction,
           Engine::Round::Draft
        h(Game::Round::Auction, game: @game, user: @user)
      when Engine::Round::Merger
        if !(%w[buy_train scrap_train reassign_trains] & current_entity_actions).empty? &&
              @game.train_actions_always_use_operating_round_view?
          h(Game::Round::Operating, game: @game)
        else
          h(Game::Round::Merger, game: @game)
        end
      else
        if @round.stock?
          h(Game::Round::Stock, game: @game)
        elsif @round.unordered?
          h(Game::Round::Unordered, game: @game, user: @user, hotseat: hotseat_or_master)
        end
      end
    end

    def hotseat_or_master
      @game_data[:mode] == :hotseat || Lib::Storage[@game.id]&.dig('master_mode')
    end

    def render_game
      @round = @game.round

      children = []
      children << render_round
      children << h(Game::GameLog, user: @user, scroll_pos: @scroll_pos, chat_input: @chat_input)
      children << h(Game::HistoryAndUndo, last_action_id: @last_action_id)
      children << h(Game::EntityOrder, round: @round)
      unless @game.finished
        children << h(Game::Abilities, user: @user, game: @game)
        children << if @game.round.unordered? && hotseat_or_master
                      h(Game::MasterPass)
                    else
                      h(Game::Pass, actions: current_entity_actions)
                    end
        children << h(Game::Help, game: @game)
      end
      children << render_action

      h('div.game', children)
    end

    def current_entity_actions
      @current_entity_actions ||= if !@game.round.unordered?
                                    @game.round.actions_for(@game.round.active_step&.current_entity) || []
                                  elsif hotseat_or_master
                                    @game.round.entities.flat_map { |e| @game.round.actions_for(e) }.uniq.compact
                                  else
                                    @game.round.actions_for(@game.player_by_id(@user['id'])) || []
                                  end
    end

    def step
      @game.round.active_step
    end
  end
end
