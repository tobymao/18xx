# frozen_string_literal: true

require 'user_manager'
require 'view/form'

module View
  class User < Form
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
            h(:a, { attrs: { href: '/forgot' } }, 'Forgot Password')
          ]]
        when :profile
          ['Profile Settings', [
            h(:div, [
              render_notifications(@user&.dig(:settings, :notifications)),
              render_button('Save Changes') { submit },
            ]),
            render_button('Logout') { logout },
          ]]
        end

      render_form(title, inputs)
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
