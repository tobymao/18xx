# frozen_string_literal: true

require 'view/game_row'

module View
  class GameCard < Snabberb::Component
    include GameManager

    needs :user
    needs :game

    ENTER_GREEN = '#3CB371'
    JOIN_YELLOW = '#F0E58C'
    YOUR_TURN_ORANGE = '#FF8C00'
    FINISHED_GREY = '#D3D3D3'

    def render
      props = {
        style: {
          display: 'inline-block',
          border: 'solid 1px black',
          padding: '0.5rem',
          width: '320px',
          'margin': '0 0.5rem 0.5rem 0',
          'vertical-align': 'top',
        }
      }

      h(:div, props, [
        render_header,
        render_body,
      ])
    end

    def new?
      @game['status'] == 'new'
    end

    def owner?
      user_owns_game?(@user, @game)
    end

    def players
      @game['players']
    end

    def render_header
      color, button_text, action =
        case @game['status']
        when 'new'
          if owner?
            [JOIN_YELLOW, 'Delete', -> { delete_game(@game) }]
          elsif user_in_game?(@user, @game)
            [JOIN_YELLOW, 'Leave', -> { leave_game(@game) }]
          else
            [JOIN_YELLOW, 'Join', -> { join_game(@game) }]
          end
        when 'active'
          [ENTER_GREEN, 'Enter', -> { enter_game(@game) }]
        when 'finished'
          [FINISHED_GREY, 'Review', -> { enter_game(@game) }]
        end

      props = {
        style: {
          position: 'relative',
          margin: '-0.5em',
          padding: '0.5em',
          'background-color': color,
        }
      }

      text_props = {
        style: {
          display: 'inline-block',
          width: '240px',
        }
      }

      button_props = {
        style: {
          position: 'absolute',
          top: '1rem',
          right: '1rem',
        },
        on: {
          click: action,
        },
      }

      buttons = [
        h('button.button', button_props, button_text),
      ]

      if owner? && new? && players.size > 1
        start_props = {
          style: {
            position: 'absolute',
            top: '1rem',
            right: '90px',
          },
          on: { click: -> { start_game(@game) } },
        }
        buttons << h('button.button', start_props, 'Start')
      end

      h('div', props, [
        h(:div, text_props, [
          h(:div, "Game: #{@game['title']}"),
          h(:div, "Owner: #{@game['user']['name']}"),
          *buttons,
        ]),
      ])
    end

    def render_body
      props = {
        style: {
          'margin-top': '0.5rem',
          'line-height': '1.2rem',
        }
      }

      p_elm = players.map { |p| p['name'] }.join(', ')

      if owner? && new?
        p_elm = players.map do |player|
          if player['id'] == @user['id']
            player['name']
          else
            button_props = {
               on: { click: -> { kick(@game, player) } },
               style: {
                 'margin-left': '0.5rem',
               },
            }
            h('button.button', button_props, player['name'])
          end
        end
      end

      h(:div, props, [
        h(:div, [h(:b, 'Id: '), @game['id']]),
        h(:div, [h(:b, 'Description: '), @game['description']]),
        h(:div, [h(:b, 'Max Players: '), @game['max_players']]),
        h(:div, [h(:b, 'Players: '), *p_elm]),
        h(:div, [h(:b, 'Created: '), @game['created_at']]),
      ])
    end
  end
end
