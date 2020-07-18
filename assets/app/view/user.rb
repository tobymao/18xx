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

    DARK = `window.matchMedia('(prefers-color-scheme: dark)').matches`.freeze
    TILE_COLORS = Lib::Hex::COLOR.freeze

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
                render_color('Main Background', :bg, color_for(:bg), DARK ? '#000000' : '#ffffff'),
                render_color('Main Font Color', :font, color_for(:font), DARK ? '#ffffff' : '#000000'),
              ]),
              h(:div, [
                render_color('Alternative Background', :bg2, color_for(:bg2), DARK ? '#dcdcdc' : '#d3d3d3'),
                render_color('Alternative Font Color', :font2, color_for(:font2), '#000000'),
              ]),
            ]),
            render_tile_colors,
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

    def render_color(label, id, hex_color, default, attrs = {})
      hex_color ||= default
      render_input(label, id: id, type: :color, attrs: { value: hex_color, **attrs },)
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
        h(:label, 'Map & Tile Colors'),
        h('div#settings__tiles__buttons', TILE_COLORS.map do |color, hex_color|
          render_color('', color, setting_for(color), hex_color, attrs: { title: color == 'white' ? 'plain' : color })
        end),
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
