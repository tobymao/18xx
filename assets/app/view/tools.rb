# frozen_string_literal: true

require 'game_manager'

module View
  class Tools < Snabberb::Component
    include GameManager
    include Actionable

    needs :game, store: true
    needs :user
    needs :confirming_conclude_game, store: true, default: false

    def render
      @game_data = @game_data.merge(actions: @game.actions.map(&:to_h))
      @json = `JSON.stringify(#{@game_data.to_n}, null, 2)`

      props = {
        style: {
           'white-space': 'pre-wrap',
        },
      }

      h(:div, props, [
        *render_admin,
        render_clone_game,
        @json,
      ])
    end

    def render_admin
      if user_owns_game?(@user, @game_data)
        admin = []
        unless @game.finished
          end_game = if !@confirming_conclude_game
                       [
                         h(
                           'button.button',
                           { style: { margin: '1rem' }, on: { click: -> { store(:confirming_conclude_game, true) } } },
                           'End Game',
                         ),
                       ]
                     else
                       confirm = lambda do
                         store(:confirming_conclude_game, false)
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
                           { style: { margin: '1rem' }, on: { click: -> { store(:confirming_conclude_game, false) } } },
                           'Cancel',
                         )
                       ]
                     end

          admin << h('div.margined', [
            h('span', 'End Game:'),
            *end_game
            ])
        end

        admin.unshift(h('div', { style: { 'font-weight': 'bold' } }, 'Admin tools')) if admin.any?

        admin
      else
        []
      end
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
