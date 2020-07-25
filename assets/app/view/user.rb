# frozen_string_literal: true

require 'game_manager'
require 'user_manager'
require 'lib/settings'
require 'view/game_row'
require 'view/logo'
require 'view/form'

module View
  class User < Form
    include Lib::Settings
    include GameManager
    include UserManager

    needs :type

    TILE_COLORS = Lib::Hex::COLOR.freeze
    ROUTE_COLORS = Lib::Settings::ROUTE_COLORS.freeze

    def render_content
      title, inputs =
        case @type
        when :signup
          ['Signup', [
            render_input('User Name', id: :name),
            render_input('Email', id: :email, type: :email, attrs: { autocomplete: 'email' }),
            render_input('Password', id: :password, type: :password, attrs: { autocomplete: 'new-password' }),
            render_notifications,
            h(:div, [render_button('Create Account') { submit }]),
          ]]
        when :login
          ['Login', [
            render_input('Email', id: :email, type: :email, attrs: { autocomplete: 'email' }),
            render_input('Password', id: :password, type: :password, attrs: { autocomplete: 'current-password' }),
            h(:div, { style: { 'margin-bottom': '1rem' } }, [render_button('Login') { submit }]),
            h(:a, { attrs: { href: '/forgot' } }, 'Forgot Password'),
          ]]
        when :profile
          ['Profile Settings', [
            render_notifications(setting_for(:notifications)),
            h('div#settings__colors', [
              render_logo_color(setting_for(:red_logo)),
              h(:div, [
                render_color('Main Background', :bg, color_for(:bg)),
                render_color('Main Font Color', :font, color_for(:font)),
              ]),
              h(:div, [
                render_color('Alternative Background', :bg2, color_for(:bg2)),
                render_color('Alternative Font Color', :font2, color_for(:font2)),
              ]),
            ]),
            render_tile_colors,
            render_route_colors,
            h('div#settings__buttons', [
              render_button('Save Changes') { submit },
              render_button('Reset to Defaults') { reset_settings },
            ]),
            h('div#settings__logout', [
              render_button('Logout') { logout },
            ]),
          ]]
        end

      children = [render_form(title, inputs)]

      if @type == :profile
        finished_games = @games.select do |game|
          user_in_game?(@user, game) && game['status'] == 'finished'
        end

        children << h(
          GameRow,
          header: 'Your Finished Games',
          game_row_games: finished_games,
          type: :personal,
          user: @user,
        )
      end

      h(:div, children)
    end

    def input_elm(setting)
      Native(@inputs[setting]).elm
    end

    def reset_settings
      input_elm(:bg).value = default_for(:bg)
      input_elm(:font).value = default_for(:font)
      input_elm(:bg2).value = default_for(:bg2)
      input_elm(:font2).value = default_for(:font2)
      input_elm(:red_logo).checked = false

      TILE_COLORS.each do |color, hex_color|
        input_elm(color).value = hex_color
      end

      ROUTE_COLORS.each_with_index do |hex_color, index|
        input_elm("r#{index}_color").value = hex_color
        input_elm("r#{index}_dash").value = '0'
        input_elm("r#{index}_width").value = 8
      end

      submit
    end

    def render_notifications(checked = true)
      h('div#settings__notifications', [
        @elm_notifications = render_input(
          'Allow Turn and Message Notifications',
          id: :notifications,
          type: :checkbox,
          attrs: { checked: checked },
        ),
      ])
    end

    def render_color(label, id, hex_color, attrs: {})
      render_input(label, id: id, type: :color, attrs: { value: hex_color, **attrs })
    end

    def render_logo_color(red_logo)
      render_input(
        'Alternative Red Logo',
        id: :red_logo,
        type: :checkbox,
        attrs: { checked: red_logo },
      )
    end

    def render_tile_colors
      h('div#settings__tiles', [
        h(:h3, 'Map & Tile Colors'),
        h('div#settings__tiles__buttons', TILE_COLORS.map do |color, _|
          render_color('', color, setting_for(color), attrs: { title: color == 'white' ? 'plain' : color })
        end),
      ])
    end

    def render_route_colors
      grid_props = {
        style: {
          display: 'grid',
          grid: '1fr / 5rem 4rem 5rem 5rem',
          alignItems: 'center',
        },
      }

      children = ROUTE_COLORS.map.with_index do |_, index|
        h(:div, grid_props, [
          h(:label, "Route #{index + 1}"),
          render_color(
            '',
            "r#{index}_color",
            route_prop(index, :color),
            attrs: { title: 'color of train and route on map' },
          ),
          render_input(
            '',
            id: "r#{index}_width",
            type: :number,
            attrs: {
              title: 'width of route on map',
              min: 6,
              max: 24,
              value: route_prop(index, :width),
            },
            input_style: { width: '2.5rem' },
          ),
          render_input(
            '',
            id: "r#{index}_dash",
            type: :text,
            attrs: {
              title: 'dash/gap lengths of route on map, for help hover/click header',
              value: route_prop(index, :dash),
            },
            input_style: { width: '2.5rem' },
          ),
        ])
      end

      header_props = { style: { marginLeft: '0.5rem' } }

      help_message = <<~MESSAGE
        5 = dash 5, gap 5, [repeat]
        15 5 7.5 5 = dash 15, gap 5, dash 7.5, gap 5, [repeat]
        hex width (side to side) = 174
      MESSAGE
      link_props = {
        props: {
          href: 'https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-dasharray',
          title: help_message,
        },
        style: {
          marginLeft: '0.5rem',
        },
      }

      h('div#routes', [
        h(:h3, 'Trains & Routes'),
        h(:div, grid_props, [
          h(:div, ''),
          h(:div, header_props, 'Color'),
          h(:div, header_props, 'Width'),
          h(:a, link_props, 'Dash'),
        ]),
        *children,
      ])
    end

    def submit
      case @type
      when :signup
        create_user(params)
      when :login
        login(params)
      when :profile
        edit_user(params)
      end
    end
  end
end
