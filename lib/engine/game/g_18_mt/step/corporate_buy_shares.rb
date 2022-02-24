# frozen_string_literal: true

require_relative '../../../step/corporate_buy_shares'

module Engine
  module Game
    module G18MT
      module Step
        class CorporateBuyShares < Engine::Step::CorporateBuyShares
          def actions(entity)
            return [] if entity.corporation? && !entity.operated?

            super
          end
        end
      end
    end
  end
end
