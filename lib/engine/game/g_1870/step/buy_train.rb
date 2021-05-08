# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1870
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def can_sell?(entity, bundle)
            super && bundle.corporation.holding_ok?(entity, -bundle.percent)
          end

          def selling_minimum_shares?(bundle)
            super || !bundle.corporation.holding_ok?(bundle.owner, -bundle.percent + 1)
          end
        end
      end
    end
  end
end
