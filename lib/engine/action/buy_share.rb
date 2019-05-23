# frozen_string_literal: true

module Engine
  module Action
    class BuyShare < Base
      def initialize(entity, share)
        @entity = entity
        @share = share
      end

      def corporation
        @share.corporation
      end
    end
  end
end
