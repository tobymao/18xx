# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G18Neb
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def actions(entity)
            return corporate_actions(entity) if entity.corporation? && entity.owned_by?(current_entity)

            actions = super
            actions << 'pass' if entity.player? && actions.empty? && players_corporations_have_actions?(entity)
            actions
          end

          def corporate_actions(entity)
            return [] unless @round.current_actions.empty?

            actions = []
            actions << 'sell_shares' unless issuable_shares(entity).empty?
            actions << 'buy_shares' unless redeemable_shares(entity).empty?
            actions
          end

          def players_corporations_have_actions?(player)
            @game.corporations.any? { |c| c.owner == player && !corporate_actions(c).empty? }
          end

          def visible_corporations
            @game.sorted_corporations.reject { |c| c.closed? || (c.type == :minor && c.ipoed) }
          end

          def issuable_shares(entity)
            return [] unless @round.current_actions.empty?
            return [] unless @game.check_sale_timing(entity, Share.new(entity).to_bundle)

            @game.issuable_shares(entity)
          end

          def redeemable_shares(entity)
            return [] unless @round.current_actions.empty?
            return [] if did_sell?(entity, entity)

            @game.redeemable_shares(entity).select { |bundle| can_buy?(entity, bundle) }
          end

          def process_buy_shares(action)
            corp = action.bundle.corporation
            super
            @game.check_for_full_capitalization(corp)
            pass! if action.entity.corporation?
          end

          def process_sell_shares(action)
            super
            pass! if action.entity.corporation?
          end

          def log_skip(entity)
            return unless @round.current_actions.empty?

            super
          end
        end
      end
    end
  end
end
