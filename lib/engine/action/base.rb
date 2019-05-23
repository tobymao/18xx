# frozen_string_literal: true

module Engine
  module Action
    class Base
      def pass?
        false
      end

      def entity
        raise NotImplementedError
      end
    end
  end
end
