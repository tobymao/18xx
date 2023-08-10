# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class BlindBid < Base
      attr_reader :bids

      def initialize(entity, bids: [])
        super(entity)
        @bids = bids
      end

      def self.h_to_args(h, _game)
        {
          bids: h['bids']&.map(&:to_i),
        }
      end

      def args_to_h
        {
          'bids' => @bids,
        }
      end
    end
  end
end
