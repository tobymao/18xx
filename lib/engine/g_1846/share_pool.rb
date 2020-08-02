# frozen_string_literal: true

require_relative '../share_bundle'
require_relative '../share_pool'

module Engine
  module G1846
    class SharePool < SharePool
      def companies
        []
      end

      def buy_shares(entity, bundle, exchange: nil)
        if @game.bundle_is_presidents_share_alone_in_pool?(bundle)
          percent = 10
          bundle = ShareBundle.new(bundle.shares, percent)
        end

        super
      end
    end
  end
end
