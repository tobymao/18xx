# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/history_controls'
require 'view/game/pass_button'
require 'view/game/undo_button'
require 'view/game/redo_button'

module View
  module Game
    class HistoryAndUndo < Snabberb::Component
      include Actionable
      needs :last_action_id, default: 0

      def render
        h('div#history_undo', { style: { overflow: :auto } }, [history, undo])
      end

      def history
        h('div#history', { style: { marginBottom: '0.5rem' } }, [h(HistoryControls, last_action_id: @last_action_id)])
      end

      def undo
        h('div#undo_redo', [h(UndoButton), h(RestartTurnButton), h(RedoButton)])
      end
    end
  end
end
