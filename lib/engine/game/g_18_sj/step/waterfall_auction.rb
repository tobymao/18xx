# frozen_string_literal: true

require_relative '../../../step/waterfall_auction'

module Engine
  module Game
    module G18SJ
      module Step
        class WaterfallAuction < Engine::Step::WaterfallAuction
          def setup
            super

            # Remove any 0 value companies - they are not part of
            # the auction, but used for player abilities.
            @companies.select! { |c| c.value.positive? }
            @cheapest = @companies.first
          end

          def buy_company(player, company, price)
            super

            if company.id == 'NE'
              # Give the buyer a one time priority deal steal
              pdc = @game.company_by_id('NEFT')
              pdc.owner = player
              player.companies << pdc
            end

            minor = @game.minor_khj

            return unless company.sym == minor&.name

            @game.log << "#{minor.name} floats"
            minor.owner = player
            minor.float!
          end
        end
      end
    end
  end
end
