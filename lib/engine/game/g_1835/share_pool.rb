# frozen_string_literal: true

require_relative '../../share_pool'

module Engine
  module Game
    module G1835
      class SharePool < Engine::SharePool
        # Bring higher percent shares to the front in order to always exchange the correct total percentage when the president
        # of PR changes. Otherwise, one 5% share might get exchange for the 10% director share.
        def possible_reorder(shares)
          shares.sort_by(&:percent).reverse
        end
      end
    end
  end
end
