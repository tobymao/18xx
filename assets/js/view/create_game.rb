# frozen_string_literal: true

require 'lib/request'

require 'engine/game/g_1889'

module View
  class CreateGame < Snabberb::Component
    needs :mode, default: :solo, store: true
    needs :num_players, default: 3, store: true
    needs :app_route, default: nil, store: true
    needs :game, default: nil, store: true

    def render
      @inputs = {}

      destroy = lambda do
        store(:mode, nil, skip: true)
        store(:num_players, nil, skip: true)
      end

      props = {
        hook: { destroy: destroy },
        style: { 'max-width': '750px' },
      }

      h('div.pure-u-1', props, [
        render_form
      ])
    end

    def render_form
      inputs = [
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

      h('from.pure-form.pure-form-stacked', [
        h(:legend, 'Create New Game'),
        render_buttons,
        h('div.pure-g', inputs),
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

    def render_input(label, id:, el: 'input', type: 'text', value: '', children: [])
      props = {
        attrs: { type: type, value: value },
        on: { keyup: ->(event) { create_game if event.JS['keyCode'] == 13 } },
      }

      input = h("#{el}.pure-u-23-24", props, children)
      @inputs[id] = input
      h('div.pure-u-1.pure-u-md-1-2', [label, input])
    end

    def render_buttons
      buttons = []

      buttons << render_button('Create Game') { create_game }

      if @mode == :solo
        buttons << render_button('+ Player') { store(:num_players, @num_players + 1) }
        buttons << render_button('- Player') { store(:num_players, @num_players - 1) }
      end

      h('div.pure-g', buttons)
    end

    def render_button(text, &block)
      h('div.pure-u-1-3', [
        h('button.pure-button.pure-button-primary.pure-u-23-24', { on: { click: block } }, text)
      ])
    end

    def create_game
      args = @inputs.map do |key, input|
        [key, input.JS['elm'].JS['value']]
      end.to_h

      if @mode == :solo
        players = args.select { |k, _| k.start_with?('player_') }.values
        store(:game, Engine::Game::G1889.new(players, mode: @mode), skip: true)
        store(:app_route, '/game/1')
      else
        Lib::Request.post('/game', args) do |data|
        end
      end
    end
  end
end
