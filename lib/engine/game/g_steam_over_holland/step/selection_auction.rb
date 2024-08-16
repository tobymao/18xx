# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/passable_auction'

module Engine
  module Game
    module GSteamOverHolland
      module Step
        class SelectionAuction < Engine::Step::SelectionAuction
          include Engine::Step::PassableAuction

          def all_passed!
            company = @companies.first
            @companies.delete(company)
            @log << "All players pass on #{company.name[3..-1]}. Company is removed from the game."
            entities.each(&:unpass!)
            next_entity!
          end
        end
      end
    end
  end
end
