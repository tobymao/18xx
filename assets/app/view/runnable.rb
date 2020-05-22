# frozen_string_literal: true

module View
  module Runnable
    def self.included(base)
      base.needs :game, store: true, default: nil
      base.needs :selected_route, store: true, default: nil
    end

    def touch_node(node)
      return if !@game&.round&.can_run_routes? || !@selected_route

      @selected_route.touch_node(node)
      store(:selected_route, @selected_route)
    end
  end
end
