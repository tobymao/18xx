# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class ViewMergeOptions < Snabberb::Component
      include Actionable

      needs :corporation

      def render
        step = @game.round.step_for(@corporation, 'view_merge_options')

        button = h(:button, {
                     on: {
                       click: lambda do
                         process_action(Engine::Action::ViewMergeOptions.new(@corporation))
                       end,
                     },
                   },
                   step.view_merge_name,)

        h(:div, [button])
      end
    end
  end
end
