# frozen_string_literal: true

require 'view/game/pass_button'
require 'view/game/undo_button'
require 'view/game/redo_button'

module View
  module Game
    class UndoAndPass < Snabberb::Component
      include Actionable
      needs :pass, default: true

      def render
        children = []
        children << h(UndoButton) if @game.undo_possible
        children << h(RedoButton) if @game.redo_possible
        children << h(PassButton) if @pass
        h(:div, children)
      end
    end
  end
end
