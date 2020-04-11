# frozen_string_literal: true

require 'compiled-opal'
require 'snabberb'
require 'polyfill'

require 'index'
require 'user_manager'
require 'engine/game/g_1889'
require 'lib/storage'
require 'view/home'
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
        'max-width': '1024px',
      },
    }

    h('div.pure-g', props, [
      h(View::Navigation),
      render_content,
    ])
  end

  def render_content
    path = @app_route.split('/').reject(&:empty?).first

    refresh_user
    handle_history

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
        padding: '0 1em',
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
      }

      if (window.location.pathname != #{@app_route}) {
        window.history.pushState('', '', #{@app_route})
      }
    }
  end

  def on_hash_change
    store(:app_route, `window.location.pathname`)
  end
end
