# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/issue_shares'

module Engine
  module Game
    module G1862
      module Step
        class RedeemShare < Engine::Step::IssueShares
          def actions(entity)
            return [] unless entity.corporation?
            return [] if entity != current_entity
            return [] if entity.receivership?
            return [] if @game.skip_round[entity]

            available_actions = []
            available_actions << 'buy_shares' if can_redeem?(entity)
            available_actions << 'pass' if blocks? && !available_actions.empty?

            available_actions
          end

          def log_skip(entity)
            super unless @game.skip_round[entity]
          end

          def description
            'Redeem a Share'
          end

          def pass_description
            'Skip (Redeem)'
          end

          def can_redeem?(entity)
            return false if (shares = redeemable_shares(entity)).empty?

            shares.any? { |s| s.price <= entity.cash }
          end
        end
      end
    end
  end
end
