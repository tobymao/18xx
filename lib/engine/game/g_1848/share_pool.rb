# frozen_string_literal: true

require_relative '../../share_pool'

module Engine
  module Game
    module G1848
      class SharePool < Engine::SharePool
        def fit_in_bank?(bundle)
          return super unless bundle.corporation == @game.boe

          # no bank limit for boe
          true
        end
      end
    end
  end
end
