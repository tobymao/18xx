# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class BuySpecial < Base
      attr_reader :entity, :item

      def initialize(entity, item:)
        @entity = entity
        @item = item
      end

      def self.h_to_args(h, _game)
        {
          item: h['item'],
        }
      end

      def args_to_h
        {
          'item' => @item,
        }
      end
    end
  end
end
