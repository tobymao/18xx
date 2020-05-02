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

        pending_undos = 0
        pending_redos = 0

        actions.reverse_each.with_index do |action, index|
          # We cannot construct the object here since some rely on the game state
          klass = if action.is_a?(Action::Base)
                    action.class
                  else
                    Action::Base.get_class(action)
                  end

          if klass == Action::Undo
            if pending_redos.zero?
              pending_undos += 1
            else
              pending_redos -= 1
            end
          elsif klass == Action::Redo
            pending_redos += 1
          elsif !klass.keep_on_undo? && pending_undos != 0
            # action_id's start at 1, so don't remove the extra 1
            @undo_list.append(actions.size - index)
            pending_undos -= 1
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
