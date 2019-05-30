# frozen_string_literal: true

module Engine
  module Action
    class Float < Base
      attr_reader :entity, :corporation, :share_price

      def initialize(entity, corporation, share_price)
        @entity = entity
        @corporation = corporation
        @share_price = share_price
      end
    end
  end
end
