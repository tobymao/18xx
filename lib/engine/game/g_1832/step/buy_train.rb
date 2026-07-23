# frozen_string_literal: true

require_relative '../../g_1870/step/buy_train'

module Engine
  module Game
    module G1832
      module Step
        class BuyTrain < G1870::Step::BuyTrain
          def actions(entity)
            return super unless @game.system?(entity)
            return super if must_buy_train?(entity)

            return %w[buy_train pass] if system_voluntary_buy?(entity) && can_buy_train?(entity)

            super
          end

          def can_buy_train?(entity = nil, shell = nil)
            entity ||= current_entity
            return super unless @game.system?(entity)
            return super unless system_voluntary_buy?(entity)

            room?(entity) && (entity.cash + entity.owner.cash) >= @depot.min_price(entity)
          end

          # §11.6.7: System forced to buy only when trainless; president may contribute
          # cash (not sell shares) on any voluntary purchase when system has ≤ half its limit.
          def president_may_contribute?(entity, shell = nil)
            return super unless @game.system?(entity)

            must_buy_train?(entity) || system_voluntary_buy?(entity)
          end

          # Redeemed shares (buyable: false) may not be sold to raise emergency train funds (§10.6).
          def can_sell?(entity, bundle)
            super && bundle.shares.all?(&:buyable)
          end

          private

          def system_voluntary_buy?(system)
            system.trains.count * 2 <= @game.train_limit(system)
          end
        end
      end
    end
  end
end
