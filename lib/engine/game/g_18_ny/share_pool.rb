# frozen_string_literal: true

require_relative '../../share_pool'

module Engine
  module Game
    module G18NY
      class SharePool < Engine::SharePool
        def fit_in_bank?(bundle)
          player_held = bundle.corporation.player_share_holders.values.sum
          player_held -= bundle.percent if bundle.owner.player?

          (bundle.percent + percent_of(bundle.corporation)) <= player_held
        end
      end
    end
  end
end
