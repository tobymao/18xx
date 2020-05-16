# frozen_string_literal: true

require 'user_manager'
require 'view/form'

module View
  class Reset < Form
    include UserManager

    def render_content
      title = 'Reset Password'
      inputs = [
        render_input('Temporary Password', id: :hash, type: :password, attrs: { autocomplete: 'temp-password' }),
        render_input('New Password', id: :password, type: :password, attrs: { autocomplete: 'new-password' }),
        h(:div, [render_button('Reset Password') { submit }])
      ]
      render_form(title, inputs)
    end

    def submit
      compiled_params = params
      compiled_params['id'] = Lib::Params['user_id']
      reset(compiled_params)
    end
  end
end
