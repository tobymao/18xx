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
            h(:div, [render_button('Create Account') { submit }]),
            render_input('User Name', id: :name),
            render_input('Email', id: :email, type: :email, attrs: { autocomplete: 'email' }),
            render_input('Password', id: :password, type: :password, attrs: { autocomplete: 'current-password' }),
          ]]
        when :login
          ['Login', [
            h('div.pure-u-1', [render_button('Login') { submit }]),
            render_input('Email', id: :email, type: :email, attrs: { autocomplete: 'email' }),
            render_input('Password', id: :password, type: :password, attrs: { autocomplete: 'current-password' }),
          ]]
        when :profile
          ['Edit Profile (Coming Soon)', [
            h(:div, [render_button('Logout') { submit }]),
          ]]
        end

      render_form(title, inputs)
    end

    def submit
      case @type
      when :signup
        create_user(params)
      when :login
        login(params)
      when :profile
        logout
      end
    end
  end
end
