# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class BuySpecial < Base
      attr_reader :item

      def initialize(entity, item:)
        super
        @item = item
      end

      def self.h_to_args(h, _game)
        {
          item: Item.new(description: h['description'], cost: h['cost']),
        }
      end

      def args_to_h
        {
          'description' => item.description,
          'cost' => item.cost,
        }
      end
    end
  end
end
