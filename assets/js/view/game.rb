# frozen_string_literal: true

require 'lib/connection'

require 'view/auction_round'
require 'view/corporation'
require 'view/entity_order'
require 'view/exchange'
require 'view/log'
require 'view/map'
require 'view/operating_round'
require 'view/player'
require 'view/stock_round'
require 'view/stock_market'
require 'view/tile_manifest'
require 'view/undo_button'

# debugging views
# require 'view/all_tiles'
# require 'view/all_tokens'

require 'engine/round/auction'
require 'engine/round/operating'
require 'engine/round/stock'

module View
  class Game < Snabberb::Component
    needs :game_data
    needs :game, default: nil, store: true
    needs :connection, default: nil, store: true
    needs :page, store: true, default: 'game'
    needs :show_grid, default: false, store: true
    needs :selected_company, default: nil, store: true
    needs :app_route, store: true

    def render
      unless @game
        @game = Engine::Game::G1889.new(
          @game_data['players'].map { |p| p['name'] },
          actions: @game_data['actions'],
        )
        store(:game, @game, skip: true)
      end

      if @game_data['mode'] == :multi && !@connection
        connection = Lib::Connection.new(@game_data['id'], self)
        store(:connection, connection, skip: true)
      end

      page =
        case route_anchor
        when nil
          render_game
        when 'map'
          h(View::Map, game: @game)
        when 'market'
          h(StockMarket, stock_market: @game.stock_market)
        when 'tiles'
          h(View::TileManifest, tiles: @game.tiles)
        end

      destroy = lambda do
        @connection.close
        store(:connection, skip: nil)
      end

      props = {
        hook: {
          destroy: destroy,
        }
      }

      h(:div, props, [
        *tabs,
        page,
      ])
    end

    def on_message(data)
      case data['type']
      when 'action'
        data = data['data']
        n_id = data['id']
        o_id = @game.current_action_id
        if n_id == o_id
          store(:game, @game.process_action(data))
        elsif n_id > o_id
          @connection.send('refresh')
        end
      when 'refresh'
        store(:game, @game.clone(data['data']))
      end
    end

    private

    def tabs
      [
        tab_button('Game'),
        tab_button('Map', '#map'),
        tab_button('Market', '#market'),
        tab_button('Tiles', '#tiles'),
      ]
    end

    def tab_button(name, anchor = '')
      onclick = lambda do
        path = @app_route.split('#').first
        store(:app_route, path + anchor)
      end

      props = {
        on: { click: onclick },
        style: {
          'outline-style': 'none',
          'margin': '0 1rem 1rem 0',
        },
      }

      if anchor == "##{route_anchor}" || anchor == '' && !route_anchor # rubocop:disable Style/IfUnlessModifier
        props[:style]['background-color'] = 'lightgray'
      end

      h(:button, props, name)
    end

    def route_anchor
      @app_route.split('#')[1]
    end

    def render_round
      name = @round.class.name.split(':').last
      description = @round.operating? ? "#{@game.turn}.#{@round.round_num}" : @game.turn
      description = "#{description} - #{@round.description}"
      h(:div, { style: { 'font-weight': 'bold' } }, "#{name} Round #{description}")
    end

    def render_action
      case @round
      when Engine::Round::Auction
        h(AuctionRound, game: @game, round: @round)
      when Engine::Round::Stock
        h(StockRound, game: @game, round: @round)
      when Engine::Round::Operating
        h(OperatingRound, round: @round)
      end
    end

    def render_game
      @round = @game.round

      h('div.game', [
        render_round,
        h(Log, log: @game.log),
        h(EntityOrder, round: @round),
        render_action,
        h(Exchange),
        h(UndoButton),
        h(:div, 'Players'),
        *@game.players.map { |p| h(Player, player: p) },
        h(:div, 'Corporations'),
        *@game.corporations.map { |c| h(Corporation, corporation: c) },
        @round.operating? ? h(Map) : h(StockMarket, stock_market: @game.stock_market),
      ])
    end
  end
end
