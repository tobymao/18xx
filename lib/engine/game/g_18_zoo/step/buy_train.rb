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
            old_train = action.train.owned_by_corporation?

            super

            if !@round.any_train_brought && !old_train
              prev = entity.share_price.price
              @game.stock_market.move_right(entity)
              @game.log_share_price(entity, prev, '(new-train bonus)')
              @round.any_train_brought = true
            end

            return unless @game.first_train_of_new_phase

            prev = entity.share_price.price
            @game.stock_market.move_right(entity)
            @game.log_share_price(entity, prev, '(new-phase bonus)')
            @game.first_train_of_new_phase = false
          end

          private

          def try_take_player_loan(entity, cost)
            @round.president_helped = true

            return unless cost.positive?
            return unless cost > entity.cash

            if sellable_shares?(entity)
              raise GameError, "#{entity.name} still need to sell shares before a loan can be granted"
            end

            difference = (cost - entity.cash)
            @game.take_player_loan(entity, difference)
            @log << "#{entity.name} takes a debt of #{@game.format_currency(difference)}"
          end

          def sellable_shares?(player)
            (@game.liquidity(player, emergency: true) - player.cash).positive?
          end
        end
      end
    end
  end
end
