# frozen_string_literal: true

require 'game_manager'
require 'user_manager'
require 'view/game_row'
require 'view/logo'
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
            h('a.default-bg', { attrs: { href: '/forgot' } }, 'Forgot Password'),
          ]]
        when :profile
          ['Profile Settings', [
            render_notifications(@user&.dig(:settings, :notifications)),
            h(:div, [
              render_color(:bg_color, 'Background Color', @user&.dig(:settings, :bg_color), '#ffffff'),
              render_color(:font_color, 'Font Color', @user&.dig(:settings, :font_color), '#000000'),
              render_logo_color(@user&.dig(:settings, :red_logo)),
            ]),
            render_button('Save Changes') { submit },
            render_button('Use Default Colors') { reset_colors },
            h(:div, [
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

    def reset_colors
      @inputs.delete(:font_color)
      @inputs.delete(:bg_color)
      @inputs.delete(:red_logo)
      submit
    end

    def render_color(id, name, color, default)
      color ||= default
      render_input(name, id: id, type: :color, attrs: { value: color })
    end

    def render_logo_color(red_logo)
      render_input(
        'Alternative Red Logo',
        id: :red_logo,
        type: :checkbox,
        attrs: { checked: red_logo },
      )
    end

    def render_notifications(checked = true)
      render_input(
        'Allow Turn and Message Notifications',
        id: :notifications,
        type: :checkbox,
        attrs: { checked: checked },
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
