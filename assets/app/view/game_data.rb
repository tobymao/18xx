# frozen_string_literal: true

require 'game_manager'

module View
  class GameData < Snabberb::Component
    include GameManager

    needs :allow_clone, default: true
    needs :actions

    def render
      @game_data = @game_data.merge(actions: @actions)
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

      copy_button = h(
        'button.button.margined',
        { on: { click: copy_data } },
        'Copy Data',
      )

      if @allow_clone
        clone_button = h(
          'button.button',
          { style: { margin: '1rem' }, on: { click: clone_game } },
          'Clone Game',
        )

        h('div.margined', [
          h(:span, 'Clone this game to play around in hotseat mode'),
          clone_button,
          copy_button,
        ])
      else
        h('div.margined', [
          copy_button
        ])
      end
    end
  end
end
