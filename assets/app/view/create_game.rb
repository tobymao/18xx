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
    needs :visible_optional_rules, default: nil, store: true
    needs :selected_game, default: nil, store: true
    needs :title, default: nil

    def render_content
      @label_style = { display: 'block' }
      inputs = [
        mode_selector,
        render_button('Create', { style: { margin: '0.5rem 1rem 1rem 0' } }) { submit },
        render_inputs,
      ]

      if @mode == :multi
        inputs << h(:label, { style: @label_style }, 'Game Options')
        inputs << render_input('Invite only game', id: 'unlisted', type: :checkbox,
                                                   container_style: { paddingLeft: '0.5rem' })
        inputs << render_game_info
      elsif @mode == :hotseat
        inputs << h(:label, { style: @label_style }, 'Player Names')
        @num_players.times do |index|
          n = index + 1
          inputs << render_input('', id: "player_#{n}", attrs: { value: "Player #{n}" })
        end
        inputs << render_game_info
      elsif @mode == :json
        inputs << render_upload_button
        inputs << render_input(
          '',
          id: :game_data,
          el: :textarea,
          attrs: {
            placeholder: 'Paste JSON game data or upload a file.',
            cols: 50,
          },
          container_style: {
            display: 'block',
          },
          input_style: {
            height: '66vh',
            maxWidth: '96vw',
            margin: '1rem 0',
          },
        )
      end

      description = []
      description += [h(:a, { attrs: { href: '/signup' } }, 'Signup'), ' or ',
                      h(:a, { attrs: { href: '/login' } }, 'login'), ' to play multiplayer.'] unless @user
      description << h(:p, 'If you are new to 18xx games then 1889, 18Chesapeake or 18MS are good games to begin with.')
      render_form('Create New Game', inputs, description)
    end

    def render_inputs
      @min_p = {}
      @max_p = {}
      closest_title = @title && Engine.closest_title(@title)

      game_options = visible_games.group_by { |game| game::DEV_STAGE }.flat_map do |dev_stage, game_list|
        option_list = game_list.map do |game|
          @min_p[game.title], @max_p[game.title] = game::PLAYER_RANGE

          title = game.title
          title += " (#{game::GAME_LOCATION})" if game::GAME_LOCATION
          attrs = { value: game.title }
          attrs[:selected] = true if game.title == closest_title

          h(:option, { attrs: attrs }, title)
        end

        if dev_stage == :production
          option_list
        else
          [h(:optgroup, { attrs: { label: dev_stage } }, option_list)]
        end
      end

      title_change = lambda do
        @optional_rules = []
        update_inputs
      end

      inputs = [
        render_input('Game Title', id: :title, el: 'select', on: { input: title_change },
                                   container_style: @label_style, label_style: @label_style,
                                   input_style: { maxWidth: '90vw' }, children: game_options),
        render_input('Description', id: :description, placeholder: 'Add a title', label_style: @label_style),
        render_input(
          @mode == :hotseat ? 'Players' : 'Max Players',
          id: :max_players,
          type: :number,
          attrs: {
            min: @min_p.values.first,
            max: @max_p.values.first,
            value: @num_players,
            required: true,
          },
          input_style: { width: '3.5rem' },
          label_style: @label_style,
          on: { input: -> { update_inputs } },
        ),
      ]
      inputs << render_optional if (@visible_optional_rules ||= selected_game::OPTIONAL_RULES).any?

      div_props = {}
      div_props[:style] = { display: 'none' } if @mode == :json

      h(:div, div_props, inputs)
    end

    def toggle_optional_rule(sym)
      lambda do
        if (@optional_rules ||= []).include?(sym)
          @optional_rules.delete(sym)
        else
          @optional_rules << sym
        end
      end
    end

    def render_optional
      children = @visible_optional_rules.map do |o_r|
        label_text = "#{o_r[:short_name]}: #{o_r[:desc]}"
        h(:li, [render_input(
          label_text,
          type: 'checkbox',
          id: o_r[:sym],
          attrs: { value: o_r[:sym] },
          on: { input: toggle_optional_rule(o_r[:sym]) },
        )])
      end

      ul_props = {
        style: {
          listStyle: 'none',
          marginTop: '0',
          paddingLeft: '0.5rem',
        },
      }

      h(:div, [
          h(:label, 'Optional Rules'),
          h(:ul, ul_props, children),
        ])
    end

    def render_upload_button
      upload = lambda do |e|
        %x{
          const result = document.getElementById('game_data')
          var file = #{e}.target.files[0];

          if(file.size <= 5 * 1024 * 1024) {
            var reader = new FileReader();
            reader.onload = function(event) {
                result.value = event.target.result;
              };
            reader.readAsText(file, 'UTF-8');
          } else {
            self['$store']('flash_opts', 'This file is too big.')
          }
        }
      end

      h('div.inline-block', [
        render_button('Upload file') { `document.getElementById('file_upload').click()` },
        h(:input, {
            attrs: {
              id: :file_upload,
              type: :file,
              accept: 'application/json',
            },
            on: { change: upload },
            style: { display: 'none' },
          }),
      ])
    end

    def render_game_info
      h(Game::GameMeta, game: @selected_game || selected_game)
    end

    def mode_selector
      h(:div, { style: { margin: '1rem 0' } }, [
        *mode_input(:multi, 'Multiplayer'),
        *mode_input(:hotseat, 'Hotseat'),
        *mode_input(:json, 'Import hotseat game'),
      ])
    end

    def mode_input(mode, text)
      click_handler = lambda do
        store(:mode, mode, skip: true)
        update_inputs
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
      return create_game(params) if @mode == :multi

      players = game_params
        .select { |k, _| k.start_with?('player_') }
        .values
        .map { |name| name.gsub(/\s+/, ' ').strip }

      return store(:flash_opts, 'Cannot have duplicate player names') if players.uniq.size != players.size

      if @mode == :json
        begin
          game_data = JSON.parse(game_params['game_data'])
        rescue JSON::ParserError => e
          return store(:flash_opts, e.message)
        end
      else
        game_data = {
          settings: {
            optional_rules: game_params[:optional_rules] || [],
          },
        }
      end

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

      game = Engine::GAME_META_BY_TITLE[params['title']]
      params[:optional_rules] = game::OPTIONAL_RULES
                                  .map { |o_r| o_r[:sym] }
                                  .select { |rule| params.delete(rule) }

      params
    end

    def visible_games
      (Lib::Params['all'] ? Engine::GAME_METAS : Engine::VISIBLE_GAMES).sort
    end

    def selected_game
      title = Native(@inputs[:title]).elm&.value
      title ||= lambda do
        closest = Engine.meta_by_title(@title)
        closest.title if visible_games.include?(closest)
      end.call if @title
      title ||= visible_games.first.title

      Engine::GAME_META_BY_TITLE[title]
    end

    def update_inputs
      title = selected_game.title

      range = Native(@inputs[:max_players]).elm
      unless range.value == ''
        min = range.min = @min_p[title]
        max = range.max = @max_p[title]
        val = range.value.to_i
        range.value = (min..max).include?(val) ? val : max
        store(:num_players, range.value.to_i, skip: true)
      end

      store(:selected_game, selected_game, skip: true)

      `window.history.replaceState(window.history.state, null, '?title=' + encodeURIComponent(#{title}))`
      root.store_app_route

      visible_rules = selected_game::OPTIONAL_RULES.reject do |rule|
        rule[:players] && !rule[:players].include?(@num_players)
      end
      store(:visible_optional_rules, visible_rules)
    end
  end
end
