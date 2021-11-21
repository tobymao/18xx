# frozen_string_literal: true

require_relative '../../share_pool'

module Engine
  module Game
    module G1822MX
      class SharePool < Engine::SharePool
        def fit_in_bank?(bundle)
          return super unless bundle.corporation.id == 'NDEM'

          true
        end

        def bank_at_limit?(corporation)
          return super unless corporation.id == 'NDEM'

          false
        end
      end
    end
  end
end
