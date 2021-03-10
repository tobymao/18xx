# frozen_string_literal: true

require_relative 'choose_ability_on_or'

module Engine
  module Game
    module G18ZOO
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          include Engine::Game::G18ZOO::ChooseAbilityOnOr

          def setup
            super

            @round.any_train_brought = false
            @round.new_train_brought = false
          end

          def round_state
            super.merge(
              {
                any_train_brought: false,
                new_train_brought: false,
              }
            )
          end

          def actions(entity)
            return ['choose_ability'] if entity.company? && can_choose_ability?(entity)

            super
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

            return unless @round.new_train_brought

            prev = entity.share_price.price
            @game.stock_market.move_right(entity)
            @game.log_share_price(entity, prev, '(new-phase bonus)')
            @round.new_train_brought = false
          end

          private

          def can_choose_ability?(company)
            entity = @game.current_entity
            return false if entity.player?

            # p "Dividend.can_choose_ability?(#{company.name})" # TODO: use for debug
            return true if can_choose_ability_on_any_step(entity, company)

            false
          end
        end
      end
    end
  end
end
