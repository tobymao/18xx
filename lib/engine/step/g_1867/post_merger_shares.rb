# frozen_string_literal: true

require_relative '../base'
require_relative '../share_buying'

module Engine
  module Step
    module G1867
      class PostMergerShares < Base
        include ShareBuying

        def actions(entity)
          # @todo: this needs to catch the failed merge case
          return [] if !entity.player? || !@round.converted

          actions = []
          actions << 'buy_shares' if can_buy_any?(entity)
          actions << 'pass' if actions.any?
          actions
        end

        def process_buy_shares(action)
          player = action.entity

          # @todo: this needs to catch the 10% -> 20% presidency case
          buy_shares(player, action.bundle)

          player.pass! if !@round.share_dealing_multiple.include?(player) || !can_buy_any?(player)

          # @todo: need to cover rule 9.2 D
        end

        def process_pass(action)
          log_pass(action.entity)
          action.entity.pass!
        end

        def can_buy_any?(entity)
          can_buy?(entity, corporation.shares[0])
        end

        def can_buy?(entity, bundle)
          return unless bundle

          corporation == bundle.corporation &&
            bundle.owner != @game.share_pool &&
            entity.cash >= bundle.price &&
            can_gain?(entity, bundle)
        end

        def can_sell?(_entity, _bundle)
          false
        end

        def description
          'Buy Shares Post Conversion'
        end

        def corporation
          @round.converted
        end

        def active?
          corporation
        end

        def active_entities
          return [] unless corporation

          [@round.share_dealing_players
          .select { |p| p.active? && can_buy_any?(p) }.first].compact
        end
      end
    end
  end
end
