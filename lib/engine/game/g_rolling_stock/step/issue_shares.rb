# frozen_string_literal: true

require_relative '../../../step/issue_shares'

module Engine
  module Game
    module GRollingStock
      module Step
        class IssueShares < Engine::Step::IssueShares
          def actions(entity)
            return [] if entity.corporation? && entity.receivership?

            super
          end

          def description
            'Issue Share'
          end

          def pass_description
            'Skip (Issue)'
          end

          def skip!
            return super unless receivership_can_issue?(current_entity)

            sell_shares(issuable_shares(current_entity).first)
          end

          def receivership_can_issue?(entity)
            return false unless entity.corporation?
            return false unless entity.receivership?

            !issuable_shares(entity).empty?
          end

          def process_sell_shares(action)
            sell_shares(action.bundle)
          end

          def sell_shares(bundle)
            @game.share_pool.sell_shares(bundle)
            @game.move_to_left(bundle.corporation) unless @game.abilities(bundle.corporation, :stock_masters)
            pass!
          end
        end
      end
    end
  end
end
