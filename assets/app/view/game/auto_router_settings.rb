# frozen_string_literal: true

require 'user_manager'
require 'lib/settings'
require 'lib/storage'
require 'view/form'

module View
  module Game
    class AutoRouterSettings < Form
      include Lib::Settings
      include UserManager

      needs :path_timeout, store: true, default: 30
      needs :route_timeout, store: true, default: 10

      def render_content
        fields = [
          render_input(
            'Path timeout:',
            id: :path_timeout,
            type: :number,
            input_style: { width: '5rem' },
            attrs: {
              value: setting_for(:path_timeout),
            },
            on: { change: -> { submit_path_timeout } }
          ),
          h(:label, 'seconds'),
          h(:div, 'You may want to increase path timeout as more cities are connected with dense trackage, '\
                  'if you get suboptimal routes. '),
          h(:div, ' '),
          render_input(
            'Route timeout:',
            id: :route_timeout,
            type: :number,
            input_style: { width: '5rem' },
            attrs: {
              value: setting_for(:route_timeout),
            },
            on: { change: -> { submit_route_timeout } }
          ),
          h(:label, 'seconds'),
          h(:div, 'You may want to increase route timeout when a RR has 3 or more trains, if you get suboptimal routes.'),
        ]

        h(:div, [
          h(:h3, 'Auto Router Settings'),
          *fields,
        ])
      end

      def submit_path_timeout
        store(:path_timeout, params['path_timeout'], skip: true)
        edit_user(params)
      end

      def submit_route_timeout
        store(:route_timeout, params['route_timeout'], skip: true)
        edit_user(params)
      end
    end
  end
end
