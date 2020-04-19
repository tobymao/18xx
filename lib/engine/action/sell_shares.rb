# frozen_string_literal: true

require_relative 'base'
require_relative '../share_bundle'

module Engine
  module Action
    class SellShares < Base
      attr_reader :entity, :shares

      def initialize(entity, shares, percent = nil)
        @entity = entity
        @shares = ShareBundle.new(shares, percent || shares.sum(&:percent))
      end

      def self.h_to_args(h, game)
        [h['shares'].map { |id| game.share_by_id(id) }, h['percent']]
      end

      def args_to_h
        {
          'shares': @shares.shares.map(&:id),
          'percent': @shares.percent,
        }
      end
    end
  end
end
