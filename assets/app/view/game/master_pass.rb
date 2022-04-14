# frozen_string_literal: true

require 'view/game/pass_button'

module View
  module Game
    class MasterPass < Snabberb::Component
      include Actionable

      def render
        round = @game.round
        entities = round.active_step.active_entities

        children = []
        entities.each do |entity|
          children << h(PassButton, for_player: entity) if round.actions_for(entity).include?('pass')
        end
        h(:div, children.compact)
      end
    end
  end
end
