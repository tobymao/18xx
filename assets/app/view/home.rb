# frozen_string_literal: true

require 'game_manager'
require 'lib/params'
require 'lib/settings'
require 'lib/storage'
require 'view/chat'
require 'view/game_row'
require 'view/welcome'

module View
  class Home < Snabberb::Component
    include GameManager
    include Lib::Settings

    needs :autoscroll, default: true, store: true
    needs :refreshing, default: nil, store: true
    needs :user

    def render
      type = Lib::Params['games'] || (@user ? 'personal' : 'all')
      status = Lib::Params['status'] || 'active'

      children = [
        render_header,
        h(Welcome, show_intro: !@user),
        h(Chat, user: @user, connection: @connection),
      ]

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
        render_row(children, "#{status.capitalize} Games", @games, :all, status)
      end

      # without timeout element might not exist
      `setTimeout(function(){
        document.getElementById('games_list').scrollIntoView();
        window.scrollBy(0, -55);
      }, 100);` if @autoscroll == true && @app_route != '/'
      store(:autoscroll, false, skip: true)

      game_refresh

      `document.title = #{(acting ? '* ' : '') + '18xx.Games'}`
      change_favicon(acting)
      change_tab_color(acting)

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
  end
end
