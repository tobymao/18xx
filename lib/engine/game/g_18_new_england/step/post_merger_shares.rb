# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/share_buying'

module Engine
  module Game
    module G18NewEngland
      module Step
        class PostMergerShares < Engine::Step::Base
          include Engine::Step::ShareBuying

          def actions(entity)
            return [] if !entity.player? || !@round.converted

            actions = []
            actions << 'buy_shares' if can_buy_any?(entity)
            actions << 'pass' if actions.any?
            actions
          end

          def process_buy_shares(action)
            player = action.entity
            bundle = action.bundle

            buy_shares(player, bundle)
            player.pass! unless can_buy_any?(player)
          end

          # Overrides method in share_buying
          def buy_shares(entity, shares, exchange: nil, swap: nil, allow_president_change: true, borrow_from: nil)
            corp = shares.corporation
            @game.share_pool.buy_shares(entity,
                                        shares,
                                        exchange: exchange,
                                        swap: swap,
                                        allow_president_change: allow_president_change)
            # bank compensates company always at original par price
            price = corp.original_par_price.price
            @game.bank.spend(price, corp)
          end

          def process_pass(action)
            log_pass(action.entity)
            action.entity.pass!
            # Don't make the current player pass again
            @round.share_dealing_players.delete(action.entity) if active_entities&.first == action.entity
          end

          def can_buy_any?(entity)
            can_buy?(entity, corporation.ipo_shares[0])
          end

          def can_buy?(entity, bundle)
            return unless bundle

            corporation == bundle.corporation &&
              bundle.percent == 10 &&
              bundle.owner != @game.share_pool &&
              entity.cash >= bundle.price &&
              can_gain?(entity, bundle)
          end

          def can_sell?(_entity, _bundle)
            false
          end

          def description
            return 'Failed merge, please undo' if @broken_merge

            'Buy Shares Post Merge'
          end

          def corporation
            @round.converted
          end

          def active?
            corporation
          end

          def eligible_players
            @round.share_dealing_players.select { |p| p.active? && can_buy_any?(p) }
          end

          def active_entities
            return [] unless corporation

            players = eligible_players
            players = eligible_players if players.empty?
            [players.first].compact
          end
        end
      end
    end
  end
end
