# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/half_pay'

module Engine
  module Game
    module G1847AE
      module Step
        class Dividend < Engine::Step::Dividend
          def holder_for_corporation(_entity)
            # Corps are only paid for shares in the market
            @game.share_pool
          end
        end
      end
    end
  end
end
