# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/corporation'

module View
  module Game
    module Round
      class Merger < Snabberb::Component
        include Actionable

        needs :selected_corporation, default: nil, store: true

        def render
          @corporation = @game.current_entity
          @step = @game.round.active_step
          actions = @game.round.actions_for(@corporation)

          children = []
          children << render_convert if actions.include?('convert')
          children << render_loan if actions.include?('take_loan')
          children << render_merge if actions.include?('merge')
          children << h(Corporation, corporation: @corporation)

          @step.mergeable(@corporation).each do |target|
            children << h(Corporation, corporation: target)
          end

          h(:div, children)
        end

        def render_convert
          h(
            :button,
            { on: { click: -> { process_action(Engine::Action::Convert.new(@corporation)) } } },
            'Convert',
          )
        end

        def render_merge
          merge = lambda do
            process_action(Engine::Action::Merge.new(
              @corporation,
              corporation: @selected_corporation,
            ))
          end

          h(:button, { on: { click: merge } }, 'Merge')
        end

        def render_loan
          take_loan = lambda do
            process_action(Engine::Action::TakeLoan.new(
              @corporation,
              loan: @game.loans[0],
            ))
          end

          h(:button, { on: { click: take_loan } }, 'Take Loan')
        end
      end
    end
  end
end
