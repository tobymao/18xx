# frozen_string_literal: true

module Engine
  module Corporation
    class Handler
      attr_reader :corporations

      def initialize(corporations)
        @corporations = corporations
      end
    end
  end
end
