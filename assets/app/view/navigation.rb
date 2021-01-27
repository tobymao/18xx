# frozen_string_literal: true

require 'game_manager'
require 'lib/connection'
require 'lib/settings'
require 'view/create_game'
require 'view/logo'

module View
  class Navigation < Snabberb::Component
    include Lib::Settings
    needs :app_route, default: nil, store: true
    needs :user, default: nil, store: true

    include GameManager

    def render
      store(:connection, Lib::Connection.new(root), skip: true) unless @connection
      links = if @user
                [item("Profile (#{@user['name']})", '/profile')]
              else
                [item('Signup', '/signup'), item('Login', '/login')]
              end
      links << item('About', '/about')

      props = {
        style: {
          display: 'grid',
          grid: '1fr / auto 1fr',
          position: 'sticky',
          top: '0',
          padding: '0.5vmin 0',
          backgroundColor: color_for(:bg),
          boxShadow: '0 2px 0 0 gainsboro',
        },
      }

      h('div#header', props, [
        h(Logo),
        h(:div, [
          h('nav#games', [render_games_links]),
          h('nav#main', [h('ul.no_margin.no_padding', links)]),
        ]),
      ])
    end

    def item(name, anchor)
      h('li.nav', [h(:a, { attrs: { href: anchor } }, name)])
    end

    def render_games_links
      links =
        if @user
          [
            h('li.nav', [h(:label, 'Your Games:')]),
            games_link('Active', 'personal', 'active'),
            games_link('New', 'personal', 'new'),
            games_link('Finished', 'personal', 'finished'),
            games_link('Hotseat', 'hs'),
            h('li.nav', [h(:label, 'Other Games:')]),
          ]
        else
          [h('li.nav', [h(:label, 'Games:')])]
        end
      links.concat [
        games_link('Active', 'all', 'active'),
        games_link('New', 'all', 'new'),
        games_link('Finished', 'all', 'finished'),
      ]
      links << games_link('Hotseat', 'hs') unless @user
      h('ul.no_margin.no_padding', links)
    end

    def games_link(name, type, status)
      params = "?games=#{type}"
      params += "&status=#{status}" if status

      store_route = lambda do
        get_games(params)
        store(:app_route, "/#{params}")
      end

      props = {
        attrs: {
          href: "/#{params}",
          onclick: 'return false',
        },
        on: {
          click: store_route,
        },
      }
      h('li.nav', [h(:a, props, name)])
    end
  end
end
