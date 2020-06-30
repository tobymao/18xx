# frozen_string_literal: true

require 'lib/connection'
require 'lib/params'
require_tree './game'

module View
  class GamePage < Snabberb::Component
    include Lib::Color
    needs :game_data, store: true
    needs :game, default: nil, store: true
    needs :connection
    needs :selected_company, default: nil, store: true
    needs :app_route, store: true
    needs :user
    needs :disable_user_errors
    needs :connected, default: false, store: true

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
      inner << h(Game::GameData, actions: @game_data['actions'], allow_clone: false)
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
          h(Game::TileManifest, tiles: @game.tiles, all_tiles: @game.init_tiles, layout: @game.layout)
        when 'companies'
          h(Game::Companies, game: @game, user: @user)
        when 'corporations'
          h(Game::Corporations, game: @game, user: @user)
        when 'info'
          h(Game::GameInfo, game: @game)
        when 'players'
          h(Game::Players, game: @game)
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
        tabs,
        page,
      ])
    end

    def game_path
      "/game/#{@game_data['id']}"
    end

    private

    def render_title
      title = "#{@game.class.title} - #{@game.id} - 18xx.games"
      title = "* #{title}" if @game.active_player_names.include?(@user&.dig(:name))
      `document.title = #{title}`
    end

    def tabs
      props = {
        style: {
          overflow: 'auto',
          position: 'sticky',
          padding: '1.5rem 2vmin',
          margin: '-2vmin -2vmin 2vmin -2vmin',
          borderBottom: "1px solid #{color_for(:font2)}",
          top: '0',
          'background-color': color_for(:bg2),
          'font-size': 'large',
          'z-index': '9999',
        },
      }

      buttons = [
        tab_button('Game'),
        tab_button('Players', '#players'),
        tab_button('Corporations', '#corporations'),
        tab_button('Map', '#map'),
        tab_button('Market', '#market'),
        tab_button('Info', '#info'),
        tab_button('Tiles', '#tiles'),
      ]

      buttons << tab_button('Companies', '#companies') unless @game.companies.all?(&:closed?)

      buttons.concat([
        tab_button('Spreadsheet', '#spreadsheet'),
        tab_button('Tools', '#tools'),
      ])

      h(:div, props, [
        h(:div, { style: { width: 'max-content' } }, buttons),
      ])
    end

    def tab_button(name, anchor = '')
      change_anchor = lambda do
        store(:app_route, "#{@app_route.split('#').first}#{anchor}")
      end

      props = {
        attrs: {
          href: anchor,
          onclick: 'return false',
        },
        style: {
          'margin': '0 2vmin 2vmin 0',
          'color': color_for(:font2),
          'text-decoration': route_anchor == anchor[1..-1] ? '' : 'none',
        },
        on: { click: change_anchor },
      }

      h('a.game__nav', props, name)
    end

    def route_anchor
      @app_route.split('#')[1]
    end

    def render_round
      name = @round.class.name.split(':').last
      description = "#{@game.class.title}: #{name} Round #{@game.turn}"
      description += ".#{@round.round_num} (of #{@game.operating_rounds})" if @round.operating?
      description += @game.finished ? ' - Game Over' : " - #{@round.description}"
      game_end = @game.game_ending_description
      description += " - #{game_end}" if game_end
      description += " - Pinned to Version: #{@pin}" if @pin
      h(:div, { style: { 'font-weight': 'bold', margin: '2vmin 0' } }, description)
    end

    def render_action
      crowded_corps = @round.crowded_corps
      return h(Game::DiscardTrains, corporations: crowded_corps) if @round.crowded_corps.any?

      case @round
      when Engine::Round::Stock
        h(Game::Round::Stock, game: @game)
      when Engine::Round::Operating
        h(Game::Round::Operating, game: @game)
      when Engine::Round::G1846::Draft
        h(Game::Round::Draft, game: @game)
      when Engine::Round::Auction
        h(Game::Round::Auction, game: @game)
      end
    end

    def render_game
      @round = @game.round

      h('div.game', [
        render_round,
        h(Game::GameLog, user: @user),
        h(Game::HistoryControls, num_actions: @num_actions),
        h(Game::EntityOrder, round: @round),
        h(Game::Exchange),
        render_action,
      ])
    end
  end
end
