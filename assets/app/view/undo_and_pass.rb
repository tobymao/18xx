# frozen_string_literal: true

require 'view/pass_button'
require 'view/undo_button'
require 'view/redo_button'

module View
  class UndoAndPass < Snabberb::Component
    include Actionable
    needs :undo, default: true
    needs :pass, default: true

    def render
      children = []
      children << h(UndoButton) if @game.can_undo?
      children << h(RedoButton) if @game.can_redo?
      children << h(PassButton) if @pass
      h(:div, children)
    end
  end
end
