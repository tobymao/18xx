# frozen_string_literal: true

require_relative '../../../step/buy_train'
require_relative '../skip_coal_and_oil'
require_relative 'choose_big_boy'

module Engine
  module Game
    module G1868WY
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          include G1868WY::SkipCoalAndOil
          include ChooseBigBoy

          def actions(entity)
            super.concat(choice_actions(entity, cannot_pass: entity.corporation? && must_buy_train?(entity)))
          end

          def issue_text(_entity)
            'Issue'
          end

          def buyable_train_variants(train, entity)
            variants = super

            return variants if variants.size < 2

            min, max = variants.sort_by { |v| v[:price] }
            return [min] if (min[:price] <= entity.cash) && (entity.cash < max[:price])

            if (last_cash_raised = @last_share_sold_price)
              must_spend = entity.cash - last_cash_raised + 1
              must_spend += entity.owner.cash if @last_share_sold_price
              variants.reject! { |v| v[:price] < must_spend }
            end

            variants
          end

          def process_choose(action)
            process_choose_big_boy(action)
          end

          def process_buy_train(action)
            super
            action.train.remove_variants!
          end

          def room?(entity, _shell = nil)
            entity.trains.count { |t| !@game.extra_train?(t) } < @game.train_limit(entity)
          end
        end
      end
    end
  end
end
