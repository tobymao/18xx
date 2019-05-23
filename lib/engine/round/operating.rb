# frozen_string_literal: true

module Engine
  module Round
    class Operating < Base
      attr_reader :num

      def initialize(entities, **opts)
        super
        @num = opts[:num] || 1
      end
    end
  end
end
