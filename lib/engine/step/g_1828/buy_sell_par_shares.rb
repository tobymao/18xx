# frozen_string_literal: true

require_relative '../buy_sell_par_shares'

module Engine
  module Step
    module G1828
      class BuySellParShares < BuySellParShares
        PURCHASE_ACTIONS = Engine::Step::BuySellParShares::PURCHASE_ACTIONS + [Action::FailedMerge]

        def actions(entity)
          actions = super
          return actions if entity != current_entity || must_sell?(entity)

          unless bought?
            if can_merge_any?(entity)
              actions << 'choose'
              actions << 'failed_merge'
            end
            actions << 'buy_shares' if player_can_exchange?(entity)
            actions << 'pass' if !actions.empty? && !actions.include?('pass')
          end

          actions
        end

        def player_can_exchange?(entity)
          return false unless entity.player?

          company = entity.companies.find { |c| c.id == 'M&H' }
          step = @round.steps.find { |r| r.is_a?(Engine::Step::G1828::Exchange) }
          company && step&.can_exchange?(company)
        end

        def choice_available?(_entity)
          false
        end

        def merge_failed?
          false
        end

        def process_choose(action)
          corporation = @game.corporation_by_id(action.choice)
          raise GameError, 'No eligible corporation to merge with' unless can_merge?(action.entity, corporation)

          # Set the round variables needed to activate the merge step
          @round.acting_player = action.entity
          @round.merge_initiator = corporation

          @round.last_to_act = action.entity
          @current_actions << action
        end

        def process_failed_merge(action)
          @log << "#{action.entity.name} failed to merge #{action.corporations.map(&:name).join(' and ')}"
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

        def stock_action(action)
          @current_actions << action
        end
      end
    end
  end
end
