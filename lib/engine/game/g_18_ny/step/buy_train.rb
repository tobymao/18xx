# frozen_string_literal: true

require_relative '../../../step/buy_train'
require_relative '../../../step/automatic_loan'

module Engine
  module Game
    module G18NY
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            actions = super
            return actions unless entity.corporation?

            actions << 'buy_train' if !actions.include?('buy_train') && must_buy_train?(entity)
            actions << 'scrap_train' unless scrappable_trains(entity).empty?
            actions << 'take_loan' if ebuy_president_can_contribute?(entity) && @game.can_take_loan?(entity)
            actions << 'pass' if !actions.empty? && !actions.include?('pass') && !must_buy_train?(entity)
            actions
          end

          def buying_power(entity)
            super + scrappable_trains(entity).sum { |train| @game.salvage_value(train) }
          end

          def ebuy_president_can_contribute?(corporation)
            president_may_contribute?(corporation)
          end

          def president_may_contribute?(entity, _shell = nil)
            super && !@train_salvaged
          end

          def scrappable_trains(entity)
            entity.trains
          end

          def scrap_info(_train)
            ''
          end

          def scrap_button_text(_train)
            'Salvage'
          end

          def issuable_shares(entity)
            # Issue is part of emergency buy
            return [] unless ebuy_president_can_contribute?(entity)

            super.select { |bundle| selling_minimum_shares?(bundle) }
          end

          def spend_minmax(entity, train)
            # Must buy/sell at list price if either corporation has loans
            if !entity.loans.empty? || (train.owner&.corporation? && !train.owner.loans.empty?)
              [train.price, train.price]
            else
              super
            end
          end

          def process_take_loan(action)
            @game.take_loan(action.entity)
          end

          def process_scrap_train(action)
            raise GameError, 'Can only scrap trains owned by the corporation' if action.entity != action.train.owner

            @train_salvaged = true
            @game.salvage_train(action.train)
          end
        end
      end
    end
  end
end
