# frozen_string_literal: true

require 'game_manager'
require 'view/create_game'

module View
  class Home < Snabberb::Component
    include GameManager

    needs :user, default: nil, store: true

    def render
      h('div.pure-u-1', [
        h(CreateGame),
        render_new_games,
      ])
    end

    def render_new_games
      boxes = @games.map do |game|
        render_game_box(game)
      end

      h('div.pure-u-1', boxes)
    end

    def render_game_box(game)
      props = {
        style: {
          'text-align': 'center',
          'border-bottom': '1px solid gainsboro',
        }
      }

      children = [
        line('Game', game['title']),
        line('Owner', game['user']['name']),
        line('Description', "Id: #{game['id']} #{game['description']}"),
        line('Players', game['players'].map { |p| p['name'] }.join(', ')),
        line('Created', game['created_at']),
        line('Updated', game['updated_at']),
      ]

      box = h('div.pure-u-1-2.pure-u-md-1-3.pure-u-lg-1-4', props, children)

      if game['status'] != 'new'
        children << button('Enter', -> { enter_game(game) })
        return box
      end

      return box unless @user

      if game['user']['id'] == @user['id']
        children << button('Start', -> { start_game(game) })
        children << button('Delete', -> { delete_game(game) })
      elsif game['players'].any? { |p| p['id'] == @user['id'] }
        children << button('Leave', -> { leave_game(game) })
      else
        children << button('Join', -> { join_game(game) })
      end

      box
    end

    def line(key, value)
      props = {
        style: {
          margin: '0.2em',
        },
      }

      h('div.pure-u-1', props, [
        h('div.pure-u-1-2', "#{key}:"),
        h('div.pure-u-1-2', value),
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

      h('button.pure-button.pure-button-secondary', props, name)
    end
  end
end
