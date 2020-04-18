# frozen_string_literal: true

require 'lib/request'

require 'game_manager'
require 'view/form'
require 'engine/game/g_1889'

module View
  class CreateGame < Form
    include GameManager

    needs :mode, default: :multi, store: true
    needs :num_players, default: 3, store: true

    def render_content
      inputs = [
        mode_selector,
        *render_buttons,
        render_inputs,
      ]

      if @mode == :hotseat
        @num_players.times do |index|
          num = index + 1
          inputs << render_input("Player #{num}", id: "player_#{num}", attrs: { value: "Player #{num}" })
        end
      end

      h(:div, [
        render_form('Create New Game', inputs)
      ])
    end

    def render_inputs
      h(:div, [
        render_input('Game Title', id: :title, el: 'select', children: [
          h(:option, '1889'),
        ]),
        render_input('Description', id: :description),
        render_input('Max Players', id: :max_players, type: :number, attrs: { value: 6 }),
      ])
    end

    def mode_selector
      h(:div, { style: { margin: '1rem 0' } }, [
        *mode_input(:multi, 'Multiplayer'),
        *mode_input(:hotseat, 'Hotseat'),
      ])
    end

    def mode_input(mode, text)
      props = {
        attrs: { type: 'radio', name: 'mode_options', checked: @mode == mode },
        on: { click: -> { store(:mode, mode) } },
      }

      [
        h(:input, props),
        h(:span, { style: { 'margin': '0 1rem 0 0.5rem' } }, text),
      ]
    end

    def render_buttons
      buttons = []

      buttons << render_button('Create') { submit }

      if @mode == :hotseat
        buttons << render_button('+ Player') { store(:num_players, @num_players + 1) if @num_players + 1 <= 6 }
        buttons << render_button('- Player') { store(:num_players, @num_players - 1) if @num_players - 1 >= 2 }
      end

      buttons
    end

    def submit
      if @mode == :hotseat
        players = params
          .select { |k, _| k.start_with?('player_') }
          .values
          .map { |name| { name: name } }

        game_data = {
          title: params[:title],
          players: players,
          actions: [],
          mode: :hotseat,
        }
        store(:game_data, game_data, skip: true)
        store(:app_route, '/game')
      else
        create_game(params)
      end
    end
  end
end
