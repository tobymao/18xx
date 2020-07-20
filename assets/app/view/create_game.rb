# frozen_string_literal: true

require 'game_manager'
require 'view/form'

module View
  class CreateGame < Form
    include GameManager

    needs :mode, default: :multi, store: true
    needs :num_players, default: 3, store: true
    needs :flash_opts, default: {}, store: true
    needs :user, default: nil, store: true

    def render_content
      inputs = [
        mode_selector,
        render_button('Create') { submit },
        render_inputs,
      ]

      if @mode == :hotseat
        @num_players.times do |index|
          num = index + 1
          inputs << render_input("Player #{num}", id: "player_#{num}", attrs: { value: "Player #{num}" })
        end
        inputs << render_input(
          '',
          id: :game_data,
          el: :textarea,
          attrs: {
            placeholder: 'Paste JSON Game Data. Will override settings',
            rows: 35,
            cols: 50,
          },
          container_style: {
            display: 'block',
          },
        )
      end

      description = [h(:a, { attrs: { href: '/signup' } }, 'Signup'), ' or ',
                     h(:a, { attrs: { href: '/login' } }, 'login'), ' to play multiplayer.'] unless @user
      render_form('Create New Game', inputs, description)
    end

    def render_inputs
      @min_p = {}
      @max_p = {}

      games = (Lib::Params['all'] ? Engine::GAMES : Engine::VISIBLE_GAMES).map do |game|
        @min_p[game.title], @max_p[game.title] = Engine.player_range(game)

        title = game.title
        title += " (#{game::GAME_LOCATION})" if game::GAME_LOCATION
        title += " (#{game::DEV_STAGE})" if game::DEV_STAGE != :production

        h(:option, { attrs: { value: game.title } }, title)
      end

      limit_range = lambda do
        range = Native(@inputs[:max_players]).elm
        title = Native(@inputs[:title]).elm.value
        min = range.min = @min_p[title]
        max = range.max = @max_p[title]
        val = range.value.to_i
        range.value = (min..max).include?(val) ? val : max
        store(:num_players, range.value.to_i)
      end

      enforce_range = lambda do
        elm = Native(@inputs[:max_players]).elm
        if elm.value.any?
          elm.value = elm.max.to_i unless (elm.min.to_i..elm.max.to_i).include?(elm.value.to_i)
          store(:num_players, elm.value.to_i) if @mode == :hotseat
        end
      end

      inputs = [
        render_input('Game Title', id: :title, el: 'select', on: { input: limit_range }, children: games),
        render_input('Description', placeholder: 'Add a title', id: :description),
        render_input(
          @mode != :hotseat ? 'Max Players' : 'Players',
          id: :max_players,
          type: :number,
          attrs: {
            min: @min_p.values.first,
            max: @max_p.values.first,
            value: @num_players,
            required: true,
          },
          input_style: { width: '2.5rem' },
          on: { input: enforce_range },
        ),
      ]
      h(:div, inputs)
    end

    def mode_selector
      h(:div, { style: { margin: '1rem 0' } }, [
        *mode_input(:multi, 'Multiplayer'),
        *mode_input(:hotseat, 'Hotseat'),
      ])
    end

    def mode_input(mode, text)
      click_handler = lambda do
        store(:mode, mode, skip: true)
        elm = Native(@inputs[:max_players]).elm
        elm.value = [elm.value.to_i, elm.min.to_i].max
        store(:num_players, elm.value.to_i)
      end

      [render_input(
        text,
        id: text,
        type: 'radio',
        attrs: { name: 'mode_options', checked: @mode == mode },
        on: { click: click_handler },
      )]
    end

    def submit
      return create_game(params) if @mode != :hotseat

      players = params
        .select { |k, _| k.start_with?('player_') }
        .values
        .map { |name| name.gsub(/\s+/, ' ').strip }

      return store(:flash_opts, 'Cannot have duplicate player names') if players.uniq.size != players.size

      game_data = params['game_data']

      if game_data.empty?
        game_data = {}
      else
        begin
          game_data = JSON.parse(game_data)
        rescue JSON::ParserError => e
          return store(:flash_opts, e.message)
        end
      end

      create_hotseat(
        id: Time.now.to_i,
        players: players.map { |name| { name: name } },
        title: params[:title],
        description: params[:description],
        max_players: params[:max_players],
        **game_data,
      )
    end
  end
end
