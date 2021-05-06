# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G1840
      module Step
        class Dividend < Engine::Step::Dividend
          def change_share_price(entity, payout)
            return if entity.type == :minor

            super
          end
        end
      end
    end
  end
end
