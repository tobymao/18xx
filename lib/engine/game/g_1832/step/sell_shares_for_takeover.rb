# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1832
      module Step
        class SellSharesForTakeover < Engine::Step::Base
          ACTIONS = %w[sell_shares].freeze

          def actions(entity)
            return [] unless (pending = @round.pending_takeover)
            return [] unless entity == pending[:buyer].owner
            return [] if pending[:buyer].cash + entity.cash >= @game.takeover_cost(pending[:target])

            ACTIONS
          end

          def description
            'Sell Shares to Fund Takeover'
          end

          def active_entities
            pending = @round.pending_takeover
            return [] unless pending

            [pending[:buyer].owner]
          end

          # Called by Game::Base#sellable_bundles to filter bundles for this step.
          def can_sell?(entity, bundle)
            return false unless (pending = @round.pending_takeover)
            return false unless entity == pending[:buyer].owner

            entity == bundle.owner && @game.share_pool.fit_in_bank?(bundle)
          end

          def process_sell_shares(action)
            @game.sell_shares_and_change_price(action.bundle)

            pending = @round.pending_takeover
            buyer = pending[:buyer]
            return unless buyer.cash + buyer.owner.cash >= @game.takeover_cost(pending[:target])

            @game.perform_takeover(buyer, pending[:target])
            @round.post_merge_entity = buyer
            @round.pending_takeover = nil
            pass!
          end

          def show_other_players
            true
          end
        end
      end
    end
  end
end
