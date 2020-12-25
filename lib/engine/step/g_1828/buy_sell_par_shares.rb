# frozen_string_literal: true

require_relative '../buy_sell_par_shares'

module Engine
  module Step
    module G1828
      class BuySellParShares < BuySellParShares
        PURCHASE_ACTIONS = Engine::Step::BuySellParShares::PURCHASE_ACTIONS + [Action::StartMerge]

        def actions(entity)
          return [] unless entity == current_entity
          return ['sell_shares'] if must_sell?(entity)

          actions = super
          if @current_actions.empty?
            actions << 'start_merge' if can_merge_any?(entity)
            actions << 'pass' if actions.any? && !actions.include?('pass')
          end

          actions
        end

        def process_start_merge(action)
          @game.game_error('No eligible corporation to merge with') unless can_merge?(action.entity, action.corporation)
          @round.merging_corporation = action.corporation
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
          return false if corporation.owner != entity
          return false if corporation.system?

          corporations = @game.corporations.select do |candidate|
            next if candidate == corporation ||
                    candidate.system? ||
                    !candidate.ipoed ||
                    (corporation.owner != entity && candidate.owner != entity) ||
                    candidate.operated? != corporation.operated? ||
                    (!candidate.floated? && !corporation.floated?)

            # account for another player having 5+ shares
            @game.players.any? do |player|
              num_shares = player.num_shares_of(candidate) + player.num_shares_of(corporation)
              num_shares >= 6 ||
                (num_shares == 5 && !did_sell?(player, candidate) && !did_sell?(player, corporation))
            end
          end
          corporations.any?
        end
      end
    end
  end
end
