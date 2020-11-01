# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G18CO
      class IssueShares < Base
        def actions(entity)
          available_actions = []
          return available_actions unless entity.corporation?
          return available_actions if entity != current_entity

          available_actions << 'sell_shares' unless issuable_shares(entity).empty?
          available_actions << 'pass' if blocks? && !available_actions.empty?

          available_actions
        end

        def description
          'Issue Shares'
        end

        def pass_description
          'Skip Issue Shares'
        end

        def process_sell_shares(action)
          @game.sell_shares_and_change_price(action.bundle)
        end

        def issuable_shares(entity)
          # Done via Sell Shares
          @game.issuable_shares(entity)
        end
      end
    end
  end
end
