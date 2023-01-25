# frozen_string_literal: true

require_relative '../../g_1817/step/buy_sell_par_shares'

module Engine
  module Game
    module G1877
      module Step
        class BuySellParShares < G1817::Step::BuySellParShares
          def corporate_actions(entity)
            return [] if @winning_bid

            return [] if @corporate_action && @corporate_action.entity != entity

            actions = []
            if @round.current_actions.none?
              actions << 'take_loan' if @game.can_take_loan?(entity) && !@corporate_action.is_a?(Action::BuyShares)
              actions << 'buy_shares' unless @game.redeemable_shares(entity).empty?
              actions << 'buy_train' if can_buy_train?(entity)
            end
            actions
          end

          def room?(entity, _shell = nil)
            entity.trains.size < @game.train_limit(entity)
          end

          def can_buy_train?(entity)
            return false unless entity.corporation?
            return false if entity.operated?
            return false unless entity.owned_by?(current_entity)

            room?(entity) && entity.cash >= @depot.min_price(entity)
          end

          def buyable_train_variants(train, entity)
            train.variants.values.select { |v| v[:price] <= entity.cash }
          end

          def buyable_trains(corporation)
            @depot.depot_trains.select { |train| train.price <= corporation.cash }
          end

          def must_buy_train?(_entity)
            false
          end

          def should_buy_train?(entity); end

          def issuable_shares(_entity)
            []
          end

          def president_may_contribute?(_entity, _shell = nil)
            false
          end

          def win_bid(winner, _company)
            @winning_bid = winner
            entity = @winning_bid.entity
            corporation = @winning_bid.corporation
            price = @winning_bid.price

            @log << "#{entity.name} wins bid on #{corporation.name} for #{@game.format_currency(price)}"

            share_price = @game.find_share_price(price / 2)

            action = Action::Par.new(entity, corporation: corporation, share_price: share_price)
            process_par(action)
            remainder = price - (share_price.price * 2)
            entity.spend(remainder, @game.bank) if remainder.positive?

            @corporation_size = nil
            size_corporation(@game.phase.corporation_sizes[0])

            par_corporation if available_subsidiaries(winner.entity).none?
          end

          def size_corporation(size)
            @corporation_size = size
            @game.size_corporation(@winning_bid.corporation, @corporation_size)
          end

          def par_corporation
            winner = @winning_bid.entity
            super

            unpass!
            winner.unpass!
            setup
            @round.pass_order.delete(winner)
            @round.goto_entity!(winner)
          end

          def can_short?(entity, corporation)
            shorts = @game.shorts(corporation).size

            corporation.floated? &&
              shorts < corporation.total_shares &&
              entity.num_shares_of(corporation) <= 0 &&
              !(corporation.share_price.acquisition? || corporation.share_price.liquidation?) &&
              !@round.players_sold[entity].value?(:short)
          end

          def process_buy_train(action)
            if @corporate_action && action.entity != @corporate_action.entity
              raise GameError, 'Cannot act as multiple corporations'
            end

            @corporate_action = action

            entity ||= action.entity
            track_action(action, entity, false)
            train = action.train
            price = action.price

            raise GameError, 'Not a buyable train' unless buyable_train_variants(train,
                                                                                 entity).include?(train.variant)
            raise GameError, 'Must pay face value' if price != train.price

            @game.queue_log! { @game.phase.buying_train!(entity, train, train.owner) }

            source = @depot.discarded.include?(train) ? 'The Discard' : train.owner.name

            @log << "#{entity.name} buys a #{train.name} train for "\
                    "#{@game.format_currency(price)} from #{source}"

            @game.flush_log!

            @game.buy_train(entity, train, price)
          end

          def setup
            super

            @depot = @game.depot
          end
        end
      end
    end
  end
end
