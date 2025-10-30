# frozen_string_literal: true

require 'view/game/pass_button'
require 'view/game/pass_auto_button'

module View
  module Game
    class Pass < Snabberb::Component
      include Actionable
      needs :actions, default: []

      def render
        # This lambda runs *before* the PassButton executes its action
        confirm_before = lambda do
          # Recompute step on every click
          step =
            if @game.round.respond_to?(:active_step)
              @game.round.active_step
            else
              @game.round
            end

          needs_confirm = step.respond_to?(:confirm_pass?) && step&.confirm_pass?
          message =
            if step.respond_to?(:confirm_pass_message) && (m = step.confirm_pass_message).to_s.strip != ''
              m
            else
              'Are you sure you want to pass?'
            end

          do_pass = -> { process_action(Engine::Action::Pass.new(@game.pass_entity(@user))) }

          if needs_confirm
            store(:confirm_opts, { message: message, click: do_pass }, skip: false)
            false # stop default behavior (PassButton won’t run process_action yet)
          else
            true # allow PassButton to proceed normally
          end
        end

        children = []
        if @actions.include?('pass')
          children << h(PassButton, before_process_pass: confirm_before)

          if @game.round.show_auto? && @game.active_players_id.include?(@user&.dig('id'))
            children << h(PassAutoButton, before_process_pass: confirm_before)
          end
        end

        h(:div, children.compact)
      end
    end
  end
end
