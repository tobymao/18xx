# frozen_string_literal: true

require_relative 'base'

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

      def self.h_to_args(h, game)
        [game.share_by_id(h['share'])]
      end

      def args_to_h
        { 'share' => @share.id }
      end
    end
  end
end
