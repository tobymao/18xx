# frozen_string_literal: true

require 'view/game/pass_button'
require 'view/game/pass_auto_button'

module View
  module Game
    class Pass < Snabberb::Component
      include Actionable
      needs :actions, default: []

      def render
        children = []
        if @actions.include?('pass')
          children << h(PassButton)
          children << h(PassAutoButton) if @game.round.stock? && @game.active_players_id.include?(@user&.dig('id'))
        end
        h(:div, children.compact)
      end
    end
  end
end
