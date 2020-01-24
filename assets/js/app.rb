# frozen_string_literal: true

require 'compiled-opal'
require 'snabberb'
require 'polyfill'

require 'view/game'
require 'view/tiles'
require 'engine/player'
require 'engine/game/base'
require 'engine/game/g_1889'

class App < Snabberb::Component
  needs :game
  needs :page, store: true, default: 'tiles'

  def render
    h(:div, { props: { id: 'app' } }, [
      *tabs,
      h(View::Game, game: @game, visible: @page == 'game'),
      h(View::Tiles, visible: @page == 'tiles'),
    ])
  end

  def tabs
    [
      h(:button, { on: { click: -> { store(:page, 'game') } } }, 'Game'),
      h(:button, { on: { click: -> { store(:page, 'tiles') } } }, 'Tiles'),
    ]
  end
end

class Index < Snabberb::Layout
  def render
    h(:html, [
      h(:head, [
        h(:meta, props: { charset: 'utf-8' }),
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

players = [
  Engine::Player.new('Ambie'),
  Engine::Player.new('Talbot'),
  Engine::Player.new('Toby'),
]

game = Engine::Game::G1889.new(players)

App.attach('app', game: game)
