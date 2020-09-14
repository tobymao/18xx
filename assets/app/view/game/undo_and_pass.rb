# frozen_string_literal: true

require 'view/game/pass_button'
require 'view/game/undo_button'
require 'view/game/redo_button'

module View
  module Game
    class UndoAndPass < Snabberb::Component
      include Actionable

      needs :before_process_pass, store: true

      def render
        children = []
        entity = @game.round.current_entity
        current_actions = @game.round.actions_for(entity)
        children << h(UndoButton) if @game.undo_possible
        children << h(RedoButton) if @game.redo_possible
        children << h(PassButton, before_process_pass: @before_process_pass) if current_actions.include?('pass')
        h(:div, children)
      end
    end
  end
end
