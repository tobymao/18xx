# frozen_string_literal: true

require_relative '../../share_pool'

module Engine
  module Game
    module G1866
      class SharePool < Engine::SharePool
        def fit_in_bank?(bundle)
          return super unless @game.major_national_corporation?(bundle.corporation)

          (bundle.percent + percent_of(bundle.corporation)) <= @game.class::NATIONAL_MARKET_SHARE_LIMIT
        end

        def bank_at_limit?(corporation)
          return super unless @game.major_national_corporation?(corporation)

          percent_of(corporation) >= @game.class::NATIONAL_MARKET_SHARE_LIMIT
        end
      end
    end
  end
end
