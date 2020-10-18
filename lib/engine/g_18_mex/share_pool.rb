# frozen_string_literal: true

require_relative '../share_pool'

module Engine
  module G18MEX
    class SharePool < SharePool
      # Put any 5% shares last so that they are only exchanged if they need to make
      # up the 20% needed.
      def possible_reorder(shares)
        shares.sort_by(&:percent).reverse
      end
    end
  end
end
