# frozen_string_literal: true

require 'game_manager'
require 'view/game_row'
require 'view/welcome'

module View
  class Home < Snabberb::Component
    include GameManager

    needs :user, default: nil, store: true

    def render
      children = [
        h(Welcome, user: @user),
      ]

      grouped = @games.group_by { |game| game['status'] }

      your_games, active_games = grouped['active']&.partition do |game|
        user_in_game?(@user, game)
      end

      if @user
        render_row(children, 'Your Games', your_games)
        render_row(children, 'New Games', grouped['new'])
      end

      render_row(children, 'Active Games', active_games)
      render_row(children, 'Finished Games', grouped['finished'])

      h(:div, children)
    end

    def render_row(children, header, games)
      return unless games&.any?

      children << h(GameRow, header: header, games: games, user: @user)
    end

    def render_game_box(game)
      props = {
        style: {
          'text-align': 'center',
          'border-top': '1px solid gainsboro',
        }
      }

      children = [
        line('Game', game['title']),
        line('Owner', game['user']['name']),
        line('Description', "Id: #{game['id']} #{game['description']}"),
        line('Players', game['players'].map { |p| p['name'] }.join(', ')),
        line('Created', game['created_at']),
      ]

      box = h(:div, props, children)

      if game['status'] != 'new'
        children << button('Enter', -> { enter_game(game) })
        return box
      end

      return box unless @user

      if game['user']['id'] == @user['id']
        children << button('Start', -> { start_game(game) }) if game['players'].size > 1
        children << button('Delete', -> { delete_game(game) })
      elsif game['players'].any? { |p| p['id'] == @user['id'] }
        children << button('Leave', -> { leave_game(game) })
      elsif game['max_players'] > game['players'].size
        children << button('Join', -> { join_game(game) })
      end

      box
    end

    def line(key, value)
      props = {
        style: {
          margin: '0.5em',
          display: 'inline-block',
        },
      }

      h(:div, props, [
        h(:div, "#{key}:"),
        h(:div, value),
      ])
    end

    def button(name, action)
      props = {
        attrs: { type: :button },
        on: { click: action },
        style: {
          margin: '1rem',
        }
      }

      h(:button, props, name)
    end
  end
end
