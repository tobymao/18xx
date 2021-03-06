# frozen_string_literal: true

require_relative '../../../step/waterfall_auction'

module Engine
  module Game
    module G2038
      module Step
        class WaterfallAuction < Engine::Step::WaterfallAuction
          def setup
            @log << "-- Using our setup"
            super

            @companies = @companies + @game.minors
            @companies = @companies.sort_by(&:value)
            @cheapest = @companies.first

            @log << "-- Done"
          end
        end
      end
    end
  end
end
