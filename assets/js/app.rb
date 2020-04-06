# frozen_string_literal: true

require 'compiled-opal'
require 'snabberb'
require 'polyfill'

require 'view/home'
require 'view/game'
require 'view/navigation'

class App < Snabberb::Component
  needs :app_route, default: '/', store: true

  def render
    h(:div, { props: { id: 'app' } }, [
      h(View::Navigation),
      render_content,
    ])
  end

  def render_content
    path = @app_route.split('/').reject(&:empty?).first

    handle_history

    page =
      case path
      when nil
        h(View::Home)
      when 'game'
        h(View::Game)
      end

    props = {
      style: {
        padding: '1rem',
      },
    }

    h(:div, props, [page])
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

class Index < Snabberb::Layout
  def render
    css = <<~CSS
      * { font-family: Arial; }
    CSS

    view_port = {
      name: 'viewport',
      content: 'width=device-width, initial-scale=1, maximum-scale=1.0, minimum-scale=1.0, user-scalable=0',
    }

    h(:html, [
      h(:head, [
        h(:meta, props: { charset: 'utf-8' }),
        h(:meta, props: view_port),
        h(:title, '18xx.games'),
        h(:link, attrs: { rel: 'stylesheet', href: 'https://unpkg.com/purecss@1.0.1/build/pure-min.css' }),
        h(:link, attrs: { rel: 'stylesheet', href: 'https://unpkg.com/purecss@1.0.1/build/grids-responsive-min.css' }),
        h(:style, props: { innerHTML: css }),
      ]),
      h(:body, [
        @application,
        h(:div, props: { innerHTML: @javascript_include_tags }),
        h(:script, props: { innerHTML: @attach_func }),
      ]),
    ])
  end
end
