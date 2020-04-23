# frozen_string_literal: true

require 'lib/connection'

require 'view/auction_round'
require 'view/companies'
require 'view/corporations'
require 'view/entity_order'
require 'view/exchange'
require 'view/log'
require 'view/map'
require 'view/operating_round'
require 'view/players'
require 'view/stock_round'
require 'view/stock_market'
require 'view/tile_manifest'
require 'view/tools'
require 'view/train_roster'

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
    needs :connection
    needs :show_grid, default: false, store: true
    needs :selected_company, default: nil, store: true
    needs :app_route, store: true

    def render
      game_id = @game_data[:id]
      if game_id != @game&.id
        @game = Engine::Game::G1889.new(
          @game_data['players'].map { |p| p['name'] },
          id: game_id,
          actions: @game_data['actions'],
        )
        store(:game, @game, skip: true)
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
          h(TileManifest, tiles: @game.tiles)
        when 'companies'
          h(Companies, game: @game, user: @user)
        when 'corporations'
          h(Corporations, game: @game, user: @user)
        when 'trains'
          h(TrainRoster, game: @game)
        when 'players'
          h(Players, game: @game)
        when 'tools'
          h(Tools, game: @game, game_data: @game_data)
        end

      @connection.subscribe(game_path) do |data|
        if data['id'] == @game.current_action_id
          store(:game, @game.process_action(data))
        else
          @connection.get(game_path) do |new_data|
            store(:game, @game.clone(new_data['actions']))
          end
        end
      end

      destroy = lambda do
        @connection.unsubscribe(game_path)
        store(:show_grid, false, skip: true)
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

      h(:div, props, [
        h(:div, { style: { width: 'max-content' } }, [
          tab_button('Game'),
          tab_button('Players', 'players'),
          tab_button('Corporations', 'corporations'),
          tab_button('Map', 'map'),
          tab_button('Market', 'market'),
          tab_button('Trains', 'trains'),
          tab_button('Tiles', 'tiles'),
          tab_button('Companies', 'companies'),
          tab_button('Tools', 'tools'),
        ]),
      ])
    end

    def tab_button(name, anchor = '')
      change_anchor = lambda do
        store(:app_route, "#{@app_route.split('#').first}##{anchor}")
      end

      props = {
        attrs: {
          href: "##{anchor}",
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
      h(:div, { style: { 'font-weight': 'bold' } }, "#{name} Round #{description}")
    end

    def render_action
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
        h(:div, { style: { margin: '1rem 0 1rem 0' } }, [
          h(Log, log: @game.log),
        ]),
        h(EntityOrder, round: @round),
        h(Exchange),
        render_action,
      ])
    end
  end
end
