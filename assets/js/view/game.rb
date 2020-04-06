# frozen_string_literal: true

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
require 'view/undo_button'

require 'view/all_tiles'
require 'view/all_tokens'

require 'lib/connection'

require 'engine/game/g_1889'
require 'engine/round/auction'
require 'engine/round/operating'
require 'engine/round/stock'

module View
  class Game < Snabberb::Component
    needs :page, store: true, default: 'game'
    needs :show_grid, default: false, store: true
    needs :connection, store: true, default: nil
    needs :game, store: true, default: nil
    needs :app_route, store: true, default: nil
    needs :selected_company, default: nil, store: true

    def render
      unless @game
        store(:app_route, '/')
        return h(:div, 'game not loaded')
      end
      if @game.mode == :multi
        @connection ||= Lib::Connection.new('/game/subscribe', self)
        store(:connection, @connection, skip: true)
      end

      page =
        case @page
        when 'game'
          render_game
        when 'map'
          h(View::Map)
        when 'tiles'
          h(View::AllTiles)
        when 'tokens'
          h(View::AllTokens)
        end

      h(:div, { props: { id: 'app' } }, [
        *tabs,
        page,
      ])
    end

    def tabs
      [
        h(:button, { on: { click: -> { store(:page, 'game') } } }, 'Game'),
        h(:button, { on: { click: -> { store(:page, 'map') } } }, 'Map'),
        h(:button, { on: { click: -> { store(:page, 'tiles') } } }, 'All Tiles'),
        h(:button, { on: { click: -> { store(:page, 'tokens') } } }, 'All Tokens'),
        h(:button, { on: { click: -> { store(:show_grid, !@show_grid) } } }, 'Toggle Tile Grid'),
      ]
    end

    def on_message(type, data)
      case type
      when 'action'
        n_id = data['id']
        o_id = @game.actions.size
        if n_id == o_id
          store(:game, @game.process_action(data))
        elsif n_id > o_id
          @connection.send('refresh')
        end
      when 'refresh'
        store(:game, @game.clone(data))
      end
    end

    def render_round
      name = @round.class.name.split(':').last
      description = @round.operating? ? "#{@game.turn}.#{@round.round_num}" : @game.turn
      description = "#{description} - #{@round.description}"
      h(:div, "#{name} Round #{description}")
    end

    def render_action
      case @round
      when Engine::Round::Auction
        h(AuctionRound, round: @round)
      when Engine::Round::Stock
        h(StockRound, round: @round)
      when Engine::Round::Operating
        h(OperatingRound, round: @round)
      end
    end

    def render_game
      @round = @game.round

      h(:div, { attrs: { id: 'game' } }, [
        render_round,
        h(Log),
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
