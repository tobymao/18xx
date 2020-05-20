# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class Undo < Base
      def free?
        true
      end
    end
  end
end
