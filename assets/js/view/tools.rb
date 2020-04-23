# frozen_string_literal: true

require 'game_manager'
require 'json'
require 'snabberb/component'

module View
  class Tools < Snabberb::Component
    include GameManager

    needs :game, store: true

    def render
      @game_data = @game_data.merge(actions: @game.actions.map(&:to_h))

      props = {
        style: {
           'white-space': 'pre-wrap',
        },
      }

      h(:div, props, [
        render_clone_game,
        `JSON.stringify(#{@game_data.to_n}, null, 2)`,
      ])
    end

    def render_clone_game
      clone_game = lambda do
        store(:game, nil, skip: true)
        create_hotseat(**@game_data, description: "Cloned from game #{@game_data[:id]}")
      end

      props = {
        style: {
          'margin-bottom': '1rem',
        }
      }

      button_props = {
        style: {
          'margin-left': '1rem',
        },
        on: {
          click: clone_game,
        },
      }

      h(:div, props, [
        h(:span, 'Clone this game to play around in hotseat mode'),
        h('button.button', button_props, 'Clone Game'),
      ])
    end
  end
end
