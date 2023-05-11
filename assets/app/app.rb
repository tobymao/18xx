# frozen_string_literal: true

require 'index'
require 'game_manager'
require 'user_manager'
require 'lib/connection'
require 'lib/settings'
require 'lib/storage'
require 'view/about'
require 'view/create_game'
require 'view/game_card_page'
require 'view/home'
require 'view/confirm'
require 'view/flash'
require 'view/game_page'
require 'view/map_page'
require 'view/market_page'
require 'view/navigation'
require 'view/tiles_page'
require 'view/user'
require 'view/forgot'
require 'view/reset'

class App < Snabberb::Component
  include GameManager
  include UserManager
  include Lib::Settings

  needs :pin, default: nil
  needs :title, default: nil
  needs :production, default: nil
  needs :keywords, default: nil

  def render
    props = {
      props: { id: 'app' },
      style: {
        backgroundColor: color_for(:bg) || 'inherit',
        color: color_for(:font) || 'currentColor',
        minHeight: '98vh',
        padding: '0 2vmin 2vmin 2vmin',
        transition: 'background-color 1s ease',
      },
    }

    h(:div, props, [
      h(View::Navigation),
      h(View::Flash),
      h(View::Confirm),
      render_content,
    ])
  end

  def render_content
    store(:connection, Lib::Connection.new(root), skip: true) unless @connection

    js_handlers

    needs_consent = @user && !@user.dig('settings', 'consent')

    page =
      case @app_route
      when /new_game/
        h(View::CreateGame, title: @title, production: @production, keywords: @keywords)
      when /[^?](game|hotseat|tutorial|fixture)/
        render_game
      when /signup/
        h(View::User, type: :signup)
      when /login/
        h(View::User, type: :login)
      when /forgot/
        h(View::Forgot)
      when /reset/
        h(View::Reset)
      when /profile/
        h(View::User, profile: @profile, type: :profile, user: @user)
      when /about/
        h(View::About)
      when /tiles/
        h(View::TilesPage, route: @app_route, connection: @connection)
      when /map/
        h(View::MapPage, route: @app_route)
      when /market/
        h(View::MarketPage, route: @app_route)
      else
        h(View::Home, user: @user)
      end

    page = h(View::About, needs_consent: true) if needs_consent

    h('div#content', [page])
  end

  def render_game
    match = @app_route.match(%r{(hotseat|game|fixture)/((18.*/)?([^?#]*))})

    if !@game_data&.any? # this is a hotseat game
      if @app_route.include?('tutorial')
        enter_tutorial
      elsif @app_route.include?('fixture')
        enter_fixture(match[2])
      else
        enter_game(id: match[2], mode: match[1] == 'game' ? :muti : :hotseat, pin: @pin)
      end
    elsif %w[new archived].include?(@game_data['status'])
      return h(View::GameCardPage, user: @user, game: @game_data)
    elsif !@game_data['loaded'] && !@game_data['loading']
      enter_game(@game_data)
    end

    return h('div.padded', 'Loading game...') unless @game_data&.dig('loaded')

    h(View::GamePage, connection: @connection, user: @user)
  end

  def js_handlers
    %x{
      var self = this

      if (!window.onpopstate) {
        window.onpopstate = function(event) { self.$on_hash_change(event.state) }
        self.$store_app_route()
      }

      var location = window.location

      if (location.pathname + location.search + location.hash != #{@app_route}) {
        window.history.pushState(#{@game_data.to_n}, #{@app_route}, #{@app_route})
      }
    }
  end

  def on_hash_change(state)
    game_data = Hash.new(state)
    store(:game_data, game_data, skip: true) if game_data
    store_app_route(skip: false)
  end

  def store_app_route(skip: true)
    window_route = `window.location.pathname + window.location.search + window.location.hash`
    store(:app_route, window_route, skip: skip) unless window_route == ''
  end
end
