# frozen_string_literal: true

require_relative 'base'
require_relative 'share_buying'
require_relative '../action/corporate_buy_shares'

module Engine
  module Step
    class CorporateBuyShares < Base
      include ShareBuying

      PURCHASE_ACTIONS = [Action::CorporateBuyShares].freeze

      def description
        'Corporate Share Buying'
      end

      def setup
        @bought = []
      end

      def actions(entity)
        return [] unless entity == current_entity

        actions = []
        actions << 'corporate_buy_shares' if can_buy_any?(entity)

        actions << 'pass' if actions.any?

        actions
      end

      def log_pass(entity)
        @log << "#{entity.name} passes buying shares"
      end

      def log_skip(entity)
        @log << "#{entity.name} skips corporate share buy"
      end

      def can_buy_any?(entity)
        can_buy_any_from_market?(entity) || can_buy_any_from_president?(entity)
      end

      def can_buy_any_from_market?(entity)
        @game.share_pool.shares.any? { |s| can_buy?(entity, s.to_bundle) }
      end

      def can_buy_any_from_president?(entity)
        return unless @game.class::CORPORATE_BUY_SHARE_ALLOW_BUY_FROM_PRESIDENT

        entity.owner.shares.any? { |s| can_buy?(entity, s.to_bundle) }
      end

      def can_buy?(entity, bundle)
        return unless bundle
        return unless bundle.buyable
        return if bundle.presidents_share
        return if entity == bundle.corporation

        if @game.class::CORPORATE_BUY_SHARE_SINGLE_CORP_ONLY && bought?
          return unless bundle.corporation == @bought.last
        end

        entity.cash >= bundle.price
      end

      def process_corporate_buy_shares(action)
        buy_shares(action.entity, action.bundle)
        @bought << action.bundle.corporation
        pass! unless can_buy_any?(action.entity)
      end

      def source_list(entity)
        if @game.class::CORPORATE_BUY_SHARE_SINGLE_CORP_ONLY && bought?
          source = @game.sorted_corporations
            .select { |corp| (corp == @bought.last && !corp.num_market_shares.zero?) }
        else
          source = @game.sorted_corporations
            .select { |corp| corp != entity && corp.floated? && !corp.closed? && !corp.num_market_shares.zero? }
        end

        if @game.class::CORPORATE_BUY_SHARE_ALLOW_BUY_FROM_PRESIDENT && can_buy_any_from_president?(entity)
          source << entity.owner
        end

        source
      end

      def bought?
        @bought.any?
      end
    end
  end
end
