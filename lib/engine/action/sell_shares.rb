# frozen_string_literal: true

require 'engine/action/base'

module Engine
  module Action
    class SellShares < Base
      attr_reader :entity, :shares

      def initialize(entity, shares)
        @entity = entity
        @shares = shares
      end

      def corporation
        @shares.first.corporation
      end

      def self.h_to_args(h, game)
        [h['shares'].map { |id| game.share_by_id(id) }]
      end

      def args_to_h
        { 'shares' => @shares.map(&:id) }
      end
    end
  end
end
