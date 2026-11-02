# frozen_string_literal: true

require_relative '../../../round/auction'

module Engine
  module Game
    module G18VA
      module Round
        class Auction < Engine::Round::Auction
          # The auction only ends once everyone passes in a row, so offer the
          # standard "Auto pass" (ProgramSharePass); see Step::WaterfallAuction.
          def show_auto?
            true
          end
        end
      end
    end
  end
end
