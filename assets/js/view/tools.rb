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
      @json = `JSON.stringify(#{@game_data.to_n}, null, 2)`

      props = {
        style: {
           'white-space': 'pre-wrap',
        },
      }

      h(:div, props, [
        render_clone_game,
        @json,
      ])
    end

    def render_clone_game
      clone_game = lambda do
        store(:game, nil, skip: true)
        create_hotseat(**@game_data, description: "Cloned from game #{@game_data[:id]}")
      end

      copy_data = lambda do
        `navigator.clipboard.writeText(self.json)`

        store(
          :flash_opts,
          { message: 'Copied Data', color: 'lightgreen' },
          skip: false,
        )
      end

      clone_button = h(
        'button.button',
        { style: { margin: '1rem' }, on: { click: clone_game } },
        'Clone Game',
      )

      copy_button = h(
        'button.button.margined',
        { on: { click: copy_data } },
        'Copy Data',
      )

      h('div.margined', [
        h(:span, 'Clone this game to play around in hotseat mode'),
        clone_button,
        copy_button,
      ])
    end
  end
end
