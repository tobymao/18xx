# frozen_string_literal: true

require_relative '../buy_sell_par_shares'

module Engine
  module Step
    module G1828
      class BuySellParShares < BuySellParShares
        PURCHASE_ACTIONS = Engine::Step::BuySellParShares::PURCHASE_ACTIONS + [Action::StartMerge]

        def actions(entity)
          actions = super
          return actions if entity != current_entity || must_sell?(entity)

          unless bought?
            actions << 'start_merge' if can_merge_any?(entity)
            actions << 'pass' if actions.any? && !actions.include?('pass')
          end

          actions
        end

        def process_start_merge(action)
          @game.game_error('No eligible corporation to merge with') unless can_merge?(action.entity, action.corporation)
          @round.merge_initiator = action.corporation
          @round.acting_player = action.entity

          @round.last_to_act = action.entity
          @current_actions << action
        end

        def can_buy_multiple?(entity, corporation)
          super && corporation.owner == entity && num_shares_bought(corporation) < 2
        end

        def num_shares_bought(corporation)
          @current_actions.count { |x| x.is_a?(Action::BuyShares) && x.bundle.corporation == corporation }
        end

        def can_merge_any?(entity)
          @game.corporations.any? { |corporation| can_merge?(entity, corporation) }
        end

        def can_merge?(entity, corporation)
          @game.merge_candidates(entity, corporation).any?
        end
      end
    end
  end
end
