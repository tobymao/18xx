# frozen_string_literal: true

require 'user_manager'
require 'view/form'

module View
  class Reset < Form
    include UserManager

    def render_content
      title = 'Reset Password'
      inputs = [
        render_input('Email', id: :email, type: :email, attrs: { autocomplete: 'email' }),
        render_input('Temporary Password', id: :hash, type: :password, attrs: { autocomplete: 'temp-password' }),
        render_input('New Password', id: :password, type: :password, attrs: { autocomplete: 'new-password' }),
        h(:div, [render_button('Reset Password') { submit }])
      ]
      render_form(title, inputs)
    end

    def submit
      reset(params)
    end
  end
end
