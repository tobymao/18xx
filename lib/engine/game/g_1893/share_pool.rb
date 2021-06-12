# frozen_string_literal: true

require_relative 'share_pool'

module Engine
  module Game
    module G1893
      class SharePool < Engine::SharePool
        # AdSK can be 100% in market
        def bank_at_limit?(corporation)
          return false if corporation == @game.adsk && percent_of(corporation) < 100

          super
        end
      end
    end
  end
end
