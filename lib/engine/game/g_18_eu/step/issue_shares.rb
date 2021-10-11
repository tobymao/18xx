# frozen_string_literal: true

require_relative '../../../step/issue_shares'

module Engine
  module Game
    module G18EU
      module Step
        class IssueShares < Engine::Step::IssueShares
          def actions(entity)
            return super if @game.corporations_operated.include?(entity)

            @game.corporations_operated << entity

            []
          end

          def process_sell_shares(action)
            @game.sell_shares_and_change_price(action.bundle)
            pass!
          end
        end
      end
    end
  end
end
