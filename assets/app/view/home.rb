# frozen_string_literal: true

require 'game_manager'
require 'lib/storage'
require 'view/chat'
require 'view/game_row'
require 'view/welcome'

module View
  class Home < Snabberb::Component
    include GameManager

    needs :user
    needs :refreshing, default: nil, store: true

    def render
      children = [
        render_header,
        h(Welcome),
        h(Chat, user: @user, connection: @connection),
      ]

      your_games, other_games = @games.partition { |game| user_in_game?(@user, game) }

      # these will show up in the profile page
      your_games.reject! { |game| game['status'] == 'finished' }

      grouped = other_games.group_by { |game| game['status'] }

      # Ready, then active, then unstarted, then completed
      your_games.sort_by! do |game|
        [
          user_is_acting?(@user, game) ? -game['id'] : 0,
          game['status'] == 'active' ? -game['id'] : 0,
          game['status'] == 'new' ? -game['id'] : 0,
          -game['id'],
        ]
      end

      hotseat = Lib::Storage
        .all_keys
        .select { |k| k.start_with?('hs_') }
        .map { |k| Lib::Storage[k] }
        .sort_by { |gd| gd[:id] }
        .reverse

      render_row(children, 'Your Games', your_games, :personal) if @user
      render_row(children, 'Hotseat Games', hotseat, :hotseat) if hotseat.any?
      render_row(children, 'New Games', grouped['new'], :new) if @user
      render_row(children, 'Active Games', grouped['active'], :active)
      render_row(children, 'Finished Games', grouped['finished'], :finished)

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

      h(:div, props, children)
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

    def render_row(children, header, games, type)
      return unless games&.any?

      children << h(
        GameRow,
        header: header,
        game_row_games: games,
        type: type,
        user: @user,
      )
    end

    def render_header
      h('div.card_header', [
        "Welcome#{@user ? ' ' + @user['name'] : ''}!",
      ])
    end
  end
end
