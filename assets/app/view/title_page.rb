# frozen_string_literal: true

require 'game_manager'
require 'lib/settings'
require 'lib/storage'
require 'view/chat'
require 'view/game_row'
require 'view/game/game_meta'

module View
  class TitlePage < Snabberb::Component
    include GameManager
    include Lib::Settings

    needs :user
    needs :route
    needs :refreshing, default: nil, store: true

    ROUTE_FORMAT = %r{/title/([^/?]*)/?}.freeze

    def render
      @game_title = @route.match(ROUTE_FORMAT)[1].gsub('%20', ' ')

      your_games, other_games = @games
        .partition { |game| user_in_game?(@user, game) || user_owns_game?(@user, game) }

      children = [
        render_game_info,
        h(Chat, user: @user, connection: @connection),
      ]

      # these will show up in the profile page
      your_games.reject! { |game| game['status'] == 'finished' }

      grouped = other_games.group_by { |game| game['status'] }

      # Ready, then active, then unstarted, then completed
      your_games.sort_by! do |game|
        [
          user_is_acting?(@user, game) ? -game['updated_at'] : 0,
          game['status'] == 'active' ? -game['updated_at'] : 0,
          game['status'] == 'new' ? -game['created_at'] : 0,
          -game['updated_at'],
        ]
      end

      render_row(children, 'Your Games', your_games, :personal) if @user
      render_row(children, 'New Games', grouped['new'], :new) if @user
      render_row(children, 'Active Games', grouped['active'], :active)
      render_row(children, 'Finished Games', grouped['finished'], :finished)

      game_refresh

      acting = your_games.any? { |game| user_is_acting?(@user, game) }
      `document.title = #{(acting ? '* ' : '') + '18xx.Games'}`
      change_favicon(acting)
      change_tab_color(acting)

      destroy = lambda do
        `clearTimeout(#{@refreshing})`
        store(:refreshing, nil, skip: true)
      end

      props = {
        key: 'title_page',
        hook: {
          destroy: destroy,
        },
      }

      h('div#titlepage', props, children)
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
        title: @game_title,
      )
    end

    def render_game_info
      game_klass = Engine::GAMES_BY_TITLE[@game_title]
      players = Engine.player_range(game_klass).max.times.map { |n| "Player #{n + 1}" }
      game = game_klass.new(players)

      children = [
        h(:h1, @game_title),
        h(GameMeta, game: game),
        h(:p, [h(:a, { attrs: { href: "/map/#{@game_title}", target: '_blank' } }, 'Sample Map')]),
        h(:p, [h(:a, { attrs: { href: "/market/#{@game_title}", target: '_blank' } }, 'Sample Market')]),
      ]

      h('div.half', children)
    end
  end
end
