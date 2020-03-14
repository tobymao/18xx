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

      def copy(game)
        self.class.new(
          game.player_by_name(@player.name),
          @shares.map { |share| game.share_by_name(share.name) },
        )
      end
    end
  end
end
