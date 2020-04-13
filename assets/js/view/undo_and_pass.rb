# frozen_string_literal: true

require 'view/pass_button'
require 'view/undo_button'

module View
  class UndoAndPass < Snabberb::Component
    needs :undo, default: true
    needs :pass, default: true

    def render
      children = []
      children << h(UndoButton) if @undo
      children << h(PassButton) if @pass
      h(:div, children)
    end
  end
end
