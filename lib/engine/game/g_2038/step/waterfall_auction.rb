# frozen_string_literal: true

require_relative '../../../step/waterfall_auction'

module Engine
  module Game
    module G2038
      module Step
        class WaterfallAuction < Engine::Step::WaterfallAuction
          def all_passed!
            super
          end
        end
      end
    end
  end
end
