# frozen_string_literal: true

require 'game_manager'
require 'user_manager'
require 'view/game_row'
require 'view/logo'
require 'view/form'

module View
  class User < Form
    include Lib::Color
    include GameManager
    include UserManager

    needs :type

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
          dark = `window.matchMedia('(prefers-color-scheme: dark)').matches`
          ['Profile Settings', [
            render_notifications(@user&.dig(:settings, :notifications)),
            h('div#settings__colors', [
              render_logo_color(@user&.dig(:settings, :red_logo)),
              h(:div, [
                render_color(:bg, 'Main Background', color_for(:bg), dark ? '#000000' : '#ffffff'),
                render_color(:font, 'Main Font Color', color_for(:font), dark ? '#ffffff' : '#000000'),
              ]),
              h(:div, [
                render_color(:bg2, 'Alternative Background', color_for(:bg2), dark ? '#dcdcdc' : '#d3d3d3'),
                render_color(:font2, 'Alternative Font Color', color_for(:font2), '#000000'),
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

    def reset_settings
      dark = `window.matchMedia('(prefers-color-scheme: dark)').matches`
      Native(@inputs[:bg]).elm.value = dark ? '#000000' : '#ffffff'
      Native(@inputs[:font]).elm.value = dark ? '#dcdcdc' : '#000000'
      Native(@inputs[:bg2]).elm.value = dark ? '#dcdcdc' : '#d3d3d3'
      Native(@inputs[:font2]).elm.value = '#000000'
      Native(@inputs[:red_logo]).elm.checked = false
      Lib::Hex::COLOR.each do |color, hex_color|
        Native(@inputs[color]).elm.value = hex_color
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

    def render_color(id, name, hex_color, default)
      hex_color ||= default
      render_input(name, id: id, type: :color, attrs: { value: hex_color },)
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
        h('div#settings__tiles__buttons', Lib::Hex::COLOR.map do |color, _hex_color|
          render_input(
            '',
            id: color,
            type: :color,
            attrs: { title: color == 'white' ? 'plain' : color, value: color_for(color) },
          )
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
