# frozen_string_literal: true

require 'view/form'
require 'view/game/actionable'

module View
  module Game
    module AutoAction
      class Base < Form
        include Actionable

        needs :game, store: true
        needs :sender
        needs :settings

        def disable
          process_action(
            Engine::Action::ProgramDisable.new(
              @sender,
              reason: 'user'
            )
          )
        end

        def render_disable
          render_button('Disable') { disable }
        end
      end
    end
  end
end
