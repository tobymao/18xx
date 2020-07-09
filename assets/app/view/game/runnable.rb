# frozen_string_literal: true

module View
  module Game
    module Runnable
      def self.included(base)
        base.needs :game, store: true, default: nil
        base.needs :selected_route, store: true, default: nil
      end

      def touch_node(node)
        current_actions = @game.active_step.current_actions

        return if !current_actions.include?('run_routes') || !@selected_route

        @selected_route.touch_node(node)
        store(:selected_route, @selected_route)
      end
    end
  end
end
