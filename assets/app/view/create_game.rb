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
    needs :game_variants, default: nil, store: true
    needs :selected_variant, default: nil, store: true
    needs :title, default: nil
    needs :production, default: nil

    def render_content
      @label_style = { display: 'block' }
      inputs = [
        mode_selector,
        render_button('Create', { style: { margin: '0.5rem 1rem 1rem 0' } }) { submit },
        render_inputs,
      ]

      case @mode
      when :multi
        inputs << h(:label, { style: @label_style }, 'Game Options')
        inputs << render_input('Invite only game', id: 'unlisted', type: :checkbox,
                                                   container_style: { paddingLeft: '0.5rem' })
        inputs << render_input('Auto Routing', id: 'auto_routing', type: :checkbox)
        inputs << render_game_info
      when :hotseat
        inputs << h(:label, { style: @label_style }, 'Player Names')
        @num_players.times do |index|
          n = index + 1
          inputs << render_input('', id: "player_#{n}", attrs: { value: "Player #{n}" })
        end
        inputs << render_game_info
      when :json
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
      unless @user
        description += [
          h(:a, { attrs: { href: '/signup' } }, 'Signup'), ' or ',
          h(:a, { attrs: { href: '/login' } }, 'login'), ' to play multiplayer.'
        ]
      end
      description << h(:p, 'If you are new to 18xx games then 1889, 18Chesapeake or 18MS are good games to begin with.')
      render_form('Create New Game', inputs, description)
    end

    def render_inputs
      @min_p = {}
      @max_p = {}
      closest_title = @title && Engine.closest_title(@title)

      game_options = visible_games
      .group_by { |game| game::DEV_STAGE == :production && game::PROTOTYPE ? :prototype : game::DEV_STAGE }
      .flat_map do |dev_stage, game_list|
        option_list = game_list.map do |game|
          @min_p[game.title], @max_p[game.title] = game::PLAYER_RANGE

          title = game.title
          title += " (#{game::GAME_LOCATION})" if game::GAME_LOCATION
          title += ' [Prototype]' if game::PROTOTYPE

          attrs = { value: game.title }
          attrs[:selected] = (game.title == closest_title) ||
                             (game == Engine.meta_by_title(closest_title)::GAME_IS_VARIANT_OF)

          h(:option, { attrs: attrs }, game::GAME_DROPDOWN_TITLE || title)
        end

        if dev_stage == :production
          option_list
        else
          [h(:optgroup, { attrs: { label: dev_stage } }, option_list)]
        end
      end

      title_change = lambda do
        @selected_game = Engine.meta_by_title(Native(@inputs[:title]).elm&.value)

        uncheck_game_variant
        @selected_variant = nil
        @game_variants = {}

        uncheck_optional_rules
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

      @game_variants = selected_game.game_variants
      @visible_optional_rules = selected_game_or_variant::OPTIONAL_RULES
      inputs << render_optional if !@game_variants.empty? || !@visible_optional_rules.empty?

      div_props = {}
      div_props[:style] = { display: 'none' } if @mode == :json

      h(:div, div_props, inputs)
    end

    def uncheck_game_variant
      return unless @selected_variant

      Native(@inputs[@selected_variant[:sym]]).elm&.checked = false
    end

    def uncheck_optional_rules
      @visible_optional_rules&.each do |o_r|
        Native(@inputs[o_r[:sym]]).elm&.checked = false
      end
    end

    def toggle_game_variant(sym)
      lambda do
        uncheck_optional_rules
        uncheck_game_variant if @selected_variant
        @selected_variant =
          if @selected_variant && (@selected_variant[:sym] == sym)
            nil
          else
            selected_game.game_variants[sym]
          end
        update_inputs
      end
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
      game_variants = @game_variants.map do |sym, variant|
        title = variant[:title]
        @min_p[title], @max_p[title] = variant[:meta]::PLAYER_RANGE

        stage = variant[:meta]::DEV_STAGE
        stage_str = stage == :production ? '' : "(#{stage}) "
        label_text = "#{stage_str}#{variant[:name]}: #{variant[:desc]}"

        h(:li, [render_input(
          label_text,
          type: 'checkbox',
          id: sym,
          attrs: { value: sym, checked: @selected_variant == variant },
          on: { input: toggle_game_variant(sym) },
        )])
      end

      optional_rules = @visible_optional_rules.map do |o_r|
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
          h(:label, 'Game Variants / Optional Rules'),
          h(:ul, ul_props, [*game_variants, *optional_rules]),
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
      h(Game::GameMeta, game: selected_game_or_variant)
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
      if @mode == :multi
        begin
          return create_game(params)
        rescue Engine::OptionError => e
          return store(:flash_opts, e.message)
        end
      end

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

      params['title'] = @selected_variant[:title] if @selected_variant

      game = Engine.meta_by_title(params['title'])
      params[:optional_rules] = game::OPTIONAL_RULES
                                  .map { |o_r| o_r[:sym] }
                                  .select { |rule| params.delete(rule) }

      params
    end

    def visible_games
      @visible_games ||= (@production ? Engine::VISIBLE_GAMES : Engine::GAME_METAS).sort
    end

    def selected_game
      return @selected_game if @selected_game

      title = visible_games.first.title
      if @title
        closest = Engine.meta_by_title(@title)

        if visible_games.include?(closest)
          title = closest.title
        elsif (parent_game = Engine.meta_by_title(closest.title)::GAME_IS_VARIANT_OF)
          title = parent_game.title
          @selected_variant = parent_game.game_variants.values.find { |v| v[:title] == closest.title }
        end
      end

      @selected_game = Engine.meta_by_title(title)
    end

    def selected_game_or_variant
      @selected_variant ? @selected_variant[:meta] : selected_game
    end

    def update_inputs
      title = selected_game_or_variant.title

      range = Native(@inputs[:max_players]).elm
      unless range.value == ''
        min = range.min = @min_p[title]
        max = range.max = @max_p[title]
        val = range.value.to_i
        range.value = (min..max).cover?(val) ? val : max
        store(:num_players, range.value.to_i, skip: true)
      end

      store(:selected_game, selected_game, skip: true)

      store(:selected_variant, @selected_variant, skip: true)
      store(:game_variants, selected_game.game_variants, skip: true)

      `window.history.replaceState(window.history.state, null, '?title=' + encodeURIComponent(#{title}))`
      root.store_app_route

      visible_rules = selected_game::OPTIONAL_RULES.reject do |rule|
        rule[:players] && !rule[:players].include?(@num_players)
      end
      store(:visible_optional_rules, visible_rules)
    end
  end
end
