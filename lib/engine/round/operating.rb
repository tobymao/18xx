# frozen_string_literal: true

require 'engine/action/lay_tile'

module Engine
  module Round
    class Operating < Base
      attr_reader :num

      def initialize(entities, num: 1)
        super
        @num = num
      end

      def finished?
        false
      end

      private

      def _process_action(action)
        case action
        when Action::LayTile
          action.hex.lay(action.tile)
        end
      end
    end
  end
end
