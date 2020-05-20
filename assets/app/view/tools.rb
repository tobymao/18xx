# frozen_string_literal: true

require 'game_manager'
require 'lib/storage'

module View
  class Tools < Snabberb::Component
    include GameManager
    include Actionable

    needs :game, store: true
    needs :user
    needs :confirm_endgame, store: true, default: false

    def render
      @game_data = @game_data.merge(actions: @game.actions.map(&:to_h))
      @json = `JSON.stringify(#{@game_data.to_n}, null, 2)`
      @settings = Lib::Storage[@game.id] || {}

      props = {
        style: {
          'white-space': 'pre-wrap',
        },
      }

      h(:div, props, [
        *render_tools,
        render_clone_game,
        @json,
      ])
    end

    def master_mode
      mode = @settings[:master_mode] || false
      toggle = lambda do
        Lib::Storage[@game.id] = @settings.merge('master_mode' => !mode)
        update
      end
      h('div.margined', [
        'Master Mode (Enable to move for others):',
        h('button.button', { style: { margin: '1rem' }, on: { click: toggle } }, mode ? 'Disable' : 'Enable'),
      ])
    end

    def end_game
      end_game = if @confirm_endgame
                   confirm = lambda do
                     store(:confirm_endgame, false)
                     process_action(Engine::Action::EndGame.new(@game.current_entity))
                     # Go to main page
                     store(:app_route, @app_route.split('#').first)
                   end
                   [
                     h(
                       'button.button',
                       { style: { margin: '1rem' }, on: { click: confirm } },
                       'Confirm End Game',
                     ),
                     h(
                       'button.button',
                       { style: { margin: '1rem' }, on: { click: -> { store(:confirm_endgame, false) } } },
                       'Cancel',
                     )
                   ]
                 else
                   [
                     h(
                       'button.button',
                       { style: { margin: '1rem' }, on: { click: -> { store(:confirm_endgame, true) } } },
                       'End Game',
                     ),
                   ]
                 end

      h('div.margined', [h('span', 'End Game:'), *end_game])
    end

    def render_tools
      children = [master_mode]
      children << end_game unless @game.finished
      children
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
