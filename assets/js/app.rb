# frozen_string_literal: true

require 'compiled-opal'
require 'snabberb'
require 'polyfill'

require 'view/game'
require 'view/tiles'
require 'view/tokens'
require 'engine/game/base'
require 'engine/game/g_1889'

class App < Snabberb::Component
  needs :game, store: true
  needs :page, store: true, default: 'game'

  def render
    page =
      case @page
      when 'game'
        [h(View::Game)]
      when 'tiles'
        [h(View::Tiles)]
      when 'tokens'
        [h(View::Tokens)]
      else
        []
      end

    children = tabs + page

    h(:div, { props: { id: 'app' } }, children)
  end

  def tabs
    [
      h(:button, { on: { click: -> { store(:page, 'game') } } }, 'Game'),
      h(:button, { on: { click: -> { store(:page, 'tiles') } } }, 'Tiles'),
      h(:button, { on: { click: -> { store(:page, 'tokens') } } }, 'Tokens'),
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

players = %w[Ambie Talbot Toby]

game = Engine::Game::G1889.new(players)

App.attach('app', game: game)
