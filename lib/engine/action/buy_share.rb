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

      def copy(game)
        self.class.new(
          game.player_by_name(@player.name),
          game.share_by_name(@share.name),
        )
      end
    end
  end
end
