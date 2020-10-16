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
    needs :optional_rules_available, default: nil, store: true

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

      description = []
      description += [h(:a, { attrs: { href: '/signup' } }, 'Signup'), ' or ',
                      h(:a, { attrs: { href: '/login' } }, 'login'), ' to play multiplayer.'] unless @user
      description << h(:div,
                       'If you are new to 18xx games then 1889, 18Chesapeake, or 18MS are good games to begin with.')
      render_form('Create New Game', inputs, description)
    end

    def render_inputs
      @min_p = {}
      @max_p = {}
      @optional_rules_per_title = {}

      games = (Lib::Params['all'] ? Engine::GAMES : Engine::VISIBLE_GAMES).sort.map do |game|
        @min_p[game.title], @max_p[game.title] = Engine.player_range(game)
        @optional_rules_per_title[game.title] = game::OPTIONAL_RULES != [] ? game::OPTIONAL_RULES : nil

        title = game.title
        title += " (#{game::GAME_LOCATION})" if game::GAME_LOCATION
        title += " (#{game::DEV_STAGE})" if game::DEV_STAGE != :production
        attrs = { value: game.title }

        h(:option, { attrs: attrs }, title)
      end

      title_change = lambda do
        range = Native(@inputs[:max_players]).elm
        title = Native(@inputs[:title]).elm.value
        min = range.min = @min_p[title]
        max = range.max = @max_p[title]
        val = range.value.to_i
        range.value = (min..max).include?(val) ? val : max
        store(:num_players, range.value.to_i, skip: true)

        @optional_rules_selected = []
        update_optional_rules_store
      end

      enforce_range = lambda do
        elm = Native(@inputs[:max_players]).elm
        if elm.value.to_i.positive?
          elm.value = elm.max.to_i unless (elm.min.to_i..elm.max.to_i).include?(elm.value.to_i)
          if @mode == :hotseat
            store(:num_players, elm.value.to_i)
            update_optional_rules_store
          end
        end
      end

      inputs = [
        render_input('Game Title', id: :title, el: 'select', on: { input: title_change }, children: games),
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
      inputs << render_optional if @optional_rules_available

      h(:div, inputs)
    end

    def toggle_optional_rule(sym)
      lambda do
        if (@optional_rules_selected ||= []).include?(sym)
          @optional_rules_selected.delete(sym)
        else
          @optional_rules_selected << sym
        end
      end
    end

    def render_optional
      return unless @optional_rules_available

      optional_rules = []
      @optional_rules_available.each do |o_r|
        label_text = "#{o_r[:short_name]}: #{o_r[:desc]}"
        optional_rules << h(:li, [render_input(
          label_text,
          type: 'checkbox',
          id: o_r[:sym],
          attrs: { value: o_r[:sym] },
          on: { input: toggle_optional_rule(o_r[:sym]) },
          input_style: { float: 'left', margin: '5px' },
        )])
      end
      store(:optional_rules_available, nil, skip: true) # wipe to prevent rendering on next game creation

      h(:div, [
          h(:p, 'Optional Rules:'),
          h(:ul, { style: { 'list-style': 'none' } }, optional_rules),
        ])
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
        update_optional_rules_store
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
      game_params = params
      return create_game(game_params) if @mode != :hotseat

      players = game_params
        .select { |k, _| k.start_with?('player_') }
        .values
        .map { |name| name.gsub(/\s+/, ' ').strip }

      return store(:flash_opts, 'Cannot have duplicate player names') if players.uniq.size != players.size

      game_data = game_params['game_data']

      if game_data.empty?
        game_data = {}
      else
        begin
          game_data = JSON.parse(game_data)
        rescue JSON::ParserError => e
          return store(:flash_opts, e.message)
        end
      end
      game_data[:settings] ||= {}
      game_data[:settings][:optional_rules_selected] = game_params[:optional_rules_selected]

      create_hotseat(
        id: Time.now.to_i,
        players: players.map { |name| { name: name } },
        title: game_params[:title],
        description: game_params[:description],
        max_players: game_params[:max_players],
        **game_data,
      )
    end

    def params
      params = super

      game = Engine::GAMES_BY_TITLE[params['title']]
      game_optional_rules = game::OPTIONAL_RULES.map { |o_r| o_r[:sym] }

      optional_rules_selected = []
      game_optional_rules.each do |rule|
        optional_rules_selected << rule if params.delete(rule)
      end
      params[:optional_rules_selected] = optional_rules_selected

      params
    end

    def update_optional_rules_store
      title = Native(@inputs[:title]).elm.value
      store(:optional_rules_available, @optional_rules_per_title[title])
    end
  end
end
