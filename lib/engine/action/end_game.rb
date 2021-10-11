# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class EndGame < Base
      def free?
        true
      end
    end
  end
end
