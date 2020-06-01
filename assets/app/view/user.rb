# frozen_string_literal: true

require 'game_manager'
require 'user_manager'
require 'view/game_row'
require 'view/form'

module View
  class User < Form
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
            h(:div, [render_button('Login') { submit }]),
            h(:a, { attrs: { href: '/forgot' } }, 'Forgot Password'),
          ]]
        when :profile
          ['Profile Settings', [
            render_notifications(@user&.dig(:settings, :notifications)),
            h(:div, [
              render_bg_color(@user&.dig(:settings, :bg_color)),
              render_font_color(@user&.dig(:settings, :font_color)),
            ]),
            render_button('Save Changes') { submit },
            render_button('Logout') { logout },
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

    def render_notifications(checked = true)
      render_input(
        'Allow Turn and Message Notifications',
        id: :notifications,
        type: :checkbox,
        attrs: { checked: checked },
      )
    end

    def render_bg_color(bg_color)
      bg_color ||= '#ffffff'
      render_input(
        'Background color',
        id: :bg_color,
        type: :color,
        attrs: { value: bg_color },
      )
    end

    def render_font_color(font_color)
      font_color ||= '#000000'
      render_input(
        'Font color',
        id: :font_color,
        type: :color,
        attrs: { value: font_color },
      )
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
