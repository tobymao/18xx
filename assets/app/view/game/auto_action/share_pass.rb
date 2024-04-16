# frozen_string_literal: true

require 'view/game/auto_action/base'

module View
  module Game
    module AutoAction
      class SharePass < Base
        def name
          "Auto Pass #{' (Enabled)' if @settings}"
        end

        def description
          "Pass your turn during #{@game.stock_round_name} (does not apply to auction rounds)."
        end

        def render
          form = {}

          children = [h(:h3, name), h(:p, description)]

          unless @game.force_unconditional_stock_pass?
            children << render_checkbox('Even when players take actions that may impact you (Unconditionally Pass).',
                                        'sr_unconditional',
                                        form,
                                        !!@settings&.unconditional)
          end
          children << render_checkbox("Continue in future #{@game.stock_round_name}s (Pass forever).",
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

          unconditional = @settings['sr_unconditional'] || @game.force_unconditional_stock_pass?
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
