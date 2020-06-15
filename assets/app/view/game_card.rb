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
          width: '23rem',
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
          buttons << render_link(url(@gdata), -> { enter_game(@gdata) }, 'Review')
          FINISHED_GREY
        end

      buttons << render_button('Start', -> { start_game(@gdata) }) if owner? && new? && players.size > 1

      div_props = {
        style: {
          position: 'relative',
          padding: '0.3em 0.1rem 0 0.5rem',
          'background-color': color,
        },
      }

      text_props = {
        style: {
          color: 'black',
          display: 'inline-block',
          'max-width': '13rem',
        },
      }
      owner_props = { attrs: { title: @gdata['user']['name'].to_s }, }

      h('div.header', div_props, [
        h(:div, text_props, [
          h(:div, "Game: #{@gdata['title']}"),
          h('div.nowrap', owner_props, "Owner: #{@gdata['user']['name']}"),
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
          'line-height': '1.2rem',
          padding: '0.3rem 0.5rem',
          'word-break': 'break-all',
        },
      }

      p_elm = players.map.with_index do |player, index|
        short_name = player['name'].length > 19 ? player['name'][0...18] + '…' : player['name']
        if owner? && new? && player['id'] != @user['id']
          button_props = {
            on: { click: -> { kick(@gdata, player) } },
            attrs: {
              title: "kick #{player['name']}",
            },
            style: {
              padding: '0.1rem 0.3rem',
              margin: '0 0.3rem 0.1rem 0.3rem',
            },
          }

          elm = h('button.button', button_props, short_name)
        else
          player_props = { attrs: { title: player['name'].to_s } }

          elm = h(:span, [
            h(acting?(player) ? :em : :span, player_props, short_name),
            index == (players.size - 1) || owner? && new? ? '' : ', ',
          ])
        end
        elm
      end

      children = [
        h(:div, [h(:strong, 'Id: '), @gdata['id'].to_s]),
        h(:div, [h(:strong, 'Description: '), @gdata['description']]),
        h(:div, [h(:strong, 'Players: '), *p_elm]),
      ]

      if new?
        children << h(:div, { style: { display: 'inline' } }, [h(:strong, 'Max Players: '), @gdata['max_players']])
        children << h(:div, { style: { display: 'inline', float: 'right' } }, [
          h(:strong, 'Created: '),
          h(:span, { attrs: { title: @gdata['created_fulldate'] } },
            @gdata['created_at'] == Time.now.strftime('%Y-%m-%d') ? @gdata['created_time'] : @gdata['created_at']),
        ])
      elsif @gdata['status'] == 'finished'
        result = @gdata['result']
          .sort_by { |_, v| -v }
          .map { |k, v| "#{k} (#{v})" }
          .join(', ')

        children << h(:div, [
          h(:strong, 'Result: '),
          result,
        ])
      elsif @gdata['round'] || @gdata['updated_at'] 
        children << h(:div, [
          if @gdata['round']
            h(:div, { style: { display: 'inline' } }, [
              h(:strong, 'Round: '),
              "#{@gdata['round']&.split(' ')&.first} #{@gdata['turn']}",
            ])
          end,
          if @gdata['updated_at']
            h(:div, { style: { display: 'inline', float: 'right' } }, [
              h(:strong, 'Updated: '),
              h(:span, { attrs: { title: @gdata['updated_fulldate'] } },
                @gdata['updated_at'] == Time.now.strftime('%Y-%m-%d') ? @gdata['updated_time'] : @gdata['updated_at']),
            ])
          end,
        ])
      end

      h(:div, props, children)
    end
  end
end
