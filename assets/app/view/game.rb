# frozen_string_literal: true

require 'lib/connection'
require 'lib/params'
require 'view/auction_round'
require 'view/companies'
require 'view/corporations'
require 'view/discard_trains'
require 'view/entity_order'
require 'view/exchange'
require 'view/history_controls'
require 'view/game_log'
require 'view/map'
require 'view/operating_round'
require 'view/players'
require 'view/stock_round'
require 'view/stock_market'
require 'view/tile_manifest'
require 'view/tools'
require 'view/train_and_phase_roster'
require 'view/spreadsheet'

module View
  class Game < Snabberb::Component
    needs :game_data, store: true
    needs :game, default: nil, store: true
    needs :connection
    needs :selected_company, default: nil, store: true
    needs :app_route, store: true
    needs :user
    needs :disable_user_errors

    def render_broken_game(e)
      inner = [h(:div, "We're sorry this game cannot be continued due to #{e}")]
      if e.is_a?(Engine::GameError) && !e.action_id.nil?
        action = e.action_id - 1
        inner << h(:div, [
          h(:a, { attrs: { href: "?action=#{action}" } }, "View the last valid action (#{action})")
        ])
      end
      inner << h(:div, [
        'Please ',
        h(:a, { attrs: { href: 'https://github.com/tobymao/18xx/issues/' } }, 'raise a bug report'),
        " and include the game id (#{@game_data['id']}) and the following JSON data"
      ])
      inner << h(GameData, actions: @game_data['actions'], allow_clone: false)
      h(:div, inner)
    end

    def load_game
      game_id = @game_data['id']
      actions = @game_data['actions']
      @num_actions = actions.size
      cursor = Lib::Params['action']&.to_i
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
      @pin = @game_data&.dig('settings', 'pin')

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
          h(Map, game: @game)
        when 'market'
          h(StockMarket, game: @game, show_bank: true)
        when 'tiles'
          h(TileManifest, tiles: @game.tiles, all_tiles: @game.init_tiles)
        when 'companies'
          h(Companies, game: @game, user: @user)
        when 'corporations'
          h(Corporations, game: @game, user: @user)
        when 'trains'
          h(TrainAndPhaseRoster, game: @game)
        when 'players'
          h(Players, game: @game)
        when 'spreadsheet'
          h(Spreadsheet, game: @game)
        when 'tools'
          h(Tools, game: @game, game_data: @game_data, user: @user)
        end

      @connection.subscribe(game_path) do |data|
        if data['id'] == @game.current_action_id
          @game_data['actions'] << data
          store(:game_data, @game_data, skip: true)
          store(:game, @game.process_action(data))
        else
          @connection.get(game_path) do |new_data|
            store(:game_data, new_data, skip: true)
            store(:game, @game.clone(new_data['actions']))
          end
        end
      end

      destroy = lambda do
        @connection.unsubscribe(game_path)
        store(:selected_company, nil, skip: true)
      end

      props = {
        key: 'game_page',
        hook: {
          destroy: destroy,
        }
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

    def tabs
      props = {
        style: {
          overflow: 'auto',
          position: 'sticky',
          padding: '1.5rem',
          margin: '-16px -1.5rem 1.5rem -1.5rem',
          top: '0',
          'background-color': 'gainsboro',
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
        tab_button('Trains/Phases', '#trains'),
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
          'margin': '0 1rem 1rem 0',
          'color': 'black',
          'text-decoration': (route_anchor || '') == anchor ? '' : 'none',
        },
        on: { click: change_anchor },
      }

      h(:a, props, name)
    end

    def route_anchor
      @app_route.split('#')[1]
    end

    def render_round
      name = @round.class.name.split(':').last
      description = @round.operating? ? "#{@game.turn}.#{@round.round_num}" : @game.turn
      description = "#{description} - #{@round.description}"
      description = "#{description} - Pinned to Version: #{@pin}" if @pin
      h(:div, { style: { 'font-weight': 'bold' } }, "#{name} Round #{description}")
    end

    def render_action
      crowded_corps = @round.crowded_corps
      return h(DiscardTrains, corporations: crowded_corps) if @round.crowded_corps.any?

      case @round
      when Engine::Round::Auction
        h(AuctionRound, game: @game)
      when Engine::Round::Stock
        h(StockRound, game: @game)
      when Engine::Round::Operating
        h(OperatingRound, game: @game)
      end
    end

    def render_game
      @round = @game.round

      h('div.game', [
        render_round,
        h(GameLog, user: @user),
        h(HistoryControls, num_actions: @num_actions),
        h(EntityOrder, round: @round),
        h(Exchange),
        render_action,
      ])
    end
  end
end
