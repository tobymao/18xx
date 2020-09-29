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

        def can_issue?(entity)
          return false if @round.emergency_issued
          return false unless entity.corporation?
          return false unless issuable_shares(entity).any?

          true
        end

        def process_issue_shares(action)
          corporation = action.entity
          bundle = action.bundle

          issuable = issuable_shares(corporation)
          bundle_index = issuable.index(bundle)

          if !can_issue?(corporation) || !bundle_index
            @game.game_error("#{corporation.name} cannot issue share bundle: #{bundle.shares}")
          end

          @last_share_issued_price = if bundle_index.zero?
                                       bundle.price
                                     else
                                       bundle.price - issuable[bundle_index - 1].price
                                     end

          @game.share_pool.sell_shares(bundle)

          price = corporation.share_price.price
          bundle.num_shares.times { @game.stock_market.move_left(corporation) }
          @game.log_share_price(corporation, price)

          @round.emergency_issued = true
        end

        def buyable_trains(entity)
          trains = super

          trains.select!(&:from_depot?) if @last_share_issued_price

          trains.reject! { |t| t.owner.trains.one? } if @game.two_player? && @depot.empty?

          trains
        end

        def buyable_train_variants(train, entity)
          variants = super

          return variants if (variants.size < 2) || train.owned_by_corporation?

          min, max = variants.sort_by { |v| v[:price] }
          return [min] if ((min[:price] <= entity.cash) && (entity.cash < max[:price])) || entity.receivership?

          if (last_cash_raised = @last_share_sold_price || @last_share_issued_price)
            must_spend = entity.cash - last_cash_raised + 1
            must_spend += entity.owner.cash if @last_share_sold_price
            variants.reject! { |v| v[:price] < must_spend }
          end

          variants
        end
      end
    end
  end
end
