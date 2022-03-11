# frozen_string_literal: true

require 'view/game/auto_action/base'

module View
  module Game
    module AutoAction
      class SharePass < Base
        def name
          "Auto pass in Stock Round#{' (Enabled)' if @settings}"
        end

        def description
          'Automatically pass in the stock round.'\
            ' This will deactivate itself if other players do actions that may impact you.'\
            ' It will only pass on your normal turn and allow you to bid etc.'
        end

        def render
          form = {}

          children = [h(:h3, name), h(:p, description)]

          children << render_checkbox('Pass even if other players do actions that may impact you.',
                                      'sr_unconditional',
                                      form,
                                      !!@settings&.unconditional)
          children << render_checkbox('Continue passing in future SR as well.',
                                      'sr_indefinite',
                                      form,
                                      !!@settings&.indefinite)

          subchildren = [render_button(@settings ? 'Update' : 'Enable') { enable(form) }]
          subchildren << render_disable(@settings) if @settings
          children << h(:div, subchildren)

          children
        end

        def enable(form)
          @settings = params(form)

          unconditional = @settings['sr_unconditional']
          indefinite = @settings['sr_indefinite']

          process_action(
            Engine::Action::ProgramSharePass.new(
              @sender,
              unconditional: unconditional,
              indefinite: indefinite,
            )
          )
        end
      end
    end
  end
end
