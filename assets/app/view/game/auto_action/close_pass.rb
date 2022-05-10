# frozen_string_literal: true

require 'view/game/auto_action/base'

module View
  module Game
    module AutoAction
      class ClosePass < Base
        def name
          "Auto pass in Closing Round#{' (Enabled)' if @settings}"
        end

        def description
          'Automatically pass in the close companies phase.'\
            ' This will persist from turn to turn.'\
            ' It will deactivate itself when you control a company with negative income, unless configured not do so.'\
        end

        def render
          form = {}

          children = [h(:h3, name), h(:p, description)]

          children << render_checkbox('Continue to pass even when one of your companies has negative income',
                                      'cr_unconditional',
                                      form,
                                      !!@settings&.unconditional)

          subchildren = [render_button(@settings ? 'Update' : 'Enable') { enable(form) }]
          subchildren << render_disable(@settings) if @settings
          children << h(:div, subchildren)

          children
        end

        def enable(form)
          @settings = params(form)

          unconditional = @settings['cr_unconditional']

          process_action(
            Engine::Action::ProgramClosePass.new(
              @sender,
              unconditional: unconditional,
            )
          )
        end
      end
    end
  end
end
