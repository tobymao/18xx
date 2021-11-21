# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18NY
      module Step
        class IssueShares < Engine::Step::Base
          ACTIONS = %w[sell_shares pass].freeze

          def actions(entity)
            return [] unless entity.corporation?
            return [] if entity != current_entity
            return [] if issuable_shares(entity).empty?

            ACTIONS
          end

          def description
            'Issue Shares'
          end

          def pass_description
            'Skip (Issue)'
          end

          def process_sell_shares(action)
            @game.share_pool.sell_shares(action.bundle)
            pass!
          end

          def issuable_shares(entity)
            # Done via Sell Shares
            @game.issuable_shares(entity)
          end
        end
      end
    end
  end
end
