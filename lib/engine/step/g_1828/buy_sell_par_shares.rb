# frozen_string_literal: true

require_relative '../buy_sell_par_shares'

module Engine
  module Step
    module G1828
      class BuySellParShares < BuySellParShares
        PURCHASE_ACTIONS = Engine::Step::BuySellParShares::PURCHASE_ACTIONS + [Action::Choose]

        def actions(entity)
          actions = super
          return actions if entity != current_entity || must_sell?(entity)

          unless bought?
            actions << 'choose' if can_merge_any?(entity)
            actions << 'pass' if actions.any? && !actions.include?('pass')
          end

          actions
        end

        def choice_available?(_entity)
          false
        end

        def process_choose(action)
          corporation = @game.corporation_by_id(action.choice)
          @game.game_error('No eligible corporation to merge with') unless can_merge?(action.entity, corporation)

          # Set the round variables needed to activate the merge step
          @round.acting_player = action.entity
          @round.merge_initiator = corporation

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
