# frozen_string_literal: true

require 'game_manager'
require 'lib/connection'
require 'lib/settings'
require 'view/create_game'
require 'view/logo'

module View
  class Navigation < Snabberb::Component
    include GameManager
    include Lib::Settings
    needs :app_route, default: nil, store: true
    needs :autoscroll, default: false, store: true
    needs :show_games_submenu, default: false, store: true
    needs :show_main_submenu, default: false, store: true
    needs :user, default: nil, store: true

    def render
      store(:connection, Lib::Connection.new(root), skip: true) unless @connection

      head_props = {
        style: {
          display: 'grid',
          grid: '1fr / auto 1fr',
          position: 'sticky',
          top: '0',
          margin: '0 -2vmin',
          padding: '0.5vmin 2vmin',
          backgroundColor: color_for(:bg),
          boxShadow: '0 2px 0 0 gainsboro',
          zIndex: '10',
        },
      }
      nav_props = {
        style: {
          display: 'grid',
          grid: '1fr / 1fr auto',
          alignItems: 'center',
          justifyItems: 'center',
        },
      }

      h('div#header', head_props, [
        h(Logo),
        h(:div, nav_props, [
          render_games_menu,
          render_main_menu,
        ]),
      ])
    end

    def toggle_menu(event, games = false)
      event.JS.stopPropagation
      if games
        store(:show_games_submenu, !@show_games_submenu, skip: false)
      else
        store(:show_main_submenu, !@show_main_submenu, skip: false)
      end
      # change z-index to overlap any sticky elements (game-page nav)
      `document.getElementById('header').style.zIndex = #{@show_games_submenu || @show_main_submenu ? 1000 : 10}`
    end

    def render_games_menu
      li_props = {
        style: {
          position: 'relative',
        },
      }
      submenu_props = {
        style: {
          display: 'none',
        },
      }
      submenu_props = {
        style: {
          display: 'block',
          position: 'absolute',
          left: '0',
          backgroundColor: color_for(:bg),
        },
      } if @show_games_submenu
      toggle_props = {
        attrs: {
          href: '#',
          onclick: 'return false',
          title: 'All Games',
        },
        on: {
          click: ->(event) { toggle_menu(event, true) },
        },
      }

      sub_links = if @user
                    [
                      games_link('New', 'Your New Games', 'personal', 'new'),
                      games_link('Finished', 'Your Finished Games', 'personal', 'finished'),
                      games_link('Hotseat', 'Your Hotseat Games', 'hs', '',
                                 { style: { borderBottom: '1px solid' } }),
                    ]
                  else
                    []
                  end
      sub_links << games_link("#{'All ' if @user}Active", "#{"Others' " if @user}Active Games", 'all', 'active')
      sub_links << games_link('All New', "Others' New Games", 'all', 'new') if @user
      sub_links << games_link("#{'All ' if @user}Finished", "#{"Others' " if @user}Finished Games", 'all', 'finished')
      sub_links << games_link('Hotseat', 'Your Hotseat Games', 'hs') unless @user
      games_submenu = h('ul.submenu', submenu_props, sub_links)
      links = if @user
                [games_link('Your Games', 'Your Active Games', 'personal', 'active'),
                 h(:li, li_props, [h(:a, toggle_props, 'more'), games_submenu])]
              else
                [h(:li, li_props, [h(:a, toggle_props, 'View Games'), games_submenu])]
              end

      h('nav#games_nav', [h('ul.menu', links)])
    end

    def store_route(event, params = nil)
      event.JS.stopPropagation
      get_games(params) if params
      store(:autoscroll, true, skip: true)
      store(:app_route, "/#{params}")
    end

    def games_link(label, title, type, status, attrs = {})
      params = "?games=#{type}"
      params += "&status=#{status}" if status

      a_props = {
        attrs: {
          href: "/#{params}",
          onclick: 'return false',
          title: title,
        },
        on: {
          click: ->(event) { store_route(event, params) },
        },
      }
      h(:li, attrs, [h(:a, a_props, label)])
    end

    def render_main_menu
      menu_props = {
        style: {
          display: 'block',
          position: 'absolute',
          right: '0',
          minWidth: '5rem',
          backgroundColor: color_for(:bg),
        },
        class: {
          submenu: true,
        },
      } if @show_main_submenu

      toggle_props = {
        attrs: {
          href: '#',
          onclick: 'return false',
          title: 'Menu',
        },
        style: {
          position: 'relative',
          fontSize: '1.5rem',
        },
        on: {
          click: ->(event) { toggle_menu(event, false) },
        },
      }
      toggle_props[:style][:color] = 'red' unless @user

      links = if @user
                [menu_item("Profile (#{@user['name']})", '/profile')]
              else
                [menu_item('Signup', '/signup'),
                 menu_item('Login', '/login')]
              end
      links << menu_item('About', '/about')

      h('nav#main_nav', [h('a.toggle', toggle_props, '☰'), h('ul.menu', menu_props, links)])
    end

    def menu_item(name, anchor)
      h(:li, [h(:a, { attrs: { href: anchor } }, name)])
    end
  end
end
