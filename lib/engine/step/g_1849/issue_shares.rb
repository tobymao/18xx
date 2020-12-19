# frozen_string_literal: true

require_relative '../issue_shares'

module Engine
  module Step
    module G1849
      class IssueShares < IssueShares
        def process_sell_shares(action)
          @game.sell_shares_and_change_price(action.bundle)
          pass!
        end
      end
    end
  end
end
