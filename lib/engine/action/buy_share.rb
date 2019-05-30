# frozen_string_literal: true

require 'engine/action/base'

module Engine
  module Action
    class BuyShare < Base
      attr_reader :entity, :share

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
