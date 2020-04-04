# frozen_string_literal: true

require 'compiled-opal'
require 'snabberb'
require 'polyfill'

require 'lib/connection'
require 'view/game'
require 'view/map'
require 'view/all_tiles'
require 'view/all_tokens'
require 'engine/game/base'
require 'engine/game/g_1889'

class App < Snabberb::Component
  needs :game, store: true
  needs :page, store: true, default: 'game'
  needs :show_grid, default: false, store: true
  needs :connection, store: true, default: nil

  def render
    @connection ||= Lib::Connection.new('/game/subscribe', self)
    store(:connection, @connection, skip: true)

    page =
      case @page
      when 'game'
        h(View::Game)
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
end

class Index < Snabberb::Layout
  def render
    h(:html, [
      h(:head, [
        h(:meta, props: { charset: 'utf-8' }),
        h(
          :meta,
          props: {
            name: 'viewport',
            content: 'width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=0'
          },
        ),
        h(:title, 'Title'),
      ]),
      h(:body, [
        @application,
        h(:div, props: { innerHTML: @javascript_include_tags }),
        h(:script, props: { innerHTML: @attach_func }),
      ]),
    ])
  end
end

#players = %w[Ambie Talbot Toby]
players = %w[Ambie Toby]

game = Engine::Game::G1889.new(players)

App.attach('app', game: game)
