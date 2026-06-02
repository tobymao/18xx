# frozen_string_literal: true

module Engine
  module Game
    module G1835
      module Step
        class Dividend < Engine::Step::Dividend
          include Engine::Step::MinorHalfPay

          def holder_for_corporation(_entity)
            # Incremental corps DON'T get paid from IPO shares.
            @game.share_pool
          end
        end
      end
    end
  end
end
