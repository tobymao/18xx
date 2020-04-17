# frozen_string_literal: true

module View
  class GameCard < Snabberb::Component
    needs :user
    needs :game

    ENTER_GREEN = '#3CB371'.freeze
    JOIN_YELLOW = '#F0E58C'.freeze
    YOUR_TURN_ORANGE = '#FF8C00'.freeze
    FINISHED_GREY = '#D3D3D3'.freeze

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

    def render_header(header)
      color, button_text =
        case @game['status']
        when 'new'
          [JOIN_YELLOW, 'Join']
        when 'active'
          [ENTER_GREEN, 'Enter']
        when 'finished'
          [FINISHED_GREY, 'Review']
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
          top: '1em',
          right: '1em',
        }
      }

      h('div', props, [
        h(:div, text_props, [
          h(:div, "Game: #{@game['title']}"),
          h(:div, "Owner: #{@game['user']['name']}"),
        ]),
        h('button.button', button_props, button_text),
      ])
    end

    def render_body
      props = {
        style: {
          'margin-top': '0.5rem',
          'line-height': '1.2rem',
          'text-overflow': 'ellipsis',
          'white-space': 'nowrap',
          overflow: 'hidden',
        }
      }

      h(:div, props, [
        h(:div, "Name: #{@game['description']}"),
        h(:div, "Max Players: #{@game['max_players']}"),
        h(:div, "Players: #{@game['players'].map { |p| p['name'] }.join(', ')}"),
        h(:div, "Created: #{@game['created_at']}"),
      ])
    end
  end
end
