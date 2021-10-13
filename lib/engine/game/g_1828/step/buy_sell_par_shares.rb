# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'
require_relative 'exchange'

module Engine
  module Game
    module G1828
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          PURCHASE_ACTIONS = Engine::Step::BuySellParShares::PURCHASE_ACTIONS + [Action::Choose, Action::FailedMerge]

          def actions(entity)
            actions = super
            return actions if entity != current_entity

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
            return unless (company = entity.companies.find { |c| c.id == 'M&H' })

            step = @round.steps.find { |r| r.is_a?(Engine::Game::G1828::Step::Exchange) }
            step&.can_exchange?(company)
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

            track_action(action, corporation)
          end

          def process_failed_merge(action)
            @log << "#{action.entity.name} failed to merge #{action.corporations.map(&:name).join(' and ')}"
            @round.current_actions << action
          end

          def can_buy_multiple?(entity, corporation, _owner)
            super && corporation.owner == entity && num_shares_bought(corporation) < 2
          end

          def num_shares_bought(corporation)
            @round.current_actions.count { |x| x.is_a?(Action::BuyShares) && x.bundle.corporation == corporation }
          end

          def can_merge_any?(entity)
            @game.corporations.any? do |corporation|
              next if corporation.system?

              @game.corporations.any? { |candidate| @game.merge_candidate?(entity, corporation, candidate) }
            end
          end

          def can_merge?(entity, corporation)
            !@game.merge_candidates(entity, corporation).empty?
          end

          def can_gain?(entity, bundle, exchange: false)
            return false unless bundle.buyable
            return true if exchange

            super
          end

          def get_par_prices(entity, _corp)
            @game.par_prices.select { |p| p.price * 2 <= entity.cash }
          end
        end
      end
    end
  end
end
