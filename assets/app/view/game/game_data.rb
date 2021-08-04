# frozen_string_literal: true

require 'game_manager'

module View
  module Game
    class GameData < Snabberb::Component
      include GameManager

      needs :allow_clone, default: true
      needs :allow_delete, default: false
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

        children = [render_game_data_buttons]
        children << @json if @show_json
        h(:div, props, children)
      end

      def render_game_data_buttons
        clone_game = lambda do
          @connection.unsubscribe(url(@game_data))
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

        buttons = [
          h(:h3, 'Game Data'),
          h(:button, {
              on: { click: -> { store(:show_json, !@show_json) } },
              style: { width: '4.2rem' },
            },
            (@show_json ? 'Hide' : 'Show').to_s),
          h(:button, { on: { click: copy_data } }, 'Copy'),
          h('a.button_link', {
              attrs: {
                href: "data:text/plain;charset=utf-8,#{`encodeURI(self.json)`}",
                download: "#{@game_data[:id]}.json",
              },
            }, 'Download'),
        ]

        if @allow_delete
          delete_game = lambda do
            delete_game(@game_data)
            store(:app_route, '/')
          end

          buttons << h(:button, { on: { click: delete_game } }, 'Delete Game')
        end

        if @allow_clone
          buttons << h(:button, { on: { click: clone_game }, style: { marginRight: '0.3rem' } }, 'Clone Game')
          buttons << h(:label, 'to play around in hotseat mode')
        end

        h('div.margined', buttons)
      end
    end
  end
end
