# frozen_string_literal: true

require 'compiled-opal'
require 'snabberb'
require 'polyfill'

require 'index'
require 'user_manager'
require 'engine/game/g_1889'
require 'lib/storage'
require 'view/home'
require 'view/flash'
require 'view/game'
require 'view/navigation'
require 'view/user'

class App < Snabberb::Component
  include GameManager
  include UserManager

  def render
    props = {
      props: { id: 'app' },
      style: {
        padding: '1rem',
        margin: :auto,
      },
    }

    h(:div, props, [
      h(View::Navigation),
      render_banner,
      h(View::Flash),
      render_content,
    ])
  end

  def render_banner
    props = {
      style: {
        'background-color': 'lightgreen',
        'padding': '1em',
      }
    }

    message = <<~MESSAGE
      Thanks for participating in the beta! I've had to drop the current games due to big
      changes and bug fixes. Thanks to everyone who's provided feedback so far!
      Please join me in the 18xx slack #18xxgames channel
    MESSAGE

    h(:div, props, message)
  end

  def render_content
    refresh_user
    handle_history

    path = @app_route.split('#').first || ''
    path = path.split('/').reject(&:empty?).first

    page =
      case path
      when nil
        h(View::Home)
      when 'game'
        render_game
      when 'signup'
        h(View::User, type: :signup)
      when 'login'
        h(View::User, type: :login)
      when 'profile'
        h(View::User, type: :profile)
      else
        raise "404 - Unknown path #{path}"
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
    @game_data['mode'] ||= :multi
    h(View::Game, game_data: @game_data)
  end

  def handle_history
    %x{
      var self = this

      if (!window.onpopstate) {
        window.onpopstate = function() { self.$on_hash_change() }
        self.$store_app_route()
      }

      if (window.location.pathname + window.location.hash != #{@app_route}) {
        window.history.pushState('', '', #{@app_route})
      }
    }
  end

  def on_hash_change
    store_app_route(skip: false)
  end

  def store_app_route(skip: true)
    window_route = `window.location.pathname + window.location.hash`
    store(:app_route, window_route, skip: skip)
  end
end
