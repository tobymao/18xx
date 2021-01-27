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
    needs :user, default: nil, store: true
    needs :show_games_sub, default: false, store: true
    needs :show_main_sub, default: false, store: true

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

    def render_games_menu
      toggle_menu = lambda do
        store(:show_games_sub, !@show_games_sub)
        # change z-index to overlap any sticky elements (game-page nav)
        `document.getElementById('header').style.zIndex = #{@show_games_sub ? 1000 : 0}`
      end

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
      } if @show_games_sub
      toggle_props = {
        attrs: {
          href: '#',
          onclick: 'return false',
          title: 'All Games',
        },
        on: {
          click: toggle_menu,
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

    def games_link(label, title, type, status, attrs = {})
      params = "?games=#{type}"
      params += "&status=#{status}" if status

      store_route = lambda do
        get_games(params)
        store(:app_route, "/#{params}")
      end

      a_props = {
        attrs: {
          href: "/#{params}",
          onclick: 'return false',
          title: title,
        },
        on: {
          click: store_route,
        },
      }
      h(:li, attrs, [h(:a, a_props, label)])
    end

    def render_main_menu
      toggle_menu = lambda do
        store(:show_main_sub, !@show_main_sub)
        # change z-index to overlap any sticky elements (game-page nav)
        `document.getElementById('header').style.zIndex = #{@show_main_sub ? 1000 : 0}`
      end

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
      } if @show_main_sub

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
          click: toggle_menu,
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

      h('nav#main_nav', [h('a.toggle', toggle_props, '☰'), h('ul.menu', *menu_props, links)])
    end

    def menu_item(name, anchor)
      h(:li, [h(:a, { attrs: { href: anchor } }, name)])
    end
  end
end
