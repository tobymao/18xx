# frozen_string_literal: true

require 'game_manager'
require 'lib/settings'
require 'lib/storage'
require 'view/chat'
require 'view/game_row'
require 'view/welcome'

module View
  class Home < Snabberb::Component
    include GameManager
    include Lib::Settings

    needs :user
    needs :refreshing, default: nil, store: true

    def render
      type = get_url_param('games') || (@user ? 'personal' : 'all')
      status = get_url_param('status') || (@user ? 'active' : 'new')

      children = [
        render_header,
        h(Welcome, show_intro: false), # personal_games.size < 2), # TODO: change condition
        h(Chat, user: @user, connection: @connection),
      ]

      children << render_games_links

      acting = false

      case type
      when 'personal'
        if @games.any? { |game| user_is_acting?(@user, game) }
          acting = true
          @games.sort_by! { |game| user_is_acting?(@user, game) ? -game['updated_at'] : 0 }
        end
        render_row(children, "Your #{status.capitalize} Games", @games, :personal, status)
      when 'hs'
        hs_games = Lib::Storage
          .all_keys
          .select { |k| k.start_with?('hs_') }
          .map { |k| Lib::Storage[k] }
          .sort_by { |gd| gd[:id] }
          .reverse

        render_row(children, 'Hotseat Games', hs_games, :hs)
      else
        render_row(children, "#{status&.capitalize} Games", @games, :all, status)
      end

      `document.title = #{(acting ? '* ' : '') + '18xx.Games'}`
      change_favicon(acting)
      change_tab_color(acting)

      game_refresh

      destroy = lambda do
        `clearTimeout(#{@refreshing})`
        store(:refreshing, nil, skip: true)
      end

      props = {
        key: 'home_page',
        hook: {
          destroy: destroy,
        },
      }

      h('div#homepage', props, children)
    end

    def game_refresh
      return unless @user
      return if @refreshing

      timeout = %x{
        setTimeout(function(){
          self['$get_games']()
          self['$store']('refreshing', nil, Opal.hash({skip: true}))
        }, 10000)
      }

      store(:refreshing, timeout, skip: true)
    end

    def render_row(children, header, games, type, status = 'active')
      children << h(
        GameRow,
        header: header,
        game_row_games: games,
        status: status,
        type: type,
        user: @user,
      )
    end

    def render_header
      h('div#greeting', [
        h(:h2, "Welcome#{@user ? ' ' + @user['name'] : ''}!"),
      ])
    end

    def render_games_links
      links =
        if @user
          [
            h(:label, { style: { margin: '0 0.3rem 0 0' } }, 'Your Games:'),
            item('Active', 'personal', 'active'),
            item('New', 'personal', 'new'),
            item('Finished', 'personal', 'finished'),
            item('Archived', 'personal', 'archived'),
            item('Hotseat', 'hs'),
            h(:label, { style: { margin: '0 0.3rem 0 1rem' } }, 'Other Games:'),
          ]
        else
          [
            h(:label, { style: { margin: '0 0.3rem 0 0' } }, 'Games:'),
          ]
        end
      links.concat [
        item('Active', 'all', 'active'),
        item('New', 'all', 'new'),
        item('Finished', 'all', 'finished'),
        item('Archived', 'all', 'archived'),
      ]

      h('nav', links)
    end

    def item(name, type, status)
      search_string = Lib::Storage["search_#{type}_#{status}"]
      params = "?games=#{type}"
      params += "&status=#{status}" if status
      params += "&s=#{Native(`encodeURI(#{search_string})`)}" if search_string

      store_route = lambda do
        get_games(params)
        store(:app_route, params)
      end

      props = {
        attrs: {
          href: params,
          onclick: 'return false',
        },
        on: {
          click: store_route,
        },
        style: {
          margin: '0 0.3rem',
        },
      }
      h(:a, props, name)
    end

    def get_url_param(param)
      return if `typeof URLSearchParams === 'undefined'` # rubocop:disable Lint/LiteralAsCondition

      `(new URLSearchParams(window.location.search)).get(#{param})`
    end
  end
end
