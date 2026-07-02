# frozen_string_literal: true

require 'user_manager'
require 'view/form'

module View
  class Forgot < Form
    include UserManager

    def render_content
      title = 'Forgot Password'
      inputs = [
        render_input('Email', id: :email, type: :email, attrs: { autocomplete: 'email' }),
        turnstile_widget,
        h(:div, [render_button('Reset Password') { submit }]),
      ]
      render_form(title, inputs)
    end

    def submit
      forgot(params)
      reset_turnstile
    end
  end
end
