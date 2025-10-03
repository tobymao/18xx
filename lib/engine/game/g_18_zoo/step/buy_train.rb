# frozen_string_literal: true

require_relative 'choose_ability_on_or'

module Engine
  module Game
    module G18ZOO
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          include Engine::Game::G18ZOO::ChooseAbilityOnOr

          def actions(entity)
            actions = super

            return ['pass'] if @game.train_by_id('1S-0').owner == entity && actions.include?('buy_train')

            actions
          end

          def setup
            super

            @round.any_train_brought = false
            @round.president_helped = false
          end

          def round_state
            super.merge({ any_train_brought: false, president_helped: false })
          end

          def can_buy_train?(entity = nil, _shell = nil)
            return false if @round.president_helped

            entity ||= current_entity

            can_buy_normal = room?(entity) &&
              @game.buying_power(entity, use_tickets: true) >= @depot.min_price(entity)

            can_buy_normal || (discountable_trains_allowed?(entity) && @game
             .discountable_trains_for(entity)
             .any? { |_, _, _, price| @game.buying_power(entity, use_tickets: true) >= price })
          end

          def process_buy_train(action)
            entity ||= action.entity
            is_discarded = @game.depot.discarded.include?(action.train)
            old_train = action.train.owned_by_corporation?

            super

            return if is_discarded

            if !@round.any_train_brought && !old_train
              old_price = entity.share_price
              @game.stock_market.move_right(entity)
              @game.log_share_price(entity, old_price, '(new-train bonus)')
              @round.any_train_brought = true
            end

            return unless @game.first_train_of_new_phase

            old_price = entity.share_price
            @game.stock_market.move_right(entity)
            @game.log_share_price(entity, old_price, '(new-phase bonus)')
            @game.first_train_of_new_phase = false
          end

          def process_sell_shares(action)
            super

            @corporations_sold = [] # do not care about MUST_SELL_IN_BLOCKS when in emergency
          end

          # player cash cannot be used to buy from other corporation
          def spend_minmax(entity, train)
            if train.from_depot? && (buying_power(entity) < train.price)
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

          private

          def try_take_player_loan(entity, cost)
            @round.president_helped = true

            super
          end

          def sellable_shares?(player)
            (@game.liquidity(player, emergency: true) - player.cash).positive?
          end
        end
      end
    end
  end
end
