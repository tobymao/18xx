# frozen_string_literal: true

require_relative '../base'
require_relative '../share_buying'

module Engine
  module Step
    module G1867
      class PostMergerShares < Base
        include ShareBuying

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
          target = bundle.corporation

          # 20% still remains, they buy that instead.
          if target.shares.first.president && player.percent_of(target) == 10
            # give the 10% back, so they don't exceed cert limit
            presidency = target.shares.first
            player.shares_of(target).first.transfer(presidency.owner)

            # Buy the share (so logging is correct), then give it back
            buy_shares(player, bundle)
            player.shares_of(target).first.transfer(presidency.owner)

            # grab the presidency
            @game.share_pool.buy_shares(player, presidency.to_bundle, exchange: :free)
          else
            buy_shares(player, bundle)
          end

          player.pass! if !@round.share_dealing_multiple.include?(player) || !can_buy_any?(player)

          check_merge
        end

        def check_merge
          return unless active_entities.none?

          if corporation.shares.first&.president
            @broken_merge = true
            # This could theoretically undo the merge cleanly,
            # but it's easier to let the players press the Undo button.
            @log << 'Merge failed as no player has 20%, please undo'
          elsif @round.merge_type == :merge && @round.share_dealing_multiple.any?
            # Rule 9.2 D - All players can buy 10% after involved players can buy up to 60%
            @round.share_dealing_players.each(&:unpass!)
            @round.share_dealing_players = @game.players.rotate(@game.players.index(corporation.owner))
            @round.share_dealing_multiple.clear
          end
        end

        def process_pass(action)
          log_pass(action.entity)
          action.entity.pass!
          check_merge
          # Don't make the current player pass again
          @round.share_dealing_players.delete(action.entity) if active_entities&.first == action.entity
        end

        def can_buy_any?(entity)
          # Can't buy the 20% share directly, so check the first two shares.
          can_buy?(entity, corporation.shares[0]) || can_buy?(entity, corporation.shares[1])
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

        def active_entities
          return [] unless corporation
          return @game.players if @broken_merge

          [@round.share_dealing_players
          .select { |p| p.active? && can_buy_any?(p) }.first].compact
        end
      end
    end
  end
end
