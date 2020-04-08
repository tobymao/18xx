# frozen_string_literal: true

require 'lib/request'

require 'view/form'
require 'engine/game/g_1889'

module View
  class CreateGame < Form
    needs :mode, default: :solo, store: true
    needs :num_players, default: 3, store: true
    needs :app_route, default: nil, store: true
    needs :game, default: nil, store: true

    def render_content
      inputs = [
        *render_buttons,
        mode_selector,
        render_input('Game Title', id: :title, el: 'select', children: [
          h(:option, '1889'),
        ]),
        render_input('Description', id: :description),
      ]

      if @mode == :solo
        @num_players.times do |index|
          num = index + 1
          inputs << render_input("Player #{num}", id: "player_#{num}", value: num)
        end
      end

      h('div.pure-u-1', [
        render_form('Create New Game', inputs)
      ])
    end

    def mode_selector
      h('label.pure-radio.pure-u-23-24', [
        *mode_input(:multi, 'Multiplayer'),
        *mode_input(:solo, 'Solo'),
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

      if @mode == :solo
        buttons << render_button('+ Player') { store(:num_players, @num_players + 1) }
        buttons << render_button('- Player') { store(:num_players, @num_players - 1) }
      end

      buttons
    end

    def submit
      if @mode == :solo
        players = params.select { |k, _| k.start_with?('player_') }.values
        store(:game, Engine::Game::G1889.new(players, mode: @mode), skip: true)
        store(:app_route, '/game/1')
      else
        Lib::Request.post('/game', params) do |data|
          puts "** data #{data}"
        end
      end
    end
  end
end
