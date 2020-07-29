# frozen_string_literal: true

require 'game_manager'

module View
  module Game
    class GameData < Snabberb::Component
      include GameManager

      needs :allow_clone, default: true
      needs :show_json, default: false, store: true
      needs :actions

      def render
        @game_data = @game_data.merge(actions: @actions)
        @json = `JSON.stringify(#{@game_data.to_n}, null, 2)`

        props = {
          style: {
            whiteSpace: 'pre-wrap',
          },
        }

        children = [render_clone_game]
        children << @json if @show_json
        h(:div, props, children)
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
          :button,
          { on: { click: copy_data } },
          'Copy Game Data',
        )

        show_button = h(
          :button,
          { on: { click: -> { store(:show_json, !@show_json) } } },
          (@show_json ? 'Hide Game Data' : 'Show Game Data')
        )

        if @allow_clone
          clone_button = h(
            :button,
            { style: { margin: '1rem' }, on: { click: clone_game } },
            'Clone Game',
          )

          h('div.margined', [
            h(:span, 'Clone this game to play around in hotseat mode'),
            clone_button,
            copy_button,
            show_button,
          ])
        else
          h('div.margined', [
            copy_button,
            show_button,
          ])
        end
      end
    end
  end
end
