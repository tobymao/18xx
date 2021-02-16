# frozen_string_literal: true

require 'game_manager'
require 'lib/color'
require 'lib/connection'
require 'lib/params'
require 'lib/settings'
require_tree './game'

module View
  class GamePage < Snabberb::Component
    include Lib::Color
    include Lib::Settings

    needs :game_data, store: true
    needs :game, default: nil, store: true
    needs :connection
    needs :selected_company, default: nil, store: true
    needs :tile_selector, default: nil, store: true
    needs :app_route, store: true
    needs :user
    needs :connected, default: false, store: true
    needs :before_process_pass, default: -> {}, store: true
    needs :scroll_pos, default: nil, store: true

    def render_broken_game(e)
      inner = [h(:div, "We're sorry this game cannot be continued due to #{e}")]

      json = `JSON.stringify(#{@game.broken_action&.to_h&.to_n}, null, 2)`
      inner << h(:div, "Broken action: #{json}")

      # don't ask for a link for hotseat games
      action = @game.last_processed_action || 0
      url = "https://18xx.games/game/#{@game_data['id']}?action=#{action + 1}"
      game_link =
        if @game.id.is_a?(Integer)
          [
            'this link (',
            h(:a, { attrs: { href: url } }, url),
            ') and ',
          ]
        else
          []
        end

      inner << h(:div, [
        'Please ',
        h(:a, { attrs: { href: 'https://github.com/tobymao/18xx/issues/' } }, 'raise a bug report'),
        ' and include ',
        *game_link,
        'the following JSON data',
      ])
      inner << h(Game::GameData,
                 actions: @game_data['actions'],
                 allow_clone: false,
                 allow_delete: @game_data[:mode] == :hotseat)
      h(:div, { style: { 'margin-bottom': '25px' } }, inner)
    end

    def cursor
      @cursor ||= Lib::Params['action']&.to_i
    end

    def load_game
      game_id = @game_data['id']
      actions = @game_data['actions']
      @num_actions = actions.size
      return if game_id == @game&.id &&
        (@game.exception ||
         (!cursor && @game.raw_actions.size == @num_actions) ||
         (cursor == @game.raw_actions.size))

      @game = Engine::Game.load(@game_data, at_action: cursor)
      store(:game, @game, skip: true)
    end

    def render
      @pin = @game_data.dig('settings', 'pin')

      load_game

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
        end

      @connection = nil if @game_data[:mode] == :hotseat || cursor

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
      end unless @connected

      store(:connected, true, skip: true)

      destroy = lambda do
        @connection&.unsubscribe(game_path)
        store(:selected_company, nil, skip: true)
        store(:connected, false, skip: true)
      end

      render_title

      props = {
        attrs: {
          autofocus: true, # does not work on all browsers
          tabindex: -1, # necessary to be focusable so keyup works; -1 == not accessible by tabbing
        },
        key: 'game_page',
        hook: {
          destroy: destroy,
        },
        on: {
          keydown: ->(event) { hotkey_check(event) },
        },
      }

      children = [
        menu,
        page,
      ]
      children.unshift(render_broken_game(@game.exception)) if @game.exception

      h('div#game', props, children)
    end

    def change_anchor(anchor)
      unless route_anchor
        elm = Native(`document.getElementById('chatlog')`)
        # only store when scrolled up at least one line (20px)
        store(:scroll_pos, elm.scrollTop < elm.scrollHeight - elm.offsetHeight - 20 ? elm.scrollTop : nil, skip: true)
      end
      store(:tile_selector, nil, skip: true)
      base = @app_route.split('#').first
      new_route = base + anchor
      new_route = base if @app_route == new_route
      store(:app_route, new_route)
    end

    def hotkey_check(event)
      # 'search for text when you start typing' feature of browser prevents execution
      # only execute when no modifier is pressed to not interfere with OS shortcuts
      event = Native(event)
      return if event.getModifierState('Alt') || event.getModifierState('AltGraph') || event.getModifierState('Meta') ||
        event.getModifierState('Control') || event.getModifierState('OS') || event.getModifierState('Shift')

      active = Native(`document.activeElement`)
      return if active.id != 'game' && active.localName != 'body'

      key = event['key']
      case key
      when 'g'
        change_anchor('')
      when 'e'
        change_anchor('#entities')
      when 'm'
        change_anchor('#map')
      when 'a', 'k'
        change_anchor('#market')
      when 'i'
        change_anchor('#info')
      when 't'
        change_anchor('#tiles')
      when 's'
        change_anchor('#spreadsheet')
      when 'o'
        change_anchor('#tools')
      when 'c'
        `document.getElementById('chatbar').focus()`
        event.preventDefault
      when '-', '0', '+'
        map = `document.getElementById('map')`
        `document.getElementById('zoom'+#{key}).click()` if map
      when 'Home', 'End', 'PageUp', 'PageDown', 'ArrowLeft', 'ArrowRight'
        Native(`document.getElementById('hist_'+#{key})`)&.click()
        event.preventDefault
      end
    end

    def game_path
      GameManager.url(@game_data)
    end

    private

    def render_title
      title = "#{@game.class.title} - #{@game.id} - 18xx.Games"
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
          boxShadow: "0 5px 0 0 #{color_for(@game.phase.current[:tiles].last)}, 0 6px 0 0 #{color_for(:bg)}",
          backgroundColor: bg_color,
          color: active_player ? contrast_on(bg_color) : color_for(:font2),
          fontSize: 'large',
          zIndex: '9999',
        },
      }

      menu_items = [
        item('G|ame', ''),
        item('E|ntities', '#entities'),
        item('M|ap', '#map'),
        item('Mark|et', '#market'),
        item('I|nfo', '#info'),
        item('T|iles', '#tiles'),
        item('S|preadsheet', '#spreadsheet'),
        item('To|ols', '#tools'),
      ]

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
      description += "#{@game.class.title}: "
      description += "Phase #{@game.phase.name} - "
      name = @round.class.name.split(':').last
      description += @game.round_description(name)
      description += @game.finished ? ' - Game Over' : " - #{@round.description}"
      game_end = @game.game_ending_description
      description += " - #{game_end}" if game_end
      description += " - Pinned to Version: #{@pin}" if @pin
      h(:div, { style: { fontWeight: 'bold', margin: '2vmin 0' } }, description)
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
        if !(%w[place_token lay_tile remove_token] & current_entity_actions).empty?
          h(Game::Map, game: @game)
        else
          h(Game::Round::Stock, game: @game)
        end
      when Engine::Round::Operating
        if current_entity_actions.include?('merge')
          h(Game::Round::Merger, game: @game)
        elsif current_entity_actions.include?('buy_shares') && @game.current_entity&.player?
          h(Game::Round::Stock, game: @game)
        else
          h(Game::Round::Operating, game: @game)
        end
      when Engine::Round::Draft
        h(Game::Round::Auction, game: @game, user: @user, before_process_pass: @before_process_pass)
      when Engine::Round::Auction
        h(Game::Round::Auction, game: @game, user: @user)
      when Engine::Round::Merger
        h(Game::Round::Merger, game: @game)
      end
    end

    def render_game
      @round = @game.round

      h('div.game', [
        render_round,
        h(Game::GameLog, user: @user, scroll_pos: @scroll_pos),
        h(Game::HistoryAndUndo, num_actions: @num_actions),
        h(Game::EntityOrder, round: @round),
        h(Game::Abilities, user: @user, game: @game),
        h(Game::Pass, before_process_pass: @before_process_pass, actions: current_entity_actions),
        h(Game::Help, game: @game),
        render_action,
      ])
    end

    def current_entity_actions
      @current_entity_actions ||= @game.round.actions_for(@game.round.active_step&.current_entity) || []
    end

    def step
      @game.round.active_step
    end
  end
end
