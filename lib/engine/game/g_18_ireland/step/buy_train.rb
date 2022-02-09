# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18Ireland
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def setup
            super
            @exchanged = false
          end

          def buy_train_action(action, entity = nil)
            super
            @exchanged = true if action.exchange
          end

          def discountable_trains_allowed?(_entity)
            !@exchanged && %w[D 10].include?(@game.phase.name)
          end

          def can_ebuy_sell_shares?(entity)
            # once in ebuy then can continue to sell shares (as per other rules)
            return true if @last_share_sold_price

            # if ebuy hasn't really been entered then if the
            # corp can afford the cheapest they can't sell shares
            return false if (entity.cash) >= @depot.min_depot_price

            super
          end

          def can_sell?(entity, bundle)
            return false unless can_ebuy_sell_shares?(current_entity)

            super
          end

          def buyable_trains(entity)
            # Can't EMR if anything is affordable
            buyable = super
            affordable = buyable.select { |t| !t.from_depot? || t.price <= buying_power(entity) }
            if affordable.any?
              affordable
            else
              buyable
            end
          end

          def spend_minmax(entity, train)
            # @todo: I think the lack of the from_depot check is a bug in many games
            # but needs more detailed analysis
            if (train.from_depot? || @game.class::EBUY_OTHER_VALUE) && (buying_power(entity) < train.price)
              min = if @last_share_sold_price
                      (buying_power(entity) + entity.owner.cash) - @last_share_sold_price + 1
                    else
                      1
                    end
              max = [train.price, buying_power(entity) + entity.owner.cash].min
              [min, max]
            else
              [1, buying_power(entity)]
            end
          end
        end
      end
    end
  end
end
