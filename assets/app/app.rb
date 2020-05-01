# frozen_string_literal: true

require 'index'
require 'game_manager'
require 'user_manager'
require 'lib/connection'
require 'lib/storage'
require 'view/about'
require 'view/create_game'
require 'view/home'
require 'view/flash'
require 'view/game'
require 'view/navigation'
require 'view/all_tiles'
require 'view/user'

class App < Snabberb::Component
  include GameManager
  include UserManager

  def render
    props = {
      props: { id: 'app' },
      style: {
        padding: '0.5rem',
        margin: :auto,
      },
    }

    h(:div, props, [
      h(View::Navigation),
      h(View::Flash),
      render_content,
    ])
  end

  def render_content
    store(:connection, Lib::Connection.new(root), skip: true) unless @connection

    refresh_user
    js_handlers

    page =
      case @app_route
      when /new_game/
        h(View::CreateGame)
      when /game|hotseat/
        render_game
      when /signup/
        h(View::User, user: @user, type: :signup)
      when /login/
        h(View::User, user: @user, type: :login)
      when /profile/
        h(View::User, user: @user, type: :profile)
      when /about/
        h(View::About)
      when /all_tiles/
        h(View::AllTiles)
      else
        h(View::Home, user: @user)
      end

    props = {
      style: {
        padding: '0 1rem',
        margin: '1rem 0',
      },
    }

    h(:div, props, [page])
  end

  def render_game
    match = @app_route.match(%r{(hotseat|game)\/((hs_)?\d+)})

    unless @game_data # this only happens when refreshing a hotseat game
      enter_game(id: match[2], mode: match[1] == 'game' ? :muti : :hotseat)
      return h(:div, 'Loading game...') unless @game_data
    end

    h(View::Game, connection: @connection, game_data: @game_data, user: @user)
  end

  def js_handlers
    %x{
      var self = this

      if (!window.onpopstate) {
        window.onpopstate = function(event) { self.$on_hash_change(event.state) }
        self.$store_app_route()
      }

      if (window.location.pathname + window.location.hash != #{@app_route}) {
        window.history.pushState(#{@game_data.to_n}, #{@app_route}, #{@app_route})
      }
    }
  end

  def on_hash_change(state)
    game_data = Hash.new(state)
    store(:game_data, game_data, skip: true) if game_data.any?
    store_app_route(skip: false)
  end

  def store_app_route(skip: true)
    window_route = `window.location.pathname + window.location.hash`
    store(:app_route, window_route, skip: skip)
  end
end
