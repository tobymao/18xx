# frozen_string_literal: true

require_relative '../buy_train'

module Engine
  module Step
    module G1846
      class BuyTrain < BuyTrain
        def actions(entity)
          return [] if entity.receivership?

          if entity == current_entity.owner
            return can_issue?(current_entity) ? [] : %w[sell_shares]
          end

          return [] unless entity.corporation?

          if must_buy_train?(entity)
            actions_ = %w[buy_train]
            actions_ << 'sell_shares' if can_issue?(entity)
            actions_
          elsif can_buy_train?(entity)
            %w[buy_train pass]
          else
            []
          end
        end

        def skip!
          @round.receivership_train_buy(self, :process_buy_train)
        end

        def issuable_shares(entity)
          return [] unless entity.corporation?

          @game.emergency_issuable_bundles(entity)
        end

        def process_sell_shares(action)
          return process_issue_shares(action) if action.entity.corporation?

          if can_issue?(@round.current_entity)
            @game.game_error('President may not sell shares while corporation can issues shares.')
          end

          super
        end

        private

        def can_issue?(entity)
          return false if @round.emergency_issued
          return false unless entity.corporation?
          return false unless issuable_shares(entity).any?

          true
        end

        def process_issue_shares(action)
          corporation = action.entity
          bundle = action.bundle

          if !can_issue?(corporation) || !issuable_shares(corporation).include?(bundle)
            @game.game_error("#{corporation.name} cannot issue share bundle: #{bundle.shares}")
          end

          @game.share_pool.sell_shares(bundle)

          price = corporation.share_price.price
          bundle.num_shares.times { @game.stock_market.move_left(corporation) }
          @game.log_share_price(corporation, price)

          @round.emergency_issued = true
        end

        def buyable_train_variants(train, entity)
          variants = super

          return variants if (variants.size < 2) || train.owned_by_corporation?

          cash = entity.cash
          min, max = variants.sort_by { |v| v[:price] }
          return [min] if (min[:price] <= cash) && (cash < max[:price])

          variants
        end
      end
    end
  end
end
