# frozen_string_literal: true

require 'view/game/pass_button'

module View
  module Game
    class Pass < Snabberb::Component
      include Actionable
      needs :before_process_pass, store: true
      needs :actions, default: []

      def render
        children = []
        children << h(PassButton, before_process_pass: @before_process_pass) if @actions.include?('pass')
        h(:div, children.compact)
      end
    end
  end
end
