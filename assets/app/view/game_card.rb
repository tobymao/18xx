# frozen_string_literal: true

require 'view/game_row'
require 'view/link'

module View
  class GameCard < Snabberb::Component
    include GameManager

    needs :user
    needs :gdata # can't conflict with game_data
    needs :confirm_delete, store: true, default: false

    ENTER_GREEN = '#3CB371'
    JOIN_YELLOW = '#F0E58C'
    YOUR_TURN_ORANGE = '#FF8C00'
    FINISHED_GREY = '#D3D3D3'

    def render
      props = {
        style: {
          display: 'inline-block',
          border: 'solid 1px currentColor',
          'border-radius': '10px',
          overflow: 'hidden',
          padding: '0.5rem',
          width: '320px',
          'margin': '0 0.5rem 0.5rem 0',
          'vertical-align': 'top',
        },
      }

      h(:div, props, [
        render_header,
        render_body,
      ])
    end

    def new?
      @gdata['status'] == 'new'
    end

    def owner?
      user_owns_game?(@user, @gdata)
    end

    def players
      @gdata['players']
    end

    def acting?(player)
      return false unless player
      return false unless (acting = @gdata['acting'])

      acting.include?(player[:id])
    end

    def render_header
      buttons = []
      if owner?
        buttons << if @confirm_delete != @gdata['id']
                     render_button('Delete', -> { store(:confirm_delete, @gdata['id']) })
                   else
                     render_button('Confirm', -> { delete_game(@gdata) })
                   end
      end

      color =
        case @gdata['status']
        when 'new'
          if owner?
          elsif user_in_game?(@user, @gdata)
            buttons << render_button('Leave', -> { leave_game(@gdata) })
          elsif players.size < @gdata['max_players']
            buttons << render_button('Join', -> { join_game(@gdata) })
          end
          JOIN_YELLOW
        when 'active'
          buttons << render_link(url(@gdata), -> { enter_game(@gdata) }, 'Enter')
          acting?(@user) ? YOUR_TURN_ORANGE : ENTER_GREEN
        when 'finished'
          buttons << render_link(url(@gdata), -> { enter_game(@gdata) }, 'Enter')
          FINISHED_GREY
        end

      buttons << render_button('Start', -> { start_game(@gdata) }) if owner? && new? && players.size > 1

      props = {
        style: {
          position: 'relative',
          margin: '-0.5em',
          padding: '0.5em',
          'background-color': color,
        },
      }

      text_props = {
        style: {
          color: 'black',
          display: 'inline-block',
          width: '160px',
        },
      }

      h('div', props, [
        h(:div, text_props, [
          h(:div, "Game: #{@gdata['title']}"),
          h(:div, "Owner: #{@gdata['user']['name']}"),
        ]),
        *buttons,
      ])
    end

    def render_button(text, action)
      props = {
        style: {
          top: '1rem',
          float: 'right',
          'border-radius': '5px',
          'margin': '0 0.3rem',
          padding: '0.2rem 0.5rem',
        },
        on: {
          click: action,
        },
      }

      h('button.button', props, text)
    end

    def render_link(href, click, text)
      h(
        Link,
        href: href,
        click: click,
        children: text,
        style: {
          top: '1rem',
          float: 'right',
          'border-radius': '5px',
          'margin': '0 0.3rem',
          padding: '0.2rem 0.5rem',
        },
        class: '.button-link'
      )
    end

    def render_body
      props = {
        style: {
          'margin-top': '0.5rem',
          'line-height': '1.2rem',
          'word-break': 'break-all',
        },
      }

      p_elm = players.map.with_index do |player, index|
        elm = h(
          acting?(player) ? :u : :span,
          { style: { 'margin-right': '0.5rem' } },
          player['name'] + (index != (players.size - 1) ? ',' : ''),
        )

        if owner? && new? && player['id'] != @user['id']
          button_props = {
            on: { click: -> { kick(@gdata, player) } },
            style: {
              'margin-left': '0.5rem',
            },
          }
          elm = h('button.button', button_props, [elm])
        end

        elm
      end

      children = [
        h(:div, [h(:b, 'Id: '), @gdata['id'].to_s]),
        h(:div, [h(:b, 'Description: '), @gdata['description']]),
        h(:div, [h(:b, 'Players: '), *p_elm]),
      ]

      if new?
        children << h(:div, [h(:b, 'Max Players: '), @gdata['max_players']])
        children << h(:div, [h(:b, 'Created: '), @gdata['created_at']])
      elsif @gdata['status'] == 'finished'
        result = @gdata['result']
          .sort_by { |_, v| -v }
          .map { |k, v| "#{k} (#{v})" }
          .join(', ')

        children << h(:div, [
          h(:b, 'Result: '),
          result,
        ])
      else
        children << h(:div, [
          h(:b, 'Round: '), "#{@gdata['round']&.split(' ')&.first} #{@gdata['turn']} ",
          h(:b, 'Updated: '), @gdata['updated_at']
        ])
      end

      h(:div, props, children)
    end
  end
end
