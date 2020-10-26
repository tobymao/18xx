# frozen_string_literal: true

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
    needs :app_route, store: true
    needs :user
    needs :disable_user_errors
    needs :connected, default: false, store: true
    needs :before_process_pass, default: -> {}, store: true

    def render_broken_game(e)
      inner = [h(:div, "We're sorry this game cannot be continued due to #{e}")]
      if e.is_a?(Engine::GameError) && !e.action_id.nil?
        action = e.action_id - 1
        inner << h(:div, [
          h(:a, { attrs: { href: "?action=#{action}" } }, "View the last valid action (#{action})"),
        ])
      end
      inner << h(:div, [
        'Please ',
        h(:a, { attrs: { href: 'https://github.com/tobymao/18xx/issues/' } }, 'raise a bug report'),
        " and include the game id (#{@game_data['id']}) and the following JSON data",
      ])
      inner << h(Game::GameData,
                 actions: @game_data['actions'],
                 allow_clone: false,
                 allow_delete: @game_data[:mode] == :hotseat)
      h(:div, inner)
    end

    def cursor
      @cursor ||= Lib::Params['action']&.to_i
    end

    def load_game
      game_id = @game_data['id']
      actions = @game_data['actions']
      @num_actions = actions.size
      return if game_id == @game&.id &&
        ((!cursor && @game.actions.size == @num_actions) || (cursor == @game.actions.size))

      @game = Engine::GAMES_BY_TITLE[@game_data['title']].new(
        @game_data['players'].map { |p| p['name'] },
        id: game_id,
        actions: cursor ? actions.take(cursor) : actions,
        pin: @pin,
        optional_rules: @game_data.dig('settings', 'optional_rules_selected') || [],
      )
      store(:game, @game, skip: true)
    end

    def render
      @pin = @game_data.dig('settings', 'pin')

      if @disable_user_errors
        # Opal exceptions lack backtraces, so do this outside of a rescue in dev mode to preserve the backtrace
        load_game
      else
        begin
          load_game
        rescue StandardError => e
          return render_broken_game(e)
        end
      end

      page =
        case route_anchor
        when nil
          render_game
        when 'map'
          h(Game::Map, game: @game, opacity: 1.0)
        when 'market'
          h(Game::StockMarket, game: @game, explain_colors: true)
        when 'tiles'
          h(Game::TileManifest, game: @game)
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

      @connection&.subscribe(game_path, -2) do |data|
        # make sure we're using the newest stored vars
        # since connection is only created on the initial view
        # and views are ephemeral
        game = store['game']
        game_data = store['game_data']
        n_id = data['id']
        o_id = game.current_action_id

        if n_id == o_id
          game_data['actions'] << data
          store(:game_data, game_data, skip: true)
          store(:game, game.process_action(data))
        elsif n_id > o_id
          store['connection'].get(game_path) do |new_data|
            store(:game_data, new_data, skip: true)
            store(:game, game.clone(new_data['actions']))
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
        key: 'game_page',
        hook: {
          destroy: destroy,
        },
      }

      h(:div, props, [
        menu,
        page,
      ])
    end

    def game_path
      "/game/#{@game_data['id']}"
    end

    private

    def render_title
      title = "#{@game.class.title} - #{@game.id} - 18xx.Games"
      title = "* #{title}" if @game.active_player_names.include?(@user&.dig('name'))
      `document.title = #{title}`
      change_favicon(active_player)
      change_tab_color(active_player)
    end

    def active_player
      @game_data[:mode] != :hotseat &&
        !cursor &&
        @game.active_players.map(&:name).include?(@user&.dig('name'))
    end

    def menu
      bg_color = active_player ? color_for(:your_turn) : color_for(:bg2)
      nav_props = {
        attrs: {
          role: 'navigation',
          'aria-label': 'Game',
        },
        style: {
          overflow: 'auto',
          position: 'sticky',
          margin: '-1rem -2vmin 2vmin -2vmin',
          borderBottom: "1px solid #{color_for(:font2)}",
          top: '0',
          backgroundColor: bg_color,
          color: active_player ? contrast_on(bg_color) : color_for(:font2),
          fontSize: 'large',
          zIndex: '9999',
        },
      }

      menu_items = [
        item('Game'),
        item('Entities', '#entities'),
        item('Map', '#map'),
        item('Market', '#market'),
        item('Info', '#info'),
        item('Tiles', '#tiles'),
        item('Spreadsheet', '#spreadsheet'),
        item('Tools', '#tools'),
      ]

      h('nav#game_menu', nav_props, [
        h('ul.no_margin.no_padding', { style: { width: 'max-content' } }, menu_items),
      ])
    end

    def item(name, anchor = '')
      change_anchor = lambda do
        store(:app_route, "#{@app_route.split('#').first}#{anchor}")
      end

      a_props = {
        attrs: {
          href: anchor,
          onclick: 'return false',
        },
        style: { textDecoration: route_anchor == anchor[1..-1] ? 'underline' : 'none' },
        on: { click: change_anchor },
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
      description = "#{@game.class.title}: "
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

      entity = @round.active_step.current_entity
      current_actions = @round.actions_for(entity) || []
      return h(Game::DiscardTrains) if current_actions.include?('discard_train')

      case @round
      when Engine::Round::Stock
        if (%w[place_token lay_tile] & current_actions).any?
          h(Game::Map, game: @game)
        else
          h(Game::Round::Stock, game: @game)
        end
      when Engine::Round::Operating
        if current_actions.include?('merge')
          h(Game::Round::Merger, game: @game)
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
        h(Game::GameLog, user: @user),
        h(Game::HistoryControls, num_actions: @num_actions),
        h(Game::EntityOrder, round: @round),
        h(Game::Abilities, user: @user, game: @game),
        h(Game::UndoAndPass, before_process_pass: @before_process_pass),
        h(Game::Help, game: @game),
        render_action,
      ])
    end
  end
end
