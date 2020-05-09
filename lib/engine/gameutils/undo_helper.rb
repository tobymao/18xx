# frozen_string_literal: true

module Engine
  module GameUtils
    class UndoHelper
      attr_reader :undo_list

      def initialize(actions = nil)
        process_actions(actions)
      end

      def process_actions(actions)
        @undo_list = []
        return if actions.nil?

        # List of actions that undo does not apply to
        # TODO not happy about this, duping code from action
        kept_actions = Action.constants.map do |c|
          klass = Action.const_get(c)
          klass.split(klass).last.gsub(/(.)([A-Z])/, '\1_\2').downcase if klass.keep_on_undo?
        end.compact

        stack = []
        actions.each.with_index do |action, index|
          if action['type'] == 'undo'
            @undo_list.append(*stack.pop(action['steps']))
          elsif action['type'] == 'redo'
            @undo_list.pop(action['steps'])
          elsif !kept_actions.include?(action['type'])
            # action_id's start at 1
            stack.append(index + 1)
          end
        end
      end

      def last_undoable_action(actions)
        actions.rindex { |x| !x.class.keep_on_undo? }
      end

      def ignore_action?(action)
        if @undo_list.include?(action.id)
          true
        elsif action.is_a?(Action::Undo) || action.is_a?(Action::Redo)
          true
        else
          false
        end
      end

      # Would this action cause the undo list to change?
      def needs_reprocessing?(_action)
        # to implement
        false
      end
    end
  end
end
