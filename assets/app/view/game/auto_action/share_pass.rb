# frozen_string_literal: true

require 'view/game/auto_action/base'

module View
  module Game
    module AutoAction
      class SharePass < Base
        def name
          "Auto pass in #{@game.stock_round_name}#{' (Enabled)' if @settings}"
        end

        def description
          if @game.force_unconditional_stock_pass?
            "Automatically pass in the #{@game.stock_round_name}."\
              ' It will only pass on your normal turn and will still allow you to bid etc.'
          else
            "Automatically pass in the #{@game.stock_round_name}."\
              ' This will deactivate itself if other players do actions that may impact you.'\
              ' It will only pass on your normal turn and allow you to bid etc.'
          end
        end

        def render
          form = {}

          children = [h(:h3, name), h(:p, description)]

          unless @game.force_unconditional_stock_pass?
            children << render_checkbox('Pass even if other players do actions that may impact you.',
                                        'sr_unconditional',
                                        form,
                                        !!@settings&.unconditional)
          end
          children << render_checkbox("Continue passing in future #{@game.stock_round_name}s as well.",
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
