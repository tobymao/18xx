# frozen_string_literal: true

require 'game_manager'
require 'lib/whats_this'
require 'view/form'

module View
  class CreateGame < Form
    include GameManager
    include Lib::WhatsThis::AutoRoute

    needs :mode, default: :multi, store: true
    needs :flash_opts, default: {}, store: true
    needs :user, default: nil, store: true
    needs :visible_optional_rules, default: nil, store: true
    needs :selected_game, default: nil, store: true
    needs :game_variants, default: nil, store: true
    needs :selected_variant, default: nil, store: true
    needs :title, default: nil
    needs :production, default: nil
    needs :optional_rules, default: [], store: true
    needs :is_async, default: true, store: true
    needs :keywords, default: nil, store: true

    # hashmap, game title to min/max player count
    needs :min_p, default: {}, store: false
    needs :max_p, default: {}, store: false

    # int, min/max player count for the currently selected title
    needs :min_players, default: nil, store: true
    needs :max_players, default: nil, store: true

    def render_create_button(check_options: true)
      error = check_options &&
              selected_game_or_variant.check_options(@optional_rules, @min_players, @max_players)&.[](:error)
      (render_button('Create', { style: { margin: '0.5rem 1rem 1rem 0' }, attrs: { disabled: !!error } }) { submit })
    end

    def render_content
      @label_style = { display: 'block' }

      inputs = [mode_selector]

      if @mode == :json
        inputs << render_create_button(check_options: false)
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
      else
        if selected_game_or_variant
          update_player_range(selected_game_or_variant)
          inputs << render_create_button
          inputs << h(:h2, selected_game_or_variant.meta.full_title)
          inputs << render_inputs

          case @mode
          when :multi
            inputs << h(:label, { style: @label_style }, 'Game Options')
            inputs << render_game_type
            inputs << render_input('Invite only game', id: 'unlisted', type: :checkbox,
                                                       container_style: { paddingLeft: '0.5rem' })
            if selected_game_or_variant::AUTOROUTE
              inputs << render_input('Auto Routing', id: 'auto_routing', type: :checkbox, siblings: [auto_route_whats_this])
            end
          when :hotseat
            inputs << h(:label, { style: @label_style }, 'Player Names')
            (1..(@max_players || @max_p[selected_game_or_variant.title])).each do |n|
              inputs << render_input('', id: "player_#{n}", attrs: { value: "Player #{n}" })
            end
          end

          inputs << render_random_seed
          inputs << render_optional if should_render_optional?
          inputs << render_game_info
        end

        inputs << render_keyword_search
        inputs << render_games_table
      end

      description = []
      unless @user
        description += [
          h(:a, { attrs: { href: '/signup' } }, 'Signup'), ' or ',
          h(:a, { attrs: { href: '/login' } }, 'login'), ' to play multiplayer.'
        ]
      end
      description << h(:p, 'If you are new to 18xx games then Shikoku 1889, 18Chesapeake or 18MS are good games to begin with.')
      render_form('Create New Game', inputs, description)
    end

    def render_inputs
      title = selected_game_or_variant.title
      min_p = @min_p[title]
      max_p = @max_p[title]
      max_players = @max_players || max_p
      if selected_game_or_variant.respond_to?(:min_players)
        min_p = selected_game_or_variant.min_players(@optional_rules, max_players)
      end
      min_players = @min_players || min_p

      inputs = [
        render_input('Description', id: :description, placeholder: 'Add a title', label_style: @label_style),
        render_input(
          'Min Players',
          id: :min_players,
          type: :number,
          attrs: {
            min: min_p,
            max: max_p,
            value: min_players,
            required: true,
          },
          container_style: @mode == :hotseat ? { display: 'none' } : {},
          input_style: { width: '3.5rem' },
          label_style: @label_style,
          on: { input: -> { update_inputs } },
        ),
        render_input(
          @mode == :hotseat ? 'Players' : 'Max Players',
          id: :max_players,
          type: :number,
          attrs: {
            min: min_p,
            max: max_p,
            value: max_players,
            required: true,
          },
          input_style: { width: '3.5rem' },
          label_style: @label_style,
          on: { input: -> { update_inputs } },
        ),
      ]

      div_props = {}
      div_props[:style] = { display: 'none' } if @mode == :json

      h(:div, div_props, inputs)
    end

    def preselect_variant(game)
      game.game_variants.map do |_sym, variant|
        @selected_variant = variant if variant[:default]
      end
    end

    def preselect_optional_rules(game)
      @visible_optional_rules = []
      game::OPTIONAL_RULES.map do |o_r|
        @optional_rules << o_r[:sym] if o_r[:default]
      end
      store(:optional_rules, @optional_rules, skip: true)
    end

    def uncheck_game_variant
      return unless @selected_variant

      Native(@inputs[@selected_variant[:sym]]).elm&.checked = false
    end

    def uncheck_optional_rules
      return unless selected_game_or_variant

      selected_game_or_variant::OPTIONAL_RULES.each do |o_r|
        Native(@inputs[o_r[:sym]])&.elm&.checked = false
      end
    end

    def sync_rules
      return unless selected_game_or_variant

      selected_game_or_variant::OPTIONAL_RULES.each do |o_r|
        Native(@inputs[o_r[:sym]])&.elm&.checked = @optional_rules.include?(o_r[:sym])
      end
    end

    def sync_rule(sym)
      Native(@inputs[sym])&.elm&.checked = @optional_rules.include?(sym)
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
        update_inputs(title_change: true)
      end
    end

    def uncheck_mutex(sym)
      return unless selected_game_or_variant
      return if selected_game_or_variant::MUTEX_RULES.empty?

      selected_game_or_variant::MUTEX_RULES.each do |set|
        next unless set.include?(sym)

        set.each do |s|
          next if s == sym

          @optional_rules.delete(s)
          sync_rule(s)
        end
      end
    end

    def toggle_optional_rule(sym)
      lambda do
        if (@optional_rules ||= []).include?(sym)
          @optional_rules.delete(sym)
        else
          @optional_rules << sym
          uncheck_mutex(sym)
        end
        store(:optional_rules, @optional_rules)
      end
    end

    def render_optional
      game_variants = @game_variants.map do |sym, variant|
        update_player_range(variant[:meta])

        stage = variant[:meta]::DEV_STAGE
        stage_str = stage == :production ? '' : "(#{stage}) "

        desc_text = variant[:desc] ? ": #{variant[:desc]}" : ''
        label_text = "#{stage_str}#{variant[:name]}#{desc_text}"

        h(:li, [render_input(
          label_text,
          type: 'checkbox',
          id: sym,
          attrs: { value: sym, checked: @selected_variant == variant },
          on: { input: toggle_game_variant(sym) },
        )])
      end

      optional_rules = selected_game_or_variant::OPTIONAL_RULES.map do |o_r|
        next if o_r[:hidden]

        desc_text = o_r[:desc] ? ": #{o_r[:desc]}" : ''
        label_text = "#{o_r[:short_name]}#{desc_text}"
        h(:li, [render_input(
          label_text,
          type: 'checkbox',
          id: o_r[:sym],
          attrs: {
            value: o_r[:sym],
            checked: @optional_rules.include?(o_r[:sym]),
            disabled: !@visible_optional_rules.find { |vo_r| vo_r[:sym] == o_r[:sym] },
          },
          on: { input: toggle_optional_rule(o_r[:sym]) },
        )])
      end.compact

      ul_props = {
        style: {
          listStyle: 'none',
          marginTop: '0',
          paddingLeft: '0.5rem',
        },
      }

      children = [
        h(:h4, 'Game Variants / Optional Rules'),
        h(:ul, ul_props, [*game_variants, *optional_rules]),
      ]

      checked_options = selected_game_or_variant.check_options(@optional_rules, @min_players, @max_players)
      if checked_options
        if (info = checked_options[:info])
          children.concat(
            [
              h(:h4, 'Option Info'),
              h(:div, info),
              h(:br),
            ]
          )
        end
        if (error = checked_options[:error])
          children.concat(
            [
              h(:h4, 'Option Errors'),
              h(:div, error),
              h(:br),
            ]
          )
        end
      end

      h(:div, children)
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
      h(Game::GameMeta, game: selected_game_or_variant, show_title: false)
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
        store(:mode, mode, skip: !selected_game_or_variant.nil?)
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

    def render_game_type
      h(:div, { style: { padding: '0.5rem' } }, [
        render_input(
          'Async',
          id: 'async',
          type: 'radio',
          attrs: { name: 'is_async', checked: @is_async == true },
          on: { click: -> { store(:is_async, is_async, skip: true) } }
        ),
        render_input(
          'Live',
          id: 'live',
          type: 'radio',
          attrs: { name: 'is_async', checked: @is_async == false },
          on: { click: -> { store(:is_async, is_async, skip: true) } }
        ),
      ])
    end

    def submit
      return if !selected_game_or_variant && @mode != :json

      game_params = params
      game_params[:seed] = game_params[:seed].to_i
      game_params[:seed] = nil if (game_params[:seed]).zero?

      return create_game(game_params) if @mode == :multi

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
        game_data[:settings][:seed] = game_params[:seed] if game_params[:seed]
      end

      checked_options = Engine.meta_by_title(game_data[:title])
                          .check_options(game_data[:settings][:optional_rules],
                                         game_data[:min_players], game_data[:max_players])
      if (options_error_msg = checked_options&.[](:error))
        return store(:flash_opts, "game_data Optional Rules Error: #{options_error_msg}")
      end

      create_hotseat(
        id: Time.now.to_i,
        players: players.map.with_index { |name, i| { name: name, id: i } },
        title: game_params[:title],
        description: game_params[:description],
        min_players: game_params[:max_players],
        max_players: game_params[:max_players],
        **game_data,
      )
    end

    def params
      params = super

      params['title'] = @selected_variant ? @selected_variant[:title] : @selected_game&.title

      if params['title']
        game = Engine.meta_by_title(params['title'])
        params[:optional_rules] = game::OPTIONAL_RULES
                                    .map { |o_r| o_r[:sym] }
                                    .select { |rule| params.delete(rule) }
      end

      params
    end

    def visible_games
      @visible_games ||= (@production ? Engine::VISIBLE_GAMES : Engine::GAME_METAS).sort
    end

    def selected_game
      @selected_game ||=
        if @title
          closest = Engine.meta_by_title(@title)

          if (parent_game = Engine.meta_by_title(closest.title)::GAME_IS_VARIANT_OF)
            title = parent_game.title
            @selected_variant = parent_game.game_variants.values.find { |v| v[:title] == closest.title }
          else
            title = closest.title
          end

          Engine.meta_by_title(title)
        end
    end

    def selected_game_or_variant
      @selected_variant ? @selected_variant[:meta] : selected_game
    end

    def filtered_rule?(rule)
      rule[:hidden] ||
        (rule[:players] &&
        !((@mode == :hotseat || rule[:players].include?(@min_players)) && rule[:players].include?(@max_players)))
    end

    def update_inputs(title_change: false)
      return unless selected_game_or_variant

      title = selected_game_or_variant.title
      max_p = @max_p[title]
      min_p = @min_p[title]
      max_players_elm = Native(@inputs[:max_players])&.elm
      min_players_elm = Native(@inputs[:min_players])&.elm

      if title_change
        max_players = max_p
        min_players = min_p
      else
        # Letters resolve to 0 when converted to integers
        max_players = (val = max_players_elm&.value.to_i).zero? ? nil : val
        min_players = (val = min_players_elm&.value.to_i).zero? ? nil : val
      end

      if max_players
        max_players = [max_players, max_p].min
        if selected_game_or_variant.respond_to?(:min_players)
          min_p = selected_game_or_variant.min_players(@optional_rules, max_players)
        end
        max_players_elm&.value = max_players
      end

      if min_players
        min_players = [min_players, min_p].max
        min_players = [min_players, max_players || max_p].min
        min_players_elm&.value = min_players
      end

      store(:max_players, max_players, skip: true)
      store(:min_players, min_players, skip: true)
      store(:selected_game, selected_game, skip: true)
      store(:selected_variant, @selected_variant, skip: true)
      store(:game_variants, selected_game.game_variants, skip: true)

      `window.history.replaceState(window.history.state, null, '?title=' + encodeURIComponent(#{title}))`
      root.store_app_route

      visible_rules = []
      selected_game::OPTIONAL_RULES.each do |rule|
        if filtered_rule?(rule)
          @optional_rules.delete(rule[:sym])
        else
          visible_rules << rule
        end
      end
      sync_rules

      store(:optional_rules, @optional_rules, skip: true)
      store(:visible_optional_rules, visible_rules)
    end

    def select_game(meta)
      @selected_game = meta

      update_player_range(meta)

      uncheck_game_variant
      @selected_variant = nil
      @game_variants = {}

      uncheck_optional_rules
      @optional_rules = []

      preselect_variant(@selected_game)
      preselect_optional_rules(@selected_game)

      update_inputs(title_change: true)

      `window.scroll(0, 0)`
    end

    def render_random_seed
      h(:div, [
          render_input(
            'Random Seed',
            id: :seed,
            placeholder: 'Optional random seed',
            label_style: { display: 'none' },
            on: {
              keyup: lambda { |e|
                Native(e)['key'] == 'Enter' && e.JS.stopPropagation
              },
            }
          ),
        ])
    end

    def game_rows_data
      @game_rows_data ||= visible_games.map do |game|
        next if game.meta::GAME_IS_VARIANT_OF

        status =
          begin
            parts = []
            parts << 'Prototype' if game.meta::PROTOTYPE
            parts << game.meta::DEV_STAGE.capitalize
            parts.join(', ')
          end

        {
          'title' => game.display_title,
          'status' => status,
          'location' => game.meta::GAME_LOCATION,
          'meta' => game.meta,
        }
      end.compact
    end

    def render_games_table(cols = %w[title location status])
      selected_games = game_rows_data.sort_by { |g| [g['meta']::PROTOTYPE ? 1 : 0, g['meta']] }
      selected_games = selected_games.select { |g| %i[alpha beta production].include?(g['meta']::DEV_STAGE) } if @production

      if @keywords&.size&.positive?
        searches = @keywords.split(/[:, ]+/).map(&:upcase)

        selected_games = selected_games.select do |game|
          searches.all? do |search|
            game['meta'].keywords.any? do |keyword|
              keyword =~ /#{search}/
            end
          end
        end
      end

      td_props = { style: { 'vertical-align': 'middle' } }
      game_rows = selected_games.map do |game|
        row_style = { cursor: 'pointer' }
        if selected_game && game['meta'] == (selected_game::GAME_IS_VARIANT_OF || selected_game)
          row_style['background-color'] = 'lightblue'
          row_style['color'] = 'black'
        end

        row_props = { on: { click: -> { select_game(game['meta']) } }, style: row_style }

        h(:tr, row_props, cols.map { |col| h(:td, td_props, game[col].to_s) })
      end

      props = { style: { 'text-align': 'left' } }
      h(
        'table.create-game-table',
        {},
        [
          h(:thead, [
              h(:tr, cols.map { |col| h(:th, props, col.capitalize) }),
            ]),
          h(:tbody, game_rows),
        ]
      )
    end

    def render_keyword_search
      attrs = @keywords ? { value: @keywords } : {}

      render_input(
        'Keywords',
        id: :keywords,
        placeholder: 'Search by Keyword',
        input_style: { 'margin-top': '50px' },
        label_style: { display: 'none' },
        attrs: attrs,
        on: {
          input: ->(e) { update_keyword_search(e) },
          keyup: ->(e) { Native(e)['key'] == 'Enter' && e.JS.stopPropagation },
        },
      )
    end

    def update_keyword_search(_e, *_args, **_kwargs)
      @keywords = Native(@inputs[:keywords]).elm&.value
      store(:keywords, @keywords)
      update_inputs
    end

    def should_render_optional?
      return false unless selected_game_or_variant

      @game_variants = selected_game.game_variants
      @visible_optional_rules = selected_game_or_variant::OPTIONAL_RULES.reject { |rule| filtered_rule?(rule) }
      !@game_variants.empty? || !selected_game_or_variant::OPTIONAL_RULES.empty?
    end

    def update_player_range(meta)
      title = meta.title
      @min_p[title], @max_p[title] = meta::PLAYER_RANGE
    end
  end
end
